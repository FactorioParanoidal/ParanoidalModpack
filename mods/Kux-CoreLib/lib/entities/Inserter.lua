require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---@class KuxCoreLib.Inserter: KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.Inserter
Inserter = {
	__class  = "Inserter",
	__guid   = "bbd1b177-9f09-426f-8b36-0d40a9f02503",
	__origin = "Kux-CoreLib/lib/entities/Inserter.lua",
}
if not KuxCoreLib.__classUtils.ctor(Inserter) then return self end
---------------------------------------------------------------------------------------------------
local Math = KuxCoreLib.Math

--- this is a try to make bobmods compatible with slim inserters

local this = {}
setmetatable(this,{__index=Inserter})

local bobmods = _G["bobmods"]
if not bobmods then bobmods = {} end
if not bobmods.logistics then bobmods.logistics = {} end
if not bobmods.logistics.inserters then bobmods.logistics.inserters = {} end
if not bobmods.math then bobmods.math = {} end
-- dummy
local more_technology = "bob-inserters-1"
local more2_technology = "bob-inserters-2"
local long_technology = "bob-inserters-3"
local long2_technology = "bob-inserters-4"
local near_technology = "bob-inserters-5"

function bobmods.math.mod(number, div)
  if number < 0 then
    local newnumber = 0 - number
    local mod = newnumber % div
    return 0 - mod
  else
    return number % div
  end
end

function bobmods.math.floor(number)
  local num
  if number < 0 then num = number - 0.1
  else num = number + 0.1 end
  return math.floor (num - bobmods.math.mod(num, 1))
end

function bobmods.math.round(number)
  local num
  if number < 0 then num = number - 0.5
  else num = number + 0.5 end
  return math.floor (num - bobmods.math.mod(num, 1))
end

function bobmods.math.offset(number)
  local num = bobmods.math.mod(number, 1)
  if num < 0 then
    if num > -0.5 then return num
	else return num + 1 end
  else
    if num < 0.5 then return num
	else return num - 1 end
  end
end

local round = bobmods.math.round
local offset = bobmods.math.offset
local abs=math.abs
local sgn=Math.sgn
--local near_technology = bobmods.inserters.near_technology
--local more2_technology = bobmods.inserters.more2_technology
--local more_technology = bobmods.inserters.more_technology
--local long_technology = bobmods.inserters.long_technology
--local long2_technology = bobmods.inserters.long2_technology
local fine_offset = 0.2 -- bobmods.inserters.offset

this.changed_position_event = script.generate_event_name()

local function getPlayerInfo(player_index)
	return storage.bobmods.inserters[player_index] ---TODO
end

--bobmods.logistics.set_range
local function set_range(position_in, range)
	local position = { x = 0, y = 0 }
	if     position_in.x >  0.1 then position.x = range
	elseif position_in.x < -0.1 then position.x = -range
	else                             position.x = 0
	end
	if     position_in.y >  0.1 then position.y = range
	elseif position_in.y < -0.1 then position.y = -range
	else                             position.y = 0
	end
	return position
end

local function _slimOffset(entity, l)
	-- inserters have tile_height=1, tile_width=1 this normal form is assumed by bobinserters
	-- for "slim" insertes we transform the position into this normal form and back.
	-- this saves us from having to adjust all the calculations of bobinserters

	local o = { x = 0, y = 0 }
	if (entity.prototype.tile_height == 0 and entity.prototype.tile_width == 1) then
		-- this calculation is tested with mod arrow-inserter
		if     entity.direction == defines.direction.north then o.y = -0.5 + l
		elseif entity.direction == defines.direction.south then o.y =  0.5 - l
		elseif entity.direction == defines.direction.east  then o.x =  0.5 - l
		elseif entity.direction == defines.direction.west  then o.x = -0.5 + l
		end
		-- elseif(entity.prototype.tile_height == 1 and entity.prototype.tile_width==0) then
		-- elseif for other mods maybe other calculations
	end

	return o
end
local function slimDropOffset(entity) return _slimOffset(entity, 1) end
local function slimPickupOffset(entity) return _slimOffset(entity, 0) end

function Inserter.get_pickup_position(entity)
	local o = slimPickupOffset(entity)
	return {
		x = entity.pickup_position.x - entity.position.x + o.x,
		y = entity.pickup_position.y - entity.position.y + o.y
	}
end

function Inserter.get_drop_position(entity)
	local o = slimDropOffset(entity)
	return {
		x = entity.drop_position.x - entity.position.x + o.x,
		y = entity.drop_position.y - entity.position.y + o.y,
	}
end

function Inserter.split_drop_position(full_drop_position)
	local drop_position = { x = round(full_drop_position.x), y = round(full_drop_position.y) }
	local drop_offset = { x = offset(full_drop_position.x), y = offset(full_drop_position.y) }
	return drop_position, drop_offset
end


---@param entity LuaEntity
---@return table
---@return table
function Inserter.get_split_drop_position(entity)
	local full_position = this.get_drop_position(entity)
	local p = { x = round(full_position.x), y = round(full_position.y) }
	local o = { x = offset(full_position.x), y = offset(full_position.y) }
	return p, o
end

function Inserter.get_split_pickup_position(entity)
	local full_position = this.get_pickup_position(entity)
	local p = { x = round(full_position.x), y = round(full_position.y) }
	local o = { x = offset(full_position.x), y = offset(full_position.y) }
	return p, o
end

function Inserter.get_drop_tile_position(entity)
	local full_drop_position = this.get_drop_position(entity)
	return { x = round(full_drop_position.x), y = round(full_drop_position.y) }
end

function Inserter.get_drop_offset_position(entity)
	local full_drop_position = this.get_drop_position(entity)
	return { x = offset(full_drop_position.x), y = offset(full_drop_position.y) }
end

---@deprecated use combine_position
function Inserter.combine_drop_position(drop_position, drop_offset)
	return { x = drop_position.x + drop_offset.x, y = drop_position.y + drop_offset.y }
end

function Inserter.combine_position(position, offset)
	return {
		x = (position.x or position[1]) + (offset.x or offset[1]),
		y = (position.y or position[2]) + (offset.y or offset[2])
	}
end

function Inserter.set_pickup_position(entity, newpos)
	local o = slimPickupOffset(entity)
	local original_positions = { drop_position = entity.drop_position, pickup_position = entity.pickup_position }
	local new_positions = {
		drop_position = entity.drop_position,
		pickup_position = {
			x = entity.position.x + newpos.x - o.x,
			y = entity.position.y + newpos.y - o.y
		},
	}
	entity.pickup_position = new_positions.pickup_position
	entity.direction = entity.direction -- set direction to force update
	script.raise_event(
		this.changed_position_event,
		{ entity = entity, new_positions = new_positions, original_positions = original_positions }
	) -- Raise positions changed event.
end

function Inserter.set_drop_position(entity, newpos)
	local o = slimDropOffset(entity)
	local original_positions = { drop_position = entity.drop_position, pickup_position = entity.pickup_position }
	local new_positions = {
		drop_position = {
			x = entity.position.x + newpos.x - o.x,
			y = entity.position.y + newpos.y - o.y
		},
		pickup_position = entity.pickup_position,
	}
	entity.drop_position = new_positions.drop_position
	entity.direction = entity.direction -- set direction to force update
	script.raise_event(
		this.changed_position_event,
		{ entity = entity, new_positions = new_positions, original_positions = original_positions }
	) -- Raise positions changed event.
end

function Inserter.set_split_drop_position(entity, new_position, new_offset)
	return this.set_drop_position(entity, this.combine_drop_position(new_position, new_offset))
end

function Inserter.IsEqualPosition(a, b)
	local delta = {
		x = abs(a.x - b.x),
		y = abs(a.y - b.y)
	}
	return delta.x < 0.1 and delta.y < 0.1
end

function Inserter.check_position(pos1, pos2) return Inserter.IsEqualPosition(pos1, pos2) end

function Inserter.calculate_new_drop_offset(drop_position, drop_offset, new_position)
	local new_offset = { x = drop_offset.x, y = drop_offset.y }

	if (drop_position.x > 0 and new_position.x < 0) or (drop_position.x < 0 and new_position.x > 0) then
		new_offset.x = 0 - drop_offset.x
	elseif drop_position.x == 0 and new_position.x ~= 0 then
		if (new_position.x > 0 and drop_position.y > 0) or (new_position.x < 0 and drop_position.y < 0) then
			new_offset.x = drop_offset.y
		else
			new_offset.x = 0 - drop_offset.y
		end
	elseif drop_position.x ~= 0 and new_position.x == 0 then
		new_offset.x = 0
	end

	if (drop_position.y > 0 and new_position.y < 0) or (drop_position.y < 0 and new_position.y > 0) then
		new_offset.y = 0 - drop_offset.y
	elseif drop_position.y == 0 and new_position.y ~= 0 then
		if (new_position.y > 0 and drop_position.x > 0) or (new_position.y < 0 and drop_position.x < 0) then
			new_offset.y = drop_offset.x
		else
			new_offset.y = 0 - drop_offset.x
		end
	elseif drop_position.y ~= 0 and new_position.y == 0 then
		new_offset.y = 0
	end

	return this.normalise_tile_offset(new_offset)
end

--bobmods.inserters.normalise_tile_offset
function Inserter.normalise_tile_offset(tile_offset)
	local new_offset = { x = 0, y = 0 }
	if abs(tile_offset.x) >  0.01 then new_offset.x = sgn(tile_offset.x)*fine_offset end
	if tile_offset.x >  0.01 then new_offset.x = fine_offset end
	if tile_offset.x < -0.01 then new_offset.x = -fine_offset end
	if tile_offset.y >  0.01 then new_offset.y =  fine_offset end
	if tile_offset.y < -0.01 then new_offset.y = -fine_offset end
	return new_offset
end

-- bobmods.inserters.rotate_position
function Inserter.rotate_position(force, pickup_position)
	local more_unlocked = Technology.isUnlocked(force, more_technology)
	local more2_unlocked = Technology.isUnlocked(force, more2_technology)
	local rotation = 1
	local position = { table = {}, steps = 0 }

	-- Decide which position table to use
	if abs(pickup_position.x) > 2.1 or abs(pickup_position.y) > 2.1 then
		if     more2_unlocked then position = this.range3_24way
		elseif more_unlocked  then position = this.range3_8way
		else                       position = this.range3_4way
		end
	elseif abs(pickup_position.x) > 1.1 or abs(pickup_position.y) > 1.1 then
		if     more2_unlocked then position = this.range2_16way
		elseif more_unlocked  then position = this.range2_8way
		else                       position = this.range2_4way
		end
	else
		if more_unlocked then position = this.range1_8way
		else                  position = this.range1_4way
		end
	end

	-- Find current rotation
	for i, new_position in ipairs(position.table) do
		if this.check_position(pickup_position, new_position) then
			rotation = i
		end
	end
	-- Rotate
	rotation = rotation + 1
	if rotation > position.steps then
		rotation = rotation - position.steps
	end

	return position.table[rotation]
end

-- bobmods.inserters.rotate_pickup
function Inserter.rotate_pickup(entity, player)
	local pickup_position = this.get_pickup_position(entity)
	pickup_position = this.rotate_position(player.force, pickup_position)
	this.set_pickup_position(entity, pickup_position)
	if entity == getPlayerInfo(player.index).entity then
		this.raisenInserterPositionChanged(entity, player)
	end
end

--bobmods.inserters.rotate_drop
function Inserter.rotate_drop(entity, player)
	local drop_position, drop_offset = this.get_split_drop_position(entity)
	local new_position = this.rotate_position(player.force, drop_position)
	local new_offset = this.calculate_new_drop_offset(drop_position, drop_offset, new_position)
	this.set_split_drop_position(entity, new_position, new_offset)
	if entity == getPlayerInfo(player.index).entity then
		this.raisenInserterPositionChanged(entity, player)
	end
end

--bobmods.inserters.pickup_range
function Inserter.pickup_range(entity, player)
	local long_unlocked = Technology.isUnlocked(player.force, long_technology)
	local long2_unlocked = Technology.isUnlocked(player.force, long2_technology)
	local pickup_position = this.get_pickup_position(entity)
	local islong, islong2 = this.islongislong2(pickup_position)

	if long_unlocked or long2_unlocked then
		if islong2 then
			pickup_position = set_range(pickup_position, 1)
		elseif islong then
			if long2_unlocked then
				pickup_position = set_range(pickup_position, 3)
			else
				pickup_position = set_range(pickup_position, 1)
			end
		else
			pickup_position = set_range(pickup_position, 2)
		end
		Inserter.set_pickup_position(entity, pickup_position)
		if entity == getPlayerInfo(player.index).entity then
			this.raisenInserterPositionChanged(entity, player)
		end
	end
end

function this.islongislong2(relPos)
	if(abs(relPos.x) > 2.1 or abs(relPos.y) > 2.1) then return false, true end
	if(abs(relPos.x) > 1.1 or abs(relPos.y) > 1.1) then return false, true end
	return false,false
end

--bobmods.inserters.drop_range
function Inserter.drop_range(entity, player)
	local long_unlocked = Technology.isUnlocked(player.force, long_technology)
	local long2_unlocked = Technology.isUnlocked(player.force, long2_technology)
	local drop_position, drop_offset = Inserter.get_split_drop_position(entity)
	local islong, islong2 = this.islongislong2(drop_position);

	if long_unlocked or long2_unlocked then
		if islong2 then
			drop_position = set_range(drop_position, 1)
		elseif islong then
			if long2_unlocked then
				drop_position = set_range(drop_position, 3)
			else
				drop_position = set_range(drop_position, 1)
			end
		else
			drop_position = set_range(drop_position, 2)
		end
	end

	this.set_split_drop_position(entity, drop_position, drop_offset)
	if entity == getPlayerInfo(player.index).entity then
		this.raisenInserterPositionChanged(entity, player)
	end
end

--bobmods.inserters.long_range
function Inserter.long_range(entity, player)
	local long_unlocked = Technology.isUnlocked(player.force, long_technology)
	local long2_unlocked = Technology.isUnlocked(player.force, long2_technology)

	local pickup_position = this.get_pickup_position(entity)
	local drop_position, drop_offset = this.get_split_drop_position(entity)

	local islong, islong2 = this.islongislong2(pickup_position)

	if long_unlocked or long2_unlocked then
		if islong2 then
			pickup_position = set_range(pickup_position, 1)
			drop_position = set_range(drop_position, 1)
		elseif islong then
			if long2_unlocked then
				pickup_position = set_range(pickup_position, 3)
				drop_position = set_range(drop_position, 3)
			else
				pickup_position = set_range(pickup_position, 1)
				drop_position = set_range(drop_position, 1)
			end
		else
			pickup_position = set_range(pickup_position, 2)
			drop_position = set_range(drop_position, 2)
		end
	end

	local full_drop_position = this.combine_drop_position(drop_position, drop_offset)
	this.set_both_positions(entity, pickup_position, full_drop_position)

	if entity == getPlayerInfo(player.index).entity then
		this.raisenInserterPositionChanged(entity, player)
	end
end

--bobmods.inserters.near_range
function Inserter.near_range(entity, player)
	local near_unlocked = Technology.isUnlocked(player.force, near_technology)

	local drop_position, drop_offset = this.get_split_drop_position(entity)

	if near_unlocked then
		if
			(drop_offset.x == 0 and drop_offset.y == 0)
			or (drop_offset.x == 0 and drop_position.x ~= 0)
			or (drop_offset.y == 0 and drop_position.y ~= 0)
		then
			drop_offset = this.normalise_tile_offset({ x = drop_position.x, y = drop_position.y })
		else
			if drop_position.x ~= 0 then
				drop_offset.x = 0 - drop_offset.x
			end
			if drop_position.y ~= 0 then
				drop_offset.y = 0 - drop_offset.y
			end
		end

		if
			(drop_position.y ~= 0 and drop_position.x ~= 0)
			and (
				(
					((drop_position.x > 0 and drop_offset.x < 0) or (drop_offset.x > 0 and drop_position.x < 0)) -- x near
					and ((drop_position.y > 0 and drop_offset.y > 0) or (drop_offset.y < 0 and drop_position.y < 0))
				)                                                                                 -- y far
				or (
					((drop_position.x > 0 and drop_offset.x > 0) or (drop_offset.x < 0 and drop_position.x < 0)) -- x far
					and ((drop_position.y > 0 and drop_offset.y < 0) or (drop_offset.y > 0 and drop_position.y < 0))
				)                                                                                 -- y near
			)
		then
			drop_offset = this.normalise_tile_offset({ x = drop_position.x, y = drop_position.y })
		end
	end

	this.set_split_drop_position(entity, drop_position, drop_offset)
	if entity == getPlayerInfo(player.index).entity then
		this.raisenInserterPositionChanged(entity, player)
	end
end

function this.raisenInserterPositionChanged(entity, player) this.raisenInserterPositionChanged(entity, player) end

this.offset_positions = {
	{ x = -fine_offset, y = -fine_offset },
	{ x = 0,                         y = -fine_offset },
	{ x = fine_offset,  y = -fine_offset },

	{ x = -fine_offset, y = 0 },
	{ x = 0,                         y = 0 },
	{ x = fine_offset,  y = 0 },

	{ x = -fine_offset, y = fine_offset },
	{ x = 0,                         y = fine_offset },
	{ x = fine_offset,  y = fine_offset },
}

this.range1 = {
	pickup = {
		{ x = 0,  y = -1 },
		{ x = 1,  y = 0 },
		{ x = 0,  y = 1 },
		{ x = -1, y = 0 },
	},
	drop = {
		{ x = 0,  y = 1 },
		{ x = -1, y = 0 },
		{ x = 0,  y = -1 },
		{ x = 1,  y = 0 },
	},
}

this.range2 = {
	pickup = {
		{ x = 0,  y = -2 },
		{ x = 2,  y = 0 },
		{ x = 0,  y = 2 },
		{ x = -2, y = 0 },
	},
	drop = {
		{ x = 0,  y = 2 },
		{ x = -2, y = 0 },
		{ x = 0,  y = -2 },
		{ x = 2,  y = 0 },
	},
}

this.offset_positions = {
	near = {
		{ x = 0,                         y = -fine_offset },
		{ x = fine_offset,  y = 0 },
		{ x = 0,                         y = fine_offset },
		{ x = -fine_offset, y = 0 },
	},
	far = {
		{ x = 0,                         y = fine_offset },
		{ x = -fine_offset, y = 0 },
		{ x = 0,                         y = -fine_offset },
		{ x = fine_offset,  y = 0 },
	},
}

this.range1_4way = {
	table = {
		{ x = 0,  y = -1 },
		{ x = 1,  y = 0 },
		{ x = 0,  y = 1 },
		{ x = -1, y = 0 },
	},
	steps = 4,
}

this.range1_8way = {
	table = {
		{ x = 0,  y = -1 },
		{ x = 1,  y = -1 },
		{ x = 1,  y = 0 },
		{ x = 1,  y = 1 },
		{ x = 0,  y = 1 },
		{ x = -1, y = 1 },
		{ x = -1, y = 0 },
		{ x = -1, y = -1 },
	},
	steps = 8,
}

this.range2_4way = {
	table = {
		{ x = 0,  y = -2 },
		{ x = 2,  y = 0 },
		{ x = 0,  y = 2 },
		{ x = -2, y = 0 },
	},
	steps = 4,
}

this.range2_8way = {
	table = {
		{ x = 0,  y = -2 },
		{ x = 2,  y = -2 },
		{ x = 2,  y = 0 },
		{ x = 2,  y = 2 },
		{ x = 0,  y = 2 },
		{ x = -2, y = 2 },
		{ x = -2, y = 0 },
		{ x = -2, y = -2 },
	},
	steps = 8,
}

this.range2_16way = {
	table = {
		{ x = 0,  y = -2 },
		{ x = 1,  y = -2 },
		{ x = 2,  y = -2 },
		{ x = 2,  y = -1 },
		{ x = 2,  y = 0 },
		{ x = 2,  y = 1 },
		{ x = 2,  y = 2 },
		{ x = 1,  y = 2 },
		{ x = 0,  y = 2 },
		{ x = -1, y = 2 },
		{ x = -2, y = 2 },
		{ x = -2, y = 1 },
		{ x = -2, y = 0 },
		{ x = -2, y = -1 },
		{ x = -2, y = -2 },
		{ x = -1, y = -2 },
	},
	steps = 16,
}

this.range3_4way = {
	table = {
		{ x = 0,  y = -3 },
		{ x = 3,  y = 0 },
		{ x = 0,  y = 3 },
		{ x = -3, y = 0 },
	},
	steps = 4,
}

this.range3_8way = {
	table = {
		{ x = 0,  y = -3 },
		{ x = 3,  y = -3 },
		{ x = 3,  y = 0 },
		{ x = 3,  y = 3 },
		{ x = 0,  y = 3 },
		{ x = -3, y = 3 },
		{ x = -3, y = 0 },
		{ x = -3, y = -3 },
	},
	steps = 8,
}

this.range3_24way = {
	table = {
		{ x = 0,  y = -3 },
		{ x = 1,  y = -3 },
		{ x = 2,  y = -3 },
		{ x = 3,  y = -3 },
		{ x = 3,  y = -2 },
		{ x = 3,  y = -1 },
		{ x = 3,  y = 0 },
		{ x = 3,  y = 1 },
		{ x = 3,  y = 2 },
		{ x = 3,  y = 3 },
		{ x = 2,  y = 3 },
		{ x = 1,  y = 3 },
		{ x = 0,  y = 3 },
		{ x = -1, y = 3 },
		{ x = -2, y = 3 },
		{ x = -3, y = 3 },
		{ x = -3, y = 2 },
		{ x = -3, y = 1 },
		{ x = -3, y = 0 },
		{ x = -3, y = -1 },
		{ x = -3, y = -2 },
		{ x = -3, y = -3 },
		{ x = -2, y = -3 },
		{ x = -1, y = -3 },
	},
	steps = 24,
}

this.positions = {
	{ x = -2, y = -2 },
	{ x = -1, y = -2 },
	{ x = 0,  y = -2 },
	{ x = 1,  y = -2 },
	{ x = 2,  y = -2 },

	{ x = -2, y = -1 },
	{ x = -1, y = -1 },
	{ x = 0,  y = -1 },
	{ x = 1,  y = -1 },
	{ x = 2,  y = -1 },

	{ x = -2, y = 0 },
	{ x = -1, y = 0 },
	{ x = 0,  y = 0 },
	{ x = 1,  y = 0 },
	{ x = 2,  y = 0 },

	{ x = -2, y = 1 },
	{ x = -1, y = 1 },
	{ x = 0,  y = 1 },
	{ x = 1,  y = 1 },
	{ x = 2,  y = 1 },

	{ x = -2, y = 2 },
	{ x = -1, y = 2 },
	{ x = 0,  y = 2 },
	{ x = 1,  y = 2 },
	{ x = 2,  y = 2 },

	{ x = -3, y = -3 },
	{ x = -2, y = -3 },
	{ x = -1, y = -3 },
	{ x = 0,  y = -3 },
	{ x = 1,  y = -3 },
	{ x = 2,  y = -3 },
	{ x = 3,  y = -3 },

	{ x = -3, y = -2 },
	{ x = 3,  y = -2 },

	{ x = -3, y = -1 },
	{ x = 3,  y = -1 },

	{ x = -3, y = 0 },
	{ x = 3,  y = 0 },

	{ x = -3, y = 1 },
	{ x = 3,  y = 1 },

	{ x = -3, y = 2 },
	{ x = 3,  y = 2 },

	{ x = -3, y = 3 },
	{ x = -2, y = 3 },
	{ x = -1, y = 3 },
	{ x = 0,  y = 3 },
	{ x = 1,  y = 3 },
	{ x = 2,  y = 3 },
	{ x = 3,  y = 3 },
}

---------------------------------------------------------------------------------------------------
return Inserter