# TérangaOS — configuration zsh
export LANG=fr_FR.UTF-8
export EDITOR=nano

if [ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    export ZSH="$HOME/.oh-my-zsh"
    ZSH_THEME="agnoster"
    plugins=(git docker)
    [ -d "$ZSH/custom/plugins/zsh-autosuggestions" ] && plugins+=(zsh-autosuggestions)
    [ -d "$ZSH/custom/plugins/zsh-syntax-highlighting" ] && plugins+=(zsh-syntax-highlighting)
    source "$ZSH/oh-my-zsh.sh"
else
    autoload -Uz compinit && compinit
    PROMPT='%F{yellow}%n@%m%f:%F{208}%~%f %# '
fi

[ -f /etc/profile.d/terangaos-ai.sh ] && source /etc/profile.d/terangaos-ai.sh

alias ll='ls -la --color=auto'
alias update='sudo apt update && sudo apt upgrade -y'
alias ai='ollama run llama3.1'
alias docs='glow -p /etc/terangaos/docs/guide_fr.md 2>/dev/null || less /etc/terangaos/docs/guide_fr.md'
