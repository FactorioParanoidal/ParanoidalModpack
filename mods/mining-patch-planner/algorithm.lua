local enums = require("mpp.enums")
local mpp_util = require("mpp.mpp_util")
local compatibility = require("mpp.compatibility")

local floor, ceil = math.floor, math.ceil
local min, max = math.min, math.max
local table_insert = table.insert

local algorithm = {}

---@type table<string, Layout>
local layouts = {}
algorithm.layouts = layouts
local function require_layout(layout)
	layouts[layout] = require("layouts."..layout)
	layouts[#layouts+1] = layouts[layout]
end
require_layout("simple")
require_layout("compact")
require_layout("super_compact")
require_layout("sparse")
-- require_layout("throughput_t1")
require_layout("pipe")
require_layout("logistics")
require_layout("compact_logistics")
require_layout("sparse_logistics")
require_layout("blueprints")

---@alias TaskType
---| "layout"
---| "belt_planner"

---@class TaskState
---@field type TaskType
---@field direction_choice string
---@field player LuaPlayer
---@field surface LuaSurface
---@field coords Coords

---@class MinimumPreservedState : TaskState
---@field layout_choice string
---@field resources LuaEntity[] Filtered resources
---@field belts BaseBeltSpecification[]
---@field belt_planner_belts BeltPlannerSpecification
---@field belt_choice string
---@field _previous_state MinimumPreservedState?
---@field _collected_ghosts LuaEntity[]
---@field _preview_rectangle? LuaRenderObject LuaRendering.draw_rectangle
---@field _lane_info_rendering LuaRenderObject[]
---@field _render_objects List<LuaRenderObject> LuaRendering objects

---@class State : MinimumPreservedState
---@field _callback string -- callback to be used in the tick
---@field tick number
---@field is_space boolean
---@field resource_tiles GridTile
---@field found_resources LuaEntity[] Resource name -> resource category mapping
---@field resource_counts {name: string, count: number}[] Highest count resource first
---@field requires_fluid boolean
---@field mod_version string
---@field performance_scaling number
---
---@field layout_choice string
---@field direction_choice string
---@field miner_choice string
---@field miner_quality_choice string
---@field pole_choice string
---@field pole_quality_choice string
---@field belt_choice string Belt name
---@field belt_quality_choice string
---@field space_belt_choice string
---@field space_belt_quality_choice string
---@field lamp_choice boolean Lamp placement
---@field coverage_choice boolean
---@field logistics_choice string
---@field logistics_quality_choice string
---@field landfill_choice boolean
---@field space_landfill_choice string
---@field avoid_water_choice boolean
---@field avoid_cliffs_choice boolean
---@field start_choice boolean
---@field deconstruction_choice boolean
---@field pipe_choice string
---@field pipe_quality_choice string
---@field module_choice string
---@field module_quality_choice string
---@field force_pipe_placement_choice boolean
---@field print_placement_info_choice boolean
---@field display_lane_filling_choice boolean
---@field ore_filtering_choice boolean
---@field ore_filtering_selected string?
---@field belt_planner_choice boolean
---@field belt_merge_choice boolean
---@field balancer_choice boolean
---
---@field grid Grid
---@field convolution_cache GridTile[]
---@field deconstruct_specification DeconstructSpecification
---@field miner MinerStruct
---@field pole PoleStruct
---@field belt BeltStruct
---@field blueprint_choice LuaGuiElement
---@field blueprint_inventory LuaInventory
---@field blueprint LuaItemStack
---@field cache EvaluatedBlueprint

--- Return value for layout callbacks
--- string	- name of next callback
--- true	- repeat the current callback
--- false	- job is finished
---@alias CallbackState string|boolean

---@param event EventData.on_player_selected_area
---@return State|nil
---@return LocalisedString error status
local function create_state(event)
	---@diagnostic disable-next-line: missing-fields
	local state = {} --[[@as State]]
	state.type = "layout"
	state._callback = "start"
	state.tick = 0
	state.mod_version = script.active_mods["mining-patch-planner"]
	state._preview_rectangle = nil
	state._collected_ghosts = {}
	state._render_objects = List()
	state._lane_info_rendering = {}
	state.performance_scaling = max(0.01, settings.global["mpp-performance-scaling"].value --[[@as number]])

	---@type PlayerData
	local player_data = storage.players[event.player_index]

	-- game state properties
	state.surface = event.surface
	state.is_space = compatibility.is_space(event.surface.index)
	state.player = game.get_player(event.player_index)

	-- fill in player option properties
	local player_choices = player_data.choices
	for k, v in pairs(player_choices) do
		state[k] = util.copy(v)
	end

	if state.is_space then
		if prototypes.entity["se-space-pipe"] then
			state.pipe_choice = "se-space-pipe"
		else
			state.pipe_choice = "none"
		end

		state.belt_choice = state.space_belt_choice
		state.belt_quality_choice = state.space_belt_quality_choice
	end

	state.debug_dump = mpp_util.get_dump_state(event.player_index)

	if state.layout_choice == "blueprints" then
		local blueprint = player_data.choices.blueprint_choice
		if blueprint == nil then
			return nil, {"mpp.msg_unselected_blueprint"}
		end
		-- state.blueprint_inventory = game.create_inventory(1)
		-- state.blueprint = state.blueprint_inventory.find_empty_stack()
		-- state.blueprint.set_stack(blueprint)
		state.cache = player_data.blueprints.cache[blueprint.item_number]
		state.miner_choice = state.cache.miner_name
	end

	return state
end

---Filters resource entity list and returns patch coordinates and size
---@param entities LuaEntity[]
---@param available_resource_categories table<string, true>
---@return Coords @bounds of found resources
---@return LuaEntity[] @Filtered entities
---@return table<string, string> @key:resource name; value:resource category
---@return {name: string, count: number}[] @resource counts table
local function process_entities(entities, available_resource_categories)
	local filtered, found_resources, counts = List(), {}, {}
	local x1, y1 = math.huge, math.huge
	local x2, y2 = -math.huge, -math.huge
	local _, cached_resource_categories = enums.get_available_miners()
	for _, entity in pairs(entities) do
		local name, proto = entity.name, entity.prototype
		local category = proto.resource_category

		found_resources[name] = category
		if cached_resource_categories[category] and available_resource_categories[category] then
			counts[name] = 1 + (counts[name] or 0)
			filtered:push(entity)
			local position = entity.position
			local x, y = position.x, position.y
			if x < x1 then x1 = x end
			if y < y1 then y1 = y end
			if x2 < x then x2 = x end
			if y2 < y then y2 = y end
		end
	end

	local resource_counts = {}
	for k, v in pairs(counts) do table.insert(resource_counts, {name=k, count=v}) end
	table.sort(resource_counts, function(a, b) return a.count > b.count end)

	local coords = {
		x1 = x1, y1 = y1, x2 = x2, y2 = y2,
		ix1 = floor(x1), iy1 = floor(y1),
		ix2 = ceil(x2), iy2 = ceil(y2),
		gx = x1 - 1, gy = y1 - 1,
	}
	coords.w, coords.h = coords.ix2 - coords.ix1, coords.iy2 - coords.iy1
	return coords, filtered, found_resources, resource_counts
end

---@param player_data PlayerData
---@return table<string, true>
local function get_miner_categories(player_data)
	if player_data.choices.layout_choice == "blueprints" then
		return player_data.blueprints.cache[player_data.choices.blueprint_choice.item_number]:get_resource_categories()
	else
		return prototypes.entity[player_data.choices.miner_choice].resource_categories or {}
	end
end

---@param resources LuaEntity[]
---@param cache table<number, table<number, true>>
---@return LuaEntity[]
local function find_new_resources(resources, cache)
	local new = {}
	for _, resource in pairs(resources) do
		local pos = resource.position
		local x, y = floor(pos.x), floor(pos.y)
		local row = cache[y]
		if row == nil then
			cache[y] = {[x] = true}
			table_insert(new, resource)
		elseif row[x] == nil then
			row[x] = true
			table_insert(new, resource)
		end
	end
	return new
end

--- Algorithm hook
--- Returns nil if it fails
---@param event EventData.on_player_selected_area
function algorithm.on_player_selected_area(event)
	local player = game.get_player(event.player_index)
	---@type PlayerData
	local player_data = storage.players[event.player_index]
	local state, err = create_state(event)
	if not state then return nil, err end
	local layout = layouts[player_data.choices.layout_choice]

	if state.miner_choice == "none" then
		return nil, {"mpp.msg_miner_err_3"}
	end

	local direction = state.direction_choice
	local collected_resources = player_data.selection_collection

	local new = find_new_resources(event.entities, player_data.selection_cache)

	for _, resource in pairs(new) do
		table_insert(collected_resources, resource)
	end
	algorithm.clear_selection(player_data)

	local layout_categories = get_miner_categories(player_data)
	local coords, filtered, found_resources, resource_counts = process_entities(collected_resources, layout_categories)
	state.coords = coords
	coords.is_horizontal = direction == "east" or direction == "west"
	coords.is_vertical = not coords.is_horizontal
	state.resources = filtered
	state.found_resources = found_resources
	state.requires_fluid = false
	state.resource_counts = resource_counts

	if #state.resources == 0 then
		for resource, category in pairs(state.found_resources) do
			if not layout_categories[category] then
				local miner_name = prototypes.entity[state.miner_choice].localised_name
				local resource_name = prototypes.entity[resource].localised_name
				return nil, {"", {"mpp.msg_miner_err_2_1"}, " \"", miner_name, "\" ", {"mpp.msg_miner_err_2_2"}, " \"", resource_name, "\""}
			end
		end

		return nil, {"mpp.msg_miner_err_0"}
	end

	if state.ore_filtering_choice then -- determine filtered ore
		local current_resource = event.entities[1].name
		local homogenous_selection = true

		for _, ent in pairs(event.entities) do
			if ent.name ~= current_resource then
				homogenous_selection = false
				break
			end
		end

		if homogenous_selection then
			state.ore_filtering_selected = current_resource
		else
			state.ore_filtering_selected = resource_counts[1].name
		end
	end

	if state.ore_filtering_selected then
		local proto = prototypes.entity[state.ore_filtering_selected]
		state.requires_fluid = not not proto.mineable_properties.required_fluid
	else
		for _, t in pairs(resource_counts) do
			local proto = prototypes.entity[t.name]
			if proto.mineable_properties.required_fluid then
				state.requires_fluid = true
				break
			end
		end
	end

	if state.requires_fluid and not player.force.mining_with_fluid then
		return nil, {"cant-build-reason.mining-with-fluid-not-available"}
	end

	local last_state = player_data.last_state --[[@as MinimumPreservedState]]
	if last_state ~= nil then
		local renderables = last_state._render_objects

		local same = mpp_util.coords_overlap(coords, last_state.coords) and last_state.surface == event.surface

		if same then
			for _, renderObject in ipairs(renderables) do
				renderObject.destroy()
			end
			state._previous_state = last_state
		else
			local ttl = mpp_util.get_display_duration(event.player_index)
			for _, renderObject in ipairs(renderables) do
				if renderObject.valid then
					renderObject.time_to_live = ttl
				end
			end
		end
		player_data.last_state = nil
	end

	local validation_result, error = layout:validate(state)
	if validation_result then
		layout:initialize(state)
		
		-- "Progress" bar
		local c = state.coords
		state._preview_rectangle = rendering.draw_rectangle{
			surface=state.surface,
			left_top={state.coords.ix1, state.coords.iy1},
			right_bottom={state.coords.ix1 + c.w, state.coords.iy1 + c.h},
			filled=false, color={0, 0.8, 0.3, 1},
			width = 8,
			draw_on_ground = true,
			players={state.player},
		}

		return state
	else
		return nil, error
	end
end

function algorithm.on_player_alt_selected_area(event)
	---@type PlayerData
	local player_data = storage.players[event.player_index]

	local selection_collection = player_data.selection_collection
	local selection_render = player_data.selection_render

	local layout_categories = get_miner_categories(player_data)

	local coords, filtered, found_resources, resource_counts = process_entities(event.entities, layout_categories)

	local new = find_new_resources(filtered, player_data.selection_cache)

	for _, resource in pairs(new) do
		local pos = resource.position
		local square = rendering.draw_rectangle{
			left_top = {pos.x-.5, pos.y-.5},
			right_bottom = {pos.x+.5, pos.y+.5},
			color = {0, 0, 0.3, .3},
			players = {event.player_index},
			surface = event.surface,
			filled = true,
			draw_on_ground = true,
		}
		table_insert(selection_render, square)
		table_insert(selection_collection, resource)
	end

end

---Sets renderables timeout
---@param player_data PlayerData
function algorithm.on_gui_open(player_data)
	local last_state = player_data.last_state
	if last_state == nil or last_state._render_objects == nil then return end

	local ttl = mpp_util.get_display_duration(last_state.player.index)
	if ttl > 0 then
		for _, renderObject in ipairs(last_state._render_objects) do
			if renderObject.valid then
				renderObject.time_to_live = 0
			end
		end
	end
end

---Sets renderables timeout
---@param player_data PlayerData
function algorithm.on_gui_close(player_data)
	local last_state = player_data.last_state
	if last_state == nil or last_state._render_objects == nil then return end

	local ttl = mpp_util.get_display_duration(last_state.player.index)
	if ttl > 0 then
		for _, renderObject in ipairs(last_state._render_objects) do
			if renderObject.valid then
				renderObject.time_to_live = ttl
			end
		end
	else
		for _, renderObject in ipairs(last_state._render_objects) do
			if renderObject.valid then
				renderObject.destroy()
			end
		end
	end
end

---@param player_data PlayerData
function algorithm.cleanup_last_state(player_data)
	local state = player_data.last_state
	if not state then return end

	local force, ply = state.player.force, state.player
	
	if type(state._collected_ghosts) == "table" then
		for _, ghost in pairs(state._collected_ghosts) do
			if ghost.valid then
				ghost.order_deconstruction(force, ply)
			end
		end
		state._collected_ghosts = {}
	end

	if type(state._render_objects) == "table" then
		for _, renderObject in ipairs(state._render_objects) do
			if renderObject.valid then
				renderObject.destroy()
			end
		end
		state._render_objects = List()
	end

	if state._preview_rectangle and state._preview_rectangle.valid then
		state._preview_rectangle.destroy()
	end
	mpp_util.update_undo_button(player_data)

	player_data.last_state = nil
end

---@param player_data PlayerData
function algorithm.clear_selection(player_data)
	for k, renderObject in pairs(player_data.selection_render or {}) do
		-- rendering.destroy(v)
		if renderObject.valid then
			renderObject.destroy()
		end
	end
	player_data.selection_render = {}
	player_data.selection_collection = {}
	player_data.selection_cache = {}
end

return algorithm
