# My First PowerShell Script in Git!
# Author: Stanley Zhu
# Date: 2026-05-02

Write-Host "Hello from Git + GitHub + PowerShell!" -ForegroundColor Cyan
Write-Host "Computer : $env:COMPUTERNAME" -ForegroundColor Yellow
Write-Host "User     : $env:USERNAME" -ForegroundColor Green
Write-Host "Time     : $(Get-Date)" -ForegroundColor Magenta

Write-Host "`nTop 3 Memory Hogs:" -ForegroundColor Red
Get-Process | Sort-Object WorkingSet -Descending |
    Select-Object -First 3 Name, @{N='MemoryMB';E={[math]::Round($_.WorkingSet/1MB,1)}}