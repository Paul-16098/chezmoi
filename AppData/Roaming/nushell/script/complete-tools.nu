# This module provides path completion functionality for NuShell.
export def complete-path [
  glob: glob
  depth: int = 5
]: nothing -> record {
  {
    options: {
      sort: false
    }
    completions: (
      glob --follow-symlinks --depth $depth $glob | collect | par-each { $in | path expand | path relative-to $env.PWD } | uniq
      | sort-by --custom {|a b|
        ($a | path split | length) < ($b | path split | length)
      } | par-each --keep-order { $in | $'`($in)`' }
    )
  }
}

# wraps complete-path for file extensions
export def complete-file [ext: string]: nothing -> record {
  complete-path $"**/*.($ext)"
}
