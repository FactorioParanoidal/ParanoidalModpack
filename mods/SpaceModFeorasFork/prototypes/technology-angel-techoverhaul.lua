local researchCost = settings.startup["SpaceX-research"].value or 1
local ignoreMult = settings.startup["SpaceX-ignore-tech-multiplier"].value or false
local classicMode = settings.startup["SpaceX-classic-mode"].value or false
local ftlRampUp = settings.startup["SpaceX-ftl-ramp-up"].value or false

local marathon_adj
if ignoreMult then
	marathon_adj = 4
else
	marathon_adj = 1
end

-- adjustments for angels overhaul
researchCost = researchCost / 2

if data.raw.technology["space-assembly"] then
    data.raw.technology["space-assembly"].unit.count = 6000 * researchCost / marathon_adj
end
if data.raw.technology["space-construction"] then
    data.raw.technology["space-construction"].unit.count = 12000 * researchCost / marathon_adj
end
if data.raw.technology["space-casings"] then
    data.raw.technology["space-casings"].unit.count = 12000 * researchCost / marathon_adj
end
if data.raw.technology["protection-fields"] then
    data.raw.technology["protection-fields"].unit.count = 12000 * researchCost / marathon_adj
end
if data.raw.technology["fusion-reactor"] then
    data.raw.technology["fusion-reactor"].unit.count = 12000 * researchCost / marathon_adj
end
if data.raw.technology["space-thrusters"] then
    data.raw.technology["space-thrusters"].unit.count = 12000 * researchCost / marathon_adj
end
if data.raw.technology["fuel-cells"] then
    data.raw.technology["fuel-cells"].unit.count = 6000 * researchCost / marathon_adj
    data.raw.technology["fuel-cells"].unit.ingredients = { { "datacore-energy-2", 2 }, { "angels-science-pack-yellow", 1 } }
end
if data.raw.technology["habitation"] then
    data.raw.technology["habitation"].unit.count = 12000 * researchCost / marathon_adj
    data.raw.technology["habitation"].unit.ingredients = { { "datacore-logistic-2", 2 }, { "angels-science-pack-yellow", 1 } }
end
if data.raw.technology["life-support-systems"] then
    data.raw.technology["life-support-systems"].unit.count = 12000 * researchCost / marathon_adj
    data.raw.technology["life-support-systems"].unit.ingredients = { { "datacore-enhance-2", 2 }, { "angels-science-pack-yellow", 1 } }
end
if data.raw.technology["astrometrics"] then
    data.raw.technology["astrometrics"].unit.count = 14000 * researchCost / marathon_adj
    data.raw.technology["astrometrics"].unit.ingredients = { { "datacore-enhance-2", 2 }, { "angels-science-pack-yellow", 1 } }
end
if data.raw.technology["spaceship-command"] then
    data.raw.technology["spaceship-command"].unit.count = 24000 * researchCost / marathon_adj
    data.raw.technology["spaceship-command"].unit.ingredients = { { "datacore-logistic-2", 2 }, { "angels-science-pack-yellow", 1 } }
end
if data.raw.technology["laser-cannon"] then
    data.raw.technology["laser-cannon"].unit.count = 24000 * researchCost / marathon_adj
end
if data.raw.technology["ftl-theory-A"] then
    data.raw.technology["ftl-theory-A"].unit.count = 25000 * researchCost / marathon_adj
end
if data.raw.technology["ftl-theory-B"] then
    data.raw.technology["ftl-theory-B"].unit.count = 50000 * researchCost / marathon_adj
end
if data.raw.technology["ftl-theory-C"] then
    data.raw.technology["ftl-theory-C"].unit.count = 75000 * researchCost / marathon_adj
end
if data.raw.technology["ftl-theory-D1"] then
    data.raw.technology["ftl-theory-D1"].unit.count = 100000 * researchCost / marathon_adj
end
if data.raw.technology["ftl-theory-D2"] then
    data.raw.technology["ftl-theory-D2"].unit.count = 100000 * researchCost / marathon_adj
    data.raw.technology["ftl-theory-D2"].unit.ingredients = { { "datacore-exploration-2", 2 }, { "angels-science-pack-yellow", 1 } }
end
if data.raw.technology["ftl-propulsion"] then
    data.raw.technology["ftl-propulsion"].unit.count = 150000 * researchCost / marathon_adj
end


if not classicMode then
    if data.raw.technology["exploration-satellite"] then
        data.raw.technology["exploration-satellite"].unit.count = 175000 * researchCost / marathon_adj
    end
    if data.raw.technology["space-ai-robots"] then
        data.raw.technology["space-ai-robots"].unit.count = 175000 * researchCost / marathon_adj
    end
    if data.raw.technology["space-fluid-tanks"] then
        data.raw.technology["space-fluid-tanks"].unit.count = 175000 * researchCost / marathon_adj
    end
    if data.raw.technology["space-cartography"] then
        data.raw.technology["space-cartography"].unit.count = 200000 * researchCost / marathon_adj
        data.raw.technology["space-cartography"].unit.ingredients = { { "datacore-exploration-2", 2 }, { "angels-science-pack-yellow", 1 } }
    end
end

if classicMode then
    if data.raw.technology["ftl-theory-A"] then
        data.raw.technology["ftl-theory-A"].unit.count = 200000 * researchCost / marathon_adj
    end
    if data.raw.technology["ftl-theory-B"] then
        data.raw.technology["ftl-theory-B"].unit.count = 200000 * researchCost / marathon_adj
    end
    if data.raw.technology["ftl-theory-C"] then
        data.raw.technology["ftl-theory-C"].unit.count = 200000 * researchCost / marathon_adj
    end
    if data.raw.technology["ftl-theory-D1"] then
        data.raw.technology["ftl-theory-D1"].unit.count = 200000 * researchCost / marathon_adj
    end
    if data.raw.technology["ftl-theory-D2"] then
        data.raw.technology["ftl-theory-D2"].unit.count = 200000 * researchCost / marathon_adj
    end
    if data.raw.technology["ftl-propulsion"] then
        data.raw.technology["ftl-propulsion"].unit.count = 200000 * researchCost / marathon_adj
    end
end

if ftlRampUp then
    if data.raw.technology["ftl-theory-A"] then
        data.raw.technology["ftl-theory-A"].unit.count = 50000 * researchCost / marathon_adj
    end
    if data.raw.technology["ftl-theory-B"] then
        data.raw.technology["ftl-theory-B"].unit.count = 65000 * researchCost / marathon_adj
    end
    if data.raw.technology["ftl-theory-C"] then
        data.raw.technology["ftl-theory-C"].unit.count = 80000 * researchCost / marathon_adj
    end
    if data.raw.technology["ftl-theory-D1"] then
        data.raw.technology["ftl-theory-D1"].unit.count = 100000 * researchCost / marathon_adj
    end
    if data.raw.technology["ftl-theory-D2"] then
        data.raw.technology["ftl-theory-D2"].unit.count = 100000 * researchCost / marathon_adj
    end
    if data.raw.technology["ftl-propulsion"] then
        data.raw.technology["ftl-propulsion"].unit.count = 150000 * researchCost / marathon_adj
    end
end
