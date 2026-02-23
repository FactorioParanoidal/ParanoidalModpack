
local Data = require('__Kux-CoreLib__/stdlib/data/data')
local Table = require('__Kux-CoreLib__/stdlib/utils/table') --[[@as StdLib.Utils.Table]]

--- Space, the final frontier. Intended for planet, space-connection, and space-location
--- @class Data.Space : StdLib.Data
local Space = {
    __class = 'Space',
    __index = Data,
    __call = Data.__call
}
setmetatable(Space, Space)

local function remove_asteroid(asteroid_spawn_definitions,name) -- expected table, string
	for key, asteroid in pairs(asteroid_spawn_definitions) do
        if asteroid.asteroid == name then
            table.remove(asteroid_spawn_definitions, key)
            return true
        end
	end
end

function Space:remove_from_asteroid_spawn_definition(asteroid) -- expected string name of asteroid to remove
	if self:is_valid() then
		remove_asteroid(self.asteroid_spawn_definitions,asteroid)
	end
end

function Space:add_asteroid_spawn_definition(asteroid) -- expected table, does no checking
	if self:is_valid() then
		table.insert(self.asteroid_spawn_definitions,asteroid)
	end
end

function Space:get_asteroid_spawn_definitions()
	if self:is_valid() then
		return table.deepcopy(self.asteroid_spawn_definitions)
	end
end

function Space:clear_asteroid_spawn_definitions()
	if self:is_valid() then
		self.asteroid_spawn_definitions = {}
	end
	return true
end

function Space:copy_asteroid_spawn_definitions(space,type) -- expected string name and string type, does no checking
	if self:is_valid() then
		local object = Space(space,type)
		if object:is_valid() then
			self:clear_asteroid_spawn_definitions()
			for _, asteroid in pairs(object:get_asteroid_spawn_definitions()) do
				self:add_asteroid_spawn_definition(asteroid)
			end
		end
	end
end

return Space
