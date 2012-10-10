-- Simple and ugly as hell script to make a Mac more usable for presentations

on enable()
	try
		-- disable screensaver
		tell application "System Events" to tell screen saver preferences to set delay interval to 0
	end try
	
	try
		-- disable sleep
		do shell script "caffeinate > /dev/null 2>&1 &"
	end try
	
	try
		-- why is growl so slow?
		tell application id "com.Growl.GrowlHelperApp" to pause
	end try
	
	try
		-- kill some noisy apps
		--tell application "Calendar" to quit
		--tell application "Mail" to quit
		--tell application "Twitter" to quit
		tell application "iTunes" to quit
	end try
	
	-- Mountain Lion should pause Notification Center messages when on external display...
	display dialog "Presentation Mode Enabled" buttons {"OK"}
end enable

on disable()
	try
		-- enable screensaver, 1 min interval
		tell application "System Events" to tell screen saver preferences to set delay interval to 60
	end try
	
	try
		-- enable sleep
		do shell script "killall caffeinate"
	end try
	
	try
		-- growl is slow as...
		tell application id "com.Growl.GrowlHelperApp" to resume
	end try
	
	-- disable iCal alerts
	-- Mountain Lion handles notifications better, so this is no longer needed
	
	display dialog "Presentation Mode Disabled" buttons {"OK"}
end disable

-- main program
tell application "System Events"
	tell screen saver preferences
		set presentationMode to (delay interval = 0)
		
		if presentationMode then
			set answer to the button returned of (display dialog "Presentation mode currently enabled" with icon caution buttons {"Cancel", "Enable Again", "Disable"} default button 3)
		else
			set answer to the button returned of (display dialog "Presentation mode currently disabled" with icon note buttons {"Cancel", "Disable Again", "Enable"} default button 3)
		end if
		
		if {"Enable", "Enable Again"} contains answer then
			my enable()
		else if {"Disable", "Disable Again"} contains answer then
			my disable()
		end if
		
	end tell
end tell


