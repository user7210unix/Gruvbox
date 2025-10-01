# Syntax highlighting colors
set -g fish_color_normal fbf1c7                 # fg0
set -g fish_color_command b8bb26                # bright_green
set -g fish_color_keyword d3869b                # bright_purple
set -g fish_color_quote b8bb26                  # bright_green
set -g fish_color_redirection fabd2f            # bright_yellow
set -g fish_color_end fe8019                    # bright_orange
set -g fish_color_error fb4934                  # bright_red
set -g fish_color_param 83a598                  # bright_blue
set -g fish_color_comment 928374                # gray
set -g fish_color_match fe8019                  # bright_orange
set -g fish_color_selection --background=504945 # bg2
set -g fish_color_search_match --background=504945
set -g fish_color_operator fabd2f               # bright_yellow
set -g fish_color_escape d3869b                 # bright_purple
set -g fish_color_autosuggestion 665c54         # bg3
set -g fish_color_cancel fb4934                 # bright_red

# Pager colors
set -g fish_pager_color_progress 665c54         # bg3
set -g fish_pager_color_prefix 8ec07c           # bright_aqua
set -g fish_pager_color_completion fbf1c7       # fg0
set -g fish_pager_color_description 928374      # gray

# Disable greeting
set -g fish_greeting ''

# ╔═══════════════════════════════════════════════════════════╗
# ║                    GLOBAL VARIABLES                       ║
# ╚═══════════════════════════════════════════════════════════╝

set -g __fish_git_prompt_color_branch fabd2f
set -g __fish_git_prompt_color_dirtystate fb4934
set -g __fish_git_prompt_color_stagedstate b8bb26
set -g CMD_DURATION 0

# SHELL OPTIONS
# ─────────────────────────────────────────────────────────────

# Enable command duration tracking
set -g CMD_DURATION 0

# CUSTOM PROMPT
# ─────────────────────────────────────────────────────────────

function fish_prompt
    # Store last command status immediately
    set -l last_status $status
    
    # Gruvbox color definitions
    set -l fg4 a89984
    set -l bright_blue 83a598
    set -l bright_aqua 8ec07c
    set -l bright_yellow fabd2f
    set -l bright_green b8bb26
    set -l bright_red fb4934
    set -l bright_orange fe8019
    set -l bright_purple d3869b
    set -l dim_gray 665c54
    
    # Get current user
    set -l user (whoami)
    
    # Get current directory
    set -l pwd (pwd)
    set -l display_pwd (string replace $HOME "~" $pwd)
    
    # Print newline for spacing
    echo ""
    
    # [ user ] - color based on SSH
    set_color $fg4
    echo -n "[ "
    if set -q SSH_TTY
        set_color $bright_orange
        echo -n " $user"
    else
        set_color $bright_aqua
        echo -n "$user"
    end
    set_color $fg4
    echo -n " ] "
    
    # Smart path display with color-coded segments
    set_color $fg4
    echo -n "[ "
    
    # Split path into segments
    set -l segments (string split "/" $display_pwd)
    set -l seg_count (count $segments)
    
    # If path is too long (>5 segments), shorten it intelligently
    if test $seg_count -gt 5
        # Show first segment (~ or /)
        set_color $bright_purple
        echo -n $segments[1]
        set_color $dim_gray
        echo -n "/…/"
        
        # Show last 3 segments with different colors for hierarchy
        set -l start (math $seg_count - 2)
        for i in (seq $start $seg_count)
            if test $i -eq (math $seg_count - 2)
                set_color $dim_gray
            else if test $i -eq (math $seg_count - 1)
                set_color $bright_aqua
            else
                set_color $bright_blue
            end
            echo -n $segments[$i]
            if test $i -lt $seg_count
                set_color $fg4
                echo -n "/"
            end
        end
    else
        # Short path - color code by depth for easy scanning
        for i in (seq 1 $seg_count)
            if test $i -eq 1
                set_color $bright_purple  # Root/home
            else if test $i -eq (math $seg_count - 1)
                set_color $bright_aqua    # Parent directory
            else if test $i -eq $seg_count
                set_color $bright_blue    # Current directory
            else
                set_color $dim_gray       # Middle segments
            end
            echo -n $segments[$i]
            if test $i -lt $seg_count
                set_color $fg4
                echo -n "/"
            end
        end
    end
    
    set_color $fg4
    echo -n " ]"
    
    # Git status (fast, non-blocking)
    if git rev-parse --git-dir >/dev/null 2>&1
        set -l git_branch (git branch --show-current 2>/dev/null)
        if test -z "$git_branch"
            set git_branch (git rev-parse --short HEAD 2>/dev/null)
        end
        
        set_color $fg4
        echo -n " [ "
        set_color $bright_yellow
        echo -n " $git_branch"
        
        # Check if dirty (fast check)
        if not git diff --quiet 2>/dev/null; or not git diff --cached --quiet 2>/dev/null
            set_color $bright_red
            echo -n " ●"
        else
            set_color $bright_green
            echo -n " ✓"
        end
        
        set_color $fg4
        echo -n " ]"
    end
    
    # Show command duration if >2 seconds
    if test $CMD_DURATION -gt 2000
        set -l duration (math $CMD_DURATION / 1000)
        set_color $fg4
        echo -n " [ "
        set_color $bright_orange
        echo -n " {$duration}s"
        set_color $fg4
        echo -n " ]"
    end
    
    # Virtual environment indicator (Python, Node, etc.)
    if set -q VIRTUAL_ENV
        set_color $fg4
        echo -n " [ "
        set_color $bright_purple
        echo -n " "(basename $VIRTUAL_ENV)
        set_color $fg4
        echo -n " ]"
    else if set -q NODE_VIRTUAL_ENV
        set_color $fg4
        echo -n " [ "
        set_color $bright_purple
        echo -n " node"
        set_color $fg4
        echo -n " ]"
    end
    
    # Background jobs indicator
    set -l job_count (jobs -c | wc -l)
    if test $job_count -gt 0
        set_color $fg4
        echo -n " [ "
        set_color $bright_aqua
        echo -n " $job_count"
        set_color $fg4
        echo -n " ]"
    end
    
    # New line and prompt symbol (color based on exit status)
    echo ""
    if test $last_status -eq 0
        set_color $bright_green
    else
        set_color $bright_red
    end
    echo -n "❯ "
    set_color normal
end

# Capture command duration
function postexec_cmd_duration --on-event fish_postexec
    set -g CMD_DURATION $CMD_DURATION
end

# ╔═══════════════════════════════════════════════════════════╗
# ║                    UTILITY FUNCTIONS                      ║
# ╚═══════════════════════════════════════════════════════════╝

# Make directory and cd into it
function mkcd
    mkdir -p $argv[1]; and cd $argv[1]
end

# Quick parent directory navigation
function ..
    cd ..
end

function ...
    cd ../..
end

function ....
    cd ../../..
end

# Smart extract function
function extract
    if test -f $argv[1]
        switch $argv[1]
            case '*.tar.bz2'
                tar xjf $argv[1]
            case '*.tar.gz'
                tar xzf $argv[1]
            case '*.bz2'
                bunzip2 $argv[1]
            case '*.rar'
                unrar x $argv[1]
            case '*.gz'
                gunzip $argv[1]
            case '*.tar'
                tar xf $argv[1]
            case '*.tbz2'
                tar xjf $argv[1]
            case '*.tgz'
                tar xzf $argv[1]
            case '*.zip'
                unzip $argv[1]
            case '*.Z'
                uncompress $argv[1]
            case '*.7z'
                7z x $argv[1]
            case '*'
                echo "'$argv[1]' cannot be extracted via extract()"
        end
    else
        echo "'$argv[1]' is not a valid file"
    end
end

# ╔═══════════════════════════════════════════════════════════╗
# ║                       ALIASES                             ║
# ╚═══════════════════════════════════════════════════════════╝

# File operations
alias fetch='neofetch'
alias lt='lsd -a --tree'
alias ls='exa -abghHliS'
alias tree='exa --long --tree'
alias c='clear'
alias grep='grep --color=auto'

# System
#alias sudo='doas'
alias off='poweroff'
alias ema='emacs -nw'
alias chrome-de='LANG=de-DE.UTF-8 chromium'
alias btop='glances'
alias langde='setxkbmap de'
alias langus='setxkbmap us'
alias merge='xrdb ~/.Xresources'

# Package management
alias install='sudo apt install -y'
alias search='sudo apt search'
alias update='sudo apt update && sudo apt upgrade -y'
alias remove='sudo apt remove'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias clone='git clone --depth 1'

# Development
alias py='python3'
alias pip='pip3'
alias serve='python3 -m http.server'

# ╔═══════════════════════════════════════════════════════════╗
# ║                    PATH SETUP                             ║
# ╚═══════════════════════════════════════════════════════════╝

set -gx PATH $HOME/.cargo/bin $PATH
set -gx PATH $PATH ~/.local/bin

# Clear screen on shell start
clear
