-- allow rocket silos to be built on space platforms
if data.raw.item['se-rocket-launch-pad'] then
for s=1,6 do 
	data.raw["assembling-machine"]["rsc-silo-stage"..s].collision_mask = data.raw["rocket-silo"]["rocket-silo"].collision_mask
	if data.raw["assembling-machine"]["rsc-silo-stage"..s.."-serlp"] then data.raw["assembling-machine"]["rsc-silo-stage"..s.."-serlp"].collision_mask = data.raw["container"]["se-rocket-launch-pad"].collision_mask end
	if data.raw["assembling-machine"]["rsc-silo-stage"..s.."-sesprs"] then data.raw["assembling-machine"]["rsc-silo-stage"..s.."-sesprs"].collision_mask = data.raw["rocket-silo"]['se-space-probe-rocket-silo'].collision_mask end
	end

if data.raw.item["rsc-excavation-site-serlp"] then data.raw.item["rsc-excavation-site-serlp"].subgroup = data.raw.item["se-rocket-launch-pad"].subgroup end
if data.raw.item["rsc-excavation-site-sesprs"] then data.raw.item["rsc-excavation-site-sesprs"].subgroup = data.raw.item["se-space-probe-rocket-silo"].subgroup end
end
data.raw.item["rsc-excavation-site"].subgroup = data.raw.item["rocket-silo"].subgroup


--HIDES ORIGINAL SILO RECIPE
local effects = data.raw.technology["rocket-silo"].effects
for k,effect in pairs (effects) do
	if effect.type=='unlock-recipe' then
		if effect.recipe == 'rocket-silo' then effect.recipe = 'rsc-excavation-site' end
		end
	end
data.raw.recipe["rocket-silo"].hidden = true

if data.raw.item['se-rocket-launch-pad'] then
local enable_se_cargo = settings.startup["rsc-st-enable-se-cargo-silo"].value 
local enable_se_probe = settings.startup["rsc-st-enable-se-probe-silo"].value 

if enable_se_cargo then 
	local effects = data.raw.technology["se-rocket-launch-pad"].effects
	for k,effect in pairs (effects) do
		if effect.type=='unlock-recipe' then
			if effect.recipe == 'se-rocket-launch-pad' then effect.recipe = 'rsc-serlp-excavation-site' end
			end
		end
	data.raw.recipe["se-rocket-launch-pad"].hidden = enable_se_cargo
	end

if enable_se_probe then
	local effects = data.raw.technology["se-space-probe"].effects
	for k,effect in pairs (effects) do
		if effect.type=='unlock-recipe' then
			if effect.recipe == 'se-space-probe-rocket-silo' then effect.recipe = 'rsc-sesprs-excavation-site' end
			end
		end
	data.raw.recipe["se-space-probe-rocket-silo"].hidden = enable_se_probe
	end
end