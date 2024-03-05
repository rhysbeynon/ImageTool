$scriptLock = $false

$verboseMode = $true

$useHeader = $true

$minSizeKB = 128

$resolution = "640:-1"

$computerListFile = ".\salon_list.csv"


 
#logging logic
    $logFilePull = "\\leC:\LogLocation\pull.log\log_img_" + $todaysDate + ".txt"
    $logFilePullError = "C:\LogLocation\log\pull.log\ERROR.log_img_" + $todaysDate + ".txt"
    $logFileSize = "C:\LogLocation\log\size.log\log_img_" + $todaysDate + ".txt"
    $logFileSizeError = "C:\LogLocation\log\size.log\ERROR.log_img_" + $todaysDate + ".txt"
    $logFilePush = "C:\LogLocation\log\push.log\log_img_" + $todaysDate + ".txt"
    $logFilePushError = "C:\LogLocation\log\push.log\ERROR.log_img_" + $todaysDate + ".txt"

$source = "\\" + $salonName + "\database\images\" + $salonId + "\\"

$destination = "C:\ImageLocation\images\" + $salonId + "\\"

$pushSource = "C:\ImageLocation\Images"

$pushDestination = "\\" + $salonName + "\database\images"

$spinnerArray = @("_", "_", "_","_", "_", "_","_", "_", "_","_", "_", 
                "_","_", "_", "_","_", "_", "_","_", "_", "_","_", "_", "_", "-", "-",
                "-", "-", "-", "-", "-", "-", "``", "``", "``", "``", "``", "``", "``",
                "``", "``", "``", "``", "``", "``", "``", "``", "``", "'", "'", "'", 
                "'", "'", "'", "'", "'", $0x00B4, $0x00B4, $0x00B4, $0x00B4, $0x00B4, 
                $0x00B4, $0x00B4, $0x00B4, "-", "-", "-", "-", "-", "-", "-", "-", "_",
                "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", 
                "_", "_", "_", "_", "_", "_", "_", "_", "_")
