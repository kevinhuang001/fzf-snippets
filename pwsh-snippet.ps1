function fzfkill {
    if (!(Get-Command fzf -ErrorAction SilentlyContinue)) {
        Write-Host "Error: fzf is not installed or not in PATH." -ForegroundColor Red
        return
    }
    Get-Process | fzf -m | ForEach-Object {
        $parts = $_ -split '\s+'
        $procId = $parts[-3]     # ❗ 不要用 $pid
        $name   = $parts[-1]

        try {
            Stop-Process -Id $procId -ErrorAction Stop
            Write-Host "Killed process $name (PID=$procId)" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to kill $name (PID=$procId): $_" -ForegroundColor Red
        }
    }
}

function fzfrm {
    if (!(Get-Command fzf -ErrorAction SilentlyContinue)) {
        Write-Host "Error: fzf is not installed or not in PATH." -ForegroundColor Red
        return
    }

    $selected = Get-ChildItem -Path . -Force -Name | fzf -m --header "Select files/folders to delete (TAB to multi-select)"
    if ($selected) {
        $count = ($selected | Measure-Object).Count
        Write-Host "Are you sure you want to delete these $count item(s)? [Y/n]: " -ForegroundColor Yellow -NoNewline
        $confirmation = Read-Host
        
        if ($confirmation -eq "" -or $confirmation -eq "y" -or $confirmation -eq "Y") {
            $selected | ForEach-Object {
                try {
                    Remove-Item -Path $_ -Recurse -Force -ErrorAction Stop
                    Write-Host "Removed: $_" -ForegroundColor Green
                }
                catch {
                    Write-Host "Failed to remove $($_): $_" -ForegroundColor Red
                }
            }
        } else {
            Write-Host "Operation cancelled." -ForegroundColor Cyan
        }
    }
}

function fzfvi {
    _fzf_edit "vi"
}

function fzfvim {
    _fzf_edit "vim"
}

function fzfnvim {
    _fzf_edit "nvim"
}

function _fzf_edit {
    param($editor)
    
    if (!(Get-Command fzf -ErrorAction SilentlyContinue)) {
        Write-Host "Error: fzf is not installed or not in PATH." -ForegroundColor Red
        return
    }
    
    if (!(Get-Command $editor -ErrorAction SilentlyContinue)) {
        Write-Host "Error: $editor is not installed or not in PATH." -ForegroundColor Red
        return
    }

    # 优先使用 bat，如果不存在则使用 type (Windows cmd 兼容)
    $previewCmd = 'bat --color=always --style=numbers {} 2>nul || type {}'

    $selected = Get-ChildItem -Path . -File -Force -Name | fzf --header "Select file to open with $editor" --preview $previewCmd
    if ($selected) {
        & $editor $selected
    }
}

function fzfcd {
    if (!(Get-Command fzf -ErrorAction SilentlyContinue)) {
        Write-Host "Error: fzf is not installed or not in PATH." -ForegroundColor Red
        return
    }
    # 搜索子目录并切换 (限制深度为3层，避免过慢)
    $dir = Get-ChildItem -Path . -Directory -Recurse -Depth 3 -ErrorAction SilentlyContinue -Name | fzf --header "Change Directory"
    if ($dir) {
        Set-Location $dir
    }
}

function fzfenv {
    if (!(Get-Command fzf -ErrorAction SilentlyContinue)) {
        Write-Host "Error: fzf is not installed or not in PATH." -ForegroundColor Red
        return
    }
    $selected = Get-ChildItem Env: | ForEach-Object { "$($_.Name)=$($_.Value)" } | fzf --header "Select Environment Variable to EDIT"
    if ($selected) {
        $parts = $selected -split '=', 2
        $key = $parts[0]
        $oldValue = $parts[1]
        
        Write-Host "Change the value of '$key' from '$oldValue' to: " -ForegroundColor Cyan -NoNewline
        $newValue = Read-Host
        
        if ($null -ne $newValue -and $newValue -ne "") {
            Set-Item -Path "Env:$key" -Value $newValue
            Write-Host "Done!" -ForegroundColor Green
        }
    }
}

function fzfgb {
    if (!(Get-Command fzf -ErrorAction SilentlyContinue)) {
        Write-Host "Error: fzf is not installed or not in PATH." -ForegroundColor Red
        return
    }
    if (!(Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "Error: git is not installed." -ForegroundColor Red
        return
    }
    
    # 检查是否在 git 仓库中
    git rev-parse --is-inside-work-tree > $null 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Not a git repository." -ForegroundColor Red
        return
    }

    $branch = git branch --all | fzf --header "Select Git Branch"
    if ($branch) {
        $branch = $branch.Trim().Replace('* ', '').Split(' ')[0]
        # 如果是远程分支，需要去掉 remotes/origin/ 前缀
        if ($branch -like "remotes/*") {
            $branch = $branch -replace "^remotes/[^/]+/", ""
        }
        
        git checkout $branch
        if ($LASTEXITCODE -ne 0) {
            Write-Host "`nLocal changes detected. Stash and try again? [y/N]: " -ForegroundColor Yellow -NoNewline
            $ans = Read-Host
            if ($ans -eq "y" -or $ans -eq "Y") {
                Write-Host "Stashing..." -ForegroundColor Cyan
                git stash
                git checkout $branch
            }
        }
    }
}