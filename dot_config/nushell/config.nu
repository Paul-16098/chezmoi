# config
$env.config.buffer_editor = $env.EDITOR
$env.config.table.missing_value_symbol = "[X]"
$env.config.display_errors.exit_code = true
$env.config.history.max_size = 100
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

$env.LS_COLORS = (vivid generate molokai)
$env.VIRTUAL_ENV_DISABLE_PROMPT = true

$env.TRANSIENT_PROMPT_COMMAND = { starship module time }
$env.TRANSIENT_PROMPT_INDICATOR = { (starship module directory) + $"(ansi wd)$(ansi reset) " }

# completions
## carapace
# source ($nu.cache-dir | path join carapace.nu)
## all-completions
# overlay use ($nu.data-dir | path join all-completions.nu)
# overlay use ($nu.data-dir | path join user-completions.nu)

source "~/.local/share/atuin/init.nu"

# $env.NU_ALIAS_FINDER_PREFIX = $"(ansi gb)Alias Tip(ansi reset):"
# $env.NU_ALIAS_FINDER_IGNORED = "plugin"
# overlay use ($nu.data-dir | path join "alias-finder/alias-finder.nu")

# user functions
overlay use ($nu.data-dir | path join user-fn.nu)

# hooks
overlay use ($nu.data-dir | path join hooks.nu)
overlay use ($nu.data-dir | path join hook_display_output.nu)

# keybindings
overlay use ($nu.data-dir | path join keybindings.nu)

# nupm
overlay use nupm/nupm/ --prefix
$env.NU_LIB_DIRS = $env.NU_LIB_DIRS ++ [($env.NUPM_HOME | path join modules)]
