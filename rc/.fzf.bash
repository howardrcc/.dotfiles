# Setup fzf
# ---------
if [[ ! "$PATH" == */home/howie/.fzf/bin* ]]; then
	PATH="${PATH:+${PATH}:}/home/howie/.fzf/bin"
fi

eval "$(fzf --bash)"

export FZF_DEFAULT_OPTS="
--bind 'ctrl-y:execute(readlink -f {} | xclip -selection clipboard)'
--bind 'enter:become(nvim {})'
"
