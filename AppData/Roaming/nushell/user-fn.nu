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
    rustup self update
  }
  job spawn --tag "app-update-rust-toolchains" {
    rustup update
  }
  job spawn --tag app-update-pnpm {
    pnpm self-update
  }
  job spawn --tag app-update-airshipper {
    airshipper upgrade
    airshipper update
  }
  job spawn --tag app-update-cargo-packages {
    cargo install-update --all
  }
  job spawn --tag app-update-coreutils-completions {
    "" | save --force ($nu.data-dir | path join completions/coreutils.nu)
    ^coreutils --list | decode utf-8 | lines | par-each --keep-order {
      if ($in == '[') { return }
      let dis = (^coreutils $in --help | str replace --regex r#'\n\nUsage[\s\S]*$'# '' | lines | each { '# ' + $in } | str join "\n")
      $"($dis)\nexport extern \"coreutils ($in)\" [\n  --help \(-h) # get help information\n  --version \(-V) # get version information\n]\n" | save --append ($nu.data-dir | path join completions/coreutils.nu)
    }
  }
  job spawn --tag app-update-all-completions {
    # all-completions
    const ALL_COMPLETIONS_PATH = ($nu.data-dir | path join vendor/autoload/all-completions.nu)
    "" | save --force $ALL_COMPLETIONS_PATH
    ls ($nu.data-dir | path join completions) | par-each {|el| $"export use ($el.name) *\n" | save --append $ALL_COMPLETIONS_PATH }
    # glob `~/OneDrive/文件/git/nu_scripts/custom-completions/*/*.nu` | par-each { $"export use ($in) *\n" | save -a $ALL_COMPLETIONS_PATH }
  }
  job spawn --tag app-update-atuin {
    # atuin
    const ATUIN_INIT_PATH: path = "~/.local/share/atuin/init.nu"
    atuin init --disable-up-arrow --disable-ctrl-r nu | save --force $ATUIN_INIT_PATH
  }
  job spawn --tag app-update-starship {
    # starship
    mkdir ($nu.data-dir | path join vendor/autoload)
    starship init nu | save --force ($nu.data-dir | path join vendor/autoload/starship.nu)
  }
  job spawn --tag app-update-carapace {
    # carapace
    mkdir $nu.cache-dir
    # carapace _carapace nushell | save --force $"($nu.cache-dir)/carapace.nu"
    carapace _carapace nushell | save --force ($nu.data-dir | path join vendor/autoload/carapace.nu)
  }

  while (job list | is-not-empty) {
    cls --keep-scrollback
    print (job list | select tag pids | table --index false --expand-deep 2 --expand)
    sleep 0.5sec
  }
  print "All updates completed."
  print "\a"
  null
}

def is-git []: nothing -> bool {
  pwd | path join ".git" | path exists
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
  if not (is-git) {
    error make {
      msg: "Not a git repository"
      labels: [
        {text: "call by here" span: (metadata $rest).span}
      ]
      help: "please run this command in a git repository"
    }
  }
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
  if not (is-git) {
    error make {
      msg: "Not a git repository"
      labels: [
        {text: "call by here" span: (metadata $rest).span}
      ]
      help: "please run this command in a git repository"
    }
  }

  let old_commit = open "./.git/FETCH_HEAD" | lines | first | parse "{comm}\t{field1}" | get 0.comm
  run-external git pull ...$rest
  let new_commit = open "./.git/FETCH_HEAD" | lines | first | parse "{comm}\t{field1}" | get 0.comm
  git log $"($old_commit)...($new_commit)"

  # let old_sub_commit = git submodule status | lines | par-each { split column " " | first 2 | upsert 0 { str trim --left --char "+" | str trim --left --char "-" } } | par-each { [[sha name]; [$in.0 $in.1]] } | flatten
  # git submodule update
  # let new_sub_commit = git submodule status | lines | par-each { split column " " | first 2 | upsert 0 { str trim --left --char "+" | str trim --left --char "-" } } | par-each { [[sha name]; [$in.0 $in.1]] } | flatten  
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
  use script/complete-tools.nu complete-file
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
        p if ($table | get path | str starts-with ($env.WINDIR | path expand)) {
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
@complete external
export def --wrapped --env y [...args: string]: nothing -> nothing {
  let tmp = (mktemp --tmpdir "yazi-cwd.XXXXXX")
  ^yazi ...$args --cwd-file $tmp
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
