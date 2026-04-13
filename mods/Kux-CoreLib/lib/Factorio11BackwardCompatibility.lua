---@diagnostic disable: deprecated, undefined-field
--[[---------------------------------------------------------------------------
	 makes Factorio 2.0 API available in 1.x mods
--]]---------------------------------------------------------------------------

if not isV1 then return end
--[[
_G.storage = storage

-- https://lua-api.factorio.com/latest/classes/LuaHelpers.html
_G.helpers = helpers or {
--	* Moved LuaGameScript::table_to_json, json_to_table, write_file, remove_path, direction_to_string,
--	  evaluate_expression, encode_string, decode_string, parse_map_exchange_string,
--	  check_prototype_translations, is_valid_sound_path, is_valid_sprite_path to LuaHelpers.
--	* Removed LuaGui::is_valid_sprite_path. Use LuaHelpers::is_valid_sprite_path instead.

	table_to_json = game.table_to_json,
	json_to_table = game.json_to_table,
	write_file = game.write_file,
	remove_path = game.remove_path,
	direction_to_string = game.direction_to_string,
	evaluate_expression = game.evaluate_expression,
	encode_string = game.encode_string,
	decode_string = game.decode_string,
	parse_map_exchange_string = game.parse_map_exchange_string,
	check_prototype_translations = game.check_prototype_translations,
	is_valid_sound_path = game.is_valid_sound_path,
	is_valid_sprite_path = game.is_valid_sprite_path,

	create_profiler = nil, --new in 2.0
	object_name	= "LuaHelpers"
}


-- https://lua-api.factorio.com/latest/classes/LuaPrototypes.html
_G.prototypes = prototypes or {
	get_entity_filtered = game.get_filtered_entity_prototypes,
	get_item_filtered = game.get_filtered_item_prototypes,
	get_equipment_filtered = game.get_filtered_equipment_prototypes,
	get_mod_setting_filtered = game.get_filtered_mod_setting_prototypes,
	get_achievement_filtered = game.get_filtered_achievement_prototypes,
	get_tile_filtered = game.get_filtered_tile_prototypes,
	get_decorative_filtered = game.get_filtered_decorative_prototypes,
	get_fluid_filtered = game.get_filtered_fluid_prototypes,
	get_recipe_filtered = game.get_filtered_recipe_prototypes,
	get_technology_filtered	= game.get_filtered_technology_prototypes,
	get_history = script.get_prototype_history,
	object_name = "LuaPrototypes",
	font = game.font_prototypes,
	map_gen_preset = game.map_gen_presets,
	style = prototypes.style,
	entity = game.entity_prototypes,
	item = game.item_prototypes,
	fluid = game.fluid_prototypes,
	tile = game.tile_prototypes,
	equipment = game.equipment_prototypes,
	damage = game.damage_prototypes,
	virtual_signal = game.virtual_signal_prototypes,
	equipment_grid = game.equipment_grid_prototypes,
	recipe = game.recipe_prototypes,
	technology = game.technology_prototypes,
	decorative = game.decorative_prototypes,
	particle = game.particle_prototypes,
	autoplace_control = game.autoplace_control_prototypes,
	mod_setting = game.mod_setting_prototypes,
	custom_input = game.custom_input_prototypes,
	ammo_category = game.ammo_category_prototypes,
	named_noise_expression = game.named_noise_expressions,
	-- named_noise_function :: Read LuaCustomTable[string → LuaNamedNoiseFunction]
	item_subgroup = game.item_subgroup_prototypes,
	item_group = game.item_group_prototypes,
	fuel_category = game.fuel_category_prototypes,
	resource_category = game.resource_category_prototypes,
	achievement = game.achievement_prototypes,
	module_category = game.module_category_prototypes,
	equipment_category = game.equipment_category_prototypes,
	trivial_smoke = game.trivial_smoke_prototypes,
	shortcut = game.shortcut_prototypes,
	recipe_category = game.recipe_category_prototypes,
	--quality	:: R LuaCustomTable[string → LuaQualityPrototype]
	--surface_property	:: R LuaCustomTable[string → LuaSurfacePropertyPrototype]
	--space_location	:: R LuaCustomTable[string → LuaSpaceLocationPrototype]
	--space_connection	:: R LuaCustomTable[string → LuaSpaceConnectionPrototype]
	custom_event = game.custom_input_prototypes,
	--active_trigger = game.active_trigger_prototypes,
	--asteroid_chunk	:: R LuaCustomTable[string → LuaAsteroidChunkPrototype]
	--collision_layer	:: R LuaCustomTable[string → LuaCollisionLayerPrototype]
	--airborne_pollutant	:: R LuaCustomTable[string → LuaAirbornePollutantPrototype]
	--burner_usage :: R LuaCustomTable[string → LuaBurnerUsagePrototype]
	--surface	:: R LuaCustomTable[string → LuaSurfacePrototype]
	--procession	:: R LuaCustomTable[string → LuaProcessionPrototype]
	--procession_layer_inheritance_group	:: R LuaCustomTable[string → LuaProcessionLayerInheritanceGroupPrototype]
	--max_force_distraction_distance	:: R double
	--max_force_distraction_chunk_distance	:: R uint
	--max_electric_pole_supply_area_distance	:: R float
	--max_electric_pole_connection_distance	:: R double
	--max_beacon_supply_area_distance	:: R uint
	--max_gate_activation_distance	:: R double
	--max_inserter_reach_distance	:: R double
	--max_pipe_to_ground_distance	:: R uint8
	--max_underground_belt_distance	:: R uint8
}
]]
_G.bcu = {}
_G.bcu.player = {}
bcu.player.clear_cursor = function(player)
	if isV10 then return player.clean_cursor() end -- renamed in 1.1.0
	return player.clear_cursor() -- renamed from clean_cursor
end