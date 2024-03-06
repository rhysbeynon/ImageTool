# Description: This script resizes images in the central folder.
$todaysDate = Get-Date -Format "dd/MM/yyyy.HH:mm:ss"
# Config File Import
. "$PSScriptRoot\config.ps1"

if ($useHeader -eq "1") {
    . "$PSScriptRoot\header.ps1"
}

# Script Timer
$elapsedTime = Measure-Command {
    # Check if the script should run
    if ($scriptLock) {
        Write-Host "Scripts are locked. Please check readme.md for more information."
        return
    }

    # Import Variables
    $updatedLines = @() # This is for writing to salonOutcome

    # Create new log file
     Write-Host "Log>" $logFilePull
    New-Item $logFilePull -type file

    # Retrieve salon information from the CSV file
    $header = Get-Content -Path $computerListFile -TotalCount 1
    $notHeader = Get-Content $computerListFile | Select-Object -Skip 1

    $notHeader | ForEach-Object {
        # Set salon variables
        $parts = $_ -split ','    # Split id and name (comma separated)
        $salonId = $parts[0].Trim()
        $salonName = $parts[1].Trim()
        $pullOutcome = $parts[2].Trim()
        $pushOutcome = $parts[3].Trim()
        $salonLocked = $parts[4].Trim() # This is changed on every loop depending on prior operation

        # Config File Import Again
        . "$PSScriptRoot\config.ps1"

        if ($salonLocked -eq "1") {
            Write-Host "Salon is locked. Please check readme.md for more information."
            $outcome = 1
            $updatedLine = "$salonId,$salonName,$outcome,$salonLocked"
            $updatedLines += $updatedLine
            return
        }

        $0x00B4 = [char]0x00B4
        $spinnerArray
        $spinnerIndex = 0
        Write-Host ""

        # Resizer
        Get-ChildItem -Path $destination -Filter *.jpg | ForEach-Object {
            $fileSizeKB = (Get-Item $_.FullName).Length / 1KB
            $lastAccessed = (Get-Item $_.FullName).LastAccessTime
            #if ($fileSizeKB -gt $minSizeKB -and ($currentDate - $lastAccessed).TotalDays -lt 5) {
            if ($fileSizeKB -gt $minSizeKB) {
                & "$PSScriptRoot\ffmpeg.exe" -loglevel error -y -i $_.FullName -vf "scale=$resolution" $_.FullName
            }

            $spinner = $spinnerArray[$spinnerIndex++ % $spinnerArray.Length]
            Write-Host -NoNewline "`r $spinner"
        }

        Write-Host $salonName ":" -NoNewLine
        Write-Host "Image processing complete."
    }
}

Write-Host "Size:Total elapsed time: $($elapsedTime.TotalMilliseconds) Milliseconds or $($elapsedTime.TotalMinutes) Minutes"
