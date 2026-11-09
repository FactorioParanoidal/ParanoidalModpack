local rro = Muluna.rro
local chunk = table.deepcopy(data.raw["asteroid-chunk"]["metallic-asteroid-chunk"])
local graphics_available = false --Whether graphics are available for the anorthite asteroids

local item = data.raw["item"]["anorthite-chunk"]

rro.deep_replace(chunk,"metallic-asteroid-chunk","anorthite-chunk")

chunk.localised_name = {"item-name.anorthite-chunk"}
chunk.icon = item.icon
chunk.icon_size = item.icon_size


Muluna:extend{chunk}


local size_array = {"small","medium","big","huge"}
for i,size in pairs(size_array) do 
    local asteroid = table.deepcopy(data.raw["asteroid"][size.."-metallic-asteroid"])
    asteroid.name = size.."-anorthite-asteroid"
    asteroid.icon = "__muluna-graphics__/graphics/icons/".. asteroid.name .. ".png"
    for j,drop_size in pairs(size_array) do
        rro.deep_replace(asteroid,drop_size.."-metallic-asteroid",drop_size.."-anorthite-asteroid")
    end
    rro.deep_gsub(asteroid,size.."%-metallic%-asteroid",size.."-anorthite-asteroid")
    rro.deep_gsub(asteroid,"asteroid%-metallic"..size.."%-colour","asteroid-metallic"..size.."-colour")
    rro.deep_gsub(asteroid,"__space%-age__/graphics/entity/","__muluna-graphics__/graphics/entities/")
    rro.deep_replace(asteroid,"metallic-asteroid-chunk","anorthite-chunk")
    asteroid.order = "za".. i .. "[" .. size.."-metallic-asteroid" .. "]"

    Muluna:extend{asteroid}
end