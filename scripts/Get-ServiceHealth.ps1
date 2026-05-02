# Service Health Check
# Author: Stanley Zhu
# What this script does:
# Checks if key Windows services are running or stopped
# Shows a clear status for each service with color coding

function Get-ServiceHealth {

    # param() = parameter block
    # Lets the user pass in their own list of services
    # If they don't pass anything, use these 4 defaults
    param(
        [string[]]$ServiceNames = @(
            "Spooler",   # Print Spooler - handles printing
            "WinRM",     # Windows Remote Management - needed for PowerShell remoting
            "W32Time",   # Windows Time - keeps clock in sync (critical for Kerberos!)
            "Dnscache"   # DNS Client - caches DNS lookups for speed
        )
    )

    # Print header
    Write-Host ""
    Write-Host "SERVICE HEALTH CHECK" -ForegroundColor Cyan
    Write-Host ("=" * 40) -ForegroundColor Cyan

    # Loop through each service name one by one
    # $name = current service name being checked
    foreach ($name in $ServiceNames) {

        # try = attempt this, if it fails go to catch
        # Like a safety net - script won't crash if service not found
        try {

            # Get the service info from Windows
            # -ErrorAction Stop = if not found, jump to catch block
            $svc = Get-Service -Name $name -ErrorAction Stop

            # Decide color based on service status
            # Running = Green (good!)
            # Anything else = Red (problem!)
            if ($svc.Status -eq 'Running') {
                $color  = "Green"
                $icon   = "[OK]"
                $status = "Running"
            }
            else {
                $color  = "Red"
                $icon   = "[!!]"
                $status = "STOPPED"
            }

            # Print the result
            # $svc.DisplayName = the friendly name (e.g. "Print Spooler")
            # $svc.Status = current state (Running/Stopped)
            Write-Host "$icon $($svc.DisplayName): $status" -ForegroundColor $color

        }
        catch {

            # If Get-Service failed (service doesn't exist on this machine)
            # Print a warning in yellow - not critical, just informational
            Write-Host "[??] $name : Not found on this machine" -ForegroundColor Yellow

        }
    }

    # Blank line at the end for clean spacing
    Write-Host ""
}

# This line CALLS the function - without it nothing runs!
Get-ServiceHealth