# GI & KLIRONOMIA 360 - auto publish updates to GitHub (Pages rebuilds automatically)
# Run manually anytime, or weekly via the scheduled task "GH360-WeeklyPublish".
# Commits any local changes in this folder and pushes them. Does nothing if unchanged.

# Continue (not Stop): git writes normal progress to stderr and WinPS 5.1 would
# otherwise treat that as a terminating error. We check $LASTEXITCODE instead.
$ErrorActionPreference = "Continue"
$root = $PSScriptRoot
$log  = Join-Path $root "publish.log"

function Log($msg) {
  $line = ("[" + (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + "] " + $msg)
  Add-Content -Path $log -Value $line -Encoding utf8
  Write-Host $line
}

Set-Location $root

# Locate git
$git = (Get-Command git -ErrorAction SilentlyContinue).Source
if (-not $git) { $git = "C:\Program Files\Git\cmd\git.exe" }
if (-not (Test-Path $git)) { Log "ERROR: git not found on PATH"; exit 1 }

try {
  # Any changes?
  $status = & $git status --porcelain
  if ([string]::IsNullOrWhiteSpace($status)) {
    Log "No changes - nothing to publish."
    exit 0
  }

  & $git add -A
  $msg = "Auto-update " + (Get-Date -Format "yyyy-MM-dd HH:mm")
  & $git -c user.name="Chronis Makris" -c user.email="xoma.gr@gmail.com" commit -m $msg | Out-Null
  Log ("Committed: " + $msg)

  # Sync with remote first (in case it changed elsewhere), then push.
  # Discard stderr progress text so WinPS does not mistake it for an error.
  & $git pull --rebase origin main 2>$null 1>$null
  & $git push origin main 2>$null 1>$null
  if ($LASTEXITCODE -eq 0) {
    Log "Pushed to GitHub OK. GitHub Pages will rebuild in ~1-2 min."
  } else {
    Log ("ERROR: git push failed (exit " + $LASTEXITCODE + ")")
    exit 1
  }
}
catch {
  Log ("ERROR: " + $_.Exception.Message)
  exit 1
}
