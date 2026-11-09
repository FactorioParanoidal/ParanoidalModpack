require "prototypes.vanilla-changes"
require "prototypes.item-weight"
require "prototypes.default-import-location"
require "prototypes.item-sounds"
require "prototypes.entity.regulator-fluidbox"
require "prototypes.fluid-void"
require "prototypes.technology.promethium-quality"

require "prototypes.recipe.deepsea-research"

require "compat.aai-industry"
require "compat.aai-signal-transmission"
require "compat.editor-extensions"
require "compat.transport-ring-teleporter"
require "compat.quality-seeds"
require "compat.modules-t4"
require "compat.5-dim-automation"
require "compat.rcu-restored"
require "compat.aircraft-space-age"
require "compat.corrundum"
require "compat.muluna"
require "compat.aai-programmable-structures"

-- Paranoidal fork: fluid barrels keep their fuel properties (upstream made the barrels of every fuel fluid a fuel of
-- a new category with a burnt result; the build's fuel barrels burn at home as before, the diesel submarine burns
-- chemical fuel).

local nightvision_to_extend = {}
for _, nightvision in pairs(data.raw["night-vision-equipment"]) do
    if nightvision.name == "ee-super-night-vision-equipment" then goto continue end

    local disabled = table.deepcopy(nightvision)
    disabled.take_result = nightvision.take_result or nightvision.name
    disabled.name = nightvision.name .. "-disabled"
    disabled.darkness_to_turn_on = 1
    disabled.localised_name = nightvision.localised_name or {"equipment-name." .. nightvision.name}

    disabled.localised_description = {"",
        nightvision.localised_description or {"?", {"", {"equipment-description." .. nightvision.name}, "\n"}, {"", {"item-description." .. nightvision.name}, "\n"}, ""},
        {"equipment-description.nightvision-disabled-underwater"}
    }

    nightvision_to_extend[#nightvision_to_extend + 1] = disabled

    ::continue::
end
data:extend(nightvision_to_extend)

data:extend {{
    type = "item-subgroup",
    name = "maraxsis-atmosphere-barreling",
    order = "ff",
    group = "intermediate-products",
}}

for recipe_name, category in pairs {
    ["empty-maraxsis-atmosphere-barrel"] = "chemistry",
    ["maraxsis-atmosphere-barrel"] = "chemistry",
    ["empty-maraxsis-liquid-atmosphere-barrel"] = "cryogenics",
    ["maraxsis-liquid-atmosphere-barrel"] = "cryogenics",
} do
    local recipe = data.raw.recipe[recipe_name]
    recipe.hidden_in_factoriopedia = false
    recipe.categories = {category}
    recipe.subgroup = "maraxsis-atmosphere-barreling"

    -- Barrelling must never be boosted by productivity. Some mods, such as
    -- K2SO, add machines with innate productivity bonuses (e.g. the advanced
    -- chemical plant). Machine productivity ignores `allow_productivity`, so
    -- without an explicit limit these recipes would create free barrels and
    -- fluid out of nowhere. https://github.com/FluidNatalie/maraxsis/issues/32
    recipe.allow_productivity = false
    recipe.maximum_productivity = 0
end
data.raw.recipe["empty-maraxsis-atmosphere-barrel"].results[1].temperature = 25

require "prototypes.item-subgroups"

if mods["assembler-pipe-passthrough"] then
    appmod.blacklist["maraxsis-hydro-plant"] = true
    appmod.blacklist["maraxsis-hydro-plant-extra-module-slots"] = true
end

-- regulator factoriopedia description

local function add_quality_factoriopedia_info(entity, factoriopedia_info)
    local factoriopedia_description

    for _, factoriopedia_info in pairs(factoriopedia_info or {}) do
        local header, factoriopedia_function = unpack(factoriopedia_info)
        local localised_string = {"", "[font=default-semibold]", header, "[/font]"}

        for _, quality in pairs(data.raw.quality) do
            if quality.hidden then goto continue end

            local quality_buff = factoriopedia_function(entity, quality)
            if type(quality_buff) ~= "table" then quality_buff = tostring(quality_buff) end
            table.insert(localised_string, {"", "\n[img=quality." .. quality.name .. "] ", {"quality-name." .. quality.name}, ": [font=default-semibold]", quality_buff, "[/font]"})
            ::continue::
        end

        if factoriopedia_description then
            factoriopedia_description[#factoriopedia_description + 1] = "\n\n"
            factoriopedia_description[#factoriopedia_description + 1] = maraxsis.shorten_localised_string(localised_string)
        else
            factoriopedia_description = localised_string
        end
    end

    entity.factoriopedia_description = maraxsis.shorten_localised_string(factoriopedia_description)
end

add_quality_factoriopedia_info(data.raw["roboport"]["maraxsis-regulator"], {
    {{"quality-tooltip.atmosphere-consumption"}, function(entity, quality_level)
        local consumption_per_second = maraxsis.atmosphere_consumption(quality_level)
        return tostring(consumption_per_second) .. "/s"
    end}
})
