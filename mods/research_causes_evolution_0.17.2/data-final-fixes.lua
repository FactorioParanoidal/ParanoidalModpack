--[[
   Copyright 2018 H8UL

   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the "Software"), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in all
   copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
   SOFTWARE.
--]]

local includeUpgrades = settings.startup["research-causes-evolution-include-upgrades"].value

local function cost(tech)

    if tech.enabled == false then
        return nil
    end

    if tech.hidden == false then
        return nil
    end

    if tech.max_level == "infinite" then
        return nil
    end

    if includeUpgrades == false and tech.upgrade == true then
        return nil
    end

    local count = tech.unit.count

    if count == nil or type(count) ~= "number" or count < 1 then
        return nil
    end

    return count * tech.unit.time * #tech.unit.ingredients
end

local rankings = {}

for _,tech in pairs(data.raw.technology) do

    local c = cost(tech)
    if c then
        table.insert(rankings, {tech = tech, cost = c})
    end
end

local weighting = settings.startup["research-causes-evolution-weighting"].value

if weighting == "early" then
    table.sort(rankings, function(a,b) return a.cost > b.cost end)
elseif weighting == "late" then
    table.sort(rankings, function(a,b) return a.cost < b.cost end)
end

local nextEffectSize = 1
local total = 0

for _,entry in ipairs(rankings) do
    entry.effectSize = nextEffectSize
    total = total + nextEffectSize
    if not (weighting == "equal") then
        nextEffectSize = nextEffectSize + 1
    end
end

local unhandledPercentage = 100
for _,entry in ipairs(rankings) do
    local percentage = 100.0*entry.effectSize/total
    local rounded = tonumber(string.format("%.2g", percentage))
    entry.percentage = rounded
    unhandledPercentage = unhandledPercentage - rounded
end

if rankings[1] and unhandledPercentage > 0 then
    rankings[1].percentage = rankings[1].percentage + unhandledPercentage
end

for _,entry in ipairs(rankings) do


    local effect = {
        type  = "nothing",
        effect_description = {"research-causes-evolution-effect", entry.percentage}
    }

    local tech = entry.tech
    if tech.effects then
        table.insert(tech.effects, effect)
    else
        tech.effects = {effect}
    end
end