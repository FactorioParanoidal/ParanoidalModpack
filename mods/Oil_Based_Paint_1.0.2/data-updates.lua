-- path
local modpath     = "__Oil_Based_Paint__/"
local icons_path  = modpath .. "graphics/icons/"
local entity_path = modpath .. "graphics/entity/"

-- take an anim_table and duplicate anim_table.layers[2]
local function saturate(anim_table, copy_index, bool_at_index, greyscale_tint)
	-- TODO check that anim_table exists
	if anim_table then
		if anim_table.layers then
			if anim_table.layers[copy_index or 2] then
				-- duplicate mask with additive to achieve greater saturation
				local additive_layer = table.deepcopy(anim_table.layers[copy_index or 2])
				additive_layer.blend_mode = "additive"
				if additive_layer.hr_version then
					additive_layer.hr_version.blend_mode = "additive"
				end

				-- If given an insert_index, insert at that index, or else, insert at end
				if bool_at_index == true then
					table.insert(anim_table.layers, copy_index, additive_layer)
					table.insert(anim_table.layers, copy_index, additive_layer)
				else
					table.insert(anim_table.layers, additive_layer)
					table.insert(anim_table.layers, additive_layer)
				end
			end
		end
	end
end

-- Character
local char_anim = data.raw.character.character.animations
saturate(char_anim[1].idle)
saturate(char_anim[1].idle_with_gun)
saturate(char_anim[1].mining_with_tool)
saturate(char_anim[1].running)
saturate(char_anim[1].running_with_gun)
-- Character corpse
local corpse_pics = data.raw["character-corpse"]["character-corpse"].pictures
saturate(corpse_pics[1])

for armor = 2, 3 do -- For Heavy Armor and beyond
	for layer = 4, 2, -2 do -- For layer 4 then layer 2
		-- Copy 4 and insert before 5, then copy 2 and insert before THAT.
		saturate(char_anim[armor].idle, layer, true)
		saturate(char_anim[armor].idle_with_gun, layer, true)
		saturate(char_anim[armor].mining_with_tool, layer, true)
		saturate(char_anim[armor].running, layer, true)
		saturate(char_anim[armor].running_with_gun, layer, true)
		saturate(corpse_pics[armor], layer, true)
	end
end

-- Distractor Robot, does not have remnant mask
saturate(data.raw["combat-robot"]["distractor"].idle)
saturate(data.raw["combat-robot"]["distractor"].in_motion)

-- Car
saturate(data.raw.car.car.animation)
saturate(data.raw.corpse["car-remnants"].animation)
-- Tank
saturate(data.raw.car.tank.animation)
saturate(data.raw.car.tank.turret_animation)
saturate(data.raw.corpse["tank-remnants"].animation)
-- Flame Tank
if data.raw.car["vehicle-flame-tank"] then
	local flame_tank = data.raw.car["vehicle-flame-tank"]
	saturate(flame_tank.animation)
	saturate(flame_tank.turret_animation)
	-- Flame tank new remnant
	flame_tank.corpse = { "flamethrower-turret-remnants", "tank-remnants" }
end
-- Laser Tank
if data.raw.car["vehicle-laser-tank"] then
	local laser_tank = data.raw.car["vehicle-laser-tank"]
	saturate(laser_tank.animation)
	saturate(laser_tank.turret_animation)
	-- Flame tank new remnant
	laser_tank.corpse = { "laser-turret-remnants", "tank-remnants" }
end
-- Ironclad
if data.raw.car.ironclad then
	local ironclad = data.raw.car.ironclad
	saturate(ironclad.animation)
	saturate(ironclad.turret_animation)
	-- Ironclad new remnant
	ironclad.corpse = { "flamethrower-turret-remnants", "locomotive-remnants" }
end
-- Warden
if data.raw.car["vehicle-warden"] then
	local warden = data.raw.car["vehicle-warden"]

	-- Replace main pics to fit with Factorio
	for i = 1, 6, 1 do
		warden.animation.layers[1].stripes[i].filename = entity_path .. "warden/warden-main-" .. i .. ".png"
		warden.animation.layers[2].stripes[i].filename = entity_path .. "warden/warden-main-mask-" .. i .. ".png"
	end

	warden.turret_animation.layers[1].stripes[1].filename = entity_path .. "warden/warden-turret.png"
	warden.turret_animation.layers[2].stripes[1].filename = entity_path .. "warden/warden-turret-mask.png"

	saturate(warden.animation)
	saturate(warden.animation)
	saturate(warden.turret_animation)
	saturate(warden.turret_animation)
end
-- One More Hovercraft
if data.raw.car["hcraft-entity"] then
	saturate(data.raw.car["hcraft-entity"].animation) -- without gun turret
	saturate(data.raw.car["acraft-entity"].animation) -- gun "assault hover craft"
	saturate(data.raw.corpse["hovercraft-remnants"].animation)
end

-- Locomotive
saturate(data.raw["locomotive"]["locomotive"].pictures)
saturate(data.raw.corpse["locomotive-remnants"].animation)

-- Cargo Wagon
saturate(data.raw["cargo-wagon"]["cargo-wagon"].pictures)
saturate(data.raw["cargo-wagon"]["cargo-wagon"].horizontal_doors, 5, true) --top
saturate(data.raw["cargo-wagon"]["cargo-wagon"].horizontal_doors, 3, true) --side
saturate(data.raw["cargo-wagon"]["cargo-wagon"].vertical_doors, 5, true) --top
saturate(data.raw["cargo-wagon"]["cargo-wagon"].vertical_doors, 3, true) --side
-- Cargo Wagon remnants do not have color mask

-- Fluid Wagon
if mods["FluidWagonColorMask"] then
	saturate(data.raw["fluid-wagon"]["fluid-wagon"].pictures, 3)
	-- Fluid Wagon remnants do not have color mask
end

-- Train Stop
for _, direction in ipairs { "east", "north", "south", "west" } do
	saturate(data.raw["train-stop"]["train-stop"].top_animations[direction])
	saturate(data.raw.corpse["train-stop-remnants"].animation)
end

-- Spidertron
saturate(data.raw["spider-vehicle"]["spidertron"].graphics_set.animation)
saturate(data.raw["spider-vehicle"]["spidertron"].graphics_set.base_animation)
for leg = 1, 8, 1 do
	local gfx = data.raw["spider-leg"]["spidertron-leg-" .. leg].graphics_set
	saturate(gfx.joint)
	saturate(gfx.lower_part.top_end)
	saturate(gfx.lower_part.bottom_end)
	saturate(gfx.upper_part.top_end)
	saturate(gfx.upper_part.bottom_end)
end
-- Spiderling from Spider Patrols
if data.raw["spider-vehicle"]["sp-spiderling"] then
	local spiderling = data.raw["spider-vehicle"]["sp-spiderling"]
	saturate(spiderling.graphics_set.animation)
	saturate(spiderling.graphics_set.base_animation)
	for leg = 1, 8, 1 do
		local gfx = data.raw["spider-leg"]["sp-spiderling-leg-" .. leg].graphics_set
		saturate(gfx.joint)
		saturate(gfx.lower_part.top_end)
		saturate(gfx.lower_part.bottom_end)
		saturate(gfx.upper_part.top_end)
		saturate(gfx.upper_part.bottom_end)
	end
end
saturate(data.raw.corpse["spidertron-remnants"].animation[1])

-- Gun Turret
saturate(data.raw["ammo-turret"]["gun-turret"].attacking_animation)
saturate(data.raw["ammo-turret"]["gun-turret"].base_picture)
saturate(data.raw["ammo-turret"]["gun-turret"].folded_animation)
saturate(data.raw["ammo-turret"]["gun-turret"].folding_animation)
saturate(data.raw["ammo-turret"]["gun-turret"].prepared_animation)
saturate(data.raw["ammo-turret"]["gun-turret"].preparing_animation)
saturate(data.raw.corpse["gun-turret-remnants"].animation[1])
saturate(data.raw.corpse["gun-turret-remnants"].animation[2])
saturate(data.raw.corpse["gun-turret-remnants"].animation[3])

-- Laser Turret
local laser_turret = data.raw["electric-turret"]["laser-turret"]

-- Was missing mask
local base_mask = table.deepcopy(laser_turret.base_picture.layers[1])
if base_mask.hr_version then
	base_mask.hr_version.filename = entity_path .. "laser-turret/hr-base-mask.png"
	base_mask.hr_version.apply_runtime_tint = true
	base_mask.hr_version.flags = { "mask" }
	table.insert(laser_turret.base_picture.layers, base_mask)
end

saturate(laser_turret.base_picture, 3)
saturate(laser_turret.folded_animation, 3)
saturate(laser_turret.folding_animation, 3)
saturate(laser_turret.prepared_animation, 3)
saturate(laser_turret.preparing_animation, 3)
saturate(data.raw.corpse["laser-turret-remnants"].animation[1])
saturate(data.raw.corpse["laser-turret-remnants"].animation[2])
saturate(data.raw.corpse["laser-turret-remnants"].animation[3])

-- Flamethrower Turret
local flamethrower = data.raw["fluid-turret"]["flamethrower-turret"]
for _, direction in ipairs { "east", "north", "south", "west" } do
	saturate(flamethrower.attacking_animation[direction], 4)
	saturate(flamethrower.base_picture[direction])
	saturate(flamethrower.ending_attack_animation[direction], 4)
	saturate(flamethrower.folded_animation[direction])
	saturate(flamethrower.folding_animation[direction])
	saturate(flamethrower.prepared_animation[direction])
	saturate(flamethrower.preparing_animation[direction])
end
saturate(data.raw.corpse["flamethrower-turret-remnants"].animation)

-- Spidertron remote inventory item
local remote = data.raw["spidertron-remote"]["spidertron-remote"]
remote.icon = icons_path .. "spidertron-remote.png"
-- Double the indicator mask for darker blacks and more saturation
remote.icon_color_indicator_mask = nil
remote.icon_color_indicator_masks = {
	{
		icon_color_indicator_mask = icons_path .. "spidertron-remote-mask.png",
		icon_size = 64
	},
	{
		icon_color_indicator_mask = icons_path .. "spidertron-remote-mask.png",
		icon_size = 64
	}
}

-- Also double the indicator mask on Spidertron Patrols remote
if data.raw["spidertron-remote"]["sp-spidertron-patrol-remote"] then
	remote = data.raw["spidertron-remote"]["sp-spidertron-patrol-remote"]
	remote.icon_color_indicator_mask = nil
	remote.icon_color_indicator_masks = {
		{
			icon_color_indicator_mask = icons_path .. "spidertron-remote-mask.png",
			icon_size = 64
		},
		{
			icon_color_indicator_mask = icons_path .. "spidertron-remote-mask.png",
			icon_size = 64
		}
	}
end

-- Spidertron technology
local spidertron_tech = data.raw["technology"]["spidertron"]
spidertron_tech.icon = icons_path .. "technology.png"
