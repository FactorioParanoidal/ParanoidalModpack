local util = require("util")
local current_version = require("mpp.version")
local conf = {}

---@alias FilteredEntityStatus
---| "auto_hidden" marked hidden automaticall
---| "user_hidden" marked hidden by user
---| false not hidden

---@class PlayerData
---@field quality_pickers boolean Show quality pickers
---@field advanced boolean Preserve in migrations
---@field blueprint_add_mode boolean Preserve in migrations
---@field entity_filtering_mode boolean Preserve in migrations
---@field gui PlayerGui
---@field blueprint_items LuaInventory Preserve in migrations
---@field choices PlayerChoices Preserve in migrations
---@field blueprints PlayerGuiBlueprints 
---@field last_state MinimumPreservedState? Preserve in migrations
---@field filtered_entities table<string, FilteredEntityStatus> string is of format "category:name"
---@field tick_expires integer When was gui closed, for undo button disabling
---@field selection_collection LuaEntity[] Selected resources
---@field selection_cache table<number, table<number, true>> Acceleration structure
---@field selection_render LuaRenderObject[] Selection overlay
---@field belt_planner_blueprint LuaItemStack?
---@field belt_planner_stack BeltPlannerSpecification[]

---@class PlayerChoices
---@field layout_choice string
---@field blueprint_choice LuaItemStack? Currently selected blueprint (flow)
---@field direction_choice DirectionString
---@field miner_choice string
---@field miner_quality_choice string
---@field pole_choice string
---@field pole_quality_choice string
---@field lamp_choice boolean
---@field belt_choice string
---@field belt_quality_choice string
---@field space_belt_choice string
---@field space_belt_quality_choice string
---@field logistics_choice string
---@field logistics_quality_choice string
---@field landfill_choice boolean
---@field space_landfill_choice string
---@field avoid_water_choice boolean
---@field avoid_cliffs_choice boolean
---@field coverage_choice boolean
---@field start_choice boolean
---@field deconstruction_choice boolean
---@field pipe_choice string
---@field pipe_quality_choice string
---@field module_choice string
---@field module_quality_choice string
---@field show_non_electric_miners_choice boolean
---@field force_pipe_placement_choice boolean
---@field print_debug_info_choice boolean
---@field display_lane_filling_choice boolean
---@field dumb_power_connectivity_choice boolean
---@field debugging_choice string Debugging only value
---@field ore_filtering_choice boolean
---@field balancer_choice boolean
---@field belt_planner_choice boolean
---@field belt_merge_choice boolean
---@field use_stack_capacity_multiplier_choice boolean

---@class PlayerGui
---@field section table<MppSettingSections, LuaGuiElement>
---@field tables table<string, LuaGuiElement>
---@field selections table<string, LuaGuiElement>
---@field quality_toggle LuaGuiElement
---@field advanced_settings LuaGuiElement
---@field filtering_settings LuaGuiElement
---@field undo_button LuaGuiElement
---@field layout_dropdown LuaGuiElement
---@field blueprint_add_button LuaGuiElement
---@field blueprint_add_section LuaGuiElement
---@field blueprint_receptacle LuaGuiElement

---@class PlayerGuiBlueprints All subtables are indexed by blueprint's item number
---@field mapping table<number, LuaItemStack>
---@field flow table<number, LuaGuiElement> Root blueprint element
---@field button table<number, LuaGuiElement> Blueprint button toggle
---@field delete table<number, LuaGuiElement> Blueprint delete button
---@field cache table<number, EvaluatedBlueprint>
---@field original_id table<number, number> Inventory blueprint id to 

---Small hack have proper typing in all other places
---@type LuaGuiElement
local nil_element_placeholder = nil
---@type LuaInventory
local nil_inventory_placeholder = nil

---@type PlayerData
conf.default_config = {
	quality_pickers = false,
	advanced = false,
	entity_filtering_mode = false,
	blueprint_add_mode = false,
	blueprint_items = nil_inventory_placeholder,
	filtered_entities = {},
	tick_expires = 0,
	selection_collection = {},
	selection_render = {},
	selection_cache = {},
	belt_planner_stack = {},

	choices = {
		layout_choice = "simple",
		direction_choice = "north",
		miner_choice = "electric-mining-drill",
		miner_quality_choice = "normal",
		pole_choice = "medium-electric-pole",
		pole_quality_choice = "normal",
		belt_choice = "transport-belt",
		belt_quality_choice = "normal",
		space_belt_choice = "se-space-transport-belt",
		space_belt_quality_choice = "normal",
		lamp_choice = false,
		logistics_choice = "passive-provider-chest",
		logistics_quality_choice = "normal",
		landfill_choice = false,
		space_landfill_choice = "se-space-platform-scaffold",
		coverage_choice = false,
		start_choice = false,
		deconstruction_choice = false,
		pipe_choice = "pipe",
		pipe_quality_choice = "normal",
		module_choice = "none",
		module_quality_choice = "normal",
		blueprint_choice = nil,
		dumb_power_connectivity_choice = false,
		debugging_choice = "none",
		ore_filtering_choice = false,
		belt_planner_choice = false,
		belt_merge_choice = false,
		balancer_choice = false,
		avoid_water_choice = false,
		avoid_cliffs_choice = false,
		use_stack_capacity_multiplier_choice = false,

		-- non layout/convienence/advanced settings
		show_non_electric_miners_choice = false,
		force_pipe_placement_choice = false,
		print_debug_info_choice = false,
		display_lane_filling_choice = true,
	},

	gui = {
		section = {},
		tables = {},
		selections = {},
		advanced_settings = nil_element_placeholder,
		filtering_settings = nil_element_placeholder,
		blueprint_add_button = nil_element_placeholder,
		blueprint_add_section = nil_element_placeholder,
		blueprint_receptacle = nil_element_placeholder,
		layout_dropdown = nil_element_placeholder,
		quality_toggle = nil_element_placeholder,
		undo_button = nil_element_placeholder,
	},

	blueprints = {
		mapping = {},
		cache = {},
		flow = {},
		button = {},
		delete = {},
		original_id = {},
	}
}

local function pass_same_type(old, new)
	if old and type(old) == type(new) then
		return old
	end
	return new
end

---quality choices
local quality_settings = {
	"miner_quality",
	"belt_quality",
	"space_belt_quality",
	"pole_quality",
	"logistics_quality",
	"module_quality",
	"pipe_quality",
}

---@param player LuaPlayer
---@return List<string>
function conf.get_locked_qualities(player)
	local force = player.force
	local locked_qualities = List()
	for name, quality in pairs(prototypes.quality) do
		if quality.hidden then goto skip_quality end
		if force.is_quality_unlocked(quality) then goto skip_quality end
		locked_qualities:push(name)
		::skip_quality::
	end
	return locked_qualities
end

function conf.update_player_data(player_index)
	---@type PlayerData
	local old_config = storage.players[player_index]
	local new_config = table.deepcopy(conf.default_config) --[[@as PlayerData]]

	new_config.quality_pickers = pass_same_type(old_config.quality_pickers, new_config.quality_pickers)
	new_config.advanced = pass_same_type(old_config.advanced, new_config.advanced)
	new_config.blueprint_add_mode = pass_same_type(old_config.blueprint_add_mode, new_config.blueprint_add_mode)
	new_config.blueprint_items = old_config.blueprint_items or game.create_inventory(1)
	new_config.last_state = old_config.last_state
	new_config.filtered_entities = old_config.filtered_entities or new_config.filtered_entities
	-- new_config.selection_render = old_config.selection_render
	-- new_config.selection_cache = old_config.selection_cache
	-- new_config.selection_collection = old_config.selection_collection
	
	for _, quality_name in pairs(conf.get_locked_qualities(game.get_player(player_index) --[[@as LuaPlayer]])) do
		for _, quality_setting in pairs(quality_settings) do
			local concat = quality_setting..":"..quality_name
			if new_config.filtered_entities[concat] == nil then
				new_config.filtered_entities[concat] = "auto_hidden"
			end
		end
	end

	local old_choices = old_config.choices or {}
	for key, new_choice in pairs(new_config.choices) do
		new_config.choices[key] = pass_same_type(old_choices[key], new_choice)
	end

	storage.players[player_index] = new_config
end

function conf.update_player_quality_data(player_index)
	local player_data = storage.players[player_index]
	local filtered_entities = player_data.filtered_entities
	for _, quality_name in pairs(conf.get_locked_qualities(game.get_player(player_index) --[[@as LuaPlayer]])) do
		for _, quality_setting in pairs(quality_settings) do
			local concat = quality_setting..":"..quality_name
			if filtered_entities[concat] == nil then
				filtered_entities[concat] = "auto_hidden"
			end
		end
	end
	
	local choices = player_data.choices
	local quality_prototypes = prototypes.quality
	for _, setting in ipairs(quality_settings) do
		local setting_name = setting.."_choice"
		local choice = choices[setting_name]
		if quality_prototypes[choice] == nil then
			choices[setting_name] = "normal"
		end
	end
end

function conf.initialize_storage()
	storage.players = {}
	---@type State[]
	storage.tasks = {}
	storage.immediate_tasks = {}
	storage.version = current_version
	conf.initialize_deconstruction_filter()

	for _, player in pairs(game.players) do
		conf.initialize_global(player.index)
	end
end

---@param player_index number
function conf.initialize_global(player_index)
	local old_data = storage.players[player_index]
	local new_data = table.deepcopy(conf.default_config) --[[@as PlayerData]]
	storage.players[player_index] = new_data
	
	for _, quality_name in pairs(conf.get_locked_qualities(game.get_player(player_index) --[[@as LuaPlayer]])) do
		for _, quality_setting in pairs(quality_settings) do
			local concat = quality_setting..":"..quality_name
			if old_data and old_data.filtered_entities[concat] == true then
				new_data.filtered_entities[concat] = "user_hidden"
			else
				new_data.filtered_entities[concat] = "auto_hidden"
			end
		end
	end
	
	if old_data and old_data.blueprint_items then
		new_data.blueprint_items = old_data.blueprint_items
	else
		new_data.blueprint_items = game.create_inventory(1)
	end
end

---@param force LuaForce
---@param qualities string[]
function conf.unhide_qualities_for_force(force, qualities)
	local game_players = game.players
	for index, player_data in pairs(storage.players) do
		local player = game_players[index]
		if player.force ~= force then goto skip_player end
		local filtered_entities = player_data.filtered_entities
		for _, quality_setting in pairs(quality_settings) do
			for _, quality_name in ipairs(qualities) do
				local concat = quality_setting..":"..quality_name
				if filtered_entities[concat] == "auto_hidden" then
					filtered_entities[concat] = false
				end
			end
		end
		::skip_player::
	end
end

function conf.initialize_deconstruction_filter()
	if storage.script_inventory then
		storage.script_inventory.destroy()
	end

	---@type LuaInventory
	local inventory = game.create_inventory(2)
	do
		---@type LuaItemStack
		local basic = inventory[1]
		basic.set_stack("deconstruction-planner")
		basic.tile_selection_mode = defines.deconstruction_item.tile_selection_mode.never
	end

	do
		---@type LuaItemStack
		local ghosts = inventory[2]
		ghosts.set_stack("deconstruction-planner")
		ghosts.entity_filter_mode = defines.deconstruction_item.entity_filter_mode.whitelist
		ghosts.entity_filters = {"entity-ghost", "tile-ghost"}
	end

	storage.script_inventory = inventory
end

script.on_event(defines.events.on_player_created, function(e)
	---@cast e EventData.on_player_created
	conf.initialize_global(e.player_index)
end)

script.on_event(defines.events.on_player_removed, function(e)
	---@cast e EventData.on_player_removed
	if storage.players[e.player_index].blueprint_items then
		storage.players[e.player_index].blueprint_items.destroy()
	end
	storage.players[e.player_index] = nil
end)

return conf
