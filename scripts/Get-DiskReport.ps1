# Disk Space Report
# Author: Stanley Zhu
# What this script does:
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