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
require("tweaks.entity.oberhaul-lab-power") -- 1.1 Oberhaul: энергия лабов (scienceoberhaul)
require("tweaks.entity.fluid-void")
require("tweaks.entity.gas-void")
require("tweaks.entity.wires")
require("tweaks.entity.nuke-cliffs")

require("tweaks.item.personal-roboport")
require("tweaks.item.roboport")
require("tweaks.item.fuel")
require("tweaks.item.grouping")

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
require("tweaks.technology.oberhaul-inserter-cost") -- 1.1 Oberhaul: дороже near/long/more-инсертер техи

require("tweaks.custom.main-menu-background")
require("tweaks.custom.map-gen-presets")
require("tweaks.custom.icons")
require("tweaks.custom.selections")


require("removals.bio-modules")
require("removals.fishes")
require("removals.aai-medium-electric-pole")
require("removals.clowns-steel-c2")

require("graphics.train.train_reskin") -- рескин поездов
-------------------------------------------------------------------------------------------------
require("final-fixes.technologies") -- Пожалуйста не добавляйте сюда новых записей. Поищите раздел в tweaks/technology или создайте там новый
require("final-fixes.recipies")-- Пожалуйста не добавляйте сюда новых записей. Поищите раздел в tweaks/recipe или создайте там новый
require("final-fixes.icon-size-fallback")
require("tweaks.recipe.angels-smelting-extended-port") -- частичный порт мода angels-smelting-extended из 1.1
require("tweaks.recipe.angels-wire-coil-insulated-port") -- port angels-wire-coil-insulated (1.1 ASE)
require("tweaks.recipe.angels-smelting-extended-gears-port") -- gear-wheel casting + dies (1.1 ASE ironworks)
require("tweaks.recipe.bi2-fixes") -- Bio_Industries_2 регрессии (stone-crushed/solid-sand renamings)
require("tweaks.recipe.marathon-port") -- 1.1 marathon-баланс (порт из 1.1 in-game)
require("tweaks.recipe.teleporters-port") -- port 1.1 paranoidal teleporter cost
require("tweaks.recipe.holographic-signs-port") -- gate hs_holo_sign behind circuit-network tech (1.1)

-- map-gen presets: на data-final-fixes, чтобы захватить autoplace-control'ы
-- любого мода, который их регистрирует в data-updates/data-final-fixes
-- (не только в data-stage).
require("prototypes.map-gen-presets")

require("tweaks.custom.uniform-recipies")

-- final aplying of override functions
angelsmods.functions.OV.execute()

-- Локали для рецептов angelsextended-remelting-fixed:
-- molten-*-alloy-mixing* и molten-*-remelting не имеют recipe-name локалей
-- ни в 1.1, ни в 2.0. В 1.1 Factorio авто-выводил имя из единственного fluid-
-- результата; в 2.0 из-за кастомного icons-оверлея авто-вывод не срабатывает
-- → "Unknown key: recipe-name.X". Прокидываем имя через localised_name к fluid.
-- (Sorting/rebalance/tier-categories — в tweaks/recipe/angels-smelting-extended-port.lua)
for name, recipe in pairs(data.raw.recipe) do
	if (name:match("^molten%-.*%-alloy%-mixing") or name:match("^molten%-.*%-remelting$"))
		and not recipe.localised_name then
		local fluid = recipe.results and recipe.results[1] and recipe.results[1].name
		if fluid then
			recipe.localised_name = { "fluid-name." .. fluid }
		end
	end
end

-- ============================================================
-- ПРЯМОЕ ИСПРАВЛЕНИЕ РЕЦЕПТОВ ПЛАВКИ (после OV.execute)
-- Стратегия 1.1: модифицируем angels*-crushed-smelting in-place
-- (7 crushed → 4 plate + 1 slag), как было в micro-final-fix.lua.
-- bob-*-plate recipe остаётся скрытым силами angelssmelting'а.
-- ============================================================

local function patch_crushed_smelting(recipe_name, crushed_name, plate_name)
    local r = data.raw.recipe[recipe_name]
    if not r then return end
    r.energy_required = 20
    r.ingredients = { { type = "item", name = crushed_name, amount = 7 } }
    r.results = {
        { type = "item", name = plate_name, amount = 4 },
        { type = "item", name = "angels-slag", amount = 1 },
    }
    r.main_product = plate_name
    r.localised_name = { "item-name." .. plate_name }
end

-- Свинец (Rubyte): 7×ore5-crushed → 4×lead-plate + 1×slag
patch_crushed_smelting("angels-ore5-crushed-smelting", "angels-ore5-crushed", "bob-lead-plate")

-- Олово (Bobmonium): 7×ore6-crushed → 4×tin-plate + 1×slag
patch_crushed_smelting("angels-ore6-crushed-smelting", "angels-ore6-crushed", "bob-tin-plate")

-- Отключить raw-ore дубликаты (появились в 2.0; в 1.1 их не было)
for _, name in ipairs({ "angels-ore5-smelting", "angels-ore6-smelting" }) do
    if data.raw.recipe[name] then
        data.raw.recipe[name].enabled = false
        data.raw.recipe[name].hidden = true
    end
end

-- Oberhaul refining-port (после OV.execute, чтобы OV не перезатёр изменения).
require("tweaks.recipe.oberhaul-refining-port")

-- Oberhaul belt-port (beltrecipes + beltentities, 1.1)
require("tweaks.recipe.oberhaul-belt-port")

-- Oberhaul petrochem-port (petrochemchange, 1.1)
require("tweaks.recipe.oberhaul-petrochem-port")

-- Баланс стоимости резины из дерева (resin/bob-resin)
require("tweaks.recipe.resin-balance")

-- Oberhaul gems-port (gems2 огранка + gems ликвефакция, 1.1)
require("tweaks.recipe.oberhaul-gems-port")

-- Oberhaul solar-port (bobssolar: ×4 тиры панелей/аккумуляторов, 1.1)
require("tweaks.recipe.oberhaul-solar-port")

-- Oberhaul module-port (эффекты + слоты модулей, 1.1; цена — отдельно)
require("tweaks.recipe.oberhaul-module-port")

-- Bob's/Angels 2.1: фл­юид angels-liquid-sulfuric-acid ретайрнут → базовый sulfuric-acid
-- (миграция angelspetrochem 2.0.2). Перенаправляем все рецепты, ещё ссылающиеся на мёртвый
-- фл­юид (angelsindustries 1.1.0 без апдейта, PCPRedux, zzz chemistry/electronics).
for _, recipe in pairs(data.raw.recipe) do
	for _, list in ipairs({ recipe.ingredients or {}, recipe.results or {} }) do
		for _, item in pairs(list) do
			if item.name == "angels-liquid-sulfuric-acid" then
				item.name = "sulfuric-acid"
			end
		end
	end
end

--должно быть последним. После всех рецептов.
require("tweaks.custom.flowfix")
