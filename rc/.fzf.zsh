# Setup fzf
# ---------
if [[ ! "$PATH" == *$HOME/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}$HOME/.fzf/bin"
fi

export FZF_DEFAULT_OPTS="
--bind 'ctrl-y:execute(readlink -f {} | xclip -selection clipboard)'
--bind 'enter:become(nvim {})'
"

source <(fzf --zsh)
