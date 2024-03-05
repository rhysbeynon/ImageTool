# Lextan Image Tool
Image tool for Resizing images and backing them up to a central destination.  
  
  Version 1.0  

  *Created 31/01/2024 RB/NR*

## Table of Contents
- [Usage](#usage)
- [Acknowledgements](#acknowledgements)

## Usage  
*Before running the script, check that "$scriptlock" on line 14 is set to false.*  
This script has a built-in lock mechanic that will prevent accidental execution when transfering or  editing in an IDE. The script will tell you if it is locked after running.  
Make sure this is set to "false"  
There is also a lock for the individual salon. This is for specifically blacklisting salons from being included in the script if they are under maintainence, deprecated, etc. This is the 4th column in the salon list. 0 = Not Locked - 1 = Locked and will not attempt any operation.

"ScriptFailed" will not be flipped to "1" if the salon is locked. It will remain whatever value it was previously regardless of the outcome.

Each frame of the loading spinner is a new image thats been proccessed. If the spinner stops, that may just mean 1 image is taking longer than expected. Use proper judgement before force quitting the CLI.  
Force-exiting the script while its running is generally not advised but testing has not since shown that FFPMEG leaves images corrupted. Since the image is retrieved, stored in memory, processed, and then rewritten, its safe to say that partial image corruption is highly unlikely.
  
*ffmpeg.exe must be placed in the root folder*  
Most FFMPEG versions after 2007 should work but we recommend version 6.1.1 or higher as that is the version used  
when writing this script.  
Ffmpeg.exe is licensed under LGPL license and GPL General License, and is provided alongside this script.   

  
## Acknowledgements  
https://ffmpeg.org/  
https://www.gnu.org/licenses/old-licenses/lgpl-2.1.en.html#SEC1


