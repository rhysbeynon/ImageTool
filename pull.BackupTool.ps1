# Description: This script pulls backups from the source to the destination.

#Config File Import
. "$PSScriptRoot\config.ps1"

if ($useHeader) {
    . "$PSScriptRoot\header.ps1"
}

#Script Timer
$elapsedTime = Measure-Command{
    # Check if the script should run
    if ($scriptLock) {
        Write-Host "Scripts are locked. Please check readme.md for more information."
        return
    }
    
    #Import Variables
    $updatedLines = @() #this is for writing to salonOutcome

    #Create new log file

    #logging logic
    Write-Host "Log>" $logFilePullBackup
    New-Item $logFilePullBackup -type file
    New-Item $logFilePullErrorBackup -type file         

    ###Image resize, sync, and log###
    $header = Get-Content -Path $computerListFile -TotalCount 1
    $notHeader = Get-Content $computerListFile | Select-Object -Skip 1

    $todaysDate = Get-Date -Format "ddMMyyyy_HHmmss"

    $notHeader | ForEach-Object {
        #Set salon variables
        $parts = $_ -split ','    #split id and name (comma separated)
        $salonId = $parts[0].Trim()
        $salonName = $parts[1].Trim()
        $pullOutcome = $parts[2].Trim()
        $pushOutcome = $parts[3].Trim()
        $salonLocked = $parts[4].Trim() #This is changed on every loop depending on prior operation

        # Set salon short code for backup folders
            $SalonCode = $SalonName -replace '^salon-|-(2|3|4|5|6|7|8|9|NEW)$'

        Write-Host $salonName ":" -NoNewLine

        #####################################################################################

        #Config File Import Again
        . "$PSScriptRoot\config.ps1"

        if ($salonLocked -eq "1") {
            Write-Host "Salon is locked. Please check readme.md for more information."
            return
        }

        Write-Host "Pulling backup files from:" $salonName "..."

        try {
            Get-ChildItem $backupSource -ErrorAction Stop
            #copy procedure runs if no catches are present
            $robocopyBackupOutput = robocopy $backupSource $BackupDestination /XN /E /COMPRESS /MT:128 /NJH /NFL /NP /LOG+:$logFilePullBackup
        } catch [System.UnauthorizedAccessException] {
            Write-Host "$($_.TargetObject): Access denied"
            Add-Content $logFilePullErrorBackup "$($_.TargetObject): Access denied"
        } catch [System.Management.Automation.ItemNotFoundException] {
            Write-Host "$($_.TargetObject): Path not found"
            Add-Content $logFilePullErrorBackup "$($_.TargetObject): Path not found"
        }

         if ($robocopyBackupOutput -match '^\s*Bytes : 0 ') {
        Write-Host "Robocopy copied 0 items."
        Add-Content $logFilePullErrorBackup "Robocopy copied 0 items."
        }

        Write-Host $salonName ":" -NoNewLine
        Write-Host "...Done."
    }
}

#deletes empty log files
$filesToDelete = Get-ChildItem -Path $logFilePullBackupLocation | Where-Object { $_.Length -eq 0KB }
$filesToDelete | Remove-Item -Force

#Writes elapsed time to console
Write-Host "Pull:Total elapsed time: $($elapsedTime.TotalMilliseconds) Milliseconds or $($elapsedTime.TotalMinutes) Minutes"
