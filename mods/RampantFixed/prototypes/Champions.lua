-- Reforged Paranoidal: sprites drawn over champions and hour bosses (libs/Champions.lua)

data:extend({
    {
        type = "sprite",
        name = "rampantFixed-champion-star-silver",
        filename = "__RampantFixed__/graphics/champions/star-silver.png",
        size = 64,
    },
    {
        type = "sprite",
        name = "rampantFixed-champion-star-gold",
        filename = "__RampantFixed__/graphics/champions/star-gold.png",
        size = 64,
    },
    {
        type = "sprite",
        name = "rampantFixed-champion-glow",
        filename = "__RampantFixed__/graphics/champions/glow.png",
        size = 128,
    },
    {
        -- the shield over a retreating champion: the base energy shield icon
        type = "sprite",
        name = "rampantFixed-champion-shield",
        filename = "__base__/graphics/icons/energy-shield-equipment.png",
        size = 64,
        mipmap_count = 4,
        flags = {"icon"},
    },
})
