-- Reskins Bob 1.1: purple fourth tier and green fifth tier, on current 2.0 assets.
-- Run after the recipe/item menu icons settle, before technology icon markers.
if not (reskins and reskins.bobs and reskins.bobs.triggers.mining.entities) then return end
local drills = data.raw["mining-drill"]

local function recolor(value, tint, animation_speed)
    if type(value) ~= "table" then return end
    if value.filename and value.filename:find("pumpjack", 1, true) then
        if value.filename:find("mask", 1, true) then value.tint = table.deepcopy(tint) end
        if animation_speed and value.frame_count then value.animation_speed = animation_speed end
    end
    for _, child in pairs(value) do
        if type(child) == "table" then recolor(child, tint, animation_speed) end
    end
end

for _, entry in ipairs({
    {"paranoidal-pumpjack-4", 4, 1.625, "paranoidal-pumpjacks-4"},
    {"bob-pumpjack-3", 5, 2, "bob-pumpjacks-4"},
}) do
    local name, tier, animation_speed = entry[1], entry[2], entry[3]
    local entity = drills[name]
    if entity then
        local tint = reskins.lib.tiers.get_tint(tier)
        reskins.lib.setup_standard_entity(name, tier, {
            type = "mining-drill", icon_name = "pumpjack", icon_base = "pumpjack",
            base_entity_name = "pumpjack", mod = "bobs", group = "mining",
            tint = tint, particles = {small = 3}, make_remnants = false,
        })
        recolor(entity.graphics_set, tint, animation_speed)
        local corpse = data.raw.corpse[entity.corpse]
        if corpse then recolor(corpse.animation, tint) end
        local recipe = data.raw.recipe[name]
        if recipe then
            recipe.icon = nil
            recipe.icons = table.deepcopy(entity.icons)
        end
        local technology = data.raw.technology[entry[4]]
        if technology then
            for _, icon in pairs(technology.icons or {}) do
                if icon.icon:find("pumpjack%-technology%-mask") then
                    icon.tint = table.deepcopy(tint)
                elseif icon.icon:find("/graphics/icons/tiers/", 1, true) then
                    icon.icon = icon.icon:gsub("/%d+%.png$", "/" .. tier .. ".png")
                    if icon.tint then
                        icon.tint = table.deepcopy(tint)
                        icon.tint.a = 0.75
                    end
                end
            end
        end
        -- Cursed-FMD's copies were generated before these final recolors.
        for clone_name, clone in pairs(drills) do
            if clone_name:match("^(.-)___") == name then
                recolor(clone.graphics_set, tint, animation_speed)
                clone.icon = entity.icon
                clone.icons = table.deepcopy(entity.icons)
                clone.corpse = entity.corpse
                clone.dying_explosion = entity.dying_explosion
            end
        end
    end
end
