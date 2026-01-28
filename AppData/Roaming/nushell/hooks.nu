const self = path self

# Edit this config.
export def "config user-hooks" []: nothing -> nothing {
  run-external $env.config.buffer_editor ($self)
}

# export alias l = ls
export-env {
  $env.config = (
    $env.config | upsert hooks.env_change.PWD {|config|
      let o = ($config | get --optional hooks.env_change.PWD)
      let val = [
        # toolkit
        {
          condition: {|old new|
            let toolkit_exists = "./toolkit.nu" | path exists
            let toolkit_active = (overlay list | where name == "toolkit" | get --optional 0?.active | default false)

            ($toolkit_exists and not $toolkit_active)
          }
          code: {|old new|
            const CODE = "overlay use toolkit.nu"
            print $"(ansi green)toolkit.nu(ansi reset) is exists in this directory, but not loaded.\nrun next line to activate it:"
            print ($CODE | nu-highlight)
            # not working
            # commandline edit $CODE
          }
        }
        {
          condition: {|old new|
            let toolkit_exists = "./toolkit.nu" | path exists
            let toolkit_active = (overlay list | where name == "toolkit" | get --optional 0?.active | default false)

            (not $toolkit_exists and $toolkit_active)
          }
          code: {|old new|
            const CODE = "overlay hide toolkit"
            print $"(ansi green)toolkit.nu(ansi reset) is not exists in this directory, but toolkit overlay is loaded.\nrun next line to deactivate it:"
            print ($CODE | nu-highlight)
            # not working
            # commandline edit $CODE
          }
        }
        # venv
        {
          condition: {|old new| ("./.venv/Scripts/activate.nu" | path exists) and not (overlay list | where name == "activate" | get --optional 0?.active | default false) }
          code: {|old new|
            const CODE = "overlay use ./.venv/Scripts/activate.nu"
            print $"venv is exists in this directory, but not activated.\nrun next line to activate it:"
            print ($CODE | nu-highlight)
            # not working
            # commandline edit $CODE
          }
        }
        {
          condition: {|old new| not ("./.venv/Scripts/activate.nu" | path exists) and (overlay list | where name == "activate" | get --optional 0?.active | default false) }
          code: {|old new|
            const CODE = "overlay hide activate"
            print $"venv is not exists in this directory, but activated.\nrun next line to deactivate it:"
            print ($CODE | nu-highlight)
            # not working
            # commandline edit $code
          }
        }
      ]

      if $o == null {
        $val
      } else {
        $o ++ $val
      }
    }
  )
}
