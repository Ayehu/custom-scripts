# ngmanage.ps1
# Usage: ngmanage.ps1 <start|stop|restart>
# 
# Derek Pascarella <derekp@ayehu.com>
# Ayehu, Inc.
#
# Simple commandline tool to start, stop, or restart the Ayehu NG Manager service and all of its child processes.

# Define our operation mode.
$mode = $args[0]

# Perform a service restart by stopping the Ayehu NG Manager service, killing all child processes, and then starting the Ayehu NG
# Manager service again.
if($mode -eq "restart")
{
    Get-Service "Ayehu NG Manager"
    Start-Sleep -Seconds 2
    Stop-Service "Ayehu NG Manager"
    Start-Sleep -Seconds 1
    taskkill /F /FI "imagename eq eyeShare*"
    Start-Service "Ayehu NG Manager"
    Get-Service "Ayehu NG Manager";
    Start-Sleep -Seconds 2
    Get-Process | findstr "eyeShare*"
}
# Stop the Ayehu NG Manager service and then kill all child processes.
elseif($mode -eq "stop")
{
    Get-Service "Ayehu NG Manager"
    Start-Sleep -Seconds 2
    Stop-Service "Ayehu NG Manager"
    taskkill /F /FI "imagename eq eyeShare*"
}
# Start the Ayehu NG Manager service.
elseif($mode -eq "start")
{
    Start-Service "Ayehu NG Manager"
    Get-Service "Ayehu NG Manager";
    Start-Sleep -Seconds 2
    Get-Process | findstr "eyeShare*"
}
# Print an error because no valid operation mode was given.
else
{
    Write-Host "Must provide a valid option."
    Write-Host "Usage: ngmanage <start|stop|restart>"
}
