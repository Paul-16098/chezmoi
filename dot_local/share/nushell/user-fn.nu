use std/log

const self = path self

# Edit this config.
export def "config user-fn" []: nothing -> nothing {
  run-external $env.config.buffer_editor ($self)
}

# whois wrapper to format output as a table
export def --wrapped whois [
  ...rest: string # a rest that to whois-cli
]: nothing -> table {
  log debug ("Executing whois with args: " + ($rest | str join " "))
  if ("-h" in $rest or "--help" in $rest) {
    log debug "Displaying help for whois"
    whois-cli --help
  } else {
    if ("-v" in $rest or "--verbose" in $rest) {
      log set-level 10
    }
    let po = (whois-cli --no-color ...$rest | complete)
    if $po.exit_code != 0 {
      error make {
        msg: $"whois command failed with exit code ($po.exit_code)"
        label: {
          span: (metadata $rest).span
          text: $po.stderr
        }
        help: "try whois-cli --help for more information"
      }
    }
    log debug "Processing whois output"
    let raw_o = $po.stdout
    log debug $"raw whois output=($raw_o)"
    if "No entries found for the selected source(s)." in $raw_o {
      return $"(ansi red)($raw_o)(ansi reset)"
    }
    let o = $raw_o | str replace --regex `(>>> ([.\s\S]*))` ""
    log debug $"new whois output=($o)"
    log debug "Parsing whois output into table"
    let o2 = $o
      | lines
      | where (str contains :)
      | par-each --keep-order { str trim }
    log debug $"parsed lines=($o2)"
    let o3 = $o2
      | parse "{k}: {v}"
    log debug $"parsed key-value pairs=($o3)"
    let o4 = $o3
      | group-by k
      | update cells { reject k }
      | update cells {|value|
        # log debug $"cell updated: ($value)"
        if (($value | length) == 1) {
          # log debug $"single cell found: ($value)"
          return ($value | get 0.v)
        } else {
          return ($value | par-each --keep-order { $in.v })
        }
      }
    mut scu = []
    for $it in ($o4 | get --optional --ignore-case "Domain Status") {
      let o = $it | split row " "
      $scu ++= [[["status codes" url]; [($o | get 0) ($o | get 1)]]]
    }
    $o4 | merge {"Domain Status": $scu}
  }
}

# get app path and remove app
export def rm-app [
  app_name: string # name of the app to remove
]: nothing -> nothing {
  let app_path = (which $app_name | get path)
  log debug $"App path for ($app_name): ($app_path)"
  if ($app_path | length) == 0 {
    log error $"App ($app_name) not found."
    return
  }
  $app_name | each { $in | path expand } | each {
    log debug $"Expanded app path: ($in)"
    if ($in | path exists) {
      rm --interactive $in
      log info $"Removed app at path: ($in)"
    } else {
      log warning $"Path does not exist: ($in)"
    }
  }
}

# es wrapper to always output json parsed table
@complete external
export def --wrapped es [...rest: string]: nothing -> table {
  let o = ^es ...$rest "-instance" 1.5a "--json"
  if ('-h' in $rest or "--help" in $rest) {
    $o
  } else {
    $o | from json
  }
}

# update rustup, pnpm,... and completions
export def app-update []: nothing -> nothing {
  job spawn --tag app-update-rustup {
    rustup self update o+e>| job send 0
  }
  job spawn --tag "app-update-rust-toolchains" {
    rustup update o+e>| job send 0
  }
  job spawn --tag app-update-pnpm {
    pnpm self-update o+e>| job send 0
  }
  job spawn --tag app-update-airshipper {
    airshipper upgrade o+e>| job send 0
    airshipper update o+e>| job send 0
  }
  job spawn --tag app-update-cargo-packages {
    cargo install-update --all o+e>| job send 0
  }
  job spawn --tag app-update-coreutils-completions {
    const COREUTILS_COMPLETIONS_PATH = ($nu.user-autoload-dirs.0 | path join completions-coreutils.nu)
    "" | save --force $COREUTILS_COMPLETIONS_PATH
    ^coreutils --list | decode utf-8 | lines | par-each --keep-order {
      if ($in == '[') { return }
      let dis = (^coreutils $in --help | str replace --regex r#'\n\nUsage[\s\S]*$'# '' | lines | each { '# ' + $in } | str join "\n")
      $"($dis)\nexport extern \"coreutils ($in)\" [\n  --help \(-h) # get help information\n  --version \(-V) # get version information\n]\n" | save --append $COREUTILS_COMPLETIONS_PATH
    }
  }

  job spawn --tag app-update-atuin {
    # atuin
    atuin init --disable-up-arrow --disable-ctrl-r nu | save --force ($nu.user-autoload-dirs.0 | path join atuin.nu)
  }
  job spawn --tag app-update-starship {
    # starship
    starship init nu | save --force ($nu.user-autoload-dirs.0 | path join starship.nu)
  }
  job spawn --tag app-update-carapace {
    # carapace
    mkdir $nu.cache-dir
    # carapace _carapace nushell | save --force $"($nu.cache-dir)/carapace.nu"
    carapace _carapace nushell | save --force ($nu.user-autoload-dirs.0 | path join carapace.nu)
  }
  job spawn --tag app-update-yazi {
    cargo install --git https://github.com/sxyazi/yazi.git yazi-build o+e>| job send 0
    ya pkg upgrade o+e>| job send 0
  }
  job spawn --tag app-update-nufmt {
    cargo install --git https://github.com/nushell/nufmt nufmt o+e>| job send 0
  }
  job spawn --tag app-update-nu {
    cargo install --locked --git https://github.com/nushell/nushell.git nu o+e>| job send 0
  }
  job spawn --tag app-update-nu-plugins {
    const NU_PLUGINS = [nu_plugin_formats nu_plugin_polars nu_plugin_query]
    $NU_PLUGINS | par-each {|plugin|
      job spawn --tag $"app-update-nu-plugin-($plugin)" {
        cargo install --locked $plugin o+e>| job send 0
        plugin add $"~/.cargo/bin/($plugin).exe"
      }
    }
  }
  sleep 1sec
  try {
    loop {
      if (job list | length) == 0 {
        break
      }
      print --raw (job recv --timeout 0sec)
    }
  } catch {|err|
    let err = $err.json | from json
    if (
      $err == {
        msg: "No message was received in the requested time interval"
        labels: []
        code: "nu::shell::job::recv_timeout"
        url: null
        help: "No message arrived within the specified time limit"
        inner: []
      }
    ) {
      print "All updates completed."
      print "\a"
    } else {
      error make $err
    }
  }
  null
}

# git log wrapper to format output as a table
#
# noreply email is filtered out
# merge commit messages are reformatted to include links
# commit messages are highlighted for common prefixes
# version tags are highlighted
# sorted by date newest at bottom
@complete external
@category git
export def --wrapped "git log" [...rest: string]: nothing -> table {
  let remote_url = git config get remote.origin.url
    | str replace "git@ssh.gitgud.io:" "https://gitgud.io/"
    | str replace --regex "\\.git$" ""

  ^git log --pretty=%h»¦«%s»¦«%aN»¦«%aE»¦«%aD ...$rest
  | lines
  | split column "»¦«" commit subject name email date
  | upsert date { $in | into datetime }
  | upsert email {|row|
    let email = $row.email
    if (["@users.noreply.github.com" "@noreply.codeberg.org"] | all {|suffix| not ($email | str ends-with $suffix) }) {
      $"mailto:($email)" | ansi link --text $email
    } else {
      $"(ansi dgri)noreply email(ansi reset)"
    }
  } | default $"(ansi dgri)N/A(ansi reset)" email
  | upsert subject {
    $in | str trim
    # Merge pull request #ID from ...
    | str replace --regex '(?i)Merge pull request #(?<id>\d+) from (?<from>.+)' {|id from|
      $"[PR (ansi gb)($"($remote_url)/pull/($id)" | ansi link --text $'#($id)')(ansi reset) from (ansi gb)($from)(ansi reset)]"
    }
    # Merge branch 'branch' of ...
    | str replace --regex "(?i)Merge branch '(?<branch>.+)' of (?<from>.+)" {|branch from|
      $"[Merge branch '(ansi gb)($"($remote_url)/tree/($branch)" | ansi link --text $branch)(ansi reset)' of (ansi gb)($from | str replace --regex "^ssh\\.gitgud\\.io:" 'https://gitgud.io/' | ansi link --text $from)(ansi reset)]"
    }
    # Merge branch 'branch' into 'from'
    # Merge branch 'branch' into from
    | str replace --regex "(?i)Merge branch '(?<branch>.+)' into '?(?<from>[^']+)'?$" {|branch from|
      $"[Merge branch '(ansi gb)($"($remote_url)/tree/($branch)" | ansi link --text $branch)(ansi reset)' into '(ansi gb)($"($remote_url)/tree/($from)" | ansi link --text $from)(ansi reset)']"
    }
    # Merge commit 'cc62c8f4f6cb164756e97efb3a001fd73976a053' into tw-dev
    | str replace --regex "(?i)Merge commit '(?<commit>.+)' into '?(?<branch>[^']+)'?$" {|commit branch|
      $"[Merge commit '(ansi gb)($"($remote_url)/commit/($commit)" | ansi link --text $commit)(ansi reset)' into '(ansi gb)($"($remote_url)/tree/($branch)" | ansi link --text $branch)(ansi reset)']"
    }
    # feat:, fix:, docs:, style:, refactor:, perf:, test:, chore:
    | str replace --all --regex "(?i)^(feat|fix|docs|style|refactor|perf|test|chore|imp|revert|bump)(\\(.*\\))?(:|：)" $"(ansi gb)$1(ansi reset)(ansi gb)$2(ansi reset):"
    # Vx.x.x
    | str replace --all --regex "(?i)^(v[\\d\\.]+(-beta\\d+)?)" $"(ansi b)$0(ansi reset)"
    | str replace --all --regex "#\\d+" $"(ansi gb)$0(ansi reset)"
  }
  | sort-by date --reverse
}
export alias gl = git log
# git pull wrapper to show updated commits
@complete external
@category git
export def --wrapped "git pull" [...rest: string]: nothing -> table {
  let old_commit = git rev-list HEAD -n 1
  ^git pull --quiet ...$rest
  let new_commit = git rev-list HEAD -n 1
  print --stderr $"Pulled latest changes. Showing commits from (ansi green)($old_commit)(ansi reset) to (ansi green)($new_commit)(ansi reset):"
  git log $"($old_commit)...($new_commit)"
}
export alias gp = git pull

export alias gc = git clone

def rust-debug-complete []: nothing -> record {
  {
    options: {
      case_sensitive: false
      sort: false
    }
    completions: [
      trace
      debug
      info
      warn
      error
      {
        value: off
        description: "Disable all logging"
      }
    ]
  }
}
# set rust debug env variables
export def --env rust-debug [lv: string@rust-debug-complete]: nothing -> nothing {
  load-env {
    RUST_LOG: $lv
    RUST_BACKTRACE: full
  }
}

def "nu-complete exe" []: nothing -> record {
  use complete-tools.nu complete-file
  complete-file exe
}

# check if input is a valid exe file
def is-exe [exe_file: path]: [
  nothing -> nothing
  nothing -> error
] {
  if not ($exe_file | str ends-with ".exe") {
    error make {
      msg: "Input file is not an .exe file"
      label: {
        text: "here"
        span: (metadata $exe_file).span
      }
      help: "please provide a valid .exe file"
    }
  }
  if not ($exe_file | path exists) {
    error make {
      msg: $"File not found: ($exe_file)"
      label: {
        text: "here"
        span: (metadata $exe_file).span
      }
      help: "please provide a valid .exe file path"
    }
  }
}

# get dll dependencies of an exe file
export def get-dll [
  exe_file: path@"nu-complete exe" # the exe file to analyze
]: nothing -> table<command: string, path?: path> {
  is-exe $exe_file
  let dll_dep = file $exe_file | get details.dependencies
  $dll_dep
  | par-each {|dll_name|
    let dll_find = which $dll_name --all;
    if ($dll_find | length) == 0 {
      let loc_dll_path = $exe_file | path dirname | path join $dll_name
      if ($loc_dll_path | path exists) {
        return {
          command: $dll_name
          path: $loc_dll_path
          type: $"(ansi d)local(ansi reset)"
        }
      }
      {
        command: (
          {
            scheme: https
            host: search.brave.com
            path: search
            params: {
              q: $dll_name
            }
          } | url join | ansi link --text $dll_name
        )
        type: "not found"
      }
    } else {
      $dll_find
      | upsert type {|table|
        if ($table | get path | str starts-with ($env.WINDIR | path expand)) {
          $"(ansi d)external(ansi reset):(ansi grey70)system(ansi reset)"
        } else {
          $"(ansi d)external(ansi reset):(ansi grey70)user(ansi reset)"
        }
      }
    }
  } | flatten
}

alias nu_ps = ps
# processes wrapper to filter by name
export def ps [
  name?: string # process name to filter
]: nothing -> table {
  if $name == null {
    nu_ps
  } else {
    nu_ps | where name =~ $name
  } | sort-by mem virtual cpu --reverse
}

# kill process by name
export def "kill with name" [
  name: string # process name to kill
  --force (-f) # force kill the process
]: nothing -> nothing {
  ps $name | kill ...$in.pid --force=$force
}

# my custom pause function
export def pause []: nothing -> nothing {
  print "Press any key to continue..."
  input listen --types [key]
  null
}
# install plugin via cargo binstall and add to plugins
export def "plugin install" [
  name: string # nu_plugin_XXX
]: nothing -> nothing {
  cargo binstall $name
  plugin add $"~/.cargo/bin/($name).exe"
}
# uninstall plugin via cargo uninstall and remove from plugins
export def "plugin uninstall" [
  name: string # just XXX not nu_plugin_XXX
]: nothing -> nothing {
  plugin rm $name
  cargo uninstall $"nu_plugin_($name)"
}

def "nu-complete steamcmd" []: nothing -> record {
  {
    options: {
      sort: false
    }
    completions: [
      {
        value: '"+login"'
        description: 'Login to Steam: login <username> [<password>] [<Steam guard code>]'
      }
      {
        value: '"+login anonymous"'
        description: 'you may login anonymously using "login anonymous" if the content you
wish to download is available for anonymous access.'
      }
      {
        value: '+runscript'
        description: 'Executing a sequence of commands via a script file'
      }
      {
        value: 'workshop_download_item'
        description: 'download an item using the workshop system: workshop_download_item <appid> <PublishedFileId>'
      }

      {
        value: '+help'
        description: 'Displays help information about SteamCMD commands.'
      }
    ]
  }
}
# steamcmd wrapper to login
export def "steamcmd" [
  ...args: string@"nu-complete steamcmd" # +COMMAND [ARG]...
]: nothing -> nothing {
  /steamcmd/steamcmd.exe ...$args
}

# https://yazi-rs.github.io/docs/quick-start#shell-wrapper
export def --wrapped --env y [...args: string]: nothing -> nothing {
  if ("YAZI_LEVEL" in $env) {
    error make {
      msg: "You are already running yazi."
      labels: [
        # {
        #   text: "YAZI_LEVEL is set here"
        #   span: (metadata $env.YAZI_LEVEL).span
        # }
        {
          text: "call by here"
          span: (metadata $args).span
        }
      ]
    }
  }
  let tmp = (mktemp --tmpdir "yazi-cwd.XXXXXX")
  yazi ...$args --cwd-file $tmp
  let cwd = (open $tmp)
  if $cwd != $env.PWD and ($cwd | path exists) {
    cd $cwd
  }
  rm --force --permanent $tmp
}
# https://www.chezmoi.io/user-guide/frequently-asked-questions/design/#why-does-chezmoi-cd-spawn-a-shell-instead-of-just-changing-directory
export def --env "chezmoi cd" [] {
  cd (chezmoi source-path | path expand)
}
# used in keybindings.nu for F5
export def reload-config []: nothing -> string {
  [
    'let _pwd = pwd'
    'source ($nu.env-path)'
    'source ($nu.config-path)'

    '# load vendor autoloads'
    (
      $nu.vendor-autoload-dirs | par-each --keep-order {|dir|
        if ($dir | path exists) {
          ls ($dir | path expand) | where ($it.type == "file") and ($it.name ends-with ".nu")
          | par-each --keep-order {|path| $"source ($path.name)" }
        }
      }
    )
    '# load user autoloads'
    (
      $nu.user-autoload-dirs | par-each --keep-order {|dir|
        if ($dir | path exists) {
          ls ($dir | path expand) | where ($it.type == "file") and ($it.name ends-with ".nu")
          | par-each --keep-order {|path| $"source ($path.name)" }
        }
      }
    )

    'cd $_pwd'
    'unlet $_pwd'
  ] | flatten | flatten | str join "\n"
}
def "nu-complete image" []: nothing -> record {
  use complete-tools.nu complete-mime
  complete-mime image/*
}

# copy image to clipboard using powershell
export def "clip copy-image" [
  ...paths: path@"nu-complete image" # paths of images to copy to clipboard
]: nothing -> nothing {
  if ($nu.os-info.name != windows) {
    error make 'only windows is supported for copying images to clipboard'
  }

  let base = "Add-Type -AssemblyName System.Windows.Forms;"

  $paths | each {|path|
    let path = $path | path expand
    if not ($path | path exists) {
      error make {
        msg: $"File not found: (ansi green)($path)(ansi reset)"
        label: {
          text: "here"
          span: (metadata $path).span
        }
        help: "please provide a valid image file path"
      }
    }
    if ($path | path type) != file {
      error make {
        msg: $"Path is not a file: (ansi green)($path)(ansi reset)"
        label: {
          text: "here"
          span: (metadata $path).span
        }
        help: "please provide a valid image file path"
      }
    }
    if not (ls $path --mime-type | get 0.type | str starts-with "image/") {
      error make {
        msg: $"File is not an image: (ansi green)($path)(ansi reset)"
        label: {
          text: "here"
          span: (metadata $path).span
        }
        help: "please provide a valid image file path"
      }
    }

    print --stderr $"Copying image to clipboard: (ansi green)($path)(ansi reset)"

    let app_comm = $"[Windows.Forms.Clipboard]::SetImage\($\([System.Drawing.Image]::Fromfile\('($path)')));"
    let comm = $base + $app_comm

    print --stderr $"> ($comm)"
    pwsh -Sta -Command $comm | complete | if ($in.exit_code != 0) {
      error make --unspanned {
        msg: $"Failed to copy image to clipboard: (ansi green)($path)(ansi reset)"
        inner: [{msg: $in.stderr}]
      }
    } else {
      print --stderr $"Successfully copied image to clipboard: (ansi green)($path)(ansi reset)"
    }
  }
  null
}

# get meme and copy to clipboard
export def "meme" [
  type: string@[fzf yazi nushell] = yazi # what tool to use to pick meme
]: nothing -> nothing {
  cd ~\OneDrive\文件\meme
  mut meme_path: list<string> = []
  match $type {
    yazi => {
      let chooser_file = mktemp --tmpdir "yazi-chooser_file.XXXXXX"
      yazi --chooser-file $chooser_file
      $meme_path = open $chooser_file | lines
      rm --force --permanent $chooser_file
    }
    fzf => {
      $meme_path = ^fzf --multi --ansi --preview '$env.TERM = "xterm-256color";viu --sixel -w $env.FZF_PREVIEW_COLUMNS -h $env.FZF_PREVIEW_LINES {}' | lines
    }

    nushell => {
      $meme_path = glob ./**/*.* | input list --multi
    }

    $_ => {
      error make {
        msg: $"Invalid meme type: (ansi green)($type)(ansi reset)"
        label: {
          text: "here"
          span: (metadata $type).span
        }
        help: "please provide a valid meme type"
      }
    }
  }

  clip copy-image ...$meme_path
}
