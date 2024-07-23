data:extend(
{
	{
		type = "sprite",
		name = "signal_control_start",
		filename = "__UnrealisticReactors__/graphics/tips_and_tricks/signal_start.png",
		priority = "extra-high-no-scale",
		width = 32,
		height = 32,
		flags = {"gui-icon"},
	},
	{
		type = "sprite",
		name = "signal_reactor_power_output",
		filename = "__UnrealisticReactors__/graphics/tips_and_tricks/signal_power.png",
		priority = "extra-high-no-scale",
		width = 32,
		height = 32,
		flags = {"gui-icon"},
	},
	{
		type = "sprite",
		name = "signal_reactor_efficiency",
		filename = "__UnrealisticReactors__/graphics/tips_and_tricks/signal_efficiency.png",
		priority = "extra-high-no-scale",
		width = 32,
		height = 32,
		flags = {"gui-icon"},
	},	
	-- reactor table
	{
		type = "sprite",
		name = "tab-r-1",
		filename = "__UnrealisticReactors__/graphics/tips_and_tricks/tab-r-1.png",
		priority = "extra-high-no-scale",
		width = 1414,
		height = 39,
	},	
	{
		type = "sprite",
		name = "tab-r-2",
		filename = "__UnrealisticReactors__/graphics/tips_and_tricks/tab-r-2.png",
		priority = "extra-high-no-scale",
		width = 1414,
		height = 39,
	},	
	{
		type = "sprite",
		name = "tab-r-3",
		filename = "__UnrealisticReactors__/graphics/tips_and_tricks/tab-r-3.png",
		priority = "extra-high-no-scale",
		width = 1414,
		height = 39,
	},	
	{
		type = "sprite",
		name = "tab-r-4",
		filename = "__UnrealisticReactors__/graphics/tips_and_tricks/tab-r-4.png",
		priority = "extra-high-no-scale",
		width = 1414,
		height = 39,
	},	
	{
		type = "sprite",
		name = "tab-r-5",
		filename = "__UnrealisticReactors__/graphics/tips_and_tricks/tab-r-5.png",
		priority = "extra-high-no-scale",
		width = 1414,
		height = 39,
	},		
	-- breeder table
	{
		type = "sprite",
		name = "tab-b-1",
		filename = "__UnrealisticReactors__/graphics/tips_and_tricks/tab-b-1.png",
		priority = "extra-high-no-scale",
		width = 1641,
		height = 39,
	},	
	{
		type = "sprite",
		name = "tab-b-2",
		filename = "__UnrealisticReactors__/graphics/tips_and_tricks/tab-b-2.png",
		priority = "extra-high-no-scale",
		width = 1641,
		height = 39,
	},	
	{
		type = "sprite",
		name = "tab-b-3",
		filename = "__UnrealisticReactors__/graphics/tips_and_tricks/tab-b-3.png",
		priority = "extra-high-no-scale",
		width = 1641,
		height = 39,
	},	
	{
		type = "sprite",
		name = "tab-b-4",
		filename = "__UnrealisticReactors__/graphics/tips_and_tricks/tab-b-4.png",
		priority = "extra-high-no-scale",
		width = 1641,
		height = 39,
	},	
	{
		type = "sprite",
		name = "tab-b-5",
		filename = "__UnrealisticReactors__/graphics/tips_and_tricks/tab-b-5.png",
		priority = "extra-high-no-scale",
		width = 1641,
		height = 39,
	},		
	
})



data:extend(
{
	{
		type = "tips-and-tricks-item-category",
		name = "RealisticReactors",
		order = "z-[RealisticReactors]"
	},

	-- Title
	{
		type = "tips-and-tricks-item",
		name = "RealisticReactors_Title",
		category = "RealisticReactors",
		tag = "[entity=realistic-reactor]",
		order = "a",
		is_title = true,
		trigger =
		{
			type = "research",
			technology = "nuclear-power"
		},
		image = "__UnrealisticReactors__/graphics/tips_and_tricks/title_pic.png"
	},
	
	
	-- How to operate a reactor
	{
		type = "tips-and-tricks-item",
		name = "RealisticReactors_Operate",
		category = "RealisticReactors",
		tag = "[img=signal_control_start]",
		order = "b",
		indent = 1,
		trigger =
		{
			type = "research",
			technology = "nuclear-power"
		},
		image = "__UnrealisticReactors__/graphics/tips_and_tricks/reactor_interface.png"
	},
	
	-- Meltdown
	{
		type = "tips-and-tricks-item",
		name = "RealisticReactors_Meltdown",
		category = "RealisticReactors",
		tag = "[entity=reactor-sarcophagus]",
		order = "c",
		indent = 1,
		trigger =
		{
			type = "research",
			technology = "nuclear-power"
		},
		image = "__UnrealisticReactors__/graphics/tips_and_tricks/meltdown.png"
	},	
	
	-- Power output and efficiency
	{
		type = "tips-and-tricks-item",
		name = "RealisticReactors_Output",
		category = "RealisticReactors",
		tag = "[img=signal_reactor_power_output][img=signal_reactor_efficiency]",
		order = "d",
		indent = 1,
		trigger =
		{
			type = "research",
			technology = "nuclear-power"
		},
	},	

	-- Output Reactor
	{
		type = "tips-and-tricks-item",
		name = "RealisticReactors_OutputReactor",
		category = "RealisticReactors",
		tag = "[entity=realistic-reactor]",
		order = "e",
		indent = 2,
		trigger =
		{
			type = "research",
			technology = "nuclear-power"
		},
		image = "__UnrealisticReactors__/graphics/tips_and_tricks/output_reactor.png"
	},
	
	-- Output Breeder
	{
		type = "tips-and-tricks-item",
		name = "RealisticReactors_OutputBreeder",
		category = "RealisticReactors",
		tag = "[entity=realistic-reactor-breeder]",
		order = "f",
		indent = 2,
		trigger =
		{
			type = "research",
			technology = "nuclear-power"
		},
		image = "__UnrealisticReactors__/graphics/tips_and_tricks/output_breeder.png"
	},	
	
	
	
})