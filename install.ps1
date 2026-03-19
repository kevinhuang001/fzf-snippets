# Repository configuration
$RepoUrl = "https://raw.githubusercontent.com/kevinhuang001/fzf-snippets/master"
$ScriptName = "pwsh-snippet.ps1"
$InstallPath = "$HOME\Documents\PowerShell\Scripts\$ScriptName"

# Ensure the directory exists
if (-not (Test-Path "$HOME\Documents\PowerShell\Scripts")) {
    New-Item -ItemType Directory -Path "$HOME\Documents\PowerShell\Scripts" -Force | Out-Null
}

Write-Host "--- fzf-snippets Installer (PowerShell) ---" -ForegroundColor Cyan

# 1. Check fzf
if (-not (Get-Command fzf -ErrorAction SilentlyContinue)) {
    Write-Host "Warning: fzf is not installed." -ForegroundColor Yellow
    Write-Host "Please install it via your package manager:"
    Write-Host "  - Scoop: scoop install fzf" -ForegroundColor Green
    Write-Host "  - Chocolatey: choco install fzf" -ForegroundColor Green
    Write-Host "After installing fzf, please run this installer again."
    exit
}

# 2. Download the script
Write-Host "Downloading $ScriptName..." -ForegroundColor Cyan
try {
    Invoke-RestMethod -Uri "$RepoUrl/$ScriptName" -OutFile "$InstallPath"
    Write-Host "Successfully downloaded to $InstallPath" -ForegroundColor Green
}
catch {
    Write-Host "Failed to download $ScriptName. Please check your network." -ForegroundColor Red
    exit
}

# 3. Add to $PROFILE
if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

$ProfileContent = Get-Content $PROFILE -ErrorAction SilentlyContinue
$SourceLine = ". `"$InstallPath`""

if ($ProfileContent -contains $SourceLine) {
    Write-Host "Already configured in $PROFILE" -ForegroundColor Green
}
else {
    Add-Content -Path $PROFILE -Value "`n# fzf-snippets`n$SourceLine"
    Write-Host "Added source line to $PROFILE" -ForegroundColor Green
}

Write-Host "Installation complete! Please restart your terminal or run: . `$PROFILE" -ForegroundColor Cyan
