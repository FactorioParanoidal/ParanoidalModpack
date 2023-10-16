local noise = require("noise")
local tne = noise.to_noise_expression
local util = require("util")
local tileMetaData=require("tileMetaData")

return function()
    for name, tileData in pairs(data.raw.tile) do
        local biome = ""
        local tileName = name

        for unaliased, alias in pairs(tileMetaData.tile_alias) do
            if name == unaliased then
                tileName = alias
                break
            end
        end

        for setting, prefix in pairs(tileMetaData.biome_settings) do
            if util.startsWith(tileName, prefix) then
                biome = setting
                break
            end
        end

        if tileData.autoplace then
            if tileData.autoplace.probability_expression ~= nil then
                if biome ~= "" then
                    tileMetaData.biomes_used[biome] = biome
                    local expr = tileData.autoplace.probability_expression
                    local a = noise.var("settings-a-" .. biome)
                    local b = noise.var("settings-b-" .. biome)
                    local c = noise.var("settings-c-" .. biome)
                    local d = tileMetaData.get_dynamic_scale(name)
                    if d~=1 then
                        a=a*tne(d)
                        c=c*tne(d)
                    end

                    local disabled = noise.var("settings-disabled-" .. biome)
                    tileData.autoplace.probability_expression = noise.if_else_chain(disabled, -1e309, ((expr + a) / b) + c)

                elseif __DebugAdapter then
                    log(tileName .. "    No biome")
                end
            elseif __DebugAdapter then
                log(tileName .. "    No expression")
            end
        end
    end

    for biome, value in pairs(tileMetaData.biomes_used) do
        data:extend { {
            type = "autoplace-control",
            name = "settings-" .. biome,
            order = "zzz-" .. biome .. "-zzz",
            richness = true,
            category = "resource"
        } }

        data:extend {
            {
                type = "noise-expression",
                name = "settings-disabled-" .. biome,
                expression = noise.equals(noise.var("control-setting:settings-" .. biome .. ":size:multiplier"), tne(0)) --disable button  size/coverage==0
            },
            {
                type = "noise-expression",
                name = "settings-a-" .. biome,
                expression = noise.log2(noise.var("control-setting:settings-" .. biome .. ":frequency:multiplier")) ^ tne(5) --frequency / scale   0.16 to 6 / 6 to 0.16
            },
            {
                type = "noise-expression",
                name = "settings-b-" .. biome,
                expression = noise.var("control-setting:settings-" .. biome .. ":size:multiplier") ^ tne(3) --size/coverage disable==0 and 0.16 to 6 / 0.16 to 6
            },
            {
                type = "noise-expression",
                name = "settings-c-" .. biome,
                expression = (noise.log2(noise.var("control-setting:settings-" .. biome .. ":richness:multiplier")) ^ tne(9)) * tne(60) --richness 0.16 to 6
            },
        }
    end
end
