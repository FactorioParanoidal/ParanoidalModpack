local function flatten(tables)
    local result = {} for _,t in ipairs(tables) do
        for _,v in ipairs(t) do table.insert(result, v) end
    end return result
end



local function Setting(setting)
	setting.name = "realistic-reactors-" .. setting.name
	setting.type = setting.type .. "-setting"
	return setting
end

local function StartupSetting(setting)
	setting.setting_type = "startup"
	return Setting(setting)
end

local function MapSetting(setting)
	setting.setting_type = "runtime-global"
	return Setting(setting)
end

local function RuntimeSetting(setting)
	setting.setting_type = "runtime-per-user"
	return Setting(setting)
end




if mods["base"] then
	data:extend{
		StartupSetting{
			type = "bool",
			name = "disable-vanilla-reactor",
			default_value = true,
			order="a1",
		},
	}
end




data:extend{
	StartupSetting{
		type = "bool",
		name = "disable-reactor-light",
		default_value = false,
		order="a2",
	},
	StartupSetting{
		type = "string",
		name = "fallout-appearance",
		default_value = "half-transparent",
		allowed_values = {
			"invisible",
			"half-transparent",
			"less-transparent",
			"green-veil",
		},
		order="a3",
	},
	StartupSetting{
		type = "int",
		name = "clouds-generation",
		default_value = 200,
		maximum_value = 9999999,
		minimum_value = 0,
		order = "a4",
	},
	StartupSetting{
		type = "int",
		name = "clouds-duration",
		default_value = 80,
		minimum_value = 1,
		maximum_value = 9999999,
		order="a5",
	},
	StartupSetting{
		type = "int",
		name = "fallout-duration",
		default_value = 600,
		minimum_value = 1,
		maximum_value = 9999999,
		order="a6",
	},
	StartupSetting{
		type = "int",
		name = "sarcophagus-duration",
		default_value = 1800,
		minimum_value = 1,
		maximum_value = 9999999,
		order="a7",
	},
	MapSetting{
		type = "string",
		name = "calculate-stats-function",
		default_value = "ingo",
		allowed_values = {
			"ownly",
			"ingo",
		},
		order="b1",
	},
	MapSetting{
		type = "int",
		name = "reactor-scram-duration",
		default_value = 180,
		minimum_value = 1,
		order="b2",
	},
	MapSetting{
		type = "int",
		name = "reactor-starting-duration",
		default_value = 30,
		minimum_value = 1,
		order="b3",
	},
	MapSetting{
		type = "double",
		name = "energy-consumption-multiplier",
		default_value = 1,
		maximum_value = 2.5,
		minimum_value = 0,
		order = "b4",
	},
	MapSetting{
		type = "bool",
		name = "static-cooling-power-consumption",
		default_value = true,
		order="b5",
	},
	MapSetting{
		type = "string",
		name = "scram-behaviour",
		default_value = "limit-to-current-cell",
		allowed_values = {
			"limit-to-current-cell",
			"stop-half-empty",
			"consume-additional-cell",
			"decay-heat-v1",
		},
		order="b6",
	},
	MapSetting{
		type = "string",
		name = "explosion-mode",
		default_value = "meltdown",
		allowed_values = flatten{
			{
				"meltdown",
			},
			not mods["True-Nukes"] and {} or {
				"really-very-small-atomic-bomb-projectile",
				"very-small-atomic-bomb-projectile",
				"small-atomic-bomb-projectile",
				"atomic-rocket",
				"big-atomic-bomb-projectile",
				"very-big-atomic-bomb-projectile",
				"thermobaric-rocket",
			},
			not mods["PlutoniumEnergy"] and {} or {
				"plutonium-atomic-rocket",
			},
		},
		order="b7",
	},
}
