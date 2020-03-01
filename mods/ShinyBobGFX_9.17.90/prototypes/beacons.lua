if data.raw["beacon"]["beacon"] then
    data.raw["beacon"]["beacon"]["base_picture"] = {
        filename = "__ShinyBobGFX__/graphics/entity/beacon/beacon-base-1.png",
        width = 116,
        height = 93,
        shift = { 0.34, 0.06},
    }
end

if data.raw["beacon"]["beacon-2"] then
	bobicon("beacon","beacon",1,3,0)
    data.raw["beacon"]["beacon"].fast_replaceable_group = "bacon"
    data.raw["beacon"]["beacon-2"].fast_replaceable_group = "bacon"
    data.raw["beacon"]["beacon-2"]["base_picture"] = {
        filename = "__ShinyBobGFX__/graphics/entity/beacon/beacon-base-2.png",
        width = 116,
        height = 93,
        shift = { 0.34, 0.06},
    }
end

if data.raw["beacon"]["beacon-3"] then
    data.raw["beacon"]["beacon-3"].fast_replaceable_group = "bacon"
    data.raw["beacon"]["beacon-3"]["base_picture"] = {
        filename = "__ShinyBobGFX__/graphics/entity/beacon/beacon-base-3.png",
        width = 116,
        height = 93,
        shift = { 0.34, 0.06},
    }
end
