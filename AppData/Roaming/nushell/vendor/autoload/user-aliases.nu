const self = path self

# Edit this completions.
export def "config user-aliases" []: nothing -> nothing {
  run-external $env.config.buffer_editor ($self)
}

alias ls = ls --all --threads
alias ll = ls --long
alias cargo = cargo auditable
alias pip = uv pip
alias python = uv run
alias py = python
alias pip = uv pip
alias gs = git status
alias cls = clear
alias & = job spawn
alias "decode url" = url decode
alias "encode url" = url encode
alias "ya pack -a" = ya pkg add
# nu#16260
# alias "from editorconfig" = from ini

# chezmoi
export alias chad = chezmoi add
export alias chap = chezmoi apply
export alias chd = chezmoi diff
export alias chda = chezmoi data
export alias chs = chezmoi status
export alias ched = chezmoi edit
export alias chst = chezmoi status
export alias chm = chezmoi merge
export alias chma = chezmoi merge-all
export alias chrad = chezmoi re-add