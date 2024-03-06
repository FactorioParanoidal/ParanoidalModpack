require "util"

--- @class MergingChests
MergingChests = MergingChests or { }

MergingChests.mod_name = 'WideChests'
MergingChests.all_types_mod_name = 'WideChestsAllTypes'
MergingChests.unlimited_mod_name = 'WideChestsUnlimited'

function MergingChests.is_mod_active(mod)
	return (mods or script.active_mods)[mod]
end

--- @param value string
function MergingChests.prefix_with_modname(value)
	return MergingChests.mod_name..'_'..value
end

--- @param setting_name string
--- @param chest_name string
--- @return string
function MergingChests.chest_specific_setting_name(setting_name, chest_name)
    return setting_name..'-'..chest_name
end

MergingChests.custom_input_names = {
	rotate_blueprint_clockwise = MergingChests.prefix_with_modname('rotate-blueprint-clockwise'),
	rotate_blueprint_counterclockwise = MergingChests.prefix_with_modname('rotate-blueprint-couterclockwise')
}

MergingChests.item_group_names = {
	merged_chests = MergingChests.prefix_with_modname('merged-chests'),
	wide_chests = MergingChests.prefix_with_modname('wide-chests'),
	high_chests = MergingChests.prefix_with_modname('high-chests'),
	warehouses = MergingChests.prefix_with_modname('warehouses'),
	trashdumps = MergingChests.prefix_with_modname('trashdumps'),
}

MergingChests.merge_selection_tool_name = MergingChests.prefix_with_modname('merge-chest-selector')

MergingChests.merge_shortcut_name = MergingChests.prefix_with_modname('merge-chest-selector')

MergingChests.setting_names = {
	mergeable_chest = MergingChests.prefix_with_modname('mergeable-chest'),
	max_width = MergingChests.prefix_with_modname('max-chest-width'),
	max_height = MergingChests.prefix_with_modname('max-chest-height'),
	max_area = MergingChests.prefix_with_modname('max-chest-area'),
	whitelist = MergingChests.prefix_with_modname('whitelist-chest-sizes'),
	mirror_whitelist = MergingChests.prefix_with_modname('mirror-whitelists'),
	inventory_size_multiplier = MergingChests.prefix_with_modname('inventory-size-multiplier'),
	inventory_size_limit = MergingChests.prefix_with_modname('inventory-size-limit'),
	sprite_decal_chance = MergingChests.prefix_with_modname('sprite-decal-chance'),
	warehouse_threshold = MergingChests.prefix_with_modname('warehouse-threshold'),
	circuit_connector_position = MergingChests.prefix_with_modname('circuit-connector-position'),
	allow_delete_items = MergingChests.prefix_with_modname('allow-delete-items')
}

local WHITELIST_SIZE_ANY = 'any'

--- @alias size_whitelist -- two dimentional array[width][height] = enabled?
--- | { [number | `WHITELIST_SIZE_ANY`]: { [number | `WHITELIST_SIZE_ANY`]: boolean } }

--- @alias circuit_connector_position
--- | 'right-top'
--- | 'right-middle'
--- | 'right-bottom'
--- | 'center-center'
--- | 'left-top'
--- | 'left-middle'
--- | 'left-bottom'
--- | 'bottom-right'
--- | 'bottom-middle'
--- | 'bottom-left'

--- @alias mod_settings
--- | { chest_name: string | nil }
--- | { max_width: number, max_height: number, max_area: number, size_whitelist: size_whitelist }
--- | { inventory_size_multiplier: number, inventory_size_limit: number }
--- | { warehouse_threshold: number, sprite_variation_chance: number }
--- | { circuit_connector_position: circuit_connector_position }

--- @param value string
--- @param mirror boolean
--- @return size_whitelist
local function parse_whitelist_setting(value, mirror)
	local size_whitelist = { }
	local has_item = false
	for width, height in string.gmatch(value, '([%dN]+)[×xX$*]([%dN]+)') do
		if (tonumber(width) or width == 'N') and (tonumber(height) or height == 'N') then
			width = tonumber(width) or WHITELIST_SIZE_ANY
			height = tonumber(height) or WHITELIST_SIZE_ANY
			if not size_whitelist[width] then
				size_whitelist[width] = { }
				has_item = true
			end
			if mirror and not size_whitelist[height] then
				size_whitelist[height] = { }
				has_item = true
			end

			if not size_whitelist[width][WHITELIST_SIZE_ANY] then
				size_whitelist[width][height] = true
			end
			if mirror and not size_whitelist[height][WHITELIST_SIZE_ANY] then
				size_whitelist[height][width] = true
			end
		end
	end

	if not has_item then
		size_whitelist = { [WHITELIST_SIZE_ANY] = { [WHITELIST_SIZE_ANY] = true } }
	end

	return size_whitelist
end

--- @param chest_name string | nil
--- @return mod_settings
local function parse_settings(chest_name)
	local function get_startup_setting_value(setting_name)
		local setting = chest_name and settings.startup[MergingChests.chest_specific_setting_name(setting_name, chest_name)] or settings.startup[setting_name]
		return setting and setting.value
	end

	--- @type mod_settings
	local mod_settings = {
		chest_name = chest_name,
		mergeable_chest = MergingChests.is_mod_active(MergingChests.all_types_mod_name) and 'all' or get_startup_setting_value(MergingChests.setting_names.mergeable_chest),
		max_width = get_startup_setting_value(MergingChests.setting_names.max_width),
		max_height = get_startup_setting_value(MergingChests.setting_names.max_height),
		max_area = get_startup_setting_value(MergingChests.setting_names.max_area),
		inventory_size_multiplier = get_startup_setting_value(MergingChests.setting_names.inventory_size_multiplier),
		inventory_size_limit = get_startup_setting_value(MergingChests.setting_names.inventory_size_limit),
		size_whitelist = parse_whitelist_setting(get_startup_setting_value(MergingChests.setting_names.whitelist), get_startup_setting_value(MergingChests.setting_names.mirror_whitelist)),
		sprite_variation_chance = get_startup_setting_value(MergingChests.setting_names.sprite_decal_chance),
		warehouse_threshold = get_startup_setting_value(MergingChests.setting_names.warehouse_threshold),
		circuit_connector_position = get_startup_setting_value(MergingChests.setting_names.circuit_connector_position),
	}

	if not MergingChests.is_mod_active(MergingChests.unlimited_mod_name) then
		mod_settings.max_width = math.min(mod_settings.max_width, 42)
		mod_settings.max_height = math.min(mod_settings.max_height, 42)
		mod_settings.max_area = math.min(mod_settings.max_area, 1600)
	end
	return mod_settings
end

--- @type { [string]: mod_settings | nil }
local cached_mod_settings = {
	default = nil
}

--- @param chest_name string | nil
--- @return mod_settings
function MergingChests.get_mod_settings(chest_name)
	local chest_name_or_default = chest_name or 'default'
	if cached_mod_settings[chest_name_or_default] == nil then
		cached_mod_settings[chest_name_or_default] = parse_settings(chest_name)
		if chest_name then
			log('Merging chests mod settings for "'..chest_name..'": '..serpent.line(cached_mod_settings[chest_name_or_default]))
		else
			log('Default merging chests mod settings: '..serpent.line(cached_mod_settings[chest_name_or_default]))
		end
	end
	return cached_mod_settings[chest_name_or_default]
end

--- Checks if width and height is allowed both by size limits and whitelist mod settings
--- @param width integer
--- @param height integer
--- @param chest_name string | nil
function MergingChests.is_size_allowed(width, height, chest_name)
    local mod_settings = MergingChests.get_mod_settings(chest_name)

	local size_whitelist = mod_settings.size_whitelist
	return (
		width <= mod_settings.max_width and
		height <= mod_settings.max_height and
		width * height <= mod_settings.max_area and
		(
			size_whitelist[width] and (size_whitelist[width][height] or size_whitelist[width][WHITELIST_SIZE_ANY]) or
			size_whitelist[WHITELIST_SIZE_ANY] and (size_whitelist[WHITELIST_SIZE_ANY][height] or size_whitelist[WHITELIST_SIZE_ANY][WHITELIST_SIZE_ANY])
		)
	)
end

--- @param merged_chest_name string Possible merged chest name
--- @return string | nil chest_name Split chest name
--- @return integer | nil width Chest width
--- @return integer | nil height Chest height
function MergingChests.get_merged_chest_info(merged_chest_name)
	local chest_name, width, height
	_, _, chest_name, width = string.find(merged_chest_name, '^'..MergingChests.mod_name..'_wide[-](.*)[-]([1-9][0-9]*)$')
	if chest_name and width then
		return chest_name, tonumber(width), 1
	end

	_, _, chest_name, height = string.find(merged_chest_name, '^'..MergingChests.mod_name..'_high[-](.*)[-]([1-9][0-9]*)$')
	if chest_name and height then
		return chest_name, 1, tonumber(height)
	end

	_, _, chest_name, width, height = string.find(merged_chest_name, '^'..MergingChests.mod_name..'_(.*)[-]warehouse[-]([1-9][0-9]*)x([1-9][0-9]*)$')
	if chest_name and width and height then
		return chest_name, tonumber(width), tonumber(height)
	end

	_, _, chest_name, width, height = string.find(merged_chest_name, '^'..MergingChests.mod_name..'_(.*)[-]trashdump[-]([1-9][0-9]*)x([1-9][0-9]*)$')
	if chest_name and width and height then
		return chest_name, tonumber(width), tonumber(height)
	end

	return nil, nil, nil
end

--- @param chest_name string
--- @param width integer
--- @param height integer
--- @return string
function MergingChests.get_merged_chest_name(chest_name, width, height)
    if width > 1 and height > 1 then
        local mod_settings = MergingChests.get_mod_settings(chest_name)
        if width > mod_settings.warehouse_threshold and height > mod_settings.warehouse_threshold then
            return MergingChests.get_trashdump_name(chest_name, width, height)
        else
            return MergingChests.get_warehouse_name(chest_name, width, height)
        end
    elseif width > 1 then
        return MergingChests.get_wide_chest_name(chest_name, width)
    else
        return MergingChests.get_high_chest_name(chest_name, height)
    end
end

--- @param chest_name string
--- @param width integer
--- @return string
function MergingChests.get_wide_chest_name(chest_name, width)
    return MergingChests.prefix_with_modname('wide-'..chest_name..'-'..width)
end

--- @param chest_name string
--- @param height integer
--- @return string
function MergingChests.get_high_chest_name(chest_name, height)
    return MergingChests.prefix_with_modname('high-'..chest_name..'-'..height)
end

--- @param chest_name string
--- @param width integer
--- @param height integer
--- @return string
function MergingChests.get_warehouse_name(chest_name, width, height)
    return MergingChests.prefix_with_modname(chest_name..'-warehouse-'..width..'x'..height)
end

--- @param chest_name string
--- @param width integer
--- @param height integer
--- @return string
function MergingChests.get_trashdump_name(chest_name, width, height)
    return MergingChests.prefix_with_modname(chest_name..'-trashdump-'..width..'x'..height)
end

--- Returns final inventory size of the chest, modified by mod settings
--- @param default_inventory_size integer
--- @param tiles integer
--- @param chest_name string | nil
--- @return integer
function MergingChests.get_inventory_size(default_inventory_size, tiles, chest_name)
    local mod_settings = MergingChests.get_mod_settings(chest_name)
	return util.clamp(
		math.floor(default_inventory_size * tiles * mod_settings.inventory_size_multiplier),
		1,
		mod_settings.inventory_size_limit
	)
end

--- @alias Grid
--- | LuaEntity[][]
--- | { min_x: integer, min_y: integer, max_x: integer, max_y: integer }

--- @param entities LuaEntity
--- @return Grid
function MergingChests.entities_to_grid(entities)
	--- @type Grid
	local grid = {
		min_x = math.huge,
		min_y = math.huge,
		max_x = -math.huge,
		max_y = -math.huge,
	}
	for _, entity in ipairs(entities) do
		local x = math.floor(entity.position.x)
		local y = math.floor(entity.position.y)

		grid[x] = grid[x] or { }
		grid[x][y] = entity

		grid.min_x = math.min(grid.min_x, x)
		grid.min_y = math.min(grid.min_y, y)
		grid.max_x = math.max(grid.max_x, x)
		grid.max_y = math.max(grid.max_y, y)
	end

	return grid
end
