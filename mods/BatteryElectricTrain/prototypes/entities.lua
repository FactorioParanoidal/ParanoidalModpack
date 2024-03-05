local hit_effects = require("__base__/prototypes/entity/hit-effects")
local sounds      = require("__base__/prototypes/entity/sounds")

local function MakeLocomotive()
	local vanilla_loc = data.raw["locomotive"]["locomotive"]
	if not vanilla_loc then
		error("Required vanilla locomotive not found. Another mod must have removed it.", 0)
	end

	local loc = shallowcopy(vanilla_loc)
	loc.name = name_locomotive

	loc.icon = graphics_path..name_locomotive.."-icon.png"
	loc.icon_size = 64
	loc.icon_mipmaps = 4

	loc.color = {99, 202, 255}

	loc.minable = {
		mining_time = 0.5,
		result = name_locomotive,
	}

	loc.burner = {
		fuel_category = name_cat_fuel_battery,
		fuel_inventory_size = 1,
		burnt_inventory_size = 2,
	}

	if settings.startup[setting_cheatsy_locs].value then
		loc.max_speed = settings.startup[setting_cheatsy_speed].value / 216 -- 1/216 = 1000 / 3600 / 60
		loc.max_power = settings.startup[setting_cheatsy_power].value.."kW"
		local braking_factor = settings.startup[setting_cheatsy_braking].value
		if loc.braking_force then loc.braking_force = loc.braking_force * braking_factor end
		if loc.braking_power then loc.braking_power = loc.braking_power * braking_factor end
	end

	loc.working_sound = {
		sound = {
			filename = sounds_path..name_locomotive..".ogg",
			volume = 0.35
		},
		deactivate_sound = {
			filename = sounds_path..name_locomotive.."-deactivate.ogg",
			volume = 0.35
		},
		match_speed_to_activity = true,
		max_sounds_per_type = 2,
	}

	local grid = settings.startup[setting_equipment_grid].value
	if grid ~= "none" then
		loc.equipment_grid = grid
	end

	return loc
end


local base_charger = {
	type = "furnace",
	icon_size = 32,
	corpse = "medium-remnants",
	dying_explosion = "medium-explosion",
	result_inventory_size = 1,
	source_inventory_size = 1,
	crafting_categories = {name_cat_recipe_chg},
	fast_replaceable_group = name_replace_chargers,
	return_ingredients_on_change = true,
	damaged_trigger_effect	= hit_effects.entity(),
	vehicle_impact_sound	= sounds.generic_impact,
	open_sound		= sounds.machine_open,
	close_sound		= sounds.machine_close,
}

local base_e_furnace = data.raw["furnace"]["electric-furnace"]
if base_e_furnace then
	base_charger.flags			= base_e_furnace.flags
	base_charger.max_health			= base_e_furnace.max_health
	base_charger.collision_box		= base_e_furnace.collision_box
	base_charger.selection_box		= base_e_furnace.selection_box
	base_charger.drawing_box		= base_e_furnace.drawing_box
else
	base_charger.flags			= {"placeable-neutral", "placeable-player", "player-creation"}
	base_charger.max_health			= 300
	base_charger.collision_box		= {{-1.2, -1.2}, {1.2, 1.2}}
	base_charger.selection_box		= {{-1.5, -1.5}, {1.5, 1.5}}
end

local base_accumulator = data.raw["accumulator"]["accumulator"]
if base_accumulator then
	base_charger.working_sound = base_accumulator.working_sound

	if base_accumulator.charge_animation and base_accumulator.charge_animation.layers and base_accumulator.charge_animation.layers[2] then
		local chg_anim = shallowcopy(base_accumulator.charge_animation.layers[2])
		chg_anim.shift = util.by_pixel(0, -10)
		base_charger.working_visualisations = {{ animation = chg_anim }}
	end
else
	log("No charging animation and sound for train battery pack chargers because the vanilla accumulator could not be found.")
end

if mods["space-exploration"] then
	base_charger.se_allow_in_space = true
end

local function MakeCharger(name, speed)
	local chg = shallowcopy(base_charger)
	chg.name = name
	chg.icon = graphics_path..name.."-icon.png"
	chg.minable = {mining_time = 0.5, result = name}
	chg.crafting_speed = speed
	chg.energy_usage = (2*speed).."MW"
	chg.energy_source = {
		type = "electric",
		drain = speed.."kW",
	}
	if name:find("tertiary", 13, true) then
		chg.energy_source.usage_priority = "tertiary"
	else
		chg.energy_source.usage_priority = "secondary-input"
	end
	chg.animation = {
		filename = graphics_path..name..".png",
		priority = "high",
		width = 135,
		height = 93,
		frame_count = 1,
		shift = util.by_pixel(21, 0),
	}
	return chg
end


data:extend({
	MakeLocomotive(),
	MakeCharger(name_chg1, 1),
	MakeCharger(name_chg2, 5),
	MakeCharger(name_chg3, 25),
	MakeCharger(name_chg1t, 1),
	MakeCharger(name_chg2t, 5),
	MakeCharger(name_chg3t, 25),
})
