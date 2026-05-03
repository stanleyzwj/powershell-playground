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

# Checks all disk drives and shows how much space is used/free
# Color coded: Green = healthy, Yellow = getting full, Red = danger!

function Get-DiskReport {

    # Print the title header
    # ("=" * 40) = repeat "=" 40 times to make a divider line
    Write-Host ""
    Write-Host "DISK SPACE REPORT" -ForegroundColor Cyan
    Write-Host ("=" * 40) -ForegroundColor Cyan

    # Get all disk drives that are real file system drives
    # -PSProvider FileSystem = only get actual disk drives (not registry etc)
    # Where-Object { $_.Used -gt 0 } = skip empty/unmounted drives
    # ForEach-Object = process each drive one by one
    Get-PSDrive -PSProvider FileSystem |
        Where-Object { $_.Used -gt 0 } |
        ForEach-Object {

            # Convert bytes to GB, rounded to 1 decimal place
            # $_.Used = bytes used on this drive
            # / 1GB = divide by 1,073,741,824 to get gigabytes
            $usedGB  = [math]::Round($_.Used / 1GB, 1)

            # $_.Free = bytes free on this drive
            $freeGB  = [math]::Round($_.Free / 1GB, 1)

            # Total = used + free
            $totalGB = $usedGB + $freeGB

            # Calculate percentage used
            # e.g. 53.6 / 64.0 * 100 = 83.75, rounded to 84
            $usedPct = [math]::Round($usedGB / $totalGB * 100, 0)

            # Decide color based on how full the drive is
            # Like a traffic light system
            if ($usedPct -gt 90) {
                $color  = "Red"      # DANGER - almost full!
                $status = "WARNING - Almost Full!"
            }
            elseif ($usedPct -gt 70) {
                $color  = "Yellow"   # Caution - getting full
                $status = "Caution - Getting Full"
            }
            else {
                $color  = "Green"    # Healthy - plenty of space
                $status = "Healthy"
            }

            # Print drive name (e.g. "Drive C:")
            # -NoNewline means don't go to next line yet
            Write-Host "Drive $($_.Name): " -NoNewline -ForegroundColor White

            # Print the space details in the chosen color
            # e.g. "199.5 GB free of 254.7 GB (22% used) - Healthy"
            Write-Host "$freeGB GB free of $totalGB GB ($usedPct% used) - $status" -ForegroundColor $color
        }

    # Print a blank line at the end for spacing
    Write-Host ""
}

# This line actually RUNS the function
# Without this line, the function is defined but never executed
Get-DiskReport
