--settings
data:extend ({

--the assemblerlights

	{	
		name = "assemblerlight-red",
		setting_type = "startup",
		type = "double-setting",
		default_value = 1,
		maximum_value = 1,
		minimum_value = 0,
		order ="0assemblerlight1"
	},
	
	{	
		name = "assemblerlight-blue",
		setting_type = "startup",
		type = "double-setting",
		default_value = 1,
		maximum_value = 1,
		minimum_value = 0,
		order ="0assemblerlight3"
	},

	{	
		name = "assemblerlight-green",
		setting_type = "startup",
		type = "double-setting",
		default_value = 1,
		maximum_value = 1,
		minimum_value = 0,
		order ="0assemblerlight2"
	},	

	{	
		name = "assemblerlight-intensity",
		setting_type = "startup",
		type = "double-setting",
		default_value = 0.5,
		minimum_value = 0,
		order ="0assemblerlight4"
	},	
		
	{
		name = "assemblerlight-size",
		setting_type = "startup",
		type = "double-setting",
		default_value = 5,
		minimum_value = 0,
		order ="0assemblerlight5"		
	},
	
	{	
		name = "assemblerlight-default-on",
		setting_type = "startup",
		type = "double-setting",
		default_value = 0,
		maximum_value = 1,
		minimum_value = 0,
		order ="0assemblerlight6"
	},	

	{	
		name = "assemblerlight-default-off",
		setting_type = "startup",
		type = "double-setting",
		default_value = 0,
		maximum_value = 1,
		minimum_value = 0,
		order ="0assemblerlight7"
		},	

--vanilla assemblers
	{	
		name = "assembler-1-red",
		setting_type = "startup",
		type = "double-setting",
		default_value = 1,
		maximum_value = 1,
		minimum_value = 0,
		order="1assember1"
	},
	
	{	
		name = "assembler-1-blue",
		setting_type = "startup",
		type = "double-setting",
		default_value = 1,
		maximum_value = 1,
		minimum_value = 0,
		order="1assember3"
	},

	{	
		name = "assembler-1-green",
		setting_type = "startup",
		type = "double-setting",
		default_value = 1,
		maximum_value = 1,
		minimum_value = 0,
		order="1assember2"
	},	
	
		{	
		name = "assembler-2-red",
		setting_type = "startup",
		type = "double-setting",
		default_value = 1,
		maximum_value = 1,
		minimum_value = 0,
		order="2assember1"
	},
	
	{	
		name = "assembler-2-blue",
		setting_type = "startup",
		type = "double-setting",
		default_value = 1,
		maximum_value = 1,
		minimum_value = 0,
		order="2assember3"
	},

	{	
		name = "assembler-2-green",
		setting_type = "startup",
		type = "double-setting",
		default_value = 1,
		maximum_value = 1,
		minimum_value = 0,
		order="2assember2"
	},	
	{	
		name = "assembler-3-red",
		setting_type = "startup",
		type = "double-setting",
		default_value = 1,
		maximum_value = 1,
		minimum_value = 0,
		order="3assember1"
	},
	
	{	
		name = "assembler-3-blue",
		setting_type = "startup",
		type = "double-setting",
		default_value = 1,
		maximum_value = 1,
		minimum_value = 0,
		order="3assember3"
	},

	{	
		name = "assembler-3-green",
		setting_type = "startup",
		type = "double-setting",
		default_value = 1,
		maximum_value = 1,
		minimum_value = 0,
		order="3assember2"
	},
	
	-- vanilla chemical lab
	{	
		name = "chemical-1-red",
		setting_type = "startup",
		type = "double-setting",
		default_value = 0.7,
		maximum_value = 1,
		minimum_value = 0,
		order="1chemical1"
	},
	
	{	
		name = "chemical-1-blue",
		setting_type = "startup",
		type = "double-setting",
		default_value = 0.1,
		maximum_value = 1,
		minimum_value = 0,
		order="1chemical3"
	},

	{	
		name = "chemical-1-green",
		setting_type = "startup",
		type = "double-setting",
		default_value = 0.74,
		maximum_value = 1,
		minimum_value = 0,
		order="1chemical2"
	},	
	
	-- vanilla oil refinery
	{	
		name = "refinery-1-red",
		setting_type = "startup",
		type = "double-setting",
		default_value = 1,
		maximum_value = 1,
		minimum_value = 0,
		order="1refinery1"
	},
	
	{	
		name = "refinery-1-blue",
		setting_type = "startup",
		type = "double-setting",
		default_value = 0.4,
		maximum_value = 1,
		minimum_value = 0,
		order="1refinery3"
	},

	{	
		name = "refinery-1-green",
		setting_type = "startup",
		type = "double-setting",
		default_value = 0.45,
		maximum_value = 1,
		minimum_value = 0,
		order="1refinery2"
	},		
	
	
})
	
--Bob's asemblers

	if mods["boblibrary"] then
	data:extend ({
	{	
		name = "assembler-4-red",
		setting_type = "startup",
		type = "double-setting",
		default_value = 1,
		maximum_value = 1,
		minimum_value = 0,
		order="4assember1"
	},
	
	{	
		name = "assembler-4-blue",
		setting_type = "startup",
		type = "double-setting",
		default_value = 1,
		maximum_value = 1,
		minimum_value = 0,
		order="4assember3"
	},

	{	
		name = "assembler-4-green",
		setting_type = "startup",
		type = "double-setting",
		default_value = 1,
		maximum_value = 1,
		minimum_value = 0,
		order="4assember2"
	},



	{	
		name = "assembler-5-red",
		setting_type = "startup",
		type = "double-setting",
		default_value = 1,
		maximum_value = 1,
		minimum_value = 0,
		order="5assember1"
	},
	
	{	
		name = "assembler-5-blue",
		setting_type = "startup",
		type = "double-setting",
		default_value = 1,
		maximum_value = 1,
		minimum_value = 0,
		order="5assember3"
	},

	{	
		name = "assembler-5-green",
		setting_type = "startup",
		type = "double-setting",
		default_value = 1,
		maximum_value = 1,
		minimum_value = 0,
		order="5assember2"
	},

	{	
		name = "assembler-6-red",
		setting_type = "startup",
		type = "double-setting",
		default_value = 1,
		maximum_value = 1,
		minimum_value = 0,
		order="6assember1"
	},
	
	{	
		name = "assembler-6-blue",
		setting_type = "startup",
		type = "double-setting",
		default_value = 1,
		maximum_value = 1,
		minimum_value = 0,
		order="6assember3"
	},

	{	
		name = "assembler-6-green",
		setting_type = "startup",
		type = "double-setting",
		default_value = 1,
		maximum_value = 1,
		minimum_value = 0,
		order="6assember2"
	},
	
	
	-- bob's chemical plants
	{	
		name = "chemical-2-red",
		setting_type = "startup",
		type = "double-setting",
		default_value = 0.7,
		maximum_value = 1,
		minimum_value = 0,
		order="2chemical1"
	},
	
	{	
		name = "chemical-2-blue",
		setting_type = "startup",
		type = "double-setting",
		default_value = 0.1,
		maximum_value = 1,
		minimum_value = 0,
		order="2chemical3"
	},

	{	
		name = "chemical-2-green",
		setting_type = "startup",
		type = "double-setting",
		default_value = 0.74,
		maximum_value = 1,
		minimum_value = 0,
		order="2chemical2"
	},
	{	
		name = "chemical-3-red",
		setting_type = "startup",
		type = "double-setting",
		default_value = 0.7,
		maximum_value = 1,
		minimum_value = 0,
		order="3chemical1"
	},
	
	{	
		name = "chemical-3-blue",
		setting_type = "startup",
		type = "double-setting",
		default_value = 0.1,
		maximum_value = 1,
		minimum_value = 0,
		order="3chemical3"
	},

	{	
		name = "chemical-3-green",
		setting_type = "startup",
		type = "double-setting",
		default_value = 0.74,
		maximum_value = 1,
		minimum_value = 0,
		order="3chemical2"
	},	
	{	
		name = "chemical-4-red",
		setting_type = "startup",
		type = "double-setting",
		default_value = 0.7,
		maximum_value = 1,
		minimum_value = 0,
		order="4chemical1"
	},
	
	{	
		name = "chemical-4-blue",
		setting_type = "startup",
		type = "double-setting",
		default_value = 0.1,
		maximum_value = 1,
		minimum_value = 0,
		order="4chemical3"
	},

	{	
		name = "chemical-4-green",
		setting_type = "startup",
		type = "double-setting",
		default_value = 0.74,
		maximum_value = 1,
		minimum_value = 0,
		order="4chemical2"
	},		
	
	-- bob's oil refineries
	{	
		name = "refinery-2-red",
		setting_type = "startup",
		type = "double-setting",
		default_value = 1,
		maximum_value = 1,
		minimum_value = 0,
		order="2refinery1"
	},
	
	{	
		name = "refinery-2-blue",
		setting_type = "startup",
		type = "double-setting",
		default_value = 0.4,
		maximum_value = 1,
		minimum_value = 0,
		order="2refinery3"
	},

	{	
		name = "refinery-2-green",
		setting_type = "startup",
		type = "double-setting",
		default_value = 0.45,
		maximum_value = 1,
		minimum_value = 0,
		order="2refinery2"
	},			
	{	
		name = "refinery-3-red",
		setting_type = "startup",
		type = "double-setting",
		default_value = 1,
		maximum_value = 1,
		minimum_value = 0,
		order="3refinery1"
	},
	
	{	
		name = "refinery-3-blue",
		setting_type = "startup",
		type = "double-setting",
		default_value = 0.4,
		maximum_value = 1,
		minimum_value = 0,
		order="3refinery3"
	},

	{	
		name = "refinery-3-green",
		setting_type = "startup",
		type = "double-setting",
		default_value = 0.45,
		maximum_value = 1,
		minimum_value = 0,
		order="3refinery2"
	},			
	{	
		name = "refinery-4-red",
		setting_type = "startup",
		type = "double-setting",
		default_value = 1,
		maximum_value = 1,
		minimum_value = 0,
		order="4refinery1"
	},
	
	{	
		name = "refinery-4-blue",
		setting_type = "startup",
		type = "double-setting",
		default_value = 0.4,
		maximum_value = 1,
		minimum_value = 0,
		order="4refinery3"
	},

	{	
		name = "refinery-4-green",
		setting_type = "startup",
		type = "double-setting",
		default_value = 0.45,
		maximum_value = 1,
		minimum_value = 0,
		order="4refinery2"
	}
	})
	end
	
	
	-- electronic assembling machines
	if mods["boblibrary"] then
	data:extend ({
	{	
		name = "elecassembler-1-red",
		setting_type = "startup",
		type = "double-setting",
		default_value = 1,
		maximum_value = 1,
		minimum_value = 0,
		order="7assember1"
	},
	
	{	
		name = "elecassembler-1-blue",
		setting_type = "startup",
		type = "double-setting",
		default_value = 1,
		maximum_value = 1,
		minimum_value = 0,
		order="7assember3"
	},

	{	
		name = "elecassembler-1-green",
		setting_type = "startup",
		type = "double-setting",
		default_value = 1,
		maximum_value = 1,
		minimum_value = 0,
		order="7assember2"
	},

	{	
		name = "elecassembler-2-red",
		setting_type = "startup",
		type = "double-setting",
		default_value = 1,
		maximum_value = 1,
		minimum_value = 0,
		order="8assember1"
	},
	
	{	
		name = "elecassembler-2-blue",
		setting_type = "startup",
		type = "double-setting",
		default_value = 1,
		maximum_value = 1,
		minimum_value = 0,
		order="8assember3"
	},

	{	
		name = "elecassembler-2-green",
		setting_type = "startup",
		type = "double-setting",
		default_value = 1,
		maximum_value = 1,
		minimum_value = 0,
		order="8assember2"
	},

	{	
		name = "elecassembler-3-red",
		setting_type = "startup",
		type = "double-setting",
		default_value = 1,
		maximum_value = 1,
		minimum_value = 0,
		order="9assember1"
	},
	
	{	
		name = "elecassembler-3-blue",
		setting_type = "startup",
		type = "double-setting",
		default_value = 1,
		maximum_value = 1,
		minimum_value = 0,
		order="9assember3"
	},

	{	
		name = "elecassembler-3-green",
		setting_type = "startup",
		type = "double-setting",
		default_value = 1,
		maximum_value = 1,
		minimum_value = 0,
		order="9assember2"
	}
	})
	end









