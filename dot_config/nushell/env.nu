# env

const NU_PLUGIN_DIRS = $NU_PLUGIN_DIRS ++ ["~/.cargo/bin/"]

load-env {
  COLORTERM: "truecolor"
  PATH: ($env.PATH | par-each --keep-order { path expand } | uniq)
} # optional

chcp 65001 | ignore

use std/formats *
use std-rfc/conversions 'into list'
