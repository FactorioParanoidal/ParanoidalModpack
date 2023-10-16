local noise = require("noise")
local tne = noise.to_noise_expression
local util=require("util")

return function()
    data:extend {
        {
            type = "noise-expression",
            name = "target",
            intended_property = "target",
            expression = tne(0)
        }
    }

    local i = 1
    for name, tileData in pairs(data.raw.tile) do
        if tileData.autoplace and tileData.autoplace.probability_expression ~= nil then
            --require("noiseImpression")(tileData.autoplace.probability_expression);
            data:extend {
                {
                    type = "noise-expression",
                    name = "settings-target-" .. name,
                    intended_property = "target",
                    expression = util.deepcopy(tileData.autoplace.probability_expression)
                },
            }
            i = i + 1
        end
    end

    local halfCount = math.floor((i - 1) / 2) + 1
    local expStep = 2
    local exp = (halfCount / 2 - 1) * expStep
    local current = 1
    local alien = "Tile colors:"
    local stat = "Tile equations:"

    for name, tileData in pairs(data.raw.tile) do
        if tileData.autoplace and tileData.autoplace.probability_expression ~= nil then
            local target = noise.var("target")

            local limCloserToNul = math.pow(10, exp - (expStep / 2))
            local limCloserToInf = math.pow(10, exp + (expStep / 2))
            local expr

            alien = alien ..  "\n" .. name .. " " .. util.RGBtoHEX(tileData.map_color)
            tileData.map_color = util.generateColor(current)

            if current < halfCount then
                if current == 1 then --first
                    expr = noise.if_else_chain(noise.less_than(target, -limCloserToNul), 1e309, -1e309)
                    stat = stat .. "\n" .. (name .. " < " .. -limCloserToNul) .. " " .. util.RGBtoHEX(tileData.map_color)
                elseif current == halfCount - 1 then --last
                    expr = noise.if_else_chain(noise.less_than(target, -limCloserToInf), -1e309,
                        noise.less_than(0, target),
                        -1e309, 1e309)
                    stat = stat .. "\n" .. (-limCloserToInf .. " <= " .. name .. " <  0") ..
                        " " .. util.RGBtoHEX(tileData.map_color)
                else
                    expr = noise.if_else_chain(noise.less_than(target, -limCloserToInf), -1e309,
                        noise.less_than(-limCloserToNul, target), -1e309, 1e309)
                    stat = stat ..
                        "\n" ..
                        (-limCloserToInf .. " <= " .. name .. " <  " .. -limCloserToNul) ..
                        " " .. util.RGBtoHEX(tileData.map_color)
                end
                exp = exp - expStep
            elseif current > halfCount then
                if current == halfCount + 1 then --first
                    expr = noise.if_else_chain(noise.less_or_equal(target, 0), -1e309,
                        noise.less_or_equal(limCloserToInf, target), -1e309, 1e309)
                    stat = stat .. "\n" .. ("0 <  " .. name .. " <= " .. limCloserToInf) ..
                        " " .. util.RGBtoHEX(tileData.map_color)
                elseif current == halfCount * 2 - 1 then --last
                    expr = noise.if_else_chain(noise.less_or_equal(limCloserToNul, target), 1e309, -1e309)
                    stat = stat .. "\n" .. (limCloserToNul .. " < " .. name) .. " " .. util.RGBtoHEX(tileData.map_color)
                else
                    expr = noise.if_else_chain(noise.less_or_equal(target, limCloserToNul), -1e309,
                        noise.less_or_equal(limCloserToInf, target), -1e309, 1e309)
                    stat = stat ..
                        "\n" ..
                        (limCloserToNul .. " <  " .. name .. " <= " .. limCloserToInf) ..
                        " " .. util.RGBtoHEX(tileData.map_color)
                end
                exp = exp + expStep
            else --position in middle is expr==Zero
                expr = noise.if_else_chain(noise.equals(target, tne(0)), 1e309, -1e309)
                stat = stat .. "\n" .. (name .. " == 0") .. " " .. util.RGBtoHEX(tileData.map_color)
            end

            tileData.autoplace.probability_expression = expr
            current = current + 1
        end
    end
    log(alien)
    log(stat)
end
