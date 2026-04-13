local Data = require('__Kux-CoreLib__/stdlib/data/data') --[[@as StdLib.Data]]
local Space = require('__Kux-CoreLib__/stdlib/data/space')
local Table = require('__Kux-CoreLib__/stdlib/utils/table') --[[@as StdLib.Utils.Table]]

--- Planet (currently just a placeholder for Space, because it looks better for planets)
--- @class StdLib.Data.Planet : StdLib.Data
local Planet = {
    __class = 'Planet',
}

-- Custom __index function for function inheritance from both Space and Data.
Planet.__index = function(table, key)
    -- Check if the key exists in Recipe first.
    if Space[key] then
        return Space[key]
    -- If not found in Recipe, fallback to Data.
    elseif Data[key] then
        return Data[key]
    end
    -- Return nil if key is not found in either Recipe or Data.
    return nil
end

function Planet:__call(planet)
    local new = self:get(planet, 'planet')
    return new
end
setmetatable(Planet, Planet)
--[[
local function Planet:add_asteroid_spawn_definition(asteroid) -- expected table, does no checking
	if self:is_valid() then
		error(serpent.block(asteroid))
		table.insert(self.asteroid_spawn_definitions,asteroid)
	end
end

function Planet:get_asteroid_spawn_definitions()
	if self:is_valid() then
		return table.deepcopy(self.asteroid_spawn_definitions)
	end
end

function Planet:clear_asteroid_spawn_definitions()
	if self:is_valid() then
		return table.deepcopy(self.asteroid_spawn_definitions)
	end
end

function Planet:copy_asteroid_spawn_definitions(planet) -- expected string name of planet
	if self:is_valid() then
		local planet = Planet(planet)
		if planet:is_valid() then
			self:clear_asteroid_spawn_definitions()
			for _, asteroid in pairs(planet:get_asteroid_spawn_definitions()) do
				self:add_asteroid_spawn_definition(asteroid)
			end
		end
	end
end
]]--
return Planet
