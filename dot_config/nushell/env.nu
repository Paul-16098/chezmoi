# env

const NU_PLUGIN_DIRS = $NU_PLUGIN_DIRS ++ ["~/.cargo/bin/"]

load-env {
  COLORTERM: "truecolor"
  PATH: ($env.PATH | par-each --keep-order { path expand } | uniq)
  CARAPACE_BRIDGES: 'zsh,fish,bash,inshellisense'
} # optional

chcp 65001 | ignore

use std/clip # 17664
use std/formats *
use std-rfc/conversions 'into list'
use ~\OneDrive\文件\git\nu_scripts\nu-hooks\nu-hooks\direnv\direnv.nu
