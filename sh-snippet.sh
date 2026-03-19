#!/bin/bash

# Helper: check if command exists
_fzf_check_cmd() {
    if ! command -v "$1" &> /dev/null; then
        printf "\033[0;31mError: $1 is not installed or not in PATH.\033[0m\n"
        return 1
    fi
}

fzfkill() {
    _fzf_check_cmd "fzf" || return
    local pid
    pid=$(ps -ef | sed 1d | fzf -m --header "Select process to KILL" | awk '{print $2}')

    if [ -n "$pid" ]; then
        echo "$pid" | xargs kill -9 && printf "\033[0;32mKilled process(es): $pid\033[0m\n"
    fi
}

fzfrm() {
    _fzf_check_cmd "fzf" || return
    local selected
    selected=$(ls -A1 | fzf -m --header "Select files/folders to delete (TAB to multi-select)")
    
    if [ -n "$selected" ]; then
        local count
        count=$(echo "$selected" | wc -l)
        printf "\033[0;33mAre you sure you want to delete these $count item(s)? [Y/n]: \033[0m"
        read -r confirmation
        
        if [[ -z "$confirmation" || "$confirmation" =~ ^[Yy]$ ]]; then
            echo "$selected" | while read -r item; do
                if rm -rf "$item"; then
                    printf "\033[0;32mRemoved: $item\033[0m\n"
                else
                    printf "\033[0;31mFailed to remove: $item\033[0m\n"
                fi
            done
        else
            printf "\033[0;36mOperation cancelled.\033[0m\n"
        fi
    fi
}

fzfvi() { _fzf_edit "vi" "$@"; }
fzfvim() { _fzf_edit "vim" "$@"; }
fzfnvim() { _fzf_edit "nvim" "$@"; }

_fzf_edit() {
    local editor=$1
    _fzf_check_cmd "fzf" || return
    _fzf_check_cmd "$editor" || return

    local preview_cmd='bat --color=always --style=numbers {} || cat {}'
    local selected
    selected=$(ls -A1p | grep -v / | fzf --header "Select file to open with $editor" --preview "$preview_cmd")
    
    if [ -n "$selected" ]; then
        "$editor" "$selected"
    fi
}

fzfcd() {
    _fzf_check_cmd "fzf" || return
    local dir
    dir=$(find . -maxdepth 3 -type d 2>/dev/null | fzf --header "Change Directory")
    if [ -n "$dir" ]; then
        cd "$dir" || return
    fi
}

fzfenv() {
    _fzf_check_cmd "fzf" || return
    local selected
    selected=$(env | fzf --header "Select Environment Variable to EDIT")
    
    if [ -n "$selected" ]; then
        local key="${selected%%=*}"
        local old_value="${selected#*=}"
        
        printf "\033[0;36mChange the value of '$key' from '$old_value' to: \033[0m"
        read -r new_value
        
        if [ -n "$new_value" ]; then
            export "$key=$new_value"
            printf "\033[0;32mDone!\033[0m\n"
        fi
    fi
}

fzfgb() {
    _fzf_check_cmd "fzf" || return
    _fzf_check_cmd "git" || return
    
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        printf "\033[0;31mError: Not a git repository.\033[0m\n"
        return 1
    fi

    local branch
    branch=$(git branch -a | fzf --header "Select Git Branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
    
    if [ -n "$branch" ]; then
        if ! git checkout "$branch"; then
            printf "\033[0;33m\nLocal changes detected. Stash and try again? [y/N]: \033[0m"
            read -r ans
            if [[ "$ans" =~ ^[Yy]$ ]]; then
                printf "\033[0;36mStashing...\033[0m\n"
                git stash
                git checkout "$branch"
            fi
        fi
    fi
}
