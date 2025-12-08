# Setup fzf
# ---------
if [[ ! "$PATH" == *$HOME/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}$HOME/.fzf/bin"
fi

export FZF_DEFAULT_OPTS="
--bind 'ctrl-y:execute(readlink -f {} | wl-copy )'
"

export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range :500 {}'"

# Alt-C (cd) with preview
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"
source <(fzf --zsh)
