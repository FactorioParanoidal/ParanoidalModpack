if data.raw["boiler"]["heat-exchanger-2"] then
bobicon("heat-exchanger","boiler",1,3,0)
end

for mk = 2,3 do
local mk_level = {"","-2","-3","-4","-5","-6"}
local entity = data.raw["boiler"]["heat-exchanger"..string.lower(mk_level[mk])]
local item = data.raw["item"]["heat-exchanger"..string.lower(mk_level[mk])]
local recipe = data.raw["recipe"]["heat-exchanger"..string.lower(mk_level[mk])]
if entity then
entity.structure.north.layers[1].filename = "__ShinyBobGFX__/graphics/entity/heat-exchanger/heatex-N-idle-"..mk..".png"
entity.structure.south.layers[1].filename = "__ShinyBobGFX__/graphics/entity/heat-exchanger/heatex-S-idle-"..mk..".png"
entity.structure.east.layers[1].filename = "__ShinyBobGFX__/graphics/entity/heat-exchanger/heatex-E-idle-"..mk..".png"
entity.structure.west.layers[1].filename = "__ShinyBobGFX__/graphics/entity/heat-exchanger/heatex-W-idle-"..mk..".png"
entity.structure.north.layers[1].hr_version.filename = "__ShinyBobGFX__/graphics/entity/heat-exchanger/hr-heatex-N-idle-"..mk..".png"
entity.structure.south.layers[1].hr_version.filename = "__ShinyBobGFX__/graphics/entity/heat-exchanger/hr-heatex-S-idle-"..mk..".png"
entity.structure.east.layers[1].hr_version.filename = "__ShinyBobGFX__/graphics/entity/heat-exchanger/hr-heatex-E-idle-"..mk..".png"
entity.structure.west.layers[1].hr_version.filename = "__ShinyBobGFX__/graphics/entity/heat-exchanger/hr-heatex-W-idle-"..mk..".png"
end
end
