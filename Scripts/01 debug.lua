
-- SM()
-- Shorthand for SCREENMAN:SystemMessage(), this is useful for
-- rapid iterative testing by allowing us to print variables to the screen.
-- If passed a table, SM() will use the TableToString_Recursive (from above)
-- to display children recursively until the SystemMessage spills off the screen.
function SM( arg )

	-- if a table has been passed in
	if type( arg ) == "table" then

		-- recurively print its contents to a string
		local msg = TableToString_Recursive(arg)
		-- and SystemMessage() that string
		SCREENMAN:SystemMessage( msg )

		-- tables as strings spill off SM's screen height quickly,
		-- so we might as well also do a proper Trace() to ./Logs/log.txt
		Trace( msg )
	else
		SCREENMAN:SystemMessage( tostring(arg) )
	end
end