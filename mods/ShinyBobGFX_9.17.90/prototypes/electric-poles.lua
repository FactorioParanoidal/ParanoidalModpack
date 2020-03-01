if data.raw["electric-pole"]["medium-electric-pole"] then
    local entity = data.raw["electric-pole"]["medium-electric-pole"]
    local item = data.raw["item"]["medium-electric-pole"]

    entity.fast_replaceable_group = "pole-s"
    data.raw["electric-pole"]["medium-electric-pole"]["pictures"]["layers"][1]["filename"] = "__ShinyBobGFX__/graphics/entity/poles/medium-electric-pole-1.png"
	data.raw["electric-pole"]["medium-electric-pole"]["pictures"]["layers"][1]["hr_version"]["filename"] = "__ShinyBobGFX__/graphics/entity/poles/hr-medium-electric-pole-1.png"

end

if data.raw["electric-pole"]["medium-electric-pole-2"] then
bobicon("medium-electric-pole","electric-pole",1,4,0)
bobicon("big-electric-pole","electric-pole",1,4,0)
bobicon("substation","electric-pole",1,4,0)

    data.raw["electric-pole"]["medium-electric-pole-2"].fast_replaceable_group = "pole-s"
    data.raw["electric-pole"]["medium-electric-pole-2"]["pictures"]["layers"][1]["filename"] = "__ShinyBobGFX__/graphics/entity/poles/medium-electric-pole-2.png"
	data.raw["electric-pole"]["medium-electric-pole-2"]["pictures"]["layers"][1]["hr_version"]["filename"] = "__ShinyBobGFX__/graphics/entity/poles/hr-medium-electric-pole-2.png"
end

if data.raw["electric-pole"]["medium-electric-pole-3"] then
    data.raw["electric-pole"]["medium-electric-pole-3"].fast_replaceable_group = "pole-s"
    data.raw["electric-pole"]["medium-electric-pole-3"]["pictures"]["layers"][1]["filename"] = "__ShinyBobGFX__/graphics/entity/poles/medium-electric-pole-3.png"
	data.raw["electric-pole"]["medium-electric-pole-3"]["pictures"]["layers"][1]["hr_version"]["filename"] = "__ShinyBobGFX__/graphics/entity/poles/hr-medium-electric-pole-3.png"
end

if data.raw["electric-pole"]["medium-electric-pole-4"] then
    data.raw["electric-pole"]["medium-electric-pole-4"].fast_replaceable_group = "pole-s"
    data.raw["electric-pole"]["small-electric-pole"].fast_replaceable_group = "pole-s"
    data.raw["electric-pole"]["medium-electric-pole-4"]["pictures"]["layers"][1]["filename"] = "__ShinyBobGFX__/graphics/entity/poles/medium-electric-pole-4.png"
	data.raw["electric-pole"]["medium-electric-pole-4"]["pictures"]["layers"][1]["hr_version"]["filename"] = "__ShinyBobGFX__/graphics/entity/poles/hr-medium-electric-pole-4.png"
end

if data.raw["electric-pole"]["small-iron-electric-pole"] then
    data.raw["electric-pole"]["small-iron-electric-pole"].fast_replaceable_group = "pole-s"
end

-- Large

if data.raw["electric-pole"]["big-electric-pole"] then
    data.raw["electric-pole"]["big-electric-pole"].pictures["filename"] = "__ShinyBobGFX__/graphics/entity/poles/big-electric-pole.png"
end

if data.raw["electric-pole"]["big-electric-pole-2"] then
    data.raw["electric-pole"]["big-electric-pole"].fast_replaceable_group = "pole-m"
    data.raw["electric-pole"]["big-electric-pole-2"].fast_replaceable_group = "pole-m"
    data.raw["electric-pole"]["big-electric-pole-2"].pictures["filename"] = "__ShinyBobGFX__/graphics/entity/poles/big-electric-pole-2.png"
end

if data.raw["electric-pole"]["big-electric-pole-3"] then
    data.raw["electric-pole"]["big-electric-pole-3"].fast_replaceable_group = "pole-m"
    data.raw["electric-pole"]["big-electric-pole-3"].pictures["filename"] = "__ShinyBobGFX__/graphics/entity/poles/big-electric-pole-3.png"
end

if data.raw["electric-pole"]["big-electric-pole-4"] then
    data.raw["electric-pole"]["big-electric-pole-4"].fast_replaceable_group = "pole-m"
    data.raw["electric-pole"]["big-electric-pole-4"].pictures["filename"] = "__ShinyBobGFX__/graphics/entity/poles/big-electric-pole-4.png"
end

-- Substation

if data.raw["electric-pole"]["substation"] then
    data.raw["electric-pole"]["substation"].pictures["filename"] = "__ShinyBobGFX__/graphics/entity/poles/substation.png"
end

if data.raw["electric-pole"]["substation-2"] then
    data.raw["electric-pole"]["substation"].fast_replaceable_group = "pole-l"
    data.raw["electric-pole"]["substation-2"].fast_replaceable_group = "pole-l"
    data.raw["electric-pole"]["substation-2"].pictures["filename"] = "__ShinyBobGFX__/graphics/entity/poles/substation-2.png"
end

if data.raw["electric-pole"]["substation-3"] then
    data.raw["electric-pole"]["substation-3"].fast_replaceable_group = "pole-l"
    data.raw["electric-pole"]["substation-3"].pictures["filename"] = "__ShinyBobGFX__/graphics/entity/poles/substation-3.png"
end

if data.raw["electric-pole"]["substation-4"] then
    data.raw["electric-pole"]["substation-4"].fast_replaceable_group = "pole-l"
    data.raw["electric-pole"]["substation-4"].pictures["filename"] = "__ShinyBobGFX__/graphics/entity/poles/substation-4.png"
end
