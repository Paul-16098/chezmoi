# env
overlay new setup-env
$env.COLORTERM = "truecolor"

overlay new setup-paths

const NU_PLUGIN_DIRS = $NU_PLUGIN_DIRS ++ ["~/.cargo/bin/"]

load-env {
  PATH: ($env.PATH | par-each --keep-order { path expand } | uniq)
  CARAPACE_BRIDGES: 'zsh,fish,bash,inshellisense'
} # optional

overlay new setup
chcp 65001 | ignore

overlay hide setup
# overlay hide setup-env

overlay new nu_scripts\custom-completions

use ~\OneDrive\文件\git\nu_scripts\custom-completions\uv\uv-completions.nu
use ~\OneDrive\文件\git\nu_scripts\custom-completions\cargo\cargo-completions.nu
use ~\OneDrive\文件\git\nu_scripts\custom-completions\cargo-make\cargo-make-completions.nu
use ~\OneDrive\文件\git\nu_scripts\custom-completions\dotnet\dotnet-completions.nu
use ~\OneDrive\文件\git\nu_scripts\custom-completions\vscode\vscode-completions.nu
use ~\OneDrive\文件\git\nu_scripts\custom-completions\rustup\rustup-completions.nu
use ~\OneDrive\文件\git\nu_scripts\custom-completions\scoop\scoop-completions.nu
use ~\OneDrive\文件\git\nu_scripts\custom-completions\winget\winget-completions.nu
use ~\OneDrive\文件\git\nu_scripts\custom-completions\ssh\ssh-completions.nu
use ~\OneDrive\文件\git\nu_scripts\custom-completions\curl\curl-completions.nu

overlay hide nu_scripts\custom-completions

use std/formats *
use std-rfc/conversions 'into list'
use std/clip
use ~\OneDrive\文件\git\nu_scripts\nu-hooks\nu-hooks\direnv\direnv.nu
