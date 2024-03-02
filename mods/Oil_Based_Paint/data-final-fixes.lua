-- path
local modpath = "__Oil_Based_Paint__/"
local icons_path = modpath .. "graphics/icons/"

local function apply_function_to_layers(table_of_layers, function_name, extra_parameter)
	-- start from last layer, to first layer
	-- if runtime tint, duplicate it
	for _, layers in pairs(table_of_layers) do
		for i = #layers, 1, -1 do
			function_name(layers[i], layers, i, extra_parameter)
		end
	end
end

-- duplicate mask with additive to achieve greater saturation
local function duplicate_mask_layer(layer, parent, index, int_times)
	if layer.apply_runtime_tint and layer.apply_runtime_tint == true then
		for times = 1, (int_times or 1) do
			table.insert(parent, index + 1, layer)
		end
	end
end

-- Find a prototype's animation layers, returns a table of "layers" tables
local function find_animation_layers(prototype)
	local anim_layers = {}

	-- As a backup, will use prototype itself as anim table
	local anim_table = prototype

	-- If entity has more than one of these, only the first will get fixed!
	if prototype.top_animations then
		anim_table = prototype.top_animations -- for train stop
	elseif prototype.graphics_set then
		anim_table = prototype.graphics_set -- for spider and legs
	elseif prototype.animations then
		anim_table = prototype.animations -- for engineer characters. Note that cars also have this, and so therefore so do DMV spider-vehicles. This will get caught if it's before graphics_set!
	elseif prototype.animation then
		anim_table = prototype.animation
		--elseif prototype.pictures then -- removing this check fixes cargo wagon
		--	anim_table = prototype.pictures
	end

	-- Check for Turret animation
	if prototype.turret_animation then
		if prototype.turret_animation.layers then
			table.insert(anim_layers, prototype.turret_animation.layers)
		end
	end

	-- Look deeply through the anim_table to find tables of layers
	if anim_table.layers then
		table.insert(anim_layers, anim_table.layers)
	else
		-- we haven't dug deep enough to get to layers yet.
		for _, anim_table_2 in pairs(anim_table) do
			if type(anim_table_2) == "table" and anim_table_2.layers then
				table.insert(anim_layers, anim_table_2.layers)
			elseif type(anim_table_2) == "table" then
				-- still not deep enough
				for _, anim_table_3 in pairs(anim_table_2) do
					if type(anim_table_3) == "table" and anim_table_3.layers then
						table.insert(anim_layers, anim_table_3.layers)
					end
				end
			end
		end
	end

	--	log(modpath .. "found " .. #anim_layers .. " in " .. prototype.name)
	return anim_layers
end

-----------------------------------------------------------------------
--  Check every prototype we're interested in and try to saturate it.
-----------------------------------------------------------------------
for _, data_type in ipairs({
	"character",
	"character-corpse",

	"cargo-wagon",
	"locomotive",
	"fluid-wagon",
	"train-stop",

	"combat-robot",
	"ammo-turret",
	"electric-turret",
	"fluid-turret",

	"car",
	"spider-vehicle",
	"spider-leg",

	"corpse",
}) do
	for _, prototype in pairs(data.raw[data_type]) do
		if string.match(prototype.name, "%-warden") then
			-- Warden mask needs even more painting
			apply_function_to_layers(find_animation_layers(prototype), duplicate_mask_layer, 4)
		elseif string.match(prototype.type, "cargo%-wagon") then
			-- If you paint a cargo wagon pictures twice,
			-- weird things happen with the doors on top when it's vertical
			apply_function_to_layers(find_animation_layers(prototype), duplicate_mask_layer, 1)
		else
			apply_function_to_layers(find_animation_layers(prototype), duplicate_mask_layer, 2)
		end
	end
end

-- We only need one projectile painted:
apply_function_to_layers(find_animation_layers(data.raw["projectile"]["distractor-capsule"]), duplicate_mask_layer, 2)

------------------------------------
--  Redirect filenames to this mod
------------------------------------
-- replace a mod path name with this mod's path in a filename
local function replace_modpath(table_with_filename, string_match)
	if string.match(table_with_filename.filename, string_match) then
		table_with_filename.filename = string.gsub(table_with_filename.filename, "__.-__/", modpath)
	else
		log(modpath .. "Filename did not match string_match")
	end
end

local function replace_layer_filename(layer, parent, index, string_match)
	-- Change the HR version, but if it doesn't exist, THEN the non-hr!
	if layer.hr_version and layer.hr_version.filename then
		replace_modpath(layer.hr_version, string_match)
	elseif layer.hr_version and layer.hr_version.stripes then
		for i, stripe in pairs(layer.hr_version.stripes) do
			replace_modpath(stripe, string_match)
		end
	elseif layer.filename then
		replace_modpath(layer, string_match)
	elseif layer.stripes then
		log(modpath .. "Found stripes")
		for i, stripe in pairs(layer.stripes) do
			replace_modpath(stripe, string_match)
		end
	else
		log(modpath .. "Could not find any filename entry")
	end
end

local function darken(layers)
	local darken_alpha = 0.5
	-- duplicate mask with additive to achieve greater saturation
	local darken_layer = table.deepcopy(layers[1])
	darken_layer.tint = { 0, 0, 0, darken_alpha }
	if darken_layer.hr_version then
		darken_layer.hr_version.tint = { 0, 0, 0, darken_alpha }
	end
	table.insert(layers, 2, darken_layer)

	-- Hood-mounted turret
	for i, layer in pairs(layers) do
		if layer.filename and string.match(layer.filename, "turret") then
			darken_layer = table.deepcopy(layer)
			darken_layer.tint = { 0, 0, 0, darken_alpha }
			if darken_layer.hr_version then
				darken_layer.hr_version.tint = { 0, 0, 0, darken_alpha }
			end
			table.insert(layers, i + 1, darken_layer)
		end
	end
end

for _, data_type in ipairs({
	"car",
	"spider-vehicle",
}) do
	for _, vehicle in pairs(data.raw[data_type]) do
		if string.match(vehicle.name, "%-warden") then
			local warden_path = modpath .. "graphics/entity/warden/warden-glow-mask-"
			local vehicle_tint = { 0.6, 0.6, 0.6, 1 }
			local turret_tint = { 0.5, 0.65, 0.7, 1 }

			-- Redirect warden "mask" files to this mod
			apply_function_to_layers(find_animation_layers(vehicle), replace_layer_filename, "mask")

			-- Here we're changing the warden texture:
			-- 1. Apply glow mask over the base image
			-- 2. Tint the base image to darken
			-- 3. Glow the turret base
			-- 4. Tint the turret base
			if vehicle.graphics_set then
				-- spider vehicle
				local glow_layer = table.deepcopy(vehicle.graphics_set.animation.layers[1])
				for i, stripe in pairs(glow_layer.stripes) do
					stripe.filename = warden_path .. i .. ".png"
				end
				glow_layer.draw_as_glow = true
				table.insert(vehicle.graphics_set.animation.layers, 7, glow_layer)
				vehicle.graphics_set.animation.layers[1].tint = vehicle_tint
				-- spider vehicle turret
				-- Now create the turret glow layer
				glow_layer = table.deepcopy(vehicle.graphics_set.animation.layers[8])
				glow_layer.draw_as_glow = true
				glow_layer.stripes[1].filename = warden_path .. "turret.png"
				table.insert(vehicle.graphics_set.animation.layers, glow_layer)
				vehicle.graphics_set.animation.layers[8].tint = turret_tint
			elseif vehicle.animations then
				-- car
				local glow_layer = table.deepcopy(vehicle.animations.layers[1])
				for i, stripe in pairs(glow_layer.stripes) do
					stripe.filename = warden_path .. i .. ".png"
				end
				glow_layer.draw_as_glow = true
				table.insert(vehicle.animations.layers, glow_layer)
				vehicle.graphics_set.animation.layers[1].tint = vehicle_tint
				-- car turret
				glow_layer = table.deepcopy(vehicle.turret_animation.layers[1])
				glow_layer.draw_as_glow = true
				glow_layer.stripes[1].filename = warden_path .. "turret.png"
				table.insert(vehicle.turret_animation.layers, glow_layer)
				vehicle.turret_animation.layers[1].tint = turret_tint
			end

			-- New Warden painted remnants
			vehicle.corpse = { "locomotive-remnants", "car-remnants" }
		end

		-- New Flame Tank painted remnant
		if string.match(vehicle.name, "flame%-tank") then
			vehicle.corpse = { "flamethrower-turret-remnants", "tank-remnants" }
		end

		-- New Laser Tank painted remnant
		if string.match(vehicle.name, "laser%-tank") then
			vehicle.corpse = { "laser-turret-remnants", "tank-remnants" }
		end

		-- New Ironclad painted remnant
		if string.match(vehicle.name, "ironclad") then
			vehicle.corpse = { "flamethrower-turret-remnants", "locomotive-remnants" }
		end
	end
end

-------------------------
--    INVENTORY ICONS
-------------------------
-- Spidertron remote inventory item
data.raw["spidertron-remote"]["spidertron-remote"].icon = icons_path .. "spidertron-remote.png"

-- Both Spidertron remote AND Spidertron Patrols remote
for _, remote in pairs(data.raw["spidertron-remote"]) do
	-- Double the indicator mask for darker blacks and more saturation
	remote.icon_color_indicator_mask = nil
	remote.icon_color_indicator_masks = {
		{
			icon_color_indicator_mask = icons_path .. "spidertron-remote-mask.png",
			icon_size = 64,
		},
		{
			icon_color_indicator_mask = icons_path .. "spidertron-remote-mask.png",
			icon_size = 64,
		},
	}
end

-- Spidertron technology
local spidertron_tech = data.raw["technology"]["spidertron"]
spidertron_tech.icon = icons_path .. "technology.png"

-- INVENTORY ICONS: Saturate & achieve darker blacks
for _, item in pairs(data.raw["item-with-entity-data"]) do
	if item.icon_tintable_mask then -- the item has tint
		-- double the color mask
		item.icon_tintable_masks = {
			{ icon_tintable_mask = item.icon_tintable_mask, icon_size = 64 },
			{ icon_tintable_mask = item.icon_tintable_mask, icon_size = 64 },
		}
	end
	item.icon_tintable_mask = nil -- get rid of the singular icon
end
