#!/bin/bash

#############################################################
# Shell Environment and Dotfiles Configuration
#############################################################

setup_shell_environment() {
    log "Setting up shell environment..."
    
    # Install Powerlevel10k theme
    if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
        log "Installing Powerlevel10k theme..."
        if [[ "$DRY_RUN" == false ]]; then
            git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
                ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
            success "Powerlevel10k installed"
        else
            log "[DRY-RUN] Would install Powerlevel10k theme"
        fi
    else
        success "Powerlevel10k already installed"
    fi
    
    # Install useful Oh My Zsh plugins
    declare -a zsh_plugins=(
        "zsh-autosuggestions"
        "zsh-syntax-highlighting"
    )
    
    for plugin in "${zsh_plugins[@]}"; do
        plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin"
        if [[ ! -d "$plugin_dir" ]]; then
            log "Installing $plugin..."
            if [[ "$DRY_RUN" == false ]]; then
                git clone "https://github.com/zsh-users/$plugin.git" "$plugin_dir"
                success "$plugin installed"
            else
                log "[DRY-RUN] Would install $plugin"
            fi
        else
            success "$plugin already installed"
        fi
    done
    
    success "Shell environment setup complete"
}

configure_dotfiles() {
    log "Configuring dotfiles..."
    
    # Backup existing files
    backup_dotfile() {
        local file="$1"
        if [[ -f "$HOME/$file" ]] && [[ ! -f "$HOME/$file.backup" ]]; then
            log "Backing up existing $file..."
            cp "$HOME/$file" "$HOME/$file.backup"
        fi
    }
    
    # Configure .zshrc
    configure_zshrc() {
        log "Configuring .zshrc..."
        
        backup_dotfile ".zshrc"
        
        if [[ "$DRY_RUN" == true ]]; then
            log "[DRY-RUN] Would configure .zshrc"
            return 0
        fi
        
        cat > "$HOME/.zshrc" << 'EOF'
# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
    git
    docker
    kubectl
    aws
    node
    bun
    golang
    rust
    zsh-autosuggestions
    zsh-syntax-highlighting
    fzf
)

# Oh My Zsh
source $ZSH/oh-my-zsh.sh

# User configuration
export LANG=en_US.UTF-8
export EDITOR='code-insiders --wait'

# Path additions
export PATH="$HOME/.bun/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$(go env GOPATH)/bin:$PATH"

# Aliases for eza (modern ls)
alias ls='eza --icons --color=always --group-directories-first'
alias ll='eza -l --icons --color=always --group-directories-first'
alias la='eza -la --icons --color=always --group-directories-first'
alias lt='eza --tree --icons --color=always --group-directories-first'
alias l.='eza -a | grep -E "^\."'

# Bun aliases to replace npm/npx
alias npm='bun'
alias npx='bunx'
alias pnpm='bun'
alias pnpx='bunx'
alias yarn='bun'

# Modern CLI replacements
alias cat='bat --paging=never'
alias find='fd'
alias grep='rg'
alias diff='delta'
alias du='dust'
alias df='duf'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gco='git checkout'
alias gb='git branch'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias gdc='git diff --cached'

# Docker shortcuts
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlog='docker logs -f'
alias dprune='docker system prune -af'

# Directory shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

# Safety nets
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Reload shell configuration
alias reload='source ~/.zshrc'
alias zshconfig='${EDITOR:-code-insiders} ~/.zshrc'

# FZF configuration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Node version manager (if needed)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF
        
        success ".zshrc configured"
    }
    
    # Configure .gitconfig
    configure_gitconfig() {
        log "Configuring .gitconfig..."
        
        backup_dotfile ".gitconfig"
        
        if [[ "$DRY_RUN" == true ]]; then
            log "[DRY-RUN] Would configure .gitconfig"
            return 0
        fi
        
        cat > "$HOME/.gitconfig" << 'EOF'
[user]
    name = Your Name
    email = your.email@example.com

[core]
    editor = code-insiders --wait
    autocrlf = input
    ignorecase = false
    whitespace = fix,-indent-with-non-tab,trailing-space,cr-at-eol

[init]
    defaultBranch = main

[pull]
    rebase = false

[push]
    default = current

[merge]
    tool = vscode
    conflictstyle = zdiff3

[mergetool "vscode"]
    cmd = code-insiders --wait $MERGED

[diff]
    tool = vscode

[difftool "vscode"]
    cmd = code-insiders --wait --diff $LOCAL $REMOTE

[color]
    ui = auto

[color "branch"]
    current = yellow bold
    local = green bold
    remote = cyan bold

[color "diff"]
    meta = yellow bold
    frag = magenta bold
    old = red bold
    new = green bold
    whitespace = red reverse

[color "status"]
    added = green bold
    changed = yellow bold
    untracked = red bold

[alias]
    # Shortcuts
    st = status
    ci = commit
    br = branch
    co = checkout
    df = diff
    dc = diff --cached
    
    # Logging
    lg = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
    ll = log --pretty=format:'%C(yellow)%h%Cred%d %Creset%s%Cblue [%cn]' --decorate --numstat
    
    # Useful commands
    undo = reset --soft HEAD^
    amend = commit --amend --reuse-message=HEAD
    branches = branch -a
    tags = tag -l
    remotes = remote -v
    
    # Show files changed in last commit
    last = log -1 HEAD --stat
    
    # Find branches containing commit
    fb = "!f() { git branch -a --contains $1; }; f"
    
    # Find commits by commit message
    fm = "!f() { git log --pretty=format:'%C(yellow)%h  %Cblue%ad  %Creset%s%Cgreen  [%cn] %Cred%d' --decorate --date=short --grep=$1; }; f"

[filter "lfs"]
    clean = git-lfs clean -- %f
    smudge = git-lfs smudge -- %f
    process = git-lfs filter-process
    required = true
EOF
        
        success ".gitconfig configured"
        info "Remember to update your name and email in ~/.gitconfig"
    }
    
    # Execute configurations
    configure_zshrc
    configure_gitconfig
    
    success "Dotfiles configured successfully"
}