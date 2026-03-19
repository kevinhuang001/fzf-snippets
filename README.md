# fzf-snippets

A cross-platform terminal efficiency toolkit based on `fzf`, providing enhanced versions of common tasks such as process management, file operations, Git branch switching, and environment variable modification. Supports **Bash**, **Zsh**, and **PowerShell**.

## 🚀 Quick Installation

Run the corresponding command for your platform to install. The script will automatically detect `fzf` dependencies and configure your shell environment.

### Linux / macOS (Bash, Zsh)
```bash
curl -fsSL https://raw.githubusercontent.com/kevinhuang001/fzf-snippets/master/install.sh | bash
```

### Windows (PowerShell)
```powershell
Invoke-RestMethod -Uri https://raw.githubusercontent.com/kevinhuang001/fzf-snippets/master/install.ps1 | pwsh
```

> **Note**: After installation, please restart your terminal or run `source ~/.zshrc` (macOS/Linux) or `. $PROFILE` (Windows) to apply the changes.

## ✨ Main Features

All commands are prefixed with `fzf` for easy discovery.

| Command | Description |
| :--- | :--- |
| `fzfkill` | Interactively search and kill processes. |
| `fzfrm` | Interactively select files or folders to delete (with double-check, default is 'y'). |
| `fzfvi` / `fzfvim` / `fzfnvim` | Search files with a preview window and open with the corresponding editor. |
| `fzfcd` | Interactively search subdirectories and switch quickly. |
| `fzfenv` | Search and modify environment variables for the current session. |
| `fzfgb` | Search and switch Git branches (supports automatic stash if local conflicts exist). |

## 🛠️ Dependencies

For the best experience, we recommend installing the following tools:

- [fzf](https://github.com/junegunn/fzf) (Required)
- [bat](https://github.com/sharkdp/bat) (Optional, for enhanced file previews)
- [git](https://git-scm.com/) (Required for `fzfgb`)

## 📄 License

MIT License
