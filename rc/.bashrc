# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
	for rc in ~/.bashrc.d/*; do
		if [ -f "$rc" ]; then
			. "$rc"
		fi
	done
fi
unset rc

# merge omakub bash settings with personal.dotfiles
source ~/.local/share/omakub/defaults/bash/rc

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
	PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi

# Editor used by CLI
export EDITOR="nvim"
export SUDO_EDITOR="nvim"
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"
export PATH="$PATH:$HOME/.local/share/nvim/plugged/fzf/bin:$HOME/.cargo/bin:$HOME/.local/share/omakub/bin:/opt/nvim-linux64/bin"
export PATH

. "$HOME/.cargo/env"
#source /home/howie/Downloads/alacritty/extra/completions/alacritty.bash
#source ~/.bash_completion/alacritty
#. "$HOME/.cargo/env"

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# alias code="flatpak run com.visualstudio.code"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

source /home/howie/Downloads/alacritty/extra/completions/alacritty.bash
