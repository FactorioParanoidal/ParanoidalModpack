require("tweaks.entity.roboport")
require("tweaks.entity.add-liquid-to-mine-ores")
require("tweaks.entity.construction-robots")
require("tweaks.entity.alien-loot")
require("tweaks.entity.increase-stack-size")
require("tweaks.entity.warfare")
require("tweaks.entity.pipes")
require("tweaks.entity.beacons") -- по маякам можно ходить
require("tweaks.entity.offshore-pumps")
require("tweaks.entity.assemblers")
require("tweaks.entity.furnaces")
require("tweaks.entity.fuel")
require("tweaks.entity.trains")
require("tweaks.entity.drills")
require("tweaks.entity.bio-mod")
require("tweaks.entity.fuel")
require("tweaks.entity.belts")
require("tweaks.entity.boilers")
require("tweaks.entity.alert-arrow")
require("tweaks.entity.miniloaders")
require("tweaks.entity.generators")
require("tweaks.entity.fluid-void")
require("tweaks.entity.gas-void")
require("tweaks.entity.wires")
require("tweaks.entity.nuke-cliffs")

require("tweaks.item.personal-roboport")
require("tweaks.item.roboport")
require("tweaks.item.fuel")

require("tweaks.recipe.insert-mining-drill-bit")
require("tweaks.recipe.insert-structured-components")
require("tweaks.recipe.metallurgy")
require("tweaks.recipe.pumps")
require("tweaks.recipe.gems")
require("tweaks.recipe.module")
require("tweaks.recipe.poles") -- Изменение рецептов ЛЭП
require("tweaks.recipe.yuoki")
require("tweaks.recipe.concrete")
require("tweaks.recipe.pipes")
require("tweaks.recipe.groups")
require("tweaks.recipe.fuel")
require("tweaks.recipe.science-packs")

require("tweaks.technology.chemistry")
require("tweaks.technology.metallurgy")
require("tweaks.technology.warfare")
require("tweaks.technology.boilers")
require("tweaks.technology.pumps")
require("tweaks.technology.yuoki")
require("tweaks.technology.concrete")
require("tweaks.technology.fuel")

require("tweaks.custom.main-menu-background")
require("tweaks.custom.map-gen-presets")
require("tweaks.custom.icons")
require("tweaks.custom.selections")


require("removals.bio-modules")
require("removals.fishes")

require("graphics.train.train_reskin") -- рескин поездов
-------------------------------------------------------------------------------------------------
require("final-fixes.technologies") -- Пожалуйста не добавляйте сюда новых записей. Поищите раздел в tweaks/technology или создайте там новый
require("final-fixes.recipies")-- Пожалуйста не добавляйте сюда новых записей. Поищите раздел в tweaks/recipe или создайте там новый

require("tweaks.custom.uniform-recipies")

-- final aplying of override functions
angelsmods.functions.OV.execute()

-- ============================================================
-- ПРЯМЕ ВИПРАВЛЕННЯ РЕЦЕПТІВ ПЛАВКИ (після OV.execute)
-- Аналог iron-plate→ore1-crushed та copper-plate→ore3-crushed
-- ============================================================

-- bob-lead-plate: замінюємо bob-lead-ore на angels-ore5-crushed (Rubyte)
log("[NEXUS-UA] Starting bob-lead-plate fix, recipe exists: "..tostring(data.raw.recipe["bob-lead-plate"] ~= nil))
if data.raw.recipe["bob-lead-plate"] then
    local r = data.raw.recipe["bob-lead-plate"]
    log("[NEXUS-UA] bob-lead-plate BEFORE: enabled="..tostring(r.enabled).." hidden="..tostring(r.hidden).." ings="..tostring(#(r.ingredients or {})))
    r.enabled = true
    r.hidden = false
    r.category = "smelting"
    r.localised_name = nil
    r.energy_required = 20
    r.ingredients = { { type = "item", name = "angels-ore5-crushed", amount = 7 } }
    r.results = {
        { type = "item", name = "bob-lead-plate", amount = 4 },
        { type = "item", name = "angels-slag", amount = 1 },
    }
    r.icon = "__angelssmeltinggraphics__/graphics/icons/plate-lead.png"
    r.icon_size = 32
    r.icons = nil
    log("[NEXUS-UA] bob-lead-plate set icon path: __angelssmeltinggraphics__/graphics/icons/plate-lead.png")
    -- Видалити з локів технологій
    for _, tech in pairs(data.raw.technology) do
        if tech.effects then
            for i = #tech.effects, 1, -1 do
                if tech.effects[i].type == "unlock-recipe" and tech.effects[i].recipe == "bob-lead-plate" then
                    table.remove(tech.effects, i)
                end
            end
        end
    end
end

-- bob-tin-plate: замінюємо bob-tin-ore на angels-ore6-crushed (Bobmonium)
if data.raw.recipe["bob-tin-plate"] then
    local r = data.raw.recipe["bob-tin-plate"]
    r.enabled = true
    r.hidden = false
    r.category = "smelting"
    r.localised_name = nil
    r.energy_required = 20
    r.ingredients = { { type = "item", name = "angels-ore6-crushed", amount = 7 } }
    r.results = {
        { type = "item", name = "bob-tin-plate", amount = 4 },
        { type = "item", name = "angels-slag", amount = 1 },
    }
    r.icons = {
        { icon = "__bobplates__/graphics/icons/plate/tin-plate.png", icon_size = 32 }
    }
    r.icon = nil
    r.icon_size = 32
    log("[NEXUS-UA] bob-tin-plate set icon path: __bobplates__/graphics/icons/plate/tin-plate.png")
    for _, tech in pairs(data.raw.technology) do
        if tech.effects then
            for i = #tech.effects, 1, -1 do
                if tech.effects[i].type == "unlock-recipe" and tech.effects[i].recipe == "bob-tin-plate" then
                    table.remove(tech.effects, i)
                end
            end
        end
    end
end

-- Відключити примітивні raw-ore рецепти (дублюють кращі crushed-ore варіанти)
-- angels-ore5-smelting: 1x Rubyte ore → 1x Lead plate (замінено на bob-lead-plate: 7x Crushed → 4x)
if data.raw.recipe["angels-ore5-smelting"] then
    data.raw.recipe["angels-ore5-smelting"].enabled = false
    data.raw.recipe["angels-ore5-smelting"].hidden = true
    log("[NEXUS-UA] angels-ore5-smelting: DISABLED + HIDDEN (replaced by bob-lead-plate)")
end

-- angels-ore6-smelting: 1x Bobmonium ore → 1x Tin plate (замінено на bob-tin-plate: 7x Crushed → 4x)
if data.raw.recipe["angels-ore6-smelting"] then
    data.raw.recipe["angels-ore6-smelting"].enabled = false
    data.raw.recipe["angels-ore6-smelting"].hidden = true
    log("[NEXUS-UA] angels-ore6-smelting: DISABLED + HIDDEN (replaced by bob-tin-plate)")
end

-- Залишити bob-lead-plate-2 доступним (хімічна піч)
if data.raw.recipe["bob-lead-plate-2"] then
    local r = data.raw.recipe["bob-lead-plate-2"]
    r.enabled = true
    r.hidden = false
    r.localised_name = nil
    r.icons = {
        { icon = "__bobplates__/graphics/icons/plate/lead-plate.png", icon_size = 32 }
    }
    r.icon = nil
    r.icon_size = 32
    log("[NEXUS-UA] bob-lead-plate-2 set icon path: __bobplates__/graphics/icons/plate/lead-plate.png")
end


--должно быть последним. После всех рецептов.
require("tweaks.custom.flowfix")
