-- Read a Mail message for engagement invitations and create related reminders
-- Currently depends on Kate following the same format for invitation subjects

using terms from application "Mail"
	on perform mail action with messages theMessages for rule theRule
		tell application "Mail"
			repeat with eachMessage in theMessages
				set theSubject to subject of eachMessage
				set theUrl to "message:%3C" & message id of eachMessage & "%3E"
				
				my setReminder(theSubject, theUrl)
			end repeat
		end tell
	end perform mail action with messages
	
	on run
		display dialog "Setting Engagement Reminders"
		tell application "Mail"
			set theMessages to selection
			repeat with eachMessage in theMessages
				set theSubject to subject of eachMessage
				set theUrl to "message:%3C" & message id of eachMessage & "%3E"
				
				my setReminder(theSubject, theUrl)
			end repeat
		end tell
	end run
end using terms from


-- helper functions
on explode(delimiter, input)
	local delimiter, input, ASTID
	set ASTID to AppleScript's text item delimiters
	try
		set AppleScript's text item delimiters to delimiter
		set input to text items of input
		set AppleScript's text item delimiters to ASTID
		return input --> list on error eMsg number eNum
		set AppleScript's text item delimiters to ASTID
		error "Can't explode: " & eMsg number eNum
	end try
end explode

on setReminder(theSubject, theUrl)
	-- All this text manipulation is really gross, but … I don't see a better way of doing it with applescript
	set working to my explode("-", theSubject)
	set check to item 1 of working
	set theSubject to item 2 of working
	
	-- exit script if not new invitation
	if check is not "Invitation: Ben " then
		return check
	end if
	
	--check for end date
	try
		set theDate to date (item 3 of working)
	on error
		set theDate to false
	end try
	
	--get the Subject and the starting date
	set working to my explode("@", theSubject)
	set theSubject to item 1 of working
	
	if theSubject is " No Travel " then
		return theSubject
	end if
	
	--get the ending date if not already set
	if theDate is false then
		set theDate to item 2 of working
		set theDate to my explode("(", theDate)
		set theDate to date (item 1 of theDate)
	end if
	
	--get the short description
	set working to my explode("(", theSubject)
	set theShort to item 1 of working
	try
		set theShort to text 2 thru 15 of theShort & "… "
	end try
	
	set theReservationDate to theDate - (14 * days)
	set theReportsDate to theDate + (2 * days)
	
	tell application "Reminders"
		make new list with properties {name:theSubject}
		tell list theSubject
			--make new reminder with properties {name:theSubject, body:theUrl, due date:theDate}
			make new reminder with properties {name:"Plane Tickets", due date:theReservationDate, remind me date:theReservationDate}
			make new reminder with properties {name:"Car Rental", due date:theReservationDate, remind me date:theReservationDate}
			make new reminder with properties {name:"Hotel Reservation", due date:theReservationDate, remind me date:theReservationDate}
			make new reminder with properties {name:"Trip Report", due date:theReportsDate}
			make new reminder with properties {name:"Expense Report", due date:theReportsDate}
			make new reminder with properties {name:"Time Sheet", due date:theReportsDate}
		end tell
	end tell
end setReminder