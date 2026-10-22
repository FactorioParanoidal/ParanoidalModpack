-- Native 1x2 loaders; AAI remains the owner of recipes and research.
-- Sprite layout adapted from Vanilla Loaders / Artisanal Reskins, (c) 2024 Kirazy.
-- MIT notices and resource provenance: graphics/loaders/.
if not require("loader-definitions").enabled(mods, settings.startup) then return end

local tiers = {
    { old = "aai-basic-loader", name = "bob-basic-loader", belt = "bob-basic-transport-belt", power = 150 },
    { old = "aai-loader", name = "loader", belt = "transport-belt", power = 300 },
    { old = "aai-fast-loader", name = "fast-loader", belt = "fast-transport-belt", power = 700 },
    { old = "aai-express-loader", name = "express-loader", belt = "express-transport-belt", power = 1800 },
    { old = "aai-turbo-loader", name = "bob-turbo-loader", belt = "turbo-transport-belt", power = 4000 },
    { old = "aai-ultimate-loader", name = "bob-ultimate-loader", belt = "bob-ultimate-transport-belt", power = 10000 },
}
local root = "__zzzparanoidal__/graphics/loaders/"
local multiplier = settings.startup["paranoidal-miniloader-energy-multiplier"].value / 4
local template = table.deepcopy(data.raw.loader.loader)
local replacements = {}

local function sprite(file, y)
    return { filename = root .. file .. ".png", priority = "extra-high", width = 212,
        height = 192, scale = 0.5, y = y }
end

local function structure_layers(tint, y)
    local base = sprite("loader-structure-base", y)
    local mask = sprite("loader-structure-mask", y)
    mask.tint = tint
    local highlights = sprite("loader-structure-highlights", y)
    highlights.blend_mode = "additive"
    local shadow = sprite("loader-structure-shadow", y)
    shadow.draw_as_shadow = true
    return { sheets = { base, mask, highlights, shadow } }
end

-- kW -> localised power string in the unit the engine would pick.
local function power_text(kw)
    if kw >= 1000 then return { "paranoidal-loader-tooltip.megawatt", string.format("%.3g", kw / 1000) } end
    if kw >= 1 then return { "paranoidal-loader-tooltip.kilowatt", string.format("%.3g", kw) } end
    return { "paranoidal-loader-tooltip.watt", string.format("%.3g", kw * 1000) }
end

-- The merged Factoriopedia page gets these fields from the item only.
-- Entity hover tooltips keep their own copy; recipes use the product tooltip.
local function tooltip_only(fields)
    local result = table.deepcopy(fields)
    for _, field in ipairs(result) do field.show_in_factoriopedia = false end
    return result
end

local function set_icons(prototype, icons)
    prototype.icon = nil
    prototype.icon_size = nil
    prototype.icons = table.deepcopy(icons)
end

for i, tier in ipairs(tiers) do
    local old_item = assert(data.raw.item[tier.old], tier.old)
    local old_entity = assert(data.raw["loader-1x1"][tier.old], tier.old)
    local belt = assert(data.raw["transport-belt"][tier.belt], tier.belt)
    local tint = reskins.lib.tiers.get_belt_tint(i - 1)
    local name = { "entity-name.paranoidal-" .. tier.name }
    -- speed is tiles/tick; two lanes, four items/tile, 60 ticks/second.
    local throughput = belt.speed * 480
    local power = tier.power * multiplier
    -- Idle drain is 10x the former value (user decision).
    local drain = belt.speed * 32 * multiplier * 10
    local per_item = power / throughput
    -- The shell has no energy source, so the engine's electricity block is absent.
    -- Shown instead as tooltip fields; values are the native loader's real figures.
    local description = { "" }
    local fields = {
        { name = { "paranoidal-loader-tooltip.speed" },
          value = { "paranoidal-loader-tooltip.items-per-second", string.format("%.6g", throughput) } },
        { name = { "paranoidal-loader-tooltip.max-consumption" }, value = power_text(power) },
        { name = { "paranoidal-loader-tooltip.min-consumption" }, value = power_text(drain) },
    }

    local item = table.deepcopy(old_item)
    item.name = tier.name
    item.place_result = tier.name
    item.hidden = false
    item.hidden_in_factoriopedia = false
    item.localised_name = name
    item.localised_description = description
    item.custom_tooltip_fields = table.deepcopy(fields)

    local entity = table.deepcopy(template)
    entity.name = tier.name
    entity.hidden = false
    entity.hidden_in_factoriopedia = false
    entity.localised_name = name
    entity.localised_description = description
    entity.custom_tooltip_fields = tooltip_only(fields)
    entity.minable = { mining_time = old_entity.minable.mining_time, result = tier.name }
    entity.max_health = old_entity.max_health
    entity.filter_count = old_entity.filter_count
    entity.next_upgrade = tiers[i + 1] and tiers[i + 1].name or nil
    entity.speed = belt.speed
    entity.belt_animation_set = table.deepcopy(belt.belt_animation_set)
    entity.structure_render_layer = "object"
    entity.structure = {
        direction_in = structure_layers(tint, 0),
        direction_out = structure_layers(tint, 192),
        back_patch = { sheet = sprite("loader-structure-back-patch") },
        front_patch = { sheet = sprite("loader-structure-front-patch") },
    }
    entity.energy_per_item = string.format("%.12gkJ", per_item)
    entity.energy_source = {
        type = "electric", usage_priority = "secondary-input",
        drain = string.format("%.12gkW", drain),
        -- Agreed starting buffer formula, NOT a verified half-second reserve.
        buffer_capacity = string.format("%.12gkJ", per_item * belt.speed * 0.16),
    }
    data:extend({ item, entity })

    reskins.lib.setup_standard_entity(tier.name, i - 1, {
        type = "loader", base_entity_name = "splitter", tint = tint,
        particles = { medium = 1, big = 4 }, make_remnants = false, make_icons = false,
    })
    local icons = {
        { icon = root .. "icons/loader-icon-base.png", icon_size = 64 },
        { icon = root .. "icons/loader-icon-mask.png", icon_size = 64, tint = tint },
        { icon = root .. "icons/loader-icon-highlights.png", icon_size = 64, tint = { 1, 1, 1, 0 } },
    }
    item.pictures = reskins.lib.sprites.create_sprite_from_icons(icons, 1.0)
    if reskins.lib.settings.get_value("reskins-bobs-do-belt-entity-tier-labeling") ~= false then
        icons = reskins.lib.tiers.add_tier_labels_to_icons(i - 1, icons)
    end
    set_icons(item, icons)
    set_icons(entity, icons)

    local remnant = table.deepcopy(data.raw.corpse["underground-belt-remnants"])
    remnant.name = "paranoidal-" .. tier.name .. "-remnants"
    remnant.localised_name = name
    remnant.selection_box = table.deepcopy(entity.selection_box)
    remnant.tile_width = 1
    remnant.tile_height = 2
    -- Keep the vanilla underground-belt debris sprite: the Vanilla Loaders remnant atlas
    -- has red/green work arrows baked in (unused upstream, its corpse call is commented out).
    set_icons(remnant, icons)
    data:extend({ remnant })
    entity.corpse = remnant.name

    local recipe = assert(data.raw.recipe[tier.old], tier.old)
    set_icons(recipe, icons)
    recipe.localised_name = name
    recipe.localised_description = description
    -- The product tooltip already includes the placing entity's fields.
    recipe.custom_tooltip_fields = nil
    local technology = assert(data.raw.technology[tier.old], tier.old)
    set_icons(technology, icons)
    -- Item icons use a 32px canvas; technology icons use 256px. Scale labels too.
    for _, icon in ipairs(technology.icons) do
        icon.scale = (icon.scale or 32 / icon.icon_size) * 8
        if icon.shift then icon.shift = { icon.shift[1] * 8, icon.shift[2] * 8 } end
    end
    technology.localised_name = name
    technology.localised_description = table.deepcopy(description)
    technology.custom_tooltip_fields = table.deepcopy(fields)

    old_item.hidden = true
    old_item.hidden_in_factoriopedia = true
    old_entity.hidden = true
    old_entity.hidden_in_factoriopedia = true
    -- The engine rejects upgrade targets whose placing items are hidden.
    old_entity.next_upgrade = nil
    replacements[tier.old] = tier.name
end

-- After OV.execute, flowfix and all Beta 8 costs: preserve every quantity and recipe field.
-- Include third-party consumers, not just the previous tier in the AAI chain.
for _, recipe in pairs(data.raw.recipe) do
    for _, list in ipairs({ recipe.ingredients or {}, recipe.results or {} }) do
        for _, entry in pairs(list) do
            if entry.type ~= "fluid" then
                local key = entry.name and "name" or 1
                entry[key] = replacements[entry[key]] or entry[key]
            end
        end
    end
    if recipe.main_product then
        recipe.main_product = replacements[recipe.main_product] or recipe.main_product
    end
end

-- Factoriopedia shows a recipe on the item page only under the item's own name.
-- Move each final AAI recipe (all costs/fields kept) to the item name; this replaces
-- base's hidden legacy loader/fast-loader/express-loader recipes. Unlocks follow.
local renamed = {}
for _, tier in ipairs(tiers) do
    local old = data.raw.recipe[tier.old]
    local new = table.deepcopy(old)
    new.name = tier.name
    new.hidden = false
    new.hidden_in_factoriopedia = false
    data.raw.recipe[tier.name] = new
    old.hidden = true
    old.hidden_in_factoriopedia = true
    old.enabled = false
    renamed[tier.old] = tier.name
end
for _, technology in pairs(data.raw.technology) do
    for _, effect in pairs(technology.effects or {}) do
        if effect.type == "unlock-recipe" and renamed[effect.recipe] then effect.recipe = renamed[effect.recipe] end
    end
end
