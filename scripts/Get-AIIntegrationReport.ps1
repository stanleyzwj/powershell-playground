# [CmdletBinding()] at the SCRIPT level makes the script itself an advanced script.
# This lets -Verbose passed to the script flow through to the function call below.
[CmdletBinding()]
param()

function Get-AIIntegrationReport {

    # ── [CmdletBinding()] — what does this do? ────────────────────────────────
    # Adding this one line turns a plain function into an "advanced function".
    # It unlocks built-in PowerShell switches for free, with no extra code:
    #   -Verbose  → activates Write-Verbose lines (silent by default)
    #   -Debug    → activates Write-Debug lines
    #   -ErrorAction, -WhatIf, and more...
    # Without [CmdletBinding()], -Verbose is just ignored.
    [CmdletBinding()]
    param()

    Write-Verbose "Starting Get-AIIntegrationReport..."

    # ── What is a List? ───────────────────────────────────────────────────────
    # [System.Collections.Generic.List[PSCustomObject]] is a resizable array.
    # Better than @() += in a loop because += copies the whole array each time;
    # .Add() just appends — much faster for many rows.
    $rows = [System.Collections.Generic.List[PSCustomObject]]::new()

    # ── Status values we use for color-coding ─────────────────────────────────
    # Each row gets one of these four Status labels.
    # The display section at the bottom maps them to colors.
    #   Info    → Cyan   (neutral facts: version numbers, config values)
    #   Healthy → Green  (everything looks good)
    #   Warning → Yellow (something needs attention but isn't broken)
    #   Error   → Red    (something failed or is missing)

    # ── Section 1: PowerShell Version ────────────────────────────────────────
    Write-Verbose "Collecting PowerShell version info..."

    $rows.Add([PSCustomObject]@{
        Category = "PowerShell"
        Item     = "Version"
        Value    = $PSVersionTable.PSVersion.ToString()
        Status   = "Info"
    })
    $rows.Add([PSCustomObject]@{
        Category = "PowerShell"
        Item     = "Edition"
        Value    = $PSVersionTable.PSEdition   # "Core" (PS 7+) or "Desktop" (PS 5)
        Status   = "Info"
    })

    Write-Verbose "  PS Version: $($PSVersionTable.PSVersion) ($($PSVersionTable.PSEdition))"

    # ── Section 2: Installed Modules ─────────────────────────────────────────
    # Get-Module -ListAvailable = scan every module installed on this machine,
    # not just the ones loaded in the current session.
    Write-Verbose "Counting installed modules (may take a moment)..."

    try {
        $moduleCount = (Get-Module -ListAvailable).Count
        $rows.Add([PSCustomObject]@{
            Category = "Modules"
            Item     = "Installed"
            Value    = "$moduleCount modules"
            Status   = "Info"
        })
        Write-Verbose "  Found $moduleCount modules"
    }
    catch {
        # $_.Exception.Message = the actual error text PowerShell gives us
        $rows.Add([PSCustomObject]@{
            Category = "Modules"
            Item     = "Installed"
            Value    = "Error: $($_.Exception.Message)"
            Status   = "Error"
        })
        Write-Verbose "  ERROR counting modules: $($_.Exception.Message)"
    }

    # ── Section 3a: Git user.name ─────────────────────────────────────────────
    # git config user.name reads the global Git identity.
    # 2>&1 merges stderr into stdout so error messages are captured too.
    # $LASTEXITCODE: 0 = success, non-0 = git missing or key not set.
    Write-Verbose "Reading Git user.name..."

    try {
        $gitName = git config user.name 2>&1
        $nameSet  = ($LASTEXITCODE -eq 0 -and $gitName)
        $rows.Add([PSCustomObject]@{
            Category = "Git Config"
            Item     = "user.name"
            Value    = if ($nameSet) { "$gitName" } else { "(not configured)" }
            Status   = if ($nameSet) { "Healthy" } else { "Warning" }
        })
        Write-Verbose "  user.name: $(if ($nameSet) { $gitName } else { 'not configured' })"
    }
    catch {
        $rows.Add([PSCustomObject]@{
            Category = "Git Config"
            Item     = "user.name"
            Value    = "Git not available"
            Status   = "Error"
        })
        Write-Verbose "  ERROR: Git not available"
    }

    # ── Section 3b: Git user.email ────────────────────────────────────────────
    # Separate try/catch so a failure here doesn't skip user.email.
    Write-Verbose "Reading Git user.email..."

    try {
        $gitEmail  = git config user.email 2>&1
        $emailSet  = ($LASTEXITCODE -eq 0 -and $gitEmail)
        $rows.Add([PSCustomObject]@{
            Category = "Git Config"
            Item     = "user.email"
            Value    = if ($emailSet) { "$gitEmail" } else { "(not configured)" }
            Status   = if ($emailSet) { "Healthy" } else { "Warning" }
        })
        Write-Verbose "  user.email: $(if ($emailSet) { $gitEmail } else { 'not configured' })"
    }
    catch {
        $rows.Add([PSCustomObject]@{
            Category = "Git Config"
            Item     = "user.email"
            Value    = "Git not available"
            Status   = "Error"
        })
        Write-Verbose "  ERROR: Git not available"
    }

    # ── Section 4: Git Repository Status ─────────────────────────────────────
    # git status --short = compact one-line-per-file output, e.g.:
    #   M  scripts/foo.ps1    ← modified
    #   ?? newfile.txt        ← untracked
    # Non-zero exit = not inside a git repo.
    # Empty output = working tree is clean.
    Write-Verbose "Checking git repository status..."

    try {
        $statusLines = git status --short 2>&1
        if ($LASTEXITCODE -ne 0) {
            $statusValue  = "Not a git repository"
            $statusHealth = "Warning"
        }
        elseif (-not $statusLines) {
            $statusValue  = "Clean — nothing to commit"
            $statusHealth = "Healthy"
        }
        else {
            # @() forces the result into an array even if it is a single string,
            # so .Count always returns a number instead of throwing.
            $changedCount = @($statusLines).Count
            $statusValue  = "$changedCount file(s) with uncommitted changes"
            $statusHealth = "Warning"
        }
        $rows.Add([PSCustomObject]@{
            Category = "Git Repo"
            Item     = "Status"
            Value    = $statusValue
            Status   = $statusHealth
        })
        Write-Verbose "  Repo status: $statusValue"
    }
    catch {
        $rows.Add([PSCustomObject]@{
            Category = "Git Repo"
            Item     = "Status"
            Value    = "Error: $($_.Exception.Message)"
            Status   = "Error"
        })
        Write-Verbose "  ERROR reading repo status: $($_.Exception.Message)"
    }

    # ── Section 5: Last 5 Commits ─────────────────────────────────────────────
    # git log --oneline -5 = one line per commit, newest first, max 5.
    # Each line looks like: "a6fbed5 Add ServiceHealth script"
    Write-Verbose "Reading last 5 commits from git log..."

    try {
        $logLines = git log --oneline -5 2>&1
        if ($LASTEXITCODE -ne 0) {
            $rows.Add([PSCustomObject]@{
                Category = "Git History"
                Item     = "Commits"
                Value    = "No commits yet or not a git repo"
                Status   = "Warning"
            })
            Write-Verbose "  No commit history found"
        }
        else {
            $counter = 1
            foreach ($line in $logLines) {
                if ($line.Trim()) {
                    $rows.Add([PSCustomObject]@{
                        Category = "Git History"
                        Item     = "Commit #$counter"
                        Value    = $line.Trim()
                        Status   = "Info"
                    })
                    Write-Verbose "  #$counter $($line.Trim())"
                    $counter++
                }
            }
        }
    }
    catch {
        $rows.Add([PSCustomObject]@{
            Category = "Git History"
            Item     = "Commits"
            Value    = "Error: $($_.Exception.Message)"
            Status   = "Error"
        })
        Write-Verbose "  ERROR reading git log: $($_.Exception.Message)"
    }

    Write-Verbose "Data collection complete. Returning $($rows.Count) rows."
    return $rows
}

# ── Helper: print one row with the right color ────────────────────────────────
# switch is like if/elseif but cleaner when matching one variable against many values.
# "{0,-15}" = left-align in a 15-character wide column (padding with spaces).
function Write-ReportRow ($row) {
    $color = switch ($row.Status) {
        "Healthy" { "Green"  }
        "Warning" { "Yellow" }
        "Error"   { "Red"    }
        default   { "Cyan"   }   # "Info" and anything else
    }
    Write-Host ("{0,-14} {1,-15} {2}" -f $row.Category, $row.Item, $row.Value) -ForegroundColor $color
}

# ── Auto-invoke ────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "===== AI INTEGRATION REPORT =====" -ForegroundColor Cyan
Write-Host ("=" * 50) -ForegroundColor Cyan
Write-Host ("{0,-14} {1,-15} {2}" -f "CATEGORY", "ITEM", "VALUE") -ForegroundColor White
Write-Host ("{0,-14} {1,-15} {2}" -f "--------", "----", "-----") -ForegroundColor DarkGray
Write-Host ""

# Collect data — pass -Verbose through if the script was called with -Verbose.
# $PSBoundParameters contains whatever flags the caller passed in.
# Using @PSBoundParameters "splatting" forwards them automatically.
$results = Get-AIIntegrationReport @PSBoundParameters

# Print each row with color
foreach ($row in $results) {
    Write-ReportRow $row
}

# ── CSV Export ─────────────────────────────────────────────────────────────────
# $PSScriptRoot = the folder this script lives in (scripts/)
# Join-Path builds a path safely regardless of trailing slashes.
# ".." goes up one level to the repo root, then into reports/.
$reportsDir = Join-Path $PSScriptRoot "..\reports"

# Test-Path checks if a folder/file exists — returns $true or $false.
# New-Item -ItemType Directory creates the folder.
# | Out-Null suppresses the "Directory created" message from cluttering output.
if (-not (Test-Path $reportsDir)) {
    New-Item -ItemType Directory -Path $reportsDir | Out-Null
    Write-Host ""
    Write-Host "  Created reports/ folder" -ForegroundColor DarkGray
}

# Get-Date -Format builds a timestamp string like "20260503_142301"
# Used in the filename so each run produces a new file instead of overwriting.
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$csvPath   = Join-Path $reportsDir "AIIntegrationReport_$timestamp.csv"

# Export-Csv writes the PSCustomObject list as a proper CSV.
#   -NoTypeInformation  = skip the ugly "#TYPE ..." header line Excel adds
#   -Encoding UTF8      = handle special characters (accented names, etc.)
$results | Select-Object Category, Item, Value, Status |
    Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

Write-Host ""
Write-Host "  Report saved: $csvPath" -ForegroundColor DarkGray
Write-Host ""
