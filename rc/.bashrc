source ~/.local/share/omakub/defaults/bash/rc

# Editor used by CLI
export EDITOR="nvim"
export SUDO_EDITOR="nvim"
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/home/howie/.local/share/nvim/plugged/fzf/bin:/home/howie/.cargo/bin:/home/howie/.local/share/omakub/bin:/opt/nvim-linux64/bin"
. "$HOME/.cargo/env"
source /home/howie/Downloads/alacritty/extra/completions/alacritty.bash
source ~/.bash_completion/alacritty

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
