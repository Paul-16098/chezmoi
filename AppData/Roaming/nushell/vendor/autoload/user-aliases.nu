const self = path self

# Edit this completions.
export def "config user-aliases" []: nothing -> nothing {
  run-external $env.config.buffer_editor ($self)
}

alias code = code-insiders
alias ls = ls --all --threads
alias ll = ls --long
alias cargo = cargo auditable
alias pip = uv pip
alias python = uv run
alias py = python
alias pip = uv pip
alias gs = git status
alias cls = clear
alias "decode url" = url decode
alias "encode url" = url encode
alias "ya pack -a" = ya pkg add
# nu#16260
# alias "from editorconfig" = from ini
