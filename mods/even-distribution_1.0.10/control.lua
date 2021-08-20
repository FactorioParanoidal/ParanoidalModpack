require("framework"){

	scripts = { -- custom scripts

		"metatables",
		"util",
		"helpers",	
		"setup",
		"remote",
		"visuals",
		"gui-tools",
		"drag",
		"cleanup",
		GUI("settings-gui"),

	},

	inputs = {  -- custom inputs

		"inventory-cleanup", -- SHIFT + C
		"fast-entity-transfer-hook",
		"fast-entity-split-hook",

	}
	
}