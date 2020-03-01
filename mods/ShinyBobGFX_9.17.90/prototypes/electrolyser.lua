if data.raw["assembling-machine"]["electrolyser-2"] then
bobicon("electrolyser","assembling-machine",1,4,0)
end

for mk = 2,4 do
local entity = data.raw["assembling-machine"]["electrolyser-"..mk]
local item = data.raw["item"]["electrolyser-"..mk]
local recipe = data.raw["recipe"]["electrolyser-"..mk]
if entity then
entity.animation.north.filename = "__ShinyBobGFX__/graphics/entity/electrolyser/electro-v-t"..mk.."u.png"
entity.animation.south.filename = "__ShinyBobGFX__/graphics/entity/electrolyser/electro-v-t"..mk.."d.png"
entity.animation.east.filename = "__ShinyBobGFX__/graphics/entity/electrolyser/electro-h-t"..mk.."r.png"
entity.animation.west.filename = "__ShinyBobGFX__/graphics/entity/electrolyser/electro-h-t"..mk.."l.png"
end
end