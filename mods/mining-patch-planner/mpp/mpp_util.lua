local enums = require("mpp.enums")
local blacklist = require("mpp.blacklist")
local floor, ceil = math.floor, math.ceil
local min, max = math.min, math.max

local EAST = defines.direction.east
local NORTH = defines.direction.north
local SOUTH = defines.direction.south
local WEST = defines.direction.west

---@alias DirectionString
---| "west"
---| "east"
---| "south"
---| "north"

local mpp_util = {}

---@alias CoordinateConverterFunction fun(number, number, number, number): number, number

---@type table<DirectionString, CoordinateConverterFunction>
local coord_convert = {
	west = function(x, y, w, h) return x, y end,
	east = function(x, y, w, h) return w-x, h-y end,
	south = function(x, y, w, h) return h-y, x end,
	north = function(x, y, w, h) return y, w-x end,
}
mpp_util.coord_convert = coord_convert

---@type table<DirectionString, CoordinateConverterFunction>
local coord_revert = {
	west = coord_convert.west,
	east = coord_convert.east,
	north = coord_convert.south,
	south = coord_convert.north,
}
mpp_util.coord_revert = coord_revert

mpp_util.miner_direction = {west="south",east="north",north="west",south="east"}
mpp_util.belt_direction = {west="north", east="south", north="east", south="west"}
mpp_util.opposite = {west="east",east="west",north="south",south="north"}

do
	-- switch to (direction + EAST) % ROTATION
	local d = defines.direction
	mpp_util.bp_direction = {
		west = {
			[d.north] = d.north,
			[d.east] = d.east,
			[d.south] = d.south,
			[d.west] = d.west,
		},
		north = {
			[d.north] = d.east,
			[d.east] = d.south,
			[d.south] = d.west,
			[d.west] = d.north,
		},
		east = {
			[d.north] = d.south,
			[d.east] = d.west,
			[d.south] = d.north,
			[d.west] = d.east,
		},
		south = {
			[d.north] = d.west,
			[d.east] = d.north,
			[d.south] = d.east,
			[d.west] = d.south,
		},
	}
end

---@type table<defines.direction, MapPosition.0>
local direction_coord = {
	[NORTH] = {x=0, y=-1},
	[WEST] = {x=-1, y=0},
	[SOUTH] = {x=0, y=1},
	[EAST] = {x=1, y=0},
}
mpp_util.direction_coord = direction_coord

---@class EntityStruct
---@field name string
---@field type string
---@field w number Collision width
---@field h number Collision height
---@field x number x origin 
---@field y number y origin
---@field size number?
---@field extent_w number Half of width
---@field extent_h number Half of height

---@type table<string, EntityStruct>
local entity_cache = {}

---@param entity_name string
---@return EntityStruct
function mpp_util.entity_struct(entity_name)
	local cached = entity_cache[entity_name]
	if cached then return cached end
	---@diagnostic disable-next-line: missing-fields
	local struct = {} --[[@as EntityStruct]]
	local proto = game.entity_prototypes[entity_name]

	local cbox = proto.collision_box
	local cbox_tl, cbox_br = cbox.left_top, cbox.right_bottom
	local cw, ch = cbox_br.x - cbox_tl.x, cbox_br.y - cbox_tl.y
	struct.name = entity_name
	struct.type = proto.type
	struct.w, struct.h = ceil(cw), ceil(ch)
	struct.size = max(struct.w, struct.h)
	struct.x = struct.w / 2 - 0.5
	struct.y = struct.h / 2 - 0.5
	struct.extent_w, struct.extent_h = struct.w / 2, struct.h / 2

	entity_cache[entity_name] = struct
	return struct
end

---@param struct EntityStruct
---@param direction defines.direction
---@return number, number, number, number
function mpp_util.rotate_struct(struct, direction)
	if direction == NORTH or direction == SOUTH then
		return struct.x, struct.y, struct.w, struct.h
	end
	return struct.y, struct.x, struct.h, struct.w
end

---A mining drill's origin (0, 0) is the top left corner
---The spawn location is (x, y), rotations need to rotate around
---@class MinerStruct : EntityStruct
---@field size number Physical miner size
---@field size_sq number Size squared
---@field symmetric boolean
---@field parity (-1|0) Parity offset for even sized drills, -1 when odd
---@field resource_categories table<string, boolean>
---@field radius float Mining area reach
---@field area number Full coverage span of the miner
---@field area_sq number Squared area
---@field outer_span number Lenght between physical size and end of radius
---@field module_inventory_size number
---@field middle number "Center" x position
---@field drop_pos MapPosition Raw drop position
---@field out_x integer Resource drop position x
---@field out_y integer Resource drop position y
---@field extent_negative number 
---@field extent_positive number
---@field supports_fluids boolean
---@field skip_outer boolean Skip outer area calculations
---@field pipe_left number Y height on left side
---@field pipe_right number Y height on right side
---@field output_rotated table<defines.direction, MapPosition> Rotated output positions in reference to (0, 0) origin
---@field power_source_tooltip (string|table)?

---@type table<string, MinerStruct>
local miner_struct_cache = {}

---Calculates values for drill sizes and extents
---@param mining_drill_name string
---@return MinerStruct
function mpp_util.miner_struct(mining_drill_name)
	local cached = miner_struct_cache[mining_drill_name]
	if cached then return cached end
	
	local miner_proto = game.entity_prototypes[mining_drill_name]
	---@diagnostic disable-next-line: missing-fields
	local miner = mpp_util.entity_struct(mining_drill_name) --[[@as MinerStruct]]
	if miner.w ~= miner.h then
		-- we have a problem ?
	end
	miner.size_sq = miner.size ^ 2
	miner.symmetric = miner.size % 2 == 1
	miner.parity = miner.size % 2 - 1
	miner.radius = miner_proto.mining_drill_radius
	miner.area = ceil(miner_proto.mining_drill_radius * 2)
	miner.area_sq = miner.area ^ 2
	miner.outer_span = floor((miner.area - miner.size) / 2)
	miner.resource_categories = miner_proto.resource_categories
	miner.name = miner_proto.name
	miner.module_inventory_size = miner_proto.module_inventory_size
	miner.extent_negative = floor(miner.size * 0.5) - floor(miner_proto.mining_drill_radius) + miner.parity
	miner.extent_positive = miner.extent_negative + miner.area - 1
	miner.middle = floor(miner.size / 2) + miner.parity

	local nauvis = game.get_surface("nauvis") --[[@as LuaSurface]]

	local dummy = nauvis.create_entity{
		name = mining_drill_name,
		position = {miner.x, miner.y},
	}

	if dummy then
		miner.drop_pos = dummy.drop_position
		miner.out_x = floor(dummy.drop_position.x)
		miner.out_y = floor(dummy.drop_position.y)
		dummy.destroy()
	else
		-- hardcoded fallback
		local dx, dy = floor(miner.size / 2) + miner.parity, -1
		miner.drop_pos = { dx+.5, -0.296875, x = dx+.5, y = -0.296875 }
		miner.out_x = dx
		miner.out_y = dy
	end
	
	local output_rotated = {
		[defines.direction.north] = {miner.out_x, miner.out_y},
		[defines.direction.south] = {miner.size - miner.out_x - 1, miner.size },
		[defines.direction.west] = {miner.size, miner.out_x},
		[defines.direction.east] = {-1, miner.size - miner.out_x -1},
	}
	output_rotated[NORTH].x = output_rotated[NORTH][1]
	output_rotated[NORTH].y = output_rotated[NORTH][2]
	output_rotated[SOUTH].x = output_rotated[SOUTH][1]
	output_rotated[SOUTH].y = output_rotated[SOUTH][2]
	output_rotated[WEST].x = output_rotated[WEST][1]
	output_rotated[WEST].y = output_rotated[WEST][2]
	output_rotated[EAST].x = output_rotated[EAST][1]
	output_rotated[EAST].y = output_rotated[EAST][2]

	miner.output_rotated = output_rotated

	--pipe height stuff
	if miner_proto.fluidbox_prototypes and #miner_proto.fluidbox_prototypes > 0 then
		local connections = miner_proto.fluidbox_prototypes[1].pipe_connections

		for _, conn in pairs(connections) do
			---@cast conn FluidBoxConnection
			-- pray a mod that does weird stuff with pipe connections doesn't appear
		end

		miner.pipe_left = floor(miner.size / 2) + miner.parity
		miner.pipe_right = floor(miner.size / 2) + miner.parity
		miner.supports_fluids = true
	else
		miner.supports_fluids = false
	end

	-- If larger than a large mining drill
	miner.skip_outer = miner.size > 7 or miner.area > 13

	if miner_proto.electric_energy_source_prototype then
		miner.power_source_tooltip = {
			"", " [img=tooltip-category-electricity] ",
			{"tooltip-category.consumes"}, " ", {"tooltip-category.electricity"},
		}
	elseif miner_proto.burner_prototype then
		local burner = miner_proto.burner_prototype --[[@as LuaBurnerPrototype]]
		if burner.fuel_categories["nuclear"] then
			miner.power_source_tooltip = {
				"", "[img=tooltip-category-nuclear]",
				{"tooltip-category.consumes"}, " ", {"fuel-category-name.nuclear"},
			}
		else
			miner.power_source_tooltip = {
				"", "[img=tooltip-category-chemical]",
				{"tooltip-category.consumes"}, " ", {"fuel-category-name.chemical"},
			}
		end
	elseif miner_proto.fluid_energy_source_prototype then
		miner.power_source_tooltip = {
			"", "[img=tooltip-category-water]",
			{"tooltip-category.consumes"}, " ", {"tooltip-category.fluid"},
		}
	end

	return miner
end

---@class PoleStruct : EntityStruct
---@field name string
---@field place boolean Flag if poles are to be actually placed
---@field size number
---@field radius number Power supply reach
---@field supply_width number Full width of supply reach
---@field wire number Max wire distance
---@field supply_area_distance number
---@field extent_negative number Negative extent of the supply reach

---@type table<string, PoleStruct>
local pole_struct_cache = {}

---@param pole_name string
---@return PoleStruct
function mpp_util.pole_struct(pole_name)
	local cached_struct = pole_struct_cache[pole_name]
	if cached_struct then return cached_struct end

	local pole_proto = game.entity_prototypes[pole_name]
	if pole_proto then
		local pole = mpp_util.entity_struct(pole_name) --[[@as PoleStruct]]

		local radius = pole_proto.supply_area_distance --[[@as number]]
		pole.supply_area_distance = radius
		pole.supply_width = floor(radius * 2)
		pole.radius = pole.supply_width / 2
		pole.wire = pole_proto.max_wire_distance

		-- local distance = beacon_proto.supply_area_distance
		-- beacon.area = beacon.size + distance * 2
		-- beacon.extent_negative = -distance

		local extent = (pole.supply_width - pole.size) / 2

		pole.extent_negative = -extent

		pole_struct_cache[pole_name] = pole
		return pole
	end
	return {
		place = false, -- nonexistent pole, use fallbacks and don't place
		size = 1,
		supply_width = 7,
		radius = 3.5,
		wire = 9,
	}
end

---@class BeaconStruct : EntityStruct
---@field extent_negative number
---@field area number

local beacon_cache = {}

---@param beacon_name string
---@return BeaconStruct
function mpp_util.beacon_struct(beacon_name)
	local cached_struct = beacon_cache[beacon_name]
	if cached_struct then return cached_struct end

	local beacon_proto = game.entity_prototypes[beacon_name]
	local beacon = mpp_util.entity_struct(beacon_name) --[[@as BeaconStruct]]

	local distance = beacon_proto.supply_area_distance
	beacon.area = beacon.size + distance * 2
	beacon.extent_negative = -distance

	beacon_cache[beacon_name] = beacon
	return beacon
end


local hardcoded_pipes = {}

---@param pipe_name string Name of the normal pipe
---@return string|nil, LuaEntityPrototype|nil
function mpp_util.find_underground_pipe(pipe_name)
	if hardcoded_pipes[pipe_name] then
		return hardcoded_pipes[pipe_name], game.entity_prototypes[hardcoded_pipes[pipe_name]]
	end
	local ground_name = pipe_name.."-to-ground"
	local ground_proto = game.entity_prototypes[ground_name]
	if ground_proto then
		return ground_name, ground_proto
	end
	return nil, nil
end

function mpp_util.revert(gx, gy, direction, x, y, w, h)
	local tx, ty = coord_revert[direction](x-.5, y-.5, w, h)
	return {gx + tx+.5, gy + ty + .5}
end

---comment
---@param gx any
---@param gy any
---@param direction any
---@param x any
---@param y any
---@param w any
---@param h any
---@return unknown
---@return unknown
function mpp_util.revert_ex(gx, gy, direction, x, y, w, h)
	local tx, ty = coord_revert[direction](x-.5, y-.5, w, h)
	return gx + tx+.5, gy + ty + .5
end

function mpp_util.revert_world(gx, gy, direction, x, y, w, h)
	local tx, ty = coord_revert[direction](x-.5, y-.5, w, h)
	return {gx + tx, gy + ty}
end

---@class BeltStruct
---@field name string
---@field related_underground_belt string?
---@field underground_reach number?

---@type table<string, BeltStruct>
local belt_struct_cache = {}

function mpp_util.belt_struct(belt_name)
	local cached = belt_struct_cache[belt_name]
	if cached then return cached end

	---@diagnostic disable-next-line: missing-fields
	local belt = {} --[[@as BeltStruct]]
	local belt_proto = game.entity_prototypes[belt_name]

	belt.name = belt_name

	local related = belt_proto.related_underground_belt
	if related then
		belt.related_underground_belt = related.name
		belt.underground_reach = related.max_underground_distance
	else
		local match_attempts = {
			["transport"]	= "underground",
			["belt"]		= "underground-belt",
		}
		for pattern, replacement in pairs(match_attempts) do
			local new_name = string.gsub(belt_name, pattern, replacement)
			if new_name == belt_name then goto continue end
			related = game.entity_prototypes[new_name]
			if related then
				belt.related_underground_belt = new_name
				belt.underground_reach = related.max_underground_distance
				break
			end
			::continue::
		end
	end

	belt_struct_cache[belt_name] = belt
	return belt
end

---@class InserterStruct : EntityStruct
---@field pickup_rotated table<defines.direction, MapPosition.0>
---@field drop_rotated table<defines.direction, MapPosition.0>

---@type table<string, InserterStruct>
local inserter_struct_cache = {}

function mpp_util.inserter_struct(inserter_name)
	local cached = inserter_struct_cache[inserter_name]
	if cached then return cached end

	local inserter_proto = game.entity_prototypes[inserter_name]
	local inserter = mpp_util.entity_struct(inserter_name) --[[@as InserterStruct]]

	local function rotations(_x, _y)
		_x, _y = floor(_x), floor(_y)
		return {
			[NORTH]	= { x =  _x, y =  _y},
			[EAST]	= { x = -_y, y = -_x},
			[SOUTH]	= { x = -_x, y = -_y},
			[WEST]	= { x =  _y, y =  _x},
		}
	end

	local pickup_position = inserter_proto.inserter_pickup_position --[[@as MapPosition.1]]
	local drop_position = inserter_proto.inserter_drop_position --[[@as MapPosition.1]]
	inserter.pickup_rotated = rotations(pickup_position[1], pickup_position[2])
	inserter.drop_rotated = rotations(drop_position[1], drop_position[2])

	inserter_struct_cache[inserter_name] = inserter
	return inserter
end

---Calculates needed power pole count
---@param state SimpleState
function mpp_util.calculate_pole_coverage(state, miner_count, lane_count)
	local cov = {}
	local m = mpp_util.miner_struct(state.miner_choice)
	local p = mpp_util.pole_struct(state.pole_choice)

	-- Shift subtract
	local covered_miners = ceil(p.supply_width / m.size)
	local miner_step = covered_miners * m.size

	-- Special handling to shift back small radius power poles so they don't poke out
	local capable_span = false
	if floor(p.wire) >= miner_step and m.size ~= p.supply_width then
		capable_span = true
	else
		miner_step = floor(p.wire)
	end
	cov.capable_span = capable_span

	local pole_start = m.middle
	if capable_span then
		if covered_miners % 2 == 0 then
			pole_start = m.size-1
		elseif miner_count % covered_miners == 0 then
			pole_start = pole_start + m.size
		end
	end

	cov.pole_start = pole_start
	cov.pole_step = miner_step
	cov.full_miner_width = miner_count * m.size

	cov.lane_start = 0
	cov.lane_step = m.size * 2 + 2
	local lane_pairs = floor(lane_count / 2)
	local lane_coverage = ceil((p.radius-1) / (m.size + 0.5))
	if lane_coverage > 1 then
		cov.lane_start = (ceil(lane_pairs / 2) % 2 == 0 and 1 or 0) * (m.size * 2 + 2)
		cov.lane_step = lane_coverage * (m.size * 2 + 2)
	end

	cov.lamp_alter = miner_step < 9 and true or false

	return cov
end

---Calculates the spacing for belt interleaved power poles
---@param state State
---@param miner_count number
---@param lane_count number
---@param force_capable (number|true)?
function mpp_util.calculate_pole_spacing(state, miner_count, lane_count, force_capable)
	local cov = {}
	local m = mpp_util.miner_struct(state.miner_choice)
	local p = mpp_util.pole_struct(state.pole_choice)

	-- Shift subtract
	local covered_miners = ceil(p.supply_width / m.size)
	local miner_step = covered_miners * m.size
	if force_capable then
		miner_step = force_capable == true and miner_step or force_capable --[[@as number]]
		force_capable = miner_step
	end

	-- Special handling to shift back small radius power poles so they don't poke out
	local capable_span = false

	if floor(p.wire) >= miner_step then
		capable_span = true
	elseif force_capable and force_capable > 0 then
		return mpp_util.calculate_pole_spacing(
			state, miner_count, lane_count, miner_step - m.size
		)
	else
		miner_step = floor(p.wire)
	end
	cov.capable_span = capable_span

	local pole_start = m.size-1
	if capable_span then
		if covered_miners % 2 == 0 then
			pole_start = m.size-1
		elseif miner_count % covered_miners == 0 and miner_step ~= m.size then
			pole_start = pole_start + m.size
		end
	end

	cov.pole_start = pole_start
	cov.pole_step = miner_step
	cov.full_miner_width = miner_count * m.size

	cov.lane_start = 0
	cov.lane_step = m.size * 2 + 2
	local lane_pairs = floor(lane_count / 2)
	local lane_coverage = ceil((p.radius-1) / (m.size + 0.5))
	if lane_coverage > 1 then
		cov.lane_start = (ceil(lane_pairs / 2) % 2 == 0 and 1 or 0) * (m.size * 2 + 2)
		cov.lane_step = lane_coverage * (m.size * 2 + 2)
	end

	return cov
end

---@param t table
---@param func function
---@return true | nil
function mpp_util.table_find(t, func)
	for k, v in pairs(t) do
		if func(v) then return true end
	end
end

---@param t table
---@param m LuaObject 
function mpp_util.table_mapping(t, m)
	for k, v in pairs(t) do
		if k == m then return v end
	end
end

---@param player LuaPlayer
---@param blueprint LuaItemStack
function mpp_util.validate_blueprint(player, blueprint)
	if not blueprint.blueprint_snap_to_grid then
		player.print({"", "[color=red]", {"mpp.msg_blueprint_undefined_grid"}, "[/color]"}, {sound_path="utility/cannot_build"})
		return false
	end

	local miners, _ = enums.get_available_miners()
	local cost = blueprint.cost_to_build
	local drills = {}
	for name, drill in pairs(miners) do
		if cost[name] then
			drills[#drills+1] = drill.localised_name
		end
	end

	if #drills > 1 then
		local msg = {"", "[color=red]", {"mpp.msg_blueprint_different_miners"}, "[/color]" }
		for _, name in pairs(drills) do
			msg[#msg+1] = "\n"
			msg[#msg+1] = name
		end
		player.print(msg, {sound_path="utility/cannot_build"})
		return false
	elseif #drills == 0 then
		player.print({"", "[color=red]", {"mpp.msg_blueprint_no_miner"}, "[/color]"}, {sound_path="utility/cannot_build"})
		return false
	end
	
	return true
end

function mpp_util.keys_to_set(...)
	local set, temp = {}, {}
	for _, t in pairs{...} do
		for k, _ in pairs(t) do
			temp[k] = true
		end
	end
	for k, _  in pairs(temp) do
		set[#set+1] = k
	end
	table.sort(set)
	return set
end

function mpp_util.list_to_keys(t)
	local temp = {}
	for _, k in ipairs(t) do
		temp[k] = true
	end
	return temp
end

---@param bp LuaItemStack
function mpp_util.blueprint_label(bp)
	local label = bp.label
	if label then
		if #label > 30 then
			return string.sub(label, 0, 28) .. "...", label
		end
		return label
	else
		return {"", {"gui-blueprint.unnamed-blueprint"}, " ", bp.item_number}
	end
end

---@class CollisionBoxProperties
---@field w number
---@field h number
---@field near number
---@field [1] boolean
---@field [2] boolean

-- LuaEntityPrototype#tile_height was added in 1.1.64, I'm developing on 1.1.61
local even_width_memoize = {}
---Gets properties of entity collision box
---@param name string
---@return CollisionBoxProperties
function mpp_util.entity_even_width(name)
	local check = even_width_memoize[name]
	if check then return check end
	local proto = game.entity_prototypes[name]
	local cbox = proto.collision_box
	local cbox_tl, cbox_br = cbox.left_top, cbox.right_bottom
	local cw, ch = cbox_br.x - cbox_tl.x, cbox_br.y - cbox_tl.y
	local w, h = ceil(cw), ceil(ch)
	local res = {w % 2 ~= 1, h % 2 ~= 1, w=w, h=h, near=floor(w/2)}
	even_width_memoize[name] = res
	return res
end

--- local EAST, NORTH, SOUTH, WEST, ROTATION = mpp_util.directions()
function mpp_util.directions()
	return
		defines.direction.east,
		defines.direction.north,
		defines.direction.south,
		defines.direction.west,
		table_size(defines.direction)
end

---@param player_index uint
---@return uint
function mpp_util.get_display_duration(player_index)
	return settings.get_player_settings(player_index)["mpp-lane-filling-info-duration"].value * 60 --[[@as uint]]
end

---@param player_index uint
---@return boolean
function mpp_util.get_dump_state(player_index)
	return settings.get_player_settings(player_index)["mpp-dump-heuristics-data"].value --[[@as boolean]]
end

function mpp_util.wrap_tooltip(...)
	return select(1, ...) and {"", "     ", ...} or nil
end

function mpp_util.tooltip_entity_not_available(check, arg)
	if check then
		return mpp_util.wrap_tooltip(arg, "\n[color=red]", {"mpp.label_not_available"}, "[/color]")
	end
	return mpp_util.wrap_tooltip(arg)
end

---@param c1 Coords
---@param c2 Coords
function mpp_util.coords_overlap(c1, c2)
	local x = (c1.ix1 <= c2.ix1 and c2.ix1 <= c1.ix2) or (c1.ix1 <= c2.ix2 and c2.ix2 <= c1.ix2) or
		(c2.ix1 <= c1.ix1 and c1.ix1 <= c2.ix2) or (c2.ix1 <= c1.ix2 and c1.ix2 <= c2.ix2)
	local y = (c1.iy1 <= c2.iy1 and c2.iy1 <= c1.iy2) or (c1.iy1 <= c2.iy2 and c2.iy2 <= c1.iy2) or
		(c2.iy1 <= c1.iy1 and c1.iy1 <= c2.iy2) or (c2.iy1 <= c1.iy2 and c1.iy2 <= c2.iy2)
	return x and y
end

---Checks if thing (entity) should never appear as a choice
---@param thing LuaEntityPrototype|MinerStruct
---@return boolean|nil
function mpp_util.check_filtered(thing)
	return
		blacklist[thing.name]
		or (thing.flags and thing.flags.hidden)
end

---@param player_data any
---@param category MppSettingSections
---@param name string
function mpp_util.set_entity_hidden(player_data, category, name, value)
	player_data.filtered_entities[category..":"..name] = value
end

function mpp_util.get_entity_hidden(player_data, category, name)
	return player_data.filtered_entities[category..":"..name]
end

---Checks if a player has hidden the entity choice
---@param player_data any
---@param category MppSettingSections
---@param thing MinerStruct|LuaEntityPrototype
---@return false
function mpp_util.check_entity_hidden(player_data, category, thing)
	return (not player_data.entity_filtering_mode and player_data.filtered_entities[category..":"..thing.name])
end

---@param player_data PlayerData
function mpp_util.update_undo_button(player_data)
	
	local enabled = false
	local undo_button = player_data.gui.undo_button
	local last_state = player_data.last_state
	
	if last_state then
		local duration = mpp_util.get_display_duration(last_state.player.index)
		enabled = enabled or (last_state and last_state._collected_ghosts and #last_state._collected_ghosts > 0 and game.tick < player_data.tick_expires)
	end

	undo_button.enabled = enabled
	undo_button.sprite = enabled and "mpp_undo_enabled" or "mpp_undo_disabled"
	undo_button.tooltip = mpp_util.wrap_tooltip(enabled and {"controls.undo"} or {"", {"controls.undo"}," (", {"gui.not-available"}, ")"})
end

return mpp_util
