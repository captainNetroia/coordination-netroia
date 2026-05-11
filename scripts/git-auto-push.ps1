# git-auto-push.ps1 — Auto-commit + push apres chaque session Claude Code
# Utilise par les hooks "stop" dans .claude/settings.json de chaque projet
# Usage : powershell.exe -NoProfile -ExecutionPolicy Bypass -File git-auto-push.ps1 -ProjectPath "C:\Netroia\{projet}" -RepoName "{repo}"

param(
    [string]$ProjectPath = $PSScriptRoot,
    [string]$RepoName = "unknown"
)

$CREDS_FILE = "C:\Netroia\credentials\github-pat.env"
if (-not (Test-Path $CREDS_FILE)) { exit 0 }

$creds = @{}
Get-Content $CREDS_FILE | Where-Object { $_ -match '^\s*[^#]\w+=.+' } | ForEach-Object {
    $parts = $_ -split '=', 2; $creds[$parts[0].Trim()] = $parts[1].Trim()
}
$PAT  = $creds['GITHUB_PAT']
$USER = $creds['GITHUB_USER']

Set-Location $ProjectPath

# Rien a faire si pas de changements
$status = git status --porcelain 2>$null
if (-not $status) { exit 0 }

# Date + heure pour le message de commit
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
$branch = git branch --show-current 2>$null

git add -A
git commit -m "chore: auto-archive session $timestamp [branch: $branch]" 2>$null

# Mettre a jour le remote avec le PAT actuel
$remoteUrl = "https://$PAT@github.com/$USER/$RepoName.git"
git remote set-url origin $remoteUrl 2>$null
git push origin $branch 2>$null

Write-Host "[$RepoName] Auto-push OK — $timestamp"
