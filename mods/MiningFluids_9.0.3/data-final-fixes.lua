--function disableEquipment()
--data.raw["recipe"]["burner-mining-drill"] = nil
--end

function extendVanilla()
if data.raw["resource"]["iron-ore"] then
data.raw["resource"]["iron-ore"].minable.required_fluid = "water"
data.raw["resource"]["iron-ore"].minable.fluid_amount = 20
end

if data.raw["resource"]["copper-ore"] then
    data.raw["resource"]["copper-ore"].minable.required_fluid = "steam"
    data.raw["resource"]["copper-ore"].minable.fluid_amount = 20
end

if data.raw["resource"]["stone"] then
    data.raw["resource"]["stone"].minable.required_fluid = "steam"
    data.raw["resource"]["stone"].minable.fluid_amount = 20
end

--[[
if data.raw["resource"]["coal"] then
    data.raw["resource"]["coal"].minable.required_fluid = "water"
    data.raw["resource"]["coal"].minable.fluid_amount = 10
end
]]

end

function extendBobs()
if data.raw["resource"]["zinc-ore"] then
data.raw["resource"]["zinc-ore"].minable.required_fluid = "water"
data.raw["resource"]["zinc-ore"].minable.fluid_amount = 20
end

if data.raw["resource"]["tungsten-ore"] then
    data.raw["resource"]["tungsten-ore"].minable.required_fluid = "water"
    data.raw["resource"]["tungsten-ore"].minable.fluid_amount = 20
end


if data.raw["resource"]["tin-ore"] then
    data.raw["resource"]["tin-ore"].minable.required_fluid = "water"
    data.raw["resource"]["tin-ore"].minable.fluid_amount = 20
end


if data.raw["resource"]["sulfur"] then
    data.raw["resource"]["sulfur"].minable.required_fluid = "steam"
    data.raw["resource"]["sulfur"].minable.fluid_amount = 20
end


if data.raw["resource"]["sort-gem-ore"] then
    data.raw["resource"]["sort-gem-ore"].minable.required_fluid = "water"
    data.raw["resource"]["sort-gem-ore"].minable.fluid_amount = 20
end


if data.raw["resource"]["silver-ore"] then
    data.raw["resource"]["silver-ore"].minable.required_fluid = "steam"
    data.raw["resource"]["silver-ore"].minable.fluid_amount = 20
end


if data.raw["resource"]["rutile"] then
    data.raw["resource"]["rutile"].minable.required_fluid = "water"
    data.raw["resource"]["rutile"].minable.fluid_amount = 20
end


if data.raw["resource"]["quartz"] then
    data.raw["resource"]["quartz"].minable.required_fluid = "water"
    data.raw["resource"]["quartz"].minable.fluid_amount = 20
end


if data.raw["resource"]["nickel-ore"] then
    data.raw["resource"]["nickel-ore"].minable.required_fluid = "steam"
    data.raw["resource"]["nickel-ore"].minable.fluid_amount = 20
end


if data.raw["resource"]["lead-ore"] then
    data.raw["resource"]["lead-ore"].minable.required_fluid = "water"
    data.raw["resource"]["lead-ore"].minable.fluid_amount = 20
end


if data.raw["resource"]["gold-ore"] then
    data.raw["resource"]["gold-ore"].minable.required_fluid = "steam"
    data.raw["resource"]["gold-ore"].minable.fluid_amount = 20
end


if data.raw["resource"]["gem-ore"] then
    data.raw["resource"]["gem-ore"].minable.required_fluid = "steam"
    data.raw["resource"]["gem-ore"].minable.fluid_amount = 20
end



if data.raw["resource"]["cobalt-ore"] then
    data.raw["resource"]["cobalt-ore"].minable.required_fluid = "water"
    data.raw["resource"]["cobalt-ore"].minable.fluid_amount = 20
end

if data.raw["resource"]["bauxite"] then
    data.raw["resource"]["bauxite"].minable.required_fluid = "water"
    data.raw["resource"]["bauxite"].minable.fluid_amount = 20
end
end

function extendAngles()
if data.raw["resource"]["angels-ore1"] then
data.raw["resource"]["angels-ore1"].minable.required_fluid = "water"
data.raw["resource"]["angels-ore1"].minable.fluid_amount = 100
end
if data.raw["resource"]["angels-ore2"] then
data.raw["resource"]["angels-ore2"].minable.required_fluid = "steam"
data.raw["resource"]["angels-ore2"].minable.fluid_amount = 100
end
if data.raw["resource"]["angels-ore3"] then
data.raw["resource"]["angels-ore3"].minable.required_fluid = "water"
data.raw["resource"]["angels-ore3"].minable.fluid_amount = 100
end
if data.raw["resource"]["angels-ore4"] then
data.raw["resource"]["angels-ore4"].minable.required_fluid = "steam"
data.raw["resource"]["angels-ore4"].minable.fluid_amount = 100
end
if data.raw["resource"]["angels-ore5"] then
data.raw["resource"]["angels-ore5"].minable.required_fluid = "steam"
data.raw["resource"]["angels-ore5"].minable.fluid_amount = 100
end
if data.raw["resource"]["angels-ore6"] then
data.raw["resource"]["angels-ore6"].minable.required_fluid = "steam"
data.raw["resource"]["angels-ore6"].minable.fluid_amount = 100
end

data.raw.resource["infinite-angels-ore1"].minable.required_fluid = "liquid-sulfuric-acid"
data.raw.resource["infinite-angels-ore2"].minable.required_fluid = "liquid-hydrofluoric-acid"
data.raw.resource["infinite-angels-ore3"].minable.required_fluid = "liquid-sulfuric-acid"
data.raw.resource["infinite-angels-ore4"].minable.required_fluid = "liquid-hydrochloric-acid"
data.raw.resource["infinite-angels-ore5"].minable.required_fluid = "liquid-nitric-acid"
data.raw.resource["infinite-angels-ore6"].minable.required_fluid = "liquid-nitric-acid"

data.raw.resource["infinite-angels-ore1"].minable.fluid_amount = 100
data.raw.resource["infinite-angels-ore2"].minable.fluid_amount = 100
data.raw.resource["infinite-angels-ore3"].minable.fluid_amount = 100
data.raw.resource["infinite-angels-ore4"].minable.fluid_amount = 100
data.raw.resource["infinite-angels-ore5"].minable.fluid_amount = 100
data.raw.resource["infinite-angels-ore6"].minable.fluid_amount = 100

data.raw["resource"]["infinite-coal"].minable.required_fluid = nil
data.raw["resource"]["infinite-coal"].minable.fluid_amount = nil

end


--disableEquipment()
extendVanilla()
extendBobs()
extendAngles()