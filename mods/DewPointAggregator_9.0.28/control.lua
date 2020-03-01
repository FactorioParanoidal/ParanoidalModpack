require "biometypes"

local function onEntityAdded(event)
	local entity = event.created_entity
	if entity.name == "dpa" then
		local biome = getBiome(entity)
		entity.set_recipe("dpa-action-" .. biome)
		entity.operable = false
	end
end

script.on_event(defines.events.on_built_entity, onEntityAdded)
script.on_event(defines.events.on_robot_built_entity, onEntityAdded)