require "styles"

data:extend(
	{	
		{
			type = "custom-input",
			name = "EMC-Hotkey",
			key_sequence = "N",
			consuming = "none"
			-- 'consuming' available options:
			--"none": The associated script event will fire when satisfied and pass through to normal game events (default).
			--"game-only": The associated script event will fire when satisfied and block game events that conflict with the key sequence. Actions that are processed regardless of game paused state cannot be blocked.
	  },
	}
)