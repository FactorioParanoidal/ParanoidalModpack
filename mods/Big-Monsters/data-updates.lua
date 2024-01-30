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


local loot = data.raw.unit["maf-boss-biter-1"].loot
function update_boss_loot(raw)
if raw then raw.loot=loot end
end
for k=1,10 do 
	update_boss_loot(data.raw.unit["maf-boss-toxic-biter-"..k])
	update_boss_loot(data.raw.unit["maf-boss-toxic-spitter-"..k])
	update_boss_loot(data.raw.unit["maf-boss-explosive-biter-"..k])
	update_boss_loot(data.raw.unit["maf-boss-explosive-spitter-"..k])
	update_boss_loot(data.raw.unit["maf-boss-frost-biter-"..k])
	update_boss_loot(data.raw.unit["maf-boss-frost-spitter-"..k])
	end