$processes = Get-Process -Name "chrome"
$results = foreach ($process in $processes) {
    [PSCustomObject]@{
          name      = $process.Name
         Version    = $process.MainModule.FileVersion
    }
}
$results | Export-Csv -path "chrome.csv"
