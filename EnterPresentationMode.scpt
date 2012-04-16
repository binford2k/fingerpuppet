-- Simple and ugly as hell script to make a Mac more usable for presentations

-- disable screensaver
tell application "System Events" to tell screen saver preferences to set delay interval to 0

-- use pmset to disable sleep
do shell script "sudo pmset -c displaysleep 0 sleep 0" password "<password>" with administrator privileges

-- disable iCal alerts
tell application "iCal" to activate
  tell application "System Events" to tell process "iCal"
    click menu item 3 of menu 1 of menu bar item 2 of menu bar 1
    click button 3 of tool bar 1 of window 1

    if value of checkbox 1 of window 1 = 0 then
      click checkbox 1 of window 1
    end if

    click menu item 10 of menu 1 of menu bar item 3 of menu bar 1
  end tell
tell application "iCal" to quit

-- kill some noisy apps
tell application "iCal" to quit
tell application "Mail" to quit
tell application "Twitter" to quit
tell application "iTunes" to quit

