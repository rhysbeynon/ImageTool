# Description: This script pulls images from the source to the destination.

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
    Write-Host "Log>" $logFilePull
    $logFilePushConstant = New-Item $logFilePull -type file


    ###Image resize, sync, and log###
    $header = Get-Content -Path $computerListFile -TotalCount 1
    $notHeader = Get-Content $computerListFile | Select-Object -Skip 1

    $notHeader | ForEach-Object {
        #Set salon variables
        $parts = $_ -split ','    #split id and name (comma separated)
        $salonId = $parts[0].Trim()
        $salonName = $parts[1].Trim()
        $pullOutcome = $parts[2].Trim()
        $pushOutcome = $parts[3].Trim()
        $salonLocked = $parts[4].Trim() #This is changed on every loop depending on prior operation

        Write-Host $salonName ":" -NoNewLine

        #####################################################################################

        #Config File Import Again
        . "$PSScriptRoot\config.ps1"

        if ($salonLocked -eq "1") {
            Write-Host "Salon is locked. Please check readme.md for more information."
            $pushOutcome = 1
            $updatedLine = "$salonId,$salonName,$pullOutcome,$pushOutcome,$salonLocked"
            $updatedLines += $updatedLine
            return
        }

        Write-Host "Pushing images to:" $salonName "..."

        #Temporary salonOutcome value. Assumes success until error occurs (0 = success 1 = fail)
        $pushOutcome = 0

        try {
            Get-ChildItem $source -ErrorAction Stop
            #copy procedure runs if no catches are present
            robocopy $pushSource $pushDestination /MT:128 /MAXAGE:14 /XO /E /NP /NFL /NJH /R:2 /w:1 /LOG+:$logFilePushConstant
        } catch [System.UnauthorizedAccessException] {
            Write-Host "$($_.TargetObject): Access denied"
            Add-Content $logFilePush "$($_.TargetObject): Access denied"
            #sets outcome to 1 if operation fails
            $pushOutcome = 1
        } catch [System.Management.Automation.ItemNotFoundException] {
            Write-Host "$($_.TargetObject): Path not found"
            Add-Content $logFilePush "$($_.TargetObject): Path not found"
            #sets outcome to 1 if operation fails
            $pushOutcome = 1
        }

        #Constructs the updated line with the new outcome
        $updatedLine = "$salonId,$salonName,$pullOutcome,$pushOutcome,$salonLocked"
        $updatedLines += $updatedLine

        Write-Host $salonName ":" -NoNewLine
        Write-Host "...Done."
    }

    #writes to the CSV record AFTER loop for safety
    Set-Content -Path $computerListFile -Value $header
    Add-Content -Path $computerListFile -Value $updatedLines

    #####################################################################################

}

Write-Host "Push:Total elapsed time: $($elapsedTime.TotalMilliseconds) Milliseconds or $($elapsedTime.TotalMinutes) Minutes"
