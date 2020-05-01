local fish = {
    type = "fish",
    name = "pollution",
    pictures = {
        {
            filename = "__toxicPollution__/graphics/pollution.png",
            priority = "low",
            width = 1,
            height = 1
        }
    },
    resistances = {},
    flags = {"not-deconstructable"}
}

for _, d in pairs(data.raw["damage-type"]) do
    table.insert(fish.resistances, {
        type = d.name,
        percent = 100,
    })
end

data:extend({fish})