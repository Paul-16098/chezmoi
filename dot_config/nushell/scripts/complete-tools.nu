use std/log

# This module provides tools for generating completions for NuShell.
def base []: nothing -> record<completions: list<string>, options: record<sort: bool>> {
  {
    options: {
      sort: false
    }
    completions: []
  }
}
# sorts paths by their depth (number of components)
def sort-path []: list<path> -> list<path> {
  sort-by --custom {|a b|
    ($a | path split | length) < ($b | path split | length)
  }
}

# This module provides path completion functionality for NuShell.
export def complete-path [
  glob: glob # the glob pattern to search for matches (e.g. "**/*" for all files and directories)
  depth: int = 5 # how deep to search for matches (number of path components)
  --sort = true # whether to sort the results by depth (number of path components)
  --raw # whether to return raw paths without sorting or filtering
]: nothing -> record {
  log debug $"Generating completions for glob: ($glob) with depth: ($depth), sort: ($sort), raw: ($raw)"

  base | update completions (
    glob --depth $depth $glob
    | par-each { $in | path relative-to $env.PWD } | uniq
    | if $sort { sort-path } else { $in }
    | if not $raw {
      par-each --keep-order {
        if ($in | str contains " ") {
          log debug $"Path contains spaces, wrapping in quotes: ($in)"
          $"'($in)'"
        } else { $in }
      }
    } else { $in }
  )
}

# wraps complete-path for file extensions
# you can use ext="{exe,bat,cmd,ps1}" to match multiple extensions
@example "complete file .txt" { complete-file txt }
@example "complete 2file .txt .json" { complete-file "{txt,json}" }
export def complete-file [ext: string]: nothing -> record {
  log debug $"Generating file completions for extensions: ($ext)"

  complete-path $"**/*.($ext)"
}

# wraps complete-path for mime types
# supports brace expansion like "text/{plain,html}" and wildcards like "text/*"
@example "complete image" { complete-mime image/* }
export def complete-mime [...mime_type: string]: nothing -> record {
  log debug $"Generating completions for mime types: ($mime_type)"

  mut out = []
  for path in (complete-path $"**/*" --sort=false --raw | get completions) {
    if ($path | path type) != "file" {
      log debug $"Skipping path: ($path) because it is not a file"
      continue
    }
    log debug $"Getting mime type for path: ($path)"

    let mime = ls $path --mime-type | get 0.type
    log debug $"Checking path: $path with mime type: ($mime) against patterns: ($mime_type)"
    for $mt in $mime_type {
      if (($mt | str contains "{") and ($mt | str contains "}")) {
        $out ++= complete-mime ($mt | str expand) | get completions
      } else if ($mt | str contains "*") {
        let pattern = $mt | str replace --all "*" ".*"
        log debug $"Converted wildcard pattern: ($mt) to regex pattern: ($pattern)"
        if ($mime =~ $pattern) {
          log debug $"Adding path: ($path) to results because mime type: ($mime) matches pattern: ($pattern)"
          $out ++= [$path]
        }
      } else {
        if $mime == $mt {
          $out += $path
        }
      }
    }
  }

  base | update completions ($out | par-each { if ($in | str contains " ") { $"'($in)'" } else { $in } } | sort-path)
}
