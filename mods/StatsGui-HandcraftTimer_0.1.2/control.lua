-- SPDX-License-Identifier: MPL-2.0

local flib_format = require("__flib__/format")

local function sensor(player)
	local force = player.force
	if not player.mod_settings[script.mod_name .. ":show-sensor"].value
	   or player.character == nil -- trainsaver and IR3’s intro (likely any other cutscenes too) crash otherwise
	   or player.cheat_mode
	   or player.crafting_queue_size == 0 then
		return
	end
	local energy = 0
	for _, item in ipairs(player.crafting_queue) do
		local recipe = force.recipes[item.recipe]
		energy = energy + recipe.energy * item.count
		if item.index == 1 then
			energy = energy - recipe.energy * player.crafting_queue_progress
		end
	end
	local ticks = energy * 60 / (1 + force.manual_crafting_speed_modifier)
	if player.character ~= nil then
		ticks = ticks / (1 + player.character.character_crafting_speed_modifier)
	end
	return { script.mod_name .. ".sensor", flib_format.time(ticks) }
end
remote.add_interface(script.mod_name, { sensor = sensor })

local function register_sensor()
	if remote.call("StatsGui", "version") == 1 then
		remote.call("StatsGui", "add_sensor", script.mod_name, "sensor")
	end
end
script.on_init(register_sensor)
script.on_load(register_sensor)
