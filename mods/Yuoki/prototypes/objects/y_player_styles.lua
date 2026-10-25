playeranimations_y1 = {
	idle = {
		filename = "__Yuoki__/graphics/armor/robo1_idle.png",
		--priority = "very-low,
		width = 80,
		height = 100,
		direction_count = 8,
		frame_count = 16,
		animation_speed = 0.15,
		shift = { 0.13, -0.25 },
		axially_symmetrical = false,
	},
	idlewithgun = {
		filename = "__Yuoki__/graphics/armor/robo1_idle.png",
		--priority = "very-low,
		width = 80,
		height = 100,
		direction_count = 8,
		frame_count = 16,
		animation_speed = 0.15,
		shift = { 0.13, -0.25 },
		axially_symmetrical = false,
	},
	miningwithhands = {
		filename = "__Yuoki__/graphics/armor/robo1_dig.png",
		--priority = "very-low,
		width = 80,
		height = 100,
		direction_count = 8,
		frame_count = 16,
		animation_speed = 0.6,
		shift = { 0.13, -0.25 },
		axially_symmetrical = false,
	},
	miningwithtool = {
		filename = "__Yuoki__/graphics/armor/robo1_dig.png",
		--priority = "very-low,
		width = 80,
		height = 100,
		direction_count = 8,
		frame_count = 16,
		animation_speed = 0.6,
		shift = { 0.13, -0.25 },
		axially_symmetrical = false,
	},
	runningwithgun = {
		filename = "__Yuoki__/graphics/armor/robo1_walk_gun.png",
		--priority = "very-low,
		width = 80,
		height = 100,
		frame_count = 1,
		direction_count = 18,
		shift = { 0.13, -0.25 },
	},
	running = {
		filename = "__Yuoki__/graphics/armor/robo1_walk.png",
		--priority = "very-low,
		width = 80,
		height = 100,
		direction_count = 8,
		frame_count = 22,
		shift = { 0.13, -0.25 },
		axially_symmetrical = false,
	},
}

table.insert(data.raw.character.character.animations, {
	armors = { "yi_walker_a" },
	idle = playeranimations_y1.idle,
	idle_with_gun = playeranimations_y1.idlewithgun,
	mining_with_tool = playeranimations_y1.miningwithtool,
	running = playeranimations_y1.running,
	running_with_gun = playeranimations_y1.runningwithgun,
})

--[[
data.raw.character.character.animations.levelAaddon = {
	armors =  {"yi_walker_a"},
	idle =
	{
		layers =
		{
			playeranimations_y1.idle
		}
	},
	idle_with_gun =
	{
		layers =
		{
			playeranimations_y1.idlewithgun
		}
	},
	mining_with_hands =
	{
		layers =
		{
			playeranimations_y1.miningwithhands
		}
	},
	mining_with_tool =
	{
		layers =
		{
			playeranimations_y1.miningwithtool
		}
	},
	running_with_gun =
	{
		layers =
		{
			playeranimations_y1.runningwithgun
		}
	},
	running =
	{
		layers =
		{
			playeranimations_y1.running
		}
	}
}
]]

playeranimations_y2 = {
	idle = {
		filename = "__Yuoki__/graphics/armor/armor2_idle_sheet.png",
		--priority = "very-low,
		width = 80,
		height = 100,
		direction_count = 8,
		frame_count = 16,
		animation_speed = 0.15,
		shift = { 0.13, -0.25 },
		axially_symmetrical = false,
	},
	idlewithgun = {
		filename = "__Yuoki__/graphics/armor/armor2_idle_sheet.png",
		--priority = "very-low,
		width = 80,
		height = 100,
		direction_count = 8,
		frame_count = 16,
		animation_speed = 0.15,
		shift = { 0.13, -0.25 },
		axially_symmetrical = false,
	},
	miningwithhands = {
		filename = "__Yuoki__/graphics/armor/armor2_dig.png",
		--priority = "very-low,
		width = 80,
		height = 100,
		direction_count = 8,
		frame_count = 1,
		animation_speed = 0.1,
		shift = { 0.13, -0.25 },
		axially_symmetrical = false,
	},
	miningwithtool = {
		filename = "__Yuoki__/graphics/armor/armor2_dig.png",
		--priority = "very-low,
		width = 80,
		height = 100,
		direction_count = 8,
		frame_count = 1,
		animation_speed = 0.1,
		shift = { 0.13, -0.25 },
		axially_symmetrical = false,
	},
	runningwithgun = {
		filename = "__Yuoki__/graphics/armor/armor2_walk_gun.png",
		--priority = "very-low,
		width = 80,
		height = 100,
		frame_count = 1,
		direction_count = 18,
		shift = { 0.13, -0.25 },
	},
	running = {
		filename = "__Yuoki__/graphics/armor/armor2_walk_sheet.png",
		--priority = "very-low,
		width = 80,
		height = 100,
		direction_count = 8,
		frame_count = 22,
		shift = { 0.13, -0.25 },
		axially_symmetrical = false,
	},
}

table.insert(data.raw.character.character.animations, {
	armors = { "yi_armor_gray" },
	idle = playeranimations_y2.idle,
	idle_with_gun = playeranimations_y2.idlewithgun,
	mining_with_tool = playeranimations_y2.miningwithtool,
	running = playeranimations_y2.running,
	running_with_gun = playeranimations_y2.runningwithgun,
})

--[[
data.raw.character.character.animations.levelBaddon = {
	armors =  {"yi_armor_gray"},
	idle =
	{
		layers =
		{
			playeranimations_y2.idle
		}
	},
	idle_with_gun =
	{
		layers =
		{
			playeranimations_y2.idlewithgun
		}
	},
	mining_with_hands =
	{
		layers =
		{
			playeranimations_y2.miningwithhands
		}
	},
	mining_with_tool =
	{
		layers =
		{
			playeranimations_y2.miningwithtool
		}
	},
	running_with_gun =
	{
		layers =
		{
			playeranimations_y2.runningwithgun
		}
	},
	running =
	{
		layers =
		{
			playeranimations_y2.running
		}
	}
}
]]

playeranimations_y3 = {
	idle = {
		filename = "__Yuoki__/graphics/armor/cb3_idle_sheet.png",
		--priority = "very-low,
		width = 80,
		height = 100,
		direction_count = 8,
		frame_count = 16,
		animation_speed = 0.15,
		shift = { 0.13, -0.25 },
		axially_symmetrical = false,
	},
	idlewithgun = {
		filename = "__Yuoki__/graphics/armor/cb3_idle_sheet.png",
		--priority = "very-low,
		width = 80,
		height = 100,
		direction_count = 8,
		frame_count = 16,
		animation_speed = 0.15,
		shift = { 0.13, -0.25 },
		axially_symmetrical = false,
	},
	miningwithhands = {
		filename = "__Yuoki__/graphics/armor/cb3_dig.png",
		--priority = "very-low,
		width = 80,
		height = 100,
		direction_count = 8,
		frame_count = 1,
		animation_speed = 0.1,
		shift = { 0.13, -0.25 },
		axially_symmetrical = false,
	},
	miningwithtool = {
		filename = "__Yuoki__/graphics/armor/cb3_dig.png",
		--priority = "very-low,
		width = 80,
		height = 100,
		direction_count = 8,
		frame_count = 1,
		animation_speed = 0.1,
		shift = { 0.13, -0.25 },
		axially_symmetrical = false,
	},
	runningwithgun = {
		filename = "__Yuoki__/graphics/armor/cb3_walk_gun.png",
		--priority = "very-low,
		width = 80,
		height = 100,
		frame_count = 1,
		direction_count = 18,
		shift = { 0.13, -0.25 },
	},
	running = {
		filename = "__Yuoki__/graphics/armor/cb3_walk_sheet.png",
		--priority = "very-low,
		width = 80,
		height = 100,
		direction_count = 8,
		frame_count = 22,
		shift = { 0.13, -0.25 },
		axially_symmetrical = false,
	},
}

table.insert(data.raw.character.character.animations, {
	armors = { "yi_armor_red" },
	idle = playeranimations_y3.idle,
	idle_with_gun = playeranimations_y3.idlewithgun,
	mining_with_tool = playeranimations_y3.miningwithtool,
	running = playeranimations_y3.running,
	running_with_gun = playeranimations_y3.runningwithgun,
})

--[[
data.raw.character.character.animations.levelCaddon = {
	armors =  {"yi_armor_red"},
	idle =
	{
		layers =
		{
			playeranimations_y3.idle
		}
	},
	idle_with_gun =
	{
		layers =
		{
			playeranimations_y3.idlewithgun
		}
	},
	mining_with_hands =
	{
		layers =
		{
			playeranimations_y3.miningwithhands
		}
	},
	mining_with_tool =
	{
		layers =
		{
			playeranimations_y3.miningwithtool
		}
	},
	running_with_gun =
	{
		layers =
		{
			playeranimations_y3.runningwithgun
		}
	},
	running =
	{
		layers =
		{
			playeranimations_y3.running
		}
	}
}
]]

playeranimations_y4 = {
	idle = {
		filename = "__Yuoki__/graphics/armor/cb4_idle_sheet.png",
		--priority = "very-low,
		width = 90,
		height = 100,
		direction_count = 8,
		frame_count = 16,
		animation_speed = 0.15,
		shift = { 0.13, -0.25 },
		axially_symmetrical = false,
	},
	idlewithgun = {
		filename = "__Yuoki__/graphics/armor/cb4_idle_sheet.png",
		--priority = "very-low,
		width = 90,
		height = 100,
		direction_count = 8,
		frame_count = 16,
		animation_speed = 0.15,
		shift = { 0.13, -0.25 },
		axially_symmetrical = false,
	},
	miningwithhands = {
		filename = "__Yuoki__/graphics/armor/cb4_dig_sheet.png",
		--priority = "very-low,
		width = 90,
		height = 100,
		direction_count = 8,
		frame_count = 1,
		animation_speed = 0.1,
		shift = { 0.13, -0.25 },
		axially_symmetrical = false,
	},
	miningwithtool = {
		filename = "__Yuoki__/graphics/armor/cb4_dig_sheet.png",
		--priority = "very-low,
		width = 90,
		height = 100,
		direction_count = 8,
		frame_count = 1,
		animation_speed = 0.1,
		shift = { 0.13, -0.25 },
		axially_symmetrical = false,
	},
	runningwithgun = {
		filename = "__Yuoki__/graphics/armor/cb4_gun_sheet.png",
		--priority = "very-low,
		width = 90,
		height = 100,
		frame_count = 1,
		direction_count = 18,
		shift = { 0.13, -0.25 },
	},
	running = {
		filename = "__Yuoki__/graphics/armor/cb4_walk_sheet.png",
		--priority = "very-low,
		width = 90,
		height = 100,
		direction_count = 8,
		frame_count = 22,
		shift = { 0.13, -0.25 },
		axially_symmetrical = false,
	},
}

table.insert(data.raw.character.character.animations, {
	armors = { "yi_walker_c" },
	idle = playeranimations_y4.idle,
	idle_with_gun = playeranimations_y4.idlewithgun,
	mining_with_tool = playeranimations_y4.miningwithtool,
	running = playeranimations_y4.running,
	running_with_gun = playeranimations_y4.runningwithgun,
})

--[[
data.raw.character.character.animations.levelDaddon = {
	armors =  {"yi_walker_c"},
	idle =				{layers ={playeranimations_y4.idle}},
	idle_with_gun =		{layers ={playeranimations_y4.idlewithgun}},
	mining_with_hands =	{layers ={playeranimations_y4.miningwithhands}},
	mining_with_tool =	{layers ={playeranimations_y4.miningwithtool}},
	running_with_gun =	{layers ={playeranimations_y4.runningwithgun}},
	running =			{layers ={playeranimations_y4.running}},
}

]]
--

playeranimations_y5 = {
	idle = {
		filename = "__Yuoki__/graphics/armor/cb5_idle_sheet.png",
		--priority = "very-low,
		width = 80,
		height = 100,
		direction_count = 8,
		frame_count = 16,
		animation_speed = 0.1,
		shift = { 0.13, -0.25 },
		axially_symmetrical = false,
	},
	idlewithgun = {
		filename = "__Yuoki__/graphics/armor/cb5_idle_sheet.png",
		--priority = "very-low,
		width = 80,
		height = 100,
		direction_count = 8,
		frame_count = 16,
		animation_speed = 0.1,
		shift = { 0.13, -0.25 },
		axially_symmetrical = false,
	},
	miningwithhands = {
		filename = "__Yuoki__/graphics/armor/cb5_dig_sheet.png",
		--priority = "very-low,
		width = 80,
		height = 100,
		direction_count = 8,
		frame_count = 1,
		animation_speed = 0.1,
		shift = { 0.13, -0.25 },
		axially_symmetrical = false,
	},
	miningwithtool = {
		filename = "__Yuoki__/graphics/armor/cb5_dig_sheet.png",
		--priority = "very-low,
		width = 80,
		height = 100,
		direction_count = 8,
		frame_count = 1,
		animation_speed = 0.1,
		shift = { 0.13, -0.25 },
		axially_symmetrical = false,
	},
	runningwithgun = {
		filename = "__Yuoki__/graphics/armor/cb5_gun_sheet.png",
		--priority = "very-low,
		width = 80,
		height = 100,
		frame_count = 1,
		direction_count = 18,
		shift = { 0.13, -0.25 },
	},
	running = {
		filename = "__Yuoki__/graphics/armor/cb5_walk_sheet.png",
		--priority = "very-low,
		width = 80,
		height = 100,
		direction_count = 8,
		frame_count = 22,
		shift = { 0.13, -0.25 },
		axially_symmetrical = false,
	},
}

table.insert(data.raw.character.character.animations, {
	armors = { "yi_armor_gold" },
	idle = playeranimations_y5.idle,
	idle_with_gun = playeranimations_y5.idlewithgun,
	mining_with_tool = playeranimations_y5.miningwithtool,
	running = playeranimations_y5.running,
	running_with_gun = playeranimations_y5.runningwithgun,
})

--[[
data.raw.character.character.animations.levelEaddon = {
	armors =  {"yi_armor_gold"},
	idle =				{layers ={playeranimations_y5.idle}},
	idle_with_gun =		{layers ={playeranimations_y5.idlewithgun}},
	mining_with_hands =	{layers ={playeranimations_y5.miningwithhands}},
	mining_with_tool =	{layers ={playeranimations_y5.miningwithtool}},
	running_with_gun =	{layers ={playeranimations_y5.runningwithgun}},
	running =			{layers ={playeranimations_y5.running}},
}
]]
