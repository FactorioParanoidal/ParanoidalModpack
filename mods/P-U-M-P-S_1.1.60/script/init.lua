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

init.bugged_pumps =
{
	"offshore-pump-output", -- AAI Industries
}

function init.regenerate_pumps()
	
	log("Regenerating offshore pumps...")
	
	for _, surface in pairs (game.surfaces) do
		
		-- Destroy bugged pumps
		for _, offshore_bug in pairs (init.bugged_pumps) do
			for _, bug_pump in pairs(surface.find_entities_filtered{name=offshore_bug}) do
				bug_pump.destroy()
			end
		end
		
		-- Regenerate pumps
		for _, water_pump in pairs (init.power_pumps) do
			for _, pump in pairs(surface.find_entities_filtered{name=water_pump}) do

				local name = pump.name
				local position = pump.position
				local direction = pump.direction
				local force = pump.force

				if not name then return end
	
				pump.destroy()
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
	end
	global.on_tick_trigger = false
end

return init