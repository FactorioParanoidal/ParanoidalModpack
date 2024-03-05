local icons = require '__rusty-locale__.icons'

local config = require 'config'


-- Crafting Combinator
local cc = table.deepcopy(data.raw['constant-combinator']['constant-combinator'])
cc.name = config.CC_NAME
cc.icon = '__crafting_combinator__/graphics/icon-crafting-combinator.png'
cc.icon_size = 32
cc.item_slot_count = 3
cc.minable.result = cc.name
table.insert(cc.flags, 'not-deconstructable')

for _, image in pairs(cc.sprites) do
	local im = image.layers[1]
	im.filename = '__crafting_combinator__/graphics/entities.png'
	im.y = 0
	im.hr_version = nil
end

local cc_item = table.deepcopy(data.raw['item']['constant-combinator'])
cc_item.name = cc.name
cc_item.place_result = cc.name
cc_item.icons = icons.of(cc)
cc_item.subgroup = 'circuit-network'
cc_item.order = 'c[combinators]-m[crafting-combinator]'

local cc_recipe = table.deepcopy(data.raw['recipe']['constant-combinator'])
cc_recipe.name = cc.name
cc_recipe.result = cc.name
table.insert(data.raw['technology']['circuit-network'].effects, {type = 'unlock-recipe', recipe = cc.name})


local rc = table.deepcopy(data.raw['arithmetic-combinator']['arithmetic-combinator'])
rc.name = config.RC_NAME
rc.minable.result = rc.name
rc.energy_source = { type = 'void' }
rc.energy_usage_per_tick = '1W'
for direction, definition in pairs(rc.multiply_symbol_sprites) do
	definition.hr_version.filename = '__crafting_combinator__/graphics/hr-combinator-displays.png'
	rc.multiply_symbol_sprites[direction] = definition.hr_version
end

local rc_item = table.deepcopy(data.raw['item']['arithmetic-combinator'])
rc_item.name = rc.name
rc_item.place_result = rc.name
rc_item.icons = icons.of(rc)
rc_item.subgroup = 'circuit-network'
rc_item.order = 'c[combinators]-m[recipe-combinator]'

local rc_recipe = table.deepcopy(data.raw['recipe']['arithmetic-combinator'])
rc_recipe.name = rc.name
rc_recipe.result = rc.name
table.insert(data.raw['technology']['circuit-network'].effects, {type = 'unlock-recipe', recipe = rc.name})


local trans = {
	filename = '__crafting_combinator__/graphics/trans.png',
	width = 1,
	height = 1,
}
local con_point = {
	wire = {
		red = {0, 0},
		green = {0, 0},
	},
	shadow = {
		red = {0, 0},
		green = {0, 0},
	},
}


data:extend {
	cc, cc_item, cc_recipe,
	rc, rc_item, rc_recipe,
	{
		type = 'item',
		name = config.MODULE_CHEST_NAME,
		flags = {'hidden'},
		stack_size = 1,
		place_result = config.MODULE_CHEST_NAME,
		icons = icons.of(cc),
	},
	{
		type = 'container',
		name = config.MODULE_CHEST_NAME,
		flags = {'placeable-off-grid', 'not-blueprintable', 'not-upgradable', 'player-creation'},
		collision_mask = {},
		collision_box = cc.collision_box,
		selection_box = cc.selection_box,
		inventory_size = config.MODULE_CHEST_SIZE,
		picture = trans,
		minable = {mining_time = 0.2, result = cc.name},
		
		-- Disguise the chest as the combinator itself, so it looks right in deconstruction planner filters
		localised_name = {'entity-name.crafting_combinator:crafting-combinator'},
		icons = icons.of(cc),
		subgroup = cc_item.subgroup,
		order = 'z-'..cc_item.order, -- For some reason the z- prefix is added to auto-generated order strings
	},
	{
		type = 'item',
		name = config.SETTINGS_ENTITY_NAME,
		flags = {'hidden'},
		stack_size = 1,
		place_result = config.SETTINGS_ENTITY_NAME,
		icon = '__base__/graphics/icons/blueprint.png',
		icon_size = 32,
	},
	{
		type = 'programmable-speaker',
		name = config.SETTINGS_ENTITY_NAME,
		flags = {'placeable-off-grid', 'placeable-neutral', 'player-creation', 'not-deconstructable', 'not-upgradable'},
		collision_mask = {},
		collision_box = cc.collision_box,
		selection_box = {{0, 0}, {0, 0}},
		sprite = trans,
		icon = '__base__/graphics/icons/blueprint.png',
		icon_size = 32,
		
		minable = {
			result = config.SETTINGS_ENTITY_NAME,
			mining_time = 0,
		},
		
		energy_source = { type = 'void' },
		energy_usage_per_tick = '1W',
		
		instruments = {},
		maximum_polyphony = 0,
	},
	{
		type = 'constant-combinator',
		name = config.RC_PROXY_NAME,
		flags = {'placeable-off-grid'},
		collision_mask = {},
		item_slot_count = config.RC_SLOT_COUNT,
		circuit_wire_max_distance = 3,
		sprites = {
			north = trans,
			east = trans,
			south = trans,
			west = trans,
		},
		activity_led_sprites = trans,
		activity_led_light_offsets = {{0, 0}, {0, 0}, {0, 0}, {0, 0}},
		
		circuit_wire_connection_points = {con_point, con_point, con_point, con_point},
		draw_circuit_wires = false,
	},
	{
		type = 'lamp',
		name = config.SIGNAL_CACHE_NAME,
		flags = {'placeable-off-grid'},
		collision_mask = {},
		circuit_wire_max_distance = 3,
		circuit_wire_connection_points = {con_point, con_point, con_point, con_point},
		draw_circuit_wires = false,
		
		picture_on = trans,
		picture_off = trans,
		energy_source = {type = 'void'},
		energy_usage_per_tick = '1W',
	},
	
	{
		type = 'item-group',
		name = config.GROUP_NAME,
		order = 'fb',
		icon = '__crafting_combinator__/graphics/recipe-book.png',
		icon_size = 64,
	},
	{
		type = 'item-subgroup',
		name = 'crafting_combinator:signals',
		group = config.GROUP_NAME,
		order = '___',
	},
	{
		type = 'item-subgroup',
		name = config.UNSORTED_RECIPE_SUBGROUP,
		group = config.GROUP_NAME,
		order = 'zzz[unsorted]',
	},
	{
		type = 'virtual-signal',
		name = config.TIME_SIGNAL_NAME,
		icon = '__core__/graphics/clock-icon.png',
		subgroup = 'crafting_combinator:signals',
		order = 'a[recipe-time]',
		icon_size = 32,
	},
	{
		type = 'virtual-signal',
		name = config.SPEED_SIGNAL_NAME,
		icon = '__crafting_combinator__/graphics/speed-icon.png',
		subgroup = 'crafting_combinator:signals',
		order = 'b[crafting-speed]',
		icon_size = 32,
	},
}
