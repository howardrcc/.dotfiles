#/bin/bash


if [ -e ~/.bashrc ]
then
    mv ~/.bashrc ~/.bashrc.bak
fi

if [ -e ~/.fzf.bash ]
then
    mv ~/.fzf.bash ~/.fzf.bash.bak
fi

if [ -e ~/.fzf.zsh ]
then
    mv ~/.fzf.zsh ~/.fzf.zsh.bak
fi

if [ -e ~/.zshrc ]
then
    mv ~/.zshrc ~/.zshrc.bak
fi


stow -S rc
