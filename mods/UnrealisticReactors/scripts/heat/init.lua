local mod = {} -- init here for circular dependencies


local function populate_heat_network()
	for _,surface in pairs(game.surfaces) do
		for _,entity in pairs(surface.find_entities_filtered{type={'reactor','heat-pipe'}}) do
			if entity.type == "reactor" then
				mod.add_reactor(entity)
			else
				mod.add_heat_pipe(entity)
			end
		end
	end
end


HEAT = nil -- global cache
function mod.load()
--	log("heat network load")
	HEAT = global.heat
end


function mod.init()
--	log("heat network init")
	global.heat = {
		network = {}, -- array  of HeatNetwork              indexed by id
		outlets = {}, -- matrix of array of ReactorPosition indexed by z,x,y and id
		cells = {},   -- matrix of HeatNetworkCell          indexed by z,x,y
		ids = {},     -- array  of HeatNetworkId
	}
	mod.load()
	populate_heat_network()
end


return mod -- exports
