$scriptLock = $false

$verboseMode = "1"

$minSizeKB = 512

$resolution = "640:-1"

$computerListFile = "\\lextandc01\backup\Scripts\salon_list.csv"

$logFile = "\\lextandc01\backup\log\log_img_" + $todaysDate + ".txt"

$source = "\\"  + $salonName + "\database\images\" + $salonId + "\"

$destination = "\\lextandc01\backup\images\" + $salonId + "\"