const self = path self .

open ($self | path join "yazi.toml") | save ($self | path join "yazi.json") --force
open ($self | path join "yazi.json") | to toml --serialize | save ($self | path join "yazi.toml") --force
rm ($self | path join "yazi.json")
