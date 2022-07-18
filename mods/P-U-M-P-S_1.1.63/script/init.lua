---------------------
---- control.lua ----
---------------------

local init = {}

init.power_pumps =
{
	"offshore-pump-0",
	"offshore-pump-1",
	"offshore-pump-2",
	"offshore-pump-3",
	"offshore-pump-4",
	"seafloor-pump", -- Angels Refining
	"ground-water-pump", -- Angels Refining
}

function init.regenerate_pumps()
	
	log("Regenerating offshore and ground pumps...")
	
	for _, surface in pairs (game.surfaces) do
		
		-- Destroy bugged pumps
		for _, bugged_pump in pairs (OSM.bugged_pumps) do
			for _, bug_pump in pairs(surface.find_entities_filtered{name=bugged_pump}) do
				bug_pump.destroy()
			end
		end
		
		-- Regenerate pumps
		for _, powered_pump in pairs (OSM.powered_pumps) do
			for _, pump in pairs(surface.find_entities_filtered{name=powered_pump.name}) do

				local name = pump.name
				local position = pump.position
				local direction = pump.direction
				local force = pump.force
	
				pump.destroy()
				surface.create_entity
				{
					name = OSM.collision_layer,
					position = position,
					direction = direction,
					force = "neutral",
					fast_replace = true,
					spill = false,
					raise_built = false,
					create_build_effect_smoke = false
				}
				surface.create_entity
				{
					name = name,
					position = position,
					direction = direction,
					force = force,
					fast_replace = true,
					spill = false,
					raise_built = true,
					create_build_effect_smoke = false
				}
			end
		end

		-- Remove collision layer if pump is not there (redundant safety check)
		for _, collision_layer in pairs(surface.find_entities_filtered{name=OSM.collision_layer}) do

			local pump = false

			for _, powered_pump in pairs(OSM.powered_pumps) do
				if game.entity_prototypes[powered_pump.name] then
					powered_pump = surface.find_entity(powered_pump.name, collision_layer.position)
					if powered_pump then pump = true end
				end
			end
			if not pump then collision_layer.destroy() end
		end
	end
	global.on_tick_trigger = false
end

return init