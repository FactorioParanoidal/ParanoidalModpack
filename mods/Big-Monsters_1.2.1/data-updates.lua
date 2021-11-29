require "util"
local fire = util.table.deepcopy(data.raw.fire["fire-flame"])
fire.initial_lifetime = 600
fire.name="fire-flame-2"
fire.damage_per_tick = {amount = 2, type = "fire"},
data:extend({fire})

local allunits={}
    for _, unitSpawner in pairs(data.raw["unit-spawner"]) do
	if not (string.find(unitSpawner.name, "protomolecule") or string.find(unitSpawner.name, "boss")) then 
		for k, RU in pairs(unitSpawner.result_units) do
			table.insert(allunits,unitSpawner.result_units[k]) end
		end	
	end

data.raw["unit-spawner"]["bm-spawner"].result_units=allunits