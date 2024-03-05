#initialization
#Config File Import
. "$PSScriptRoot\config.ps1"

if ($verboseMode -eq "1") {
    . "$PSScriptRoot\header.ps1"
}



# [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

#Script Timer
$elapsedTime = Measure-Command{


    # Check if the script should run
    if ($scriptLock) {
    Write-Host "Script is locked. Please check readme.md for more information."
    return
    }
    
 #Import Variables
 $todaysDate = Get-Date -Format("yyyyMMdd_Hmmss")
 $updatedLines = @() #this is for writing to salonOutcome
 
 #Create new log file
 Write-Host "Log>" $logFile
 New-Item $logFile -type file
 

 ###Image resize, sync, and log###
 $header = Get-Content -Path $computerListFile -TotalCount 1
 $notHeader = Get-Content $computerListFile | Select-Object -Skip 1

 $notHeader | ForEach-Object {

    #Set salon variables
    $parts = $_ -split ','    #split id and name (comma seperated for CSV compatibility)
    $salonId = $parts[0].Trim()
    $salonName = $parts[1].Trim()
    $salonOutcome = $parts[2].Trim()
    $salonLocked = $parts[3].Trim() #This is changed on every loop depending on prior operation

    Write-Host $salonName ":" -NoNewLine

 #####################################################################################
 
         #Config File Import Again
        . "$PSScriptRoot\config.ps1"
             

        if ($salonLocked -eq "1") {
            Write-Host "Salon is locked. Please check readme.md for more information."
            $outcome = 1
            $updatedLine = "$salonId,$salonName,$outcome,$salonLocked"
            $updatedLines += $updatedLine
            return
            }

$0x00B4 = [char]0x00B4
$spinnerArray =   @("_",
                    "_",
                    "_",
                    "-",
                    "``",
                    "``",
                    "'",
                    $0x00B4,
                    "-",
                    "_",
                    "_",
                    "_")

$spinner

$spinnerIndex = 0
write-host ""
 #resizer
 Get-ChildItem -Path $source -Filter *.jpg | ForEach-Object {
    $fileSizeKB = (Get-Item $_.FullName).Length / 1KB
    if ($fileSizeKB -gt $minSizeKB) {
       & "$PSScriptRoot\ffmpeg.exe" -loglevel error -y -i $_.FullName -vf "scale=$resolution" $_.FullName
    }

    $spinner = $spinnerArray[$spinnerIndex++ % $spinnerArray.Length]
    Write-Host -NoNewline "`r$spinner"

    Start-Sleep -Milliseconds 100 # Delay to make the spinner visible
 }
 Write-Host -NoNewline "`r "
 Write-Host "Image processing complete. Backup Up images..."
 
 #####################################################################################
 
    #Temporary salonOutcome value. Assumes success until error occurs (0 = success 1 = fail)
    $outcome = 0
 
 
    try {
        Get-ChildItem $source -ErrorAction Stop
        #copy procedure runs if no catches are present
            robocopy $source $destination /XO /E /NP /NFL /NJH /LOG+:$logFile
        } catch [System.UnauthorizedAccessException] {
            Write-Host "$($_.TargetObject): Access denied"
            Add-Content $logFile "$($_.TargetObject): Access denied"
        #sets outcome to 1 if operation fails
            $outcome = 1
        } catch [System.Management.Automation.ItemNotFoundException] {
            Write-Host "$($_.TargetObject): Path not found"
            Add-Content $logFile "$($_.TargetObject): Path not found"
        #sets outcome to 1 if operation fails
            $outcome = 1
        }
 
         #Constructs the updated line with the new outcome
         $updatedLine = "$salonId,$salonName,$outcome,$salonLocked"
         $updatedLines += $updatedLine


          Write-Host "...Done."
 }


 #writes to the CSV record AFTER loop for safety
 Set-Content -Path $computerListFile -Value $header
 Add-Content -Path $computerListFile -Value $updatedLines
 
 #####################################################################################
 
 }
 
 Write-Host "Total elapsed time: $($elapsedTime.TotalMilliseconds) Milliseconds or $($elapsedTime.TotalMinutes) Minutes"