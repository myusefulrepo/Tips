$BuildNumber = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\').currentbuildnumber

# Windows 10 release history. Source : https://docs.microsoft.com/en-us/windows/release-health/release-information
switch ($BuildNumber)
{
    10240
    {
        Write-Host 'Windows 10 - 1507 - RTM - End of Servicing - Extended support 14/10/2025' -ForegroundColor Green
    }
    10586
    {
        Write-Host 'Windows 10 - 1511 - End of Servicing' -ForegroundColor Green
    }
    14393
    {
        Write-Host 'Windows 10 - 1607 - End of Servicing -Extended support 13/10/2026' -ForegroundColor Green
    }
    15063
    {
        Write-Host 'Windows 10 - 1703 - End of servicing' -ForegroundColor Green
    }
    16299
    {
        Write-Host 'Windows 10 - 1709 - End of Servicing' -ForegroundColor Green
    }
    17134
    {
        Write-Host 'Windows 10 - 1803 - End of Servicing' -ForegroundColor Green
    }
    17763
    {
        Write-Host 'Windows 10 - 1809 - End of Servicing - Extended support 09/01/2029' -ForegroundColor Green
    }
    18362
    {
        Write-Host 'Windows 10 - 1903 - End of Servicing' -ForegroundColor Green
    }
    18363
    {
        Write-Host 'Windows 10 - 1909' -ForegroundColor Green
    }
    19041
    {
        Write-Host 'Windows 10 - 2004 - End of Servicing' -ForegroundColor Green
    }
    19042
    {
        Write-Host 'Windows 10 - 20H2' -ForegroundColor Green
    }
    19043
    {
        Write-Host 'Windows 10 - 21H1' -ForegroundColor Green
    }
    19044
    {
        Write-Host 'Windows 10 - 21H2' -ForegroundColor Green
    }
    19045
    {
        Write-Host 'Windows 10 - 22H2' -ForegroundColor Green
    }
    22000
    {
        Write-Host 'Windows 11 - 21H2' -ForegroundColor Green
    }
    22621
    {
        Write-Host 'Windows 11 - 22H2' -ForegroundColor Green
    }
    22631
    {
        Write-Host 'Windows 11 - 23H2' -ForegroundColor Green
    }
    Default
    {
        Write-Host 'unable to determine the release off of the build number ' -ForegroundColor Green
    }
}
