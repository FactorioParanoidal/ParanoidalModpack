local Table = require('__kry_stdlib__/stdlib/utils/table')
local Data = require('__kry_stdlib__/stdlib/data/data') --[[@as StdLib.Data]]
local Item = require('__kry_stdlib__/stdlib/data/item') --[[@as StdLib.Data.Item]]

--- Entity class
--- @class StdLib.Data.Entity : StdLib.Data
--- @field minable data.MinableProperties (AssemblingMachinePrototype and many others)
--- @field inputs (ItemID)[] (LabPrototype)
local Entity = {
    __class = 'Entity',
    __index = Data,
    __call = Data.__call
}
setmetatable(Entity, Entity)

local allowed_fields = {
    "shift", 
    "scale", 
    "collision_box",
    "selection_box",
    "north_position", 
    "south_position", 
    "east_position", 
    "west_position",
    "window_bounding_box",
    "circuit_connector",
}

local ignored_fields ={
    "fluid_boxes",
    "fluid_box",
    "energy_source",
    "input_fluid_box",
}

function Entity:get_minable_item()
    local Item = require('__kry_stdlib__/stdlib/data/item') --[[@as StdLib.Data.Item]]
    if self:is_valid() then
        local m = self.minable
        return Item(m and (m.result or (m.results and (m.results[1] or m.results.name))), nil, self.options)
    end
    return Item()
end

function Entity:set_minable_item(item)
	local item = Item(item)
    if self:is_valid() and item:is_valid() then
		self.minable.result = item.name
    end
end

function Entity:is_player_placeable()
    if self:is_valid() then
        return self:Flags():any('player-creation', 'placeable-player')
    end
    return false
end

function Entity:change_lab_inputs(name, add)
    if self:is_valid('lab') then
        Entity.Unique_Array.set(self.inputs)
        if add then
            self.inputs:add(name)
        else
            self.inputs:remove(name)
        end
    else
        log('Entity is not a lab.' .. _ENV.data_traceback())
    end
    return self
end

local function update_collision(object, shrink_value)
	-- shrinks collision box by given value (expected 0-1)
	object[1][1] = object[1][1]*shrink_value
	object[1][2] = object[1][2]*shrink_value
	object[2][1] = object[2][1]*shrink_value
	object[2][2] = object[2][2]*shrink_value
end

-- magic function provided by Kirazy for use within mini machines
-- if squeak is true, reduce the collision_box by the given shrink_value (or 0.75)
local function rescale_entity(entity, scale, squeak, shrink_value)
	for key, value in pairs(entity) do
		-- This section checks to see where we are, and for the existence of scale.
		-- Scale is defined if it is missing where it should be present.
		-- If there's a filename, means we're in a low-res table
		if entity.filename then
			entity.scale = entity.scale or 1
		end

        -- Check to see if we need to scale this key's value
        for n = 1, #allowed_fields do
            if allowed_fields[n] == key then
                entity[key] = Table.scale(value, scale)
				--Squeak through functionality
				if squeak and string.match(key, "collision_box") then
					-- backwards compatibility, if shrink_value undefined, use previous default
					if not shrink_value then shrink_value = 0.75 end
					update_collision(entity[key], shrink_value)
				end
                -- Move to the next key rather than digging down further
                goto continue
            end
        end

        -- Check to see if we need to ignore this key
        for n = 1, #ignored_fields do
            if ignored_fields[n] == key then
                -- Move to the next key rather than digging down further
                goto continue
            end
        end

        if(type(value) == "table") then
            rescale_entity(value, scale)
        end

        -- Label to skip to next iteration
        ::continue::
    end
end

function Entity:rescale_entity(scale, squeak, shrink_value)
	if self:is_valid() then
		rescale_entity(self._raw, scale, squeak, shrink_value)
	end
end

-- returns the height and width in simpler numbers
function Entity:get_dimensions()
	if self:is_valid() and self.collision_box then
		local box = self.collision_box
		local x1, y1 = box[1][1], box[1][2]
		local x2, y2 = box[2][1], box[2][2]

		-- width/height are just (max - min), rounded up to nearest int
		local width  = math.ceil(x2 - x1)
		local height = math.ceil(y2 - y1)
		
		return width, height
	end
end

return Entity
