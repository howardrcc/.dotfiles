# Setup fzf
# ---------
if [[ ! "$PATH" == */home/howie/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/howie/.fzf/bin"
fi

source <(fzf --zsh)
