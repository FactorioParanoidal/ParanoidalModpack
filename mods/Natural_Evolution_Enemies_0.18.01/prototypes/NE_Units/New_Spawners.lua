if not NE_Enemies then NE_Enemies = {} end
if not NE_Enemies.Settings then NE_Enemies.Settings = {} end

NE_Enemies.Settings.NE_Difficulty = settings.startup["NE_Difficulty"].value

--- Base Spawner, just used to create the other spawners.
data:extend(
{
 {
    type = "unit-spawner",
    name = "ne-spawner-base",
    icon = "__base__/graphics/icons/biter-spawner.png",
    icon_size = 32,
    flags = {"placeable-player", "placeable-enemy", "not-repairable"},
    max_health = 500 + (500 * NE_Enemies.Settings.NE_Difficulty), -- v 350,
    order="b-b-g",
    subgroup="enemies",
    resistances = {},
    working_sound =
    {
      sound =
      {
        {
          filename = "__base__/sound/creatures/spawner.ogg",
          volume = 1.0
        }
      },
      apparent_volume = 2
    },
    dying_sound =
    {
      {
        filename = "__base__/sound/creatures/spawner-death-1.ogg",
        volume = 1.0
      },
      {
        filename = "__base__/sound/creatures/spawner-death-2.ogg",
        volume = 1.0
      }
    },
    healing_per_tick = 0.01 + (0.01 * NE_Enemies.Settings.NE_Difficulty), -- 0.02
    collision_box = {{-3.2, -2.2}, {2.2, 2.2}},
    selection_box = {{-3.5, -2.5}, {2.5, 2.5}},
	map_generator_bounding_box = {{-4.2, -3.2}, {3.2, 3.2}},
    -- in ticks per 1 pu
    pollution_absorption_absolute = 15, -- v20,
    pollution_absorption_proportional = 0.005, -- v0.01,
    corpse = "biter-spawner-corpse",
    dying_explosion = "blood-explosion-huge",
    max_count_of_owned_units = 13 + (2 * NE_Enemies.Settings.NE_Difficulty),  --v 7
    max_friends_around_to_spawn = 20 + (2 * NE_Enemies.Settings.NE_Difficulty), --v 5,
    animations =
    {
      spawner_idle_animation(0, biter_spawner_tint),
      spawner_idle_animation(1, biter_spawner_tint),
      spawner_idle_animation(2, biter_spawner_tint),
      spawner_idle_animation(3, biter_spawner_tint)
    },
    result_units = (function()
                     local res = {}
                     res[1] = {"small-biter", {{0.0, 0.3}, {0.6, 0.0}}}
                     return res
                   end)(),
    -- With zero evolution the spawn rate is 6 seconds, with max evolution it is 2.5 seconds
    spawning_cooldown = {(200+(100/NE_Enemies.Settings.NE_Difficulty)), (100+(50/NE_Enemies.Settings.NE_Difficulty))}, -- v {360, 150},
    spawning_radius = 8 + (2 * NE_Enemies.Settings.NE_Difficulty), -- v10,
    spawning_spacing = 2, -- v3,
    max_spawn_shift = 0,
    max_richness_for_spawn_shift = 100,
    autoplace = nil,
    call_for_help_radius = 45 + (10 * NE_Enemies.Settings.NE_Difficulty),-- v50	
	
  },

})


--- NE Spawners
--- Blue - Breeders
if settings.startup["NE_Blue_Spawners"].value then

	NE_Unit_Spawner_Blue = table.deepcopy(data.raw["unit-spawner"]["ne-spawner-base"])
	NE_Unit_Spawner_Blue.name = "ne-spawner-blue"
	NE_Unit_Spawner_Blue.corpse = "ne-spawner-blue-corpse"
	NE_Unit_Spawner_Blue.autoplace = enemy_autoplace.enemy_spawner_autoplace(0)
	NE_Unit_Spawner_Blue.resistances =
		{
		  {
			type = "physical",
			decrease = 4,
			percent = 30
		  },
		  {
			type = "explosion",
			decrease = 5,
			percent = 15
		  },
		  {
			type = "fire",
			decrease = 5,
			percent = 50
		  },
		  {
			type = "ne_fire",
			percent = 100
		  },
		  {
			type = "electric",
			percent = 100
		  }
		}
	NE_Unit_Spawner_Blue.animations =
		{
		  spawner_idle_animation(0, ne_blue_tint2),
		  spawner_idle_animation(1, ne_blue_tint2),
		  spawner_idle_animation(2, ne_blue_tint2),
		  spawner_idle_animation(3, ne_blue_tint2)
		}
	NE_Unit_Spawner_Blue.result_units = (function()
						 local res = {}
							res[1] = {"ne-biter-breeder-1", {{0,0.1}, {0.1,0.3}, {0.2,0}}}
							res[2] = {"ne-spitter-breeder-1", {{0.025,0}, {0.125,0.3}, {0.225,0}}}
							res[3] = {"ne-biter-breeder-2", {{0.05,0}, {0.15,0.3}, {0.25,0}}}
							res[4] = {"ne-spitter-breeder-2", {{0.075,0}, {0.175,0.3}, {0.275,0}}}
							res[5] = {"ne-biter-breeder-3", {{0.1,0}, {0.2,0.3}, {0.3,0}}}
							res[6] = {"ne-spitter-breeder-3", {{0.125,0}, {0.225,0.3}, {0.325,0}}}
							res[7] = {"ne-biter-breeder-4", {{0.15,0}, {0.25,0.3}, {0.35,0}}}
							res[8] = {"ne-spitter-breeder-4", {{0.175,0}, {0.275,0.3}, {0.375,0}}}
							res[9] = {"ne-biter-breeder-5", {{0.2,0}, {0.3,0.3}, {0.4,0}}}
							res[10] = {"ne-spitter-breeder-5", {{0.225,0}, {0.325,0.3}, {0.425,0}}}
							res[11] = {"ne-biter-breeder-6", {{0.25,0}, {0.35,0.3}, {0.45,0}}}
							res[12] = {"ne-spitter-breeder-6", {{0.275,0}, {0.375,0.3}, {0.475,0}}}
							res[13] = {"ne-biter-breeder-7", {{0.3,0}, {0.4,0.3}, {0.5,0}}}
							res[14] = {"ne-spitter-breeder-7", {{0.325,0}, {0.425,0.3}, {0.525,0}}}
							res[15] = {"ne-biter-breeder-8", {{0.35,0}, {0.45,0.3}, {0.55,0}}}
							res[16] = {"ne-spitter-breeder-8", {{0.375,0}, {0.475,0.3}, {0.575,0}}}
							res[17] = {"ne-biter-breeder-9", {{0.4,0}, {0.5,0.3}, {0.6,0}}}
							res[18] = {"ne-spitter-breeder-9", {{0.425,0}, {0.525,0.3}, {0.625,0}}}
							res[19] = {"ne-biter-breeder-10", {{0.45,0}, {0.55,0.3}, {0.65,0}}}
							res[20] = {"ne-spitter-breeder-10", {{0.475,0}, {0.575,0.3}, {0.675,0}}}
							res[21] = {"ne-biter-breeder-11", {{0.5,0}, {0.6,0.3}, {0.7,0}}}
							res[22] = {"ne-spitter-breeder-11", {{0.525,0}, {0.625,0.3}, {0.725,0}}}
							res[23] = {"ne-biter-breeder-12", {{0.55,0}, {0.65,0.3}, {0.75,0}}}
							res[24] = {"ne-spitter-breeder-12", {{0.575,0}, {0.675,0.3}, {0.775,0}}}
							res[25] = {"ne-biter-breeder-13", {{0.6,0}, {0.7,0.3}, {0.8,0}}}
							res[26] = {"ne-spitter-breeder-13", {{0.625,0}, {0.725,0.3}, {0.825,0}}}
							res[27] = {"ne-biter-breeder-14", {{0.65,0}, {0.75,0.3}, {0.85,0}}}
							res[28] = {"ne-spitter-breeder-14", {{0.675,0}, {0.775,0.3}, {0.875,0}}}
							res[29] = {"ne-biter-breeder-15", {{0.7,0}, {0.8,0.3}, {0.9,0}}}
							res[30] = {"ne-spitter-breeder-15", {{0.725,0}, {0.825,0.3}, {0.925,0}}}
							res[31] = {"ne-biter-breeder-16", {{0.75,0}, {0.85,0.3}, {0.95,0}}}
							res[32] = {"ne-spitter-breeder-16", {{0.775,0}, {0.875,0.3}, {0.975,0}}}
							res[33] = {"ne-biter-breeder-17", {{0.8,0}, {0.9,0.3}, {0.99,0}}}
							res[34] = {"ne-spitter-breeder-17", {{0.825,0}, {0.925,0.3}, {0.99,0}}}
							res[35] = {"ne-biter-breeder-18", {{0.85,0}, {0.95,0.3}, {0.99,0}}}
							res[36] = {"ne-spitter-breeder-18", {{0.875,0}, {0.975,0.3}, {0.99,0}}}
							res[37] = {"ne-biter-breeder-19", {{0.9,0}, {1,0.1}}}
							res[38] = {"ne-spitter-breeder-19", {{0.925,0}, {1,0.15}}}
							res[39] = {"ne-biter-breeder-20", {{0.95,0}, {1,0.2}}}
							res[40] = {"ne-spitter-breeder-20", {{0.975,0}, {1,0.25}}}
							if settings.startup["NE_Challenge_Mode"].value == true then
							res[41] = {"ne-biter-megalodon", {{0.98,0.1}, {1,0.5}}}
							end
						 return res
					   end)()   
					   
	data:extend{NE_Unit_Spawner_Blue}

	-------- Blue Corpse
	NE_Unit_Spawner_Corpse_Blue = table.deepcopy(data.raw.corpse["biter-spawner-corpse"])
	NE_Unit_Spawner_Corpse_Blue.name = "ne-spawner-blue-corpse"
	NE_Unit_Spawner_Corpse_Blue.time_before_removed = 10 * 60 * 60
	NE_Unit_Spawner_Corpse_Blue.animation =
		{
		  spawner_die_animation(0, ne_blue_tint2),
		  spawner_die_animation(1, ne_blue_tint2),
		  spawner_die_animation(2, ne_blue_tint2),
		  spawner_die_animation(3, ne_blue_tint2)
		}
		
	data:extend{NE_Unit_Spawner_Corpse_Blue}


end

--- Red - Fire Units
if settings.startup["NE_Red_Spawners"].value then

	NE_Unit_Spawner_Red = table.deepcopy(data.raw["unit-spawner"]["ne-spawner-base"])
	NE_Unit_Spawner_Red.name = "ne-spawner-red"
	NE_Unit_Spawner_Red.corpse = "ne-spawner-red-corpse"
	NE_Unit_Spawner_Red.autoplace = enemy_autoplace.enemy_spawner_autoplace(0)
	NE_Unit_Spawner_Red.resistances =
		{
		  {
			type = "physical",
			decrease = 2,
			percent = 15
		  },
		  {
			type = "explosion",
			decrease = 5,
			percent = 15
		  },
		  {
			type = "fire",
			percent = 100
		  },
		  {
			type = "ne_fire",
			percent = 100
		  }
		}
	NE_Unit_Spawner_Red.animations =
		{
		  spawner_idle_animation(0, ne_fire_tint2),
		  spawner_idle_animation(1, ne_fire_tint2),
		  spawner_idle_animation(2, ne_fire_tint2),
		  spawner_idle_animation(3, ne_fire_tint2)
		}
	NE_Unit_Spawner_Red.result_units = (function()
						 local res = {}
							res[1] = {"ne-biter-fire-1", {{0,0.1}, {0.1,0.3}, {0.2,0}}}
							res[2] = {"ne-spitter-fire-1", {{0.025,0}, {0.125,0.3}, {0.225,0}}}
							res[3] = {"ne-biter-fire-2", {{0.05,0}, {0.15,0.3}, {0.25,0}}}
							res[4] = {"ne-spitter-fire-2", {{0.075,0}, {0.175,0.3}, {0.275,0}}}
							res[5] = {"ne-biter-fire-3", {{0.1,0}, {0.2,0.3}, {0.3,0}}}
							res[6] = {"ne-spitter-fire-3", {{0.125,0}, {0.225,0.3}, {0.325,0}}}
							res[7] = {"ne-biter-fire-4", {{0.15,0}, {0.25,0.3}, {0.35,0}}}
							res[8] = {"ne-spitter-fire-4", {{0.175,0}, {0.275,0.3}, {0.375,0}}}
							res[9] = {"ne-biter-fire-5", {{0.2,0}, {0.3,0.3}, {0.4,0}}}
							res[10] = {"ne-spitter-fire-5", {{0.225,0}, {0.325,0.3}, {0.425,0}}}
							res[11] = {"ne-biter-fire-6", {{0.25,0}, {0.35,0.3}, {0.45,0}}}
							res[12] = {"ne-spitter-fire-6", {{0.275,0}, {0.375,0.3}, {0.475,0}}}
							res[13] = {"ne-biter-fire-7", {{0.3,0}, {0.4,0.3}, {0.5,0}}}
							res[14] = {"ne-spitter-fire-7", {{0.325,0}, {0.425,0.3}, {0.525,0}}}
							res[15] = {"ne-biter-fire-8", {{0.35,0}, {0.45,0.3}, {0.55,0}}}
							res[16] = {"ne-spitter-fire-8", {{0.375,0}, {0.475,0.3}, {0.575,0}}}
							res[17] = {"ne-biter-fire-9", {{0.4,0}, {0.5,0.3}, {0.6,0}}}
							res[18] = {"ne-spitter-fire-9", {{0.425,0}, {0.525,0.3}, {0.625,0}}}
							res[19] = {"ne-biter-fire-10", {{0.45,0}, {0.55,0.3}, {0.65,0}}}
							res[20] = {"ne-spitter-fire-10", {{0.475,0}, {0.575,0.3}, {0.675,0}}}
							res[21] = {"ne-biter-fire-11", {{0.5,0}, {0.6,0.3}, {0.7,0}}}
							res[22] = {"ne-spitter-fire-11", {{0.525,0}, {0.625,0.3}, {0.725,0}}}
							res[23] = {"ne-biter-fire-12", {{0.55,0}, {0.65,0.3}, {0.75,0}}}
							res[24] = {"ne-spitter-fire-12", {{0.575,0}, {0.675,0.3}, {0.775,0}}}
							res[25] = {"ne-biter-fire-13", {{0.6,0}, {0.7,0.3}, {0.8,0}}}
							res[26] = {"ne-spitter-fire-13", {{0.625,0}, {0.725,0.3}, {0.825,0}}}
							res[27] = {"ne-biter-fire-14", {{0.65,0}, {0.75,0.3}, {0.85,0}}}
							res[28] = {"ne-spitter-fire-14", {{0.675,0}, {0.775,0.3}, {0.875,0}}}
							res[29] = {"ne-biter-fire-15", {{0.7,0}, {0.8,0.3}, {0.9,0}}}
							res[30] = {"ne-spitter-fire-15", {{0.725,0}, {0.825,0.3}, {0.925,0}}}
							res[31] = {"ne-biter-fire-16", {{0.75,0}, {0.85,0.3}, {0.95,0}}}
							res[32] = {"ne-spitter-fire-16", {{0.775,0}, {0.875,0.3}, {0.975,0}}}
							res[33] = {"ne-biter-fire-17", {{0.8,0}, {0.9,0.3}, {0.99,0}}}
							res[34] = {"ne-spitter-fire-17", {{0.825,0}, {0.925,0.3}, {0.99,0}}}
							res[35] = {"ne-biter-fire-18", {{0.85,0}, {0.95,0.3}, {0.99,0}}}
							res[36] = {"ne-spitter-fire-18", {{0.875,0}, {0.975,0.3}, {0.99,0}}}
							res[37] = {"ne-biter-fire-19", {{0.9,0}, {1,0.1}}}
							res[38] = {"ne-spitter-fire-19", {{0.925,0}, {1,0.15}}}
							res[39] = {"ne-biter-fire-20", {{0.95,0}, {1,0.2}}}
							res[40] = {"ne-spitter-fire-20", {{0.975,0}, {1,0.25}}}
							if settings.startup["NE_Challenge_Mode"].value == true then
							res[41] = {"ne-biter-megalodon", {{0.98,0.1}, {1,0.5}}}
							end
						 return res
					   end)()   
					   
	data:extend{NE_Unit_Spawner_Red}

	-------- Red Corpse
	NE_Unit_Spawner_Corpse_Red = table.deepcopy(data.raw.corpse["biter-spawner-corpse"])
	NE_Unit_Spawner_Corpse_Red.name = "ne-spawner-red-corpse"
	NE_Unit_Spawner_Corpse_Red.time_before_removed = 10 * 60 * 60
	NE_Unit_Spawner_Corpse_Red.animation =
		{
		  spawner_die_animation(0, ne_fire_tint2),
		  spawner_die_animation(1, ne_fire_tint2),
		  spawner_die_animation(2, ne_fire_tint2),
		  spawner_die_animation(3, ne_fire_tint2)
		}
		
	data:extend{NE_Unit_Spawner_Corpse_Red}		
		
end

--- Green - Fast Biters and Unit-Launching Spitters
if settings.startup["NE_Green_Spawners"].value then

	NE_Unit_Spawner_Green = table.deepcopy(data.raw["unit-spawner"]["ne-spawner-base"])
	NE_Unit_Spawner_Green.name = "ne-spawner-green"
	NE_Unit_Spawner_Green.corpse = "ne-spawner-green-corpse"
	NE_Unit_Spawner_Green.autoplace = enemy_autoplace.enemy_spawner_autoplace(0)
	NE_Unit_Spawner_Green.resistances =
		{
		  {
			type = "physical",
			decrease = 2,
			percent = 15
		  },
		  {
			type = "explosion",
			decrease = 5,
			percent = 15
		  },
		  {
			type = "fire",
			decrease = 5,
			percent = 50
		  },
		  {
			type = "ne_fire",
			percent = 100
		  },
		  {
			type = "acid",
			percent = 100
		  }
		}
	NE_Unit_Spawner_Green.animations =
		{
		  spawner_idle_animation(0, ne_green_tint),
		  spawner_idle_animation(1, ne_green_tint),
		  spawner_idle_animation(2, ne_green_tint),
		  spawner_idle_animation(3, ne_green_tint)
		}
	NE_Unit_Spawner_Green.result_units = (function()
						 local res = {}
							res[1] = {"ne-biter-fast-1", {{0,0.1}, {0.1,0.3}, {0.2,0}}}
							res[2] = {"ne-spitter-ulaunch-1", {{0.025,0}, {0.125,0.3}, {0.225,0}}}
							res[3] = {"ne-biter-fast-2", {{0.05,0}, {0.15,0.3}, {0.25,0}}}
							res[4] = {"ne-spitter-ulaunch-2", {{0.075,0}, {0.175,0.3}, {0.275,0}}}
							res[5] = {"ne-biter-fast-3", {{0.1,0}, {0.2,0.3}, {0.3,0}}}
							res[6] = {"ne-spitter-ulaunch-3", {{0.125,0}, {0.225,0.3}, {0.325,0}}}
							res[7] = {"ne-biter-fast-4", {{0.15,0}, {0.25,0.3}, {0.35,0}}}
							res[8] = {"ne-spitter-ulaunch-4", {{0.175,0}, {0.275,0.3}, {0.375,0}}}
							res[9] = {"ne-biter-fast-5", {{0.2,0}, {0.3,0.3}, {0.4,0}}}
							res[10] = {"ne-spitter-ulaunch-5", {{0.225,0}, {0.325,0.3}, {0.425,0}}}
							res[11] = {"ne-biter-fast-6", {{0.25,0}, {0.35,0.3}, {0.45,0}}}
							res[12] = {"ne-spitter-ulaunch-6", {{0.275,0}, {0.375,0.3}, {0.475,0}}}
							res[13] = {"ne-biter-fast-7", {{0.3,0}, {0.4,0.3}, {0.5,0}}}
							res[14] = {"ne-spitter-ulaunch-7", {{0.325,0}, {0.425,0.3}, {0.525,0}}}
							res[15] = {"ne-biter-fast-8", {{0.35,0}, {0.45,0.3}, {0.55,0}}}
							res[16] = {"ne-spitter-ulaunch-8", {{0.375,0}, {0.475,0.3}, {0.575,0}}}
							res[17] = {"ne-biter-fast-9", {{0.4,0}, {0.5,0.3}, {0.6,0}}}
							res[18] = {"ne-spitter-ulaunch-9", {{0.425,0}, {0.525,0.3}, {0.625,0}}}
							res[19] = {"ne-biter-fast-10", {{0.45,0}, {0.55,0.3}, {0.65,0}}}
							res[20] = {"ne-spitter-ulaunch-10", {{0.475,0}, {0.575,0.3}, {0.675,0}}}
							res[21] = {"ne-biter-fast-11", {{0.5,0}, {0.6,0.3}, {0.7,0}}}
							res[22] = {"ne-spitter-ulaunch-11", {{0.525,0}, {0.625,0.3}, {0.725,0}}}
							res[23] = {"ne-biter-fast-12", {{0.55,0}, {0.65,0.3}, {0.75,0}}}
							res[24] = {"ne-spitter-ulaunch-12", {{0.575,0}, {0.675,0.3}, {0.775,0}}}
							res[25] = {"ne-biter-fast-13", {{0.6,0}, {0.7,0.3}, {0.8,0}}}
							res[26] = {"ne-spitter-ulaunch-13", {{0.625,0}, {0.725,0.3}, {0.825,0}}}
							res[27] = {"ne-biter-fast-14", {{0.65,0}, {0.75,0.3}, {0.85,0}}}
							res[28] = {"ne-spitter-ulaunch-14", {{0.675,0}, {0.775,0.3}, {0.875,0}}}
							res[29] = {"ne-biter-fast-15", {{0.7,0}, {0.8,0.3}, {0.9,0}}}
							res[30] = {"ne-spitter-ulaunch-15", {{0.725,0}, {0.825,0.3}, {0.925,0}}}
							res[31] = {"ne-biter-fast-16", {{0.75,0}, {0.85,0.3}, {0.95,0}}}
							res[32] = {"ne-spitter-ulaunch-16", {{0.775,0}, {0.875,0.3}, {0.975,0}}}
							res[33] = {"ne-biter-fast-17", {{0.8,0}, {0.9,0.3}, {0.99,0}}}
							res[34] = {"ne-spitter-ulaunch-17", {{0.825,0}, {0.925,0.3}, {0.99,0}}}
							res[35] = {"ne-biter-fast-18", {{0.85,0}, {0.95,0.3}, {0.99,0}}}
							res[36] = {"ne-spitter-ulaunch-18", {{0.875,0}, {0.975,0.3}, {0.99,0}}}
							res[37] = {"ne-biter-fast-19", {{0.9,0}, {1,0.1}}}
							res[38] = {"ne-spitter-ulaunch-19", {{0.925,0}, {1,0.15}}}
							res[39] = {"ne-biter-fast-20", {{0.95,0}, {1,0.2}}}
							res[40] = {"ne-spitter-ulaunch-20", {{0.975,0}, {1,0.25}}}
							if settings.startup["NE_Challenge_Mode"].value == true then
							res[41] = {"ne-biter-megalodon", {{0.98,0.1}, {1,0.5}}}
							end
						 return res
					   end)()
					   
	data:extend{NE_Unit_Spawner_Green}

	-------- Green Corpse
	NE_Unit_Spawner_Corpse_Green = table.deepcopy(data.raw.corpse["biter-spawner-corpse"])
	NE_Unit_Spawner_Corpse_Green.name = "ne-spawner-green-corpse"
	NE_Unit_Spawner_Corpse_Green.time_before_removed = 10 * 60 * 60
	NE_Unit_Spawner_Corpse_Green.animation =
		{
		  spawner_die_animation(0, ne_green_tint),
		  spawner_die_animation(1, ne_green_tint),
		  spawner_die_animation(2, ne_green_tint),
		  spawner_die_animation(3, ne_green_tint)
		}
		
	data:extend{NE_Unit_Spawner_Corpse_Green}	
	
end

--- Yellow - Wall-Breaker Biters and Web Shooting Spitters
if settings.startup["NE_Yellow_Spawners"].value then

	NE_Unit_Spawner_Yellow = table.deepcopy(data.raw["unit-spawner"]["ne-spawner-base"])
	NE_Unit_Spawner_Yellow.name = "ne-spawner-yellow"
	NE_Unit_Spawner_Yellow.corpse = "ne-spawner-yellow-corpse"
	NE_Unit_Spawner_Yellow.autoplace = enemy_autoplace.enemy_spawner_autoplace(0)
	NE_Unit_Spawner_Yellow.resistances =
		{
		  {
			type = "physical",
			decrease = 2,
			percent = 15
		  },
		  {
			type = "explosion",
			decrease = 5,
			percent = 15
		  },
		  {
			type = "fire",
			decrease = 5,
			percent = 50
		  },
		  {
			type = "ne_fire",
			percent = 100
		  },
		  {
			type = "poison",
			percent = 100
		  }
		}
	NE_Unit_Spawner_Yellow.animations =
		{
		  spawner_idle_animation(0, ne_yellow_tint),
		  spawner_idle_animation(1, ne_yellow_tint),
		  spawner_idle_animation(2, ne_yellow_tint),
		  spawner_idle_animation(3, ne_yellow_tint)
		}
	NE_Unit_Spawner_Yellow.result_units = (function()
						 local res = {}
							res[1] = {"ne-biter-wallbreaker-1", {{0,0.1}, {0.1,0.3}, {0.2,0}}}
							res[2] = {"ne-spitter-webshooter-1", {{0.025,0}, {0.125,0.3}, {0.225,0}}}
							res[3] = {"ne-biter-wallbreaker-2", {{0.05,0}, {0.15,0.3}, {0.25,0}}}
							res[4] = {"ne-spitter-webshooter-2", {{0.075,0}, {0.175,0.3}, {0.275,0}}}
							res[5] = {"ne-biter-wallbreaker-3", {{0.1,0}, {0.2,0.3}, {0.3,0}}}
							res[6] = {"ne-spitter-webshooter-3", {{0.125,0}, {0.225,0.3}, {0.325,0}}}
							res[7] = {"ne-biter-wallbreaker-4", {{0.15,0}, {0.25,0.3}, {0.35,0}}}
							res[8] = {"ne-spitter-webshooter-4", {{0.175,0}, {0.275,0.3}, {0.375,0}}}
							res[9] = {"ne-biter-wallbreaker-5", {{0.2,0}, {0.3,0.3}, {0.4,0}}}
							res[10] = {"ne-spitter-webshooter-5", {{0.225,0}, {0.325,0.3}, {0.425,0}}}
							res[11] = {"ne-biter-wallbreaker-6", {{0.25,0}, {0.35,0.3}, {0.45,0}}}
							res[12] = {"ne-spitter-webshooter-6", {{0.275,0}, {0.375,0.3}, {0.475,0}}}
							res[13] = {"ne-biter-wallbreaker-7", {{0.3,0}, {0.4,0.3}, {0.5,0}}}
							res[14] = {"ne-spitter-webshooter-7", {{0.325,0}, {0.425,0.3}, {0.525,0}}}
							res[15] = {"ne-biter-wallbreaker-8", {{0.35,0}, {0.45,0.3}, {0.55,0}}}
							res[16] = {"ne-spitter-webshooter-8", {{0.375,0}, {0.475,0.3}, {0.575,0}}}
							res[17] = {"ne-biter-wallbreaker-9", {{0.4,0}, {0.5,0.3}, {0.6,0}}}
							res[18] = {"ne-spitter-webshooter-9", {{0.425,0}, {0.525,0.3}, {0.625,0}}}
							res[19] = {"ne-biter-wallbreaker-10", {{0.45,0}, {0.55,0.3}, {0.65,0}}}
							res[20] = {"ne-spitter-webshooter-10", {{0.475,0}, {0.575,0.3}, {0.675,0}}}
							res[21] = {"ne-biter-wallbreaker-11", {{0.5,0}, {0.6,0.3}, {0.7,0}}}
							res[22] = {"ne-spitter-webshooter-11", {{0.525,0}, {0.625,0.3}, {0.725,0}}}
							res[23] = {"ne-biter-wallbreaker-12", {{0.55,0}, {0.65,0.3}, {0.75,0}}}
							res[24] = {"ne-spitter-webshooter-12", {{0.575,0}, {0.675,0.3}, {0.775,0}}}
							res[25] = {"ne-biter-wallbreaker-13", {{0.6,0}, {0.7,0.3}, {0.8,0}}}
							res[26] = {"ne-spitter-webshooter-13", {{0.625,0}, {0.725,0.3}, {0.825,0}}}
							res[27] = {"ne-biter-wallbreaker-14", {{0.65,0}, {0.75,0.3}, {0.85,0}}}
							res[28] = {"ne-spitter-webshooter-14", {{0.675,0}, {0.775,0.3}, {0.875,0}}}
							res[29] = {"ne-biter-wallbreaker-15", {{0.7,0}, {0.8,0.3}, {0.9,0}}}
							res[30] = {"ne-spitter-webshooter-15", {{0.725,0}, {0.825,0.3}, {0.925,0}}}
							res[31] = {"ne-biter-wallbreaker-16", {{0.75,0}, {0.85,0.3}, {0.95,0}}}
							res[32] = {"ne-spitter-webshooter-16", {{0.775,0}, {0.875,0.3}, {0.975,0}}}
							res[33] = {"ne-biter-wallbreaker-17", {{0.8,0}, {0.9,0.3}, {0.99,0}}}
							res[34] = {"ne-spitter-webshooter-17", {{0.825,0}, {0.925,0.3}, {0.99,0}}}
							res[35] = {"ne-biter-wallbreaker-18", {{0.85,0}, {0.95,0.3}, {0.99,0}}}
							res[36] = {"ne-spitter-webshooter-18", {{0.875,0}, {0.975,0.3}, {0.99,0}}}
							res[37] = {"ne-biter-wallbreaker-19", {{0.9,0}, {1,0.1}}}
							res[38] = {"ne-spitter-webshooter-19", {{0.925,0}, {1,0.15}}}
							res[39] = {"ne-biter-wallbreaker-20", {{0.95,0}, {1,0.2}}}
							res[40] = {"ne-spitter-webshooter-20", {{0.975,0}, {1,0.25}}}
							if settings.startup["NE_Challenge_Mode"].value == true then
							res[41] = {"ne-biter-megalodon", {{0.98,0.1}, {1,0.5}}}
							end
						 return res
					   end)()
						   
	data:extend{NE_Unit_Spawner_Yellow}

	-------- Yellow Corpse
	NE_Unit_Spawner_Corpse_Yellow = table.deepcopy(data.raw.corpse["biter-spawner-corpse"])
	NE_Unit_Spawner_Corpse_Yellow.name = "ne-spawner-yellow-corpse"
	NE_Unit_Spawner_Corpse_Yellow.time_before_removed = 10 * 60 * 60
	NE_Unit_Spawner_Corpse_Yellow.animation =
		{
		  spawner_die_animation(0, ne_yellow_tint),
		  spawner_die_animation(1, ne_yellow_tint),
		  spawner_die_animation(2, ne_yellow_tint),
		  spawner_die_animation(3, ne_yellow_tint)
		}
		
	data:extend{NE_Unit_Spawner_Corpse_Yellow}		
	
end

--- Pink/Purple - Tank Biters and Mine-Laying Spitters
if settings.startup["NE_Pink_Spawners"].value then

	NE_Unit_Spawner_Pink = table.deepcopy(data.raw["unit-spawner"]["ne-spawner-base"])
	NE_Unit_Spawner_Pink.name = "ne-spawner-pink"
	NE_Unit_Spawner_Pink.corpse = "ne-spawner-pink-corpse"
	NE_Unit_Spawner_Pink.max_health = 1500 + (500 * NE_Enemies.Settings.NE_Difficulty) -- v 350,
	NE_Unit_Spawner_Pink.autoplace = enemy_autoplace.enemy_spawner_autoplace(0)
	NE_Unit_Spawner_Pink.resistances =
		{
		  {
			type = "physical",
			decrease = 2,
			percent = 15
		  },
		  {
			type = "explosion",
			decrease = 5,
			percent = 15
		  },
		  {
			type = "fire",
			decrease = 5,
			percent = 50
		  },
		  {
			type = "ne_fire",
			percent = 100
		  },
		}
	NE_Unit_Spawner_Pink.animations =
		{
		  spawner_idle_animation(0, ne_pink_tint),
		  spawner_idle_animation(1, ne_pink_tint),
		  spawner_idle_animation(2, ne_pink_tint),
		  spawner_idle_animation(3, ne_pink_tint)
		}
	NE_Unit_Spawner_Pink.result_units = (function()
						 local res = {}
							res[1] = {"ne-biter-tank-1", {{0,0.1}, {0.1,0.3}, {0.2,0}}}
							res[2] = {"ne-spitter-mine-1", {{0.025,0}, {0.125,0.3}, {0.225,0}}}
							res[3] = {"ne-biter-tank-2", {{0.05,0}, {0.15,0.3}, {0.25,0}}}
							res[4] = {"ne-spitter-mine-2", {{0.075,0}, {0.175,0.3}, {0.275,0}}}
							res[5] = {"ne-biter-tank-3", {{0.1,0}, {0.2,0.3}, {0.3,0}}}
							res[6] = {"ne-spitter-mine-3", {{0.125,0}, {0.225,0.3}, {0.325,0}}}
							res[7] = {"ne-biter-tank-4", {{0.15,0}, {0.25,0.3}, {0.35,0}}}
							res[8] = {"ne-spitter-mine-4", {{0.175,0}, {0.275,0.3}, {0.375,0}}}
							res[9] = {"ne-biter-tank-5", {{0.2,0}, {0.3,0.3}, {0.4,0}}}
							res[10] = {"ne-spitter-mine-5", {{0.225,0}, {0.325,0.3}, {0.425,0}}}
							res[11] = {"ne-biter-tank-6", {{0.25,0}, {0.35,0.3}, {0.45,0}}}
							res[12] = {"ne-spitter-mine-6", {{0.275,0}, {0.375,0.3}, {0.475,0}}}
							res[13] = {"ne-biter-tank-7", {{0.3,0}, {0.4,0.3}, {0.5,0}}}
							res[14] = {"ne-spitter-mine-7", {{0.325,0}, {0.425,0.3}, {0.525,0}}}
							res[15] = {"ne-biter-tank-8", {{0.35,0}, {0.45,0.3}, {0.55,0}}}
							res[16] = {"ne-spitter-mine-8", {{0.375,0}, {0.475,0.3}, {0.575,0}}}
							res[17] = {"ne-biter-tank-9", {{0.4,0}, {0.5,0.3}, {0.6,0}}}
							res[18] = {"ne-spitter-mine-9", {{0.425,0}, {0.525,0.3}, {0.625,0}}}
							res[19] = {"ne-biter-tank-10", {{0.45,0}, {0.55,0.3}, {0.65,0}}}
							res[20] = {"ne-spitter-mine-10", {{0.475,0}, {0.575,0.3}, {0.675,0}}}
							res[21] = {"ne-biter-tank-11", {{0.5,0}, {0.6,0.3}, {0.7,0}}}
							res[22] = {"ne-spitter-mine-11", {{0.525,0}, {0.625,0.3}, {0.725,0}}}
							res[23] = {"ne-biter-tank-12", {{0.55,0}, {0.65,0.3}, {0.75,0}}}
							res[24] = {"ne-spitter-mine-12", {{0.575,0}, {0.675,0.3}, {0.775,0}}}
							res[25] = {"ne-biter-tank-13", {{0.6,0}, {0.7,0.3}, {0.8,0}}}
							res[26] = {"ne-spitter-mine-13", {{0.625,0}, {0.725,0.3}, {0.825,0}}}
							res[27] = {"ne-biter-tank-14", {{0.65,0}, {0.75,0.3}, {0.85,0}}}
							res[28] = {"ne-spitter-mine-14", {{0.675,0}, {0.775,0.3}, {0.875,0}}}
							res[29] = {"ne-biter-tank-15", {{0.7,0}, {0.8,0.3}, {0.9,0}}}
							res[30] = {"ne-spitter-mine-15", {{0.725,0}, {0.825,0.3}, {0.925,0}}}
							res[31] = {"ne-biter-tank-16", {{0.75,0}, {0.85,0.3}, {0.95,0}}}
							res[32] = {"ne-spitter-mine-16", {{0.775,0}, {0.875,0.3}, {0.975,0}}}
							res[33] = {"ne-biter-tank-17", {{0.8,0}, {0.9,0.3}, {0.99,0}}}
							res[34] = {"ne-spitter-mine-17", {{0.825,0}, {0.925,0.3}, {0.99,0}}}
							res[35] = {"ne-biter-tank-18", {{0.85,0}, {0.95,0.3}, {0.99,0}}}
							res[36] = {"ne-spitter-mine-18", {{0.875,0}, {0.975,0.3}, {0.99,0}}}
							res[37] = {"ne-biter-tank-19", {{0.9,0}, {1,0.1}}}
							res[38] = {"ne-spitter-mine-19", {{0.925,0}, {1,0.15}}}
							res[39] = {"ne-biter-tank-20", {{0.95,0}, {1,0.2}}}
							res[40] = {"ne-spitter-mine-20", {{0.975,0}, {1,0.25}}}
							if settings.startup["NE_Challenge_Mode"].value == true then
							res[41] = {"ne-biter-megalodon", {{0.98,0.1}, {1,0.5}}}
							end
						 return res
					   end)()
						   
	data:extend{NE_Unit_Spawner_Pink}

	-------- Pink Corpse

	NE_Unit_Spawner_Corpse_Pink = table.deepcopy(data.raw.corpse["biter-spawner-corpse"])
	NE_Unit_Spawner_Corpse_Pink.name = "ne-spawner-pink-corpse"
	NE_Unit_Spawner_Corpse_Pink.time_before_removed = 10 * 60 * 60
	NE_Unit_Spawner_Corpse_Pink.animation =
		{
		  spawner_die_animation(0, ne_pink_tint),
		  spawner_die_animation(1, ne_pink_tint),
		  spawner_die_animation(2, ne_pink_tint),
		  spawner_die_animation(3, ne_pink_tint)
		}
		
	data:extend{NE_Unit_Spawner_Corpse_Pink}	
	
end


