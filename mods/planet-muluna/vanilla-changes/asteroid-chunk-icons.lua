

local asteroids = {
    "oxide-asteroid-chunk",
    "metallic-asteroid-chunk",
    "carbonic-asteroid-chunk",
    "anorthite-chunk"
}

for _,asteroid in pairs(asteroids) do
    data.raw["item"][asteroid].pictures =
    {
        {size = 64, filename = "__muluna-graphics__/graphics/icons/asteroid-chunks/" .. asteroid .. ".png",scale = 0.5, mipmap_count = 4},
        {size = 64, filename = "__muluna-graphics__/graphics/icons/asteroid-chunks/" .. asteroid .. "-1.png",scale = 0.5, mipmap_count = 4, tint = {0.9,0.9,0.9,1}},
        --{size = 64, filename = "__muluna-graphics__/graphics/icons/asteroid-chunks/" .. asteroid .. "-2.png",scale = 0.5, mipmap_count = 4, tint = {0.8,0.8,0.8,1}},
        --{size = 64, filename = "__muluna-graphics__/graphics/icons/asteroid-chunks/" .. asteroid .. "-3.png",scale = 0.5, mipmap_count = 4, tint = {0.9,0.9,0.9,1}},
    }
end