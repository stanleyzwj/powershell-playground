function Test-MyEnvironment {
    # ── Section 1: Print a title banner ──────────────────────────────────────
    # Write-Host lets us pick a foreground color. Cyan stands out as a header.
    Write-Host ""
    Write-Host "===== Environment Check =====" -ForegroundColor Cyan
    Write-Host ""

    # ── Section 2: PowerShell version and edition ────────────────────────────
    # $PSVersionTable is a built-in hashtable that PowerShell always populates.
    # PSVersion holds the full version object; PSEdition is "Desktop" or "Core".
    Write-Host "PowerShell Version:" -ForegroundColor Cyan
    Write-Host "  Version : $($PSVersionTable.PSVersion)" -ForegroundColor Yellow
    Write-Host "  Edition : $($PSVersionTable.PSEdition)"  -ForegroundColor Yellow
    Write-Host ""

    # ── Section 3: Current user ───────────────────────────────────────────────
    # $env:USERNAME is an environment variable Windows sets automatically when
    # a user logs in — no extra commands needed.
    Write-Host "Current User:" -ForegroundColor Cyan
    Write-Host "  $env:USERNAME" -ForegroundColor Yellow
    Write-Host ""

    # ── Section 4: Computer name ──────────────────────────────────────────────
    # $env:COMPUTERNAME is another Windows environment variable that holds the
    # machine's hostname (the name you see in File Explorer / System settings).
    Write-Host "Computer Name:" -ForegroundColor Cyan
    Write-Host "  $env:COMPUTERNAME" -ForegroundColor Yellow
    Write-Host ""

    # ── Section 5: Working directory ──────────────────────────────────────────
    # Get-Location returns the current directory path, the same as `pwd` on
    # Unix. We call .Path to get the plain string instead of the full object.
    Write-Host "Working Directory:" -ForegroundColor Cyan
    Write-Host "  $(( Get-Location ).Path)" -ForegroundColor Yellow
    Write-Host ""

    # ── Section 6: Check whether Git is installed ────────────────────────────
    # We run `git --version` and capture stderr+stdout. If the command fails
    # (git not found), $LASTEXITCODE will be non-zero, so we show a warning.
    # 2>&1 merges stderr into stdout so we can capture any error message too.
    Write-Host "Git Installation:" -ForegroundColor Cyan
    $gitOutput = git --version 2>&1

    if ($LASTEXITCODE -eq 0) {
        # Git responded normally — show the version string in green to signal "all good".
        Write-Host "  [OK] $gitOutput" -ForegroundColor Green
    } else {
        # git command failed or was not found — warn the user in red.
        Write-Host "  [NOT FOUND] Git does not appear to be installed or is not in PATH." -ForegroundColor Red
    }

    Write-Host ""
    Write-Host "===== Check Complete =====" -ForegroundColor Cyan
    Write-Host ""
}

# ── Auto-invoke ───────────────────────────────────────────────────────────────
# Calling the function here means running the script executes the check
# immediately, without the caller having to type anything extra.
Test-MyEnvironment
# ────────────────────────────────────────────
# BUGGY CODE FOR CLAUDE TO FIX
# ────────────────────────────────────────────
function Get-BadDiskInfo {
    Get-PSDrive |
        Where-Object { $_.Used -gt 0 } |
        ForEach-Object { Write-Host $_.Name }
}

Get-BadDiskInfo