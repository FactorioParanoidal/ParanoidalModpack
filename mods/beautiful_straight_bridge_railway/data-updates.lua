-- technology
table.insert(data.raw["technology"]["railway"].effects, {type = "unlock-recipe", recipe = "bbr-rail-brick"})
--[[
-- change default entity to placeable on water
--data.raw["rail-signal"]["rail-signal"].collision_mask = { "rail-layer" } --DrD
--data.raw["rail-chain-signal"]["rail-chain-signal"].collision_mask = { "rail-layer" } --DrD
for _, signal in pairs(data.raw["rail-signal"]) do                                       --DrD
   signal.collision_mask = { "object-layer" }
end
for _, signal in pairs(data.raw["rail-chain-signal"]) do                                  --DrD
   signal.collision_mask = { "object-layer" }
end  
]]
-- change big electric pole including other mods (bobs etc.)
local poles = data.raw["electric-pole"]
for key, value in pairs(poles) do
	if (string.find(key, "big-electric-pole",1,true)) then
		data.raw["electric-pole"][key].collision_mask = { "object-layer" }
	end
end