const self = path self

# Edit this config.
export def "config user-keybindings" []: nothing -> nothing {
  run-external $env.config.buffer_editor ($self)
}

export-env {
  $env.config = (
    $env.config | upsert keybindings (
      $env.config.keybindings ++ [
        {
          name: reload_config
          modifier: none
          keycode: f5
          mode: [emacs vi_insert vi_normal]
          event: [
            {
              send: executehostcommand
              cmd: (reload-config)
            }
          ]
        }
        {
          name: atuin
          modifier: control
          keycode: "char_/"
          mode: [emacs vi_normal vi_insert]
          event: {send: executehostcommand cmd: (_atuin_search_cmd)}
        }
        {
          name: "exit-nu"
          modifier: control
          keycode: char_d
          mode: [emacs vi_normal vi_insert]
          event: {send: executehostcommand cmd: "exit 0"}
        }
        {
          name: "cls-nu"
          modifier: control
          keycode: char_l
          mode: [emacs vi_normal vi_insert]
          event: {send: executehostcommand cmd: "clear --keep-scrollback"}
        }
        {
          name: "cls-nu-no-keep-scrollback"
          modifier: control_shift
          keycode: char_l
          mode: [emacs vi_normal vi_insert]
          event: {send: executehostcommand cmd: "clear"}
        }
        {
          name: "overlay-menu"
          modifier: control
          keycode: "char_\\"
          mode: [emacs vi_normal vi_insert]
          event: [
            # {
            #   edit: InsertString
            #   value: "overlay "
            # }
            # {send: Menu name: overlay_menu}
            {send: executehostcommand cmd: "y"}
          ]
        }
      ]
    ) | upsert menus (
      $env.config.menus ++ [
        {
          name: overlay_menu
          only_buffer_difference: true
          marker: "? "
          type: {
            layout: columnar
            page_size: 10
          }
          style: {
            text: green
            selected_text: green_reverse
            description_text: yellow
          }
          source: {|buffer position|
            overlay list
            | where name =~ $buffer
            | each {|row|
              let o = {
              }
              if $row.active {
                $o | merge {value: $"hide ($row.name)" description: "hide overlay"}
              } else {
                $o | merge {value: $"use ($row.name)" description: "use overlay"}
              }
            }
            | append {value: $"new ($buffer)" description: "create new overlay"}
            | append {value: $"use ($buffer)" description: "use new overlay"}
          }
        }
      ]
    )
  )
}
