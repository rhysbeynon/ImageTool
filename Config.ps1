$scriptLock = $false

$minSizeKB = 128

$resolution = "640x480"

$computerListFile = "\\networkdrive\scripts\test.salon_list.csv"

$logFile = "E:\Software\Scripts\log_img_" + $todaysDate + ".txt"

$source = "\\"  + $salonName + "images\" + $salonId + "\"

$destination = "\\networkdrive\images\" + $salonId + "\"