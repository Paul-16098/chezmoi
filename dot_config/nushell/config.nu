# nu-lint-ignore-file: dynamic_script_import
# config
try {
  $env.config.buffer_editor = $env.EDITOR | split row ' ' | update 0 {
      which --all $in | get 0.path
    }
}

$env.config.table.missing_value_symbol = "∅"
$env.config.max_last_result_size = 1mb
$env.config.display_errors.exit_code = true
# $env.config.use_kitty_protocol = true
$env.config.history.path = null
$env.config.history.file_format = "sqlite"
$env.config.history.sync_on_enter = false
$env.config.history.isolation = true
$env.config.color_config.string = {
  if $in =~ '^#[a-fA-F\d]{6}' {
    $in
  } else {
    'default'
  }
}
$env.config.show_banner = "short"
$env.config.rm.always_trash = true
$env.config.completions.quick = false
$env.config.footer_mode = "auto"
$env.config.filesize.precision = 2
$env.config.highlight_resolved_externals = true
$env.config.completions.partial = false
$env.config.error_lines = 3
$env.config.error_style = "nested"
$env.config.hinter.closure = {|ctx|
  if ($ctx.line | str length) == 0 {
    null
  } else {
    let candidate = (
      try {
        ^atuin search --cwd $ctx.cwd --limit 1 --cmd-only ($"^($ctx.line)")
        | lines
        | first
      } catch {
        null
      }
    )

    if $candidate == null or not ($candidate | str starts-with $ctx.line) {
      null
    } else {
      ($candidate | str substring (($ctx.line | str length))..)
    }
  }
}
$env.config.abbreviations = {
  ll: 'ls --long'

  py: python

  gl: 'git log'
  glo: 'git log @{u}..'

  gp: 'git pull'
  gs: 'git status-or-diff'
  gso: 'git show @{u}..'
  gc: 'git clone'
}
$env.config.menus = $env.config.menus | where name == completion_menu

$env.LS_COLORS = (vivid generate molokai)
$env.VIRTUAL_ENV_DISABLE_PROMPT = true

$env.TRANSIENT_PROMPT_COMMAND = { starship prompt --profile transient_prompt }
# $env.TRANSIENT_PROMPT_COMMAND_RIGHT = ""

source "~/.local/share/atuin/init.nu"

use std/help
$env.NU_HELPER = 'tldr'

# user functions
overlay use ('./scripts' | path join user-fn.nu)

# hooks
overlay use ('.' | path join hooks.nu)
overlay use ('.' | path join hook_display_output.nu)
overlay use ('.' | path join command_not_found_hook.nu)

# keybindings
overlay use ('.' | path join keybindings.nu)

# completions
overlay use ('.' | path join user-completions.nu)

# aliases
overlay use ('.' | path join user-aliases.nu)

# nupm
use ../nupm/modules/nupm
$env.NU_LIB_DIRS = $env.NU_LIB_DIRS ++ [($env.NUPM_HOME | path join modules)]

overlay new REPL

alias 'ast md' = from md
@deprecated "use 'ast md' instead"
def 'from md' []: string -> nothing { do {} (print --stderr 'Please use "ast md" instead.') }

$env | reject --optional --ignore-case config FILE_PWD CURRENT_FILE PWD | transpose key val | str uppercase key | transpose --as-record --header-row | load-env
