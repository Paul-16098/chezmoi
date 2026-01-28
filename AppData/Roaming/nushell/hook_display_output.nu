const self = path self

# Edit this config.
export def "config user-display-output" []: nothing -> nothing {
  run-external $env.config.buffer_editor ($self)
}

def classify []: record -> record {
  let md = $in
  # print --stderr $md
  let head = try { view span $md.span.start $md.span.end }
  match $md.content_type? {
    null => {table: true}
    $mimetype if $mimetype starts-with 'image' => {image: true}
    $mimetype if ($mimetype starts-with 'video' or $mimetype starts-with 'audio') => {video: true}
    "application/x-nuscript" | "application/x-nuon" | "text/x-nushell" => {nu: true}
    _ => {table: true}
  }
  | insert head $head
  | insert source $md.source?
}

export-env {
  $env.config.hooks.display_output = {
    metadata access {|meta|
      # print --stderr $meta
      # nu-lint-ignore: try_instead_of_do
      do {|class|
        # print --stderr $class
        match $class {
          {nu: true} => { nu-highlight }
          {source: ls} => { sort-by type modified size name --custom {|a b| $a == dir } }
          _ => { }
        }
        | match $class {
          {video: true} | {image: true} => {
            ^($env.ProgramFiles | path join VideoLAN\VLC\vlc.exe) -
          }

          {source: ls} if (term size).columns >= 100 => { table --expand --icons --index false }
          {source: ls} => { table --icons --index false }

          _ if (term size).columns >= 100 => { table --expand }
          _ => { table }
        }
      } ($meta | classify)
    }
  }
}
