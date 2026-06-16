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
require("tweaks.technology.research-evolution-icon") -- иконка-график вместо красного "+" у эффекта research_evolution_factor
require("tweaks.technology.factorissimo-recursion-clean") -- убираем пустой "+" эффект у factory-recursion-t1/t2

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

-- molten-*-alloy-mixing/remelting не имеют recipe-name локали → "Unknown key" в 2.0
-- (icons-оверлей ломает авто-вывод). Берём имя из fluid-результата.
for name, recipe in pairs(data.raw.recipe) do
	if (name:match("^molten%-.*%-alloy%-mixing") or name:match("^molten%-.*%-remelting$"))
		and not recipe.localised_name then
		local fluid = recipe.results and recipe.results[1] and recipe.results[1].name
		if fluid then
			recipe.localised_name = { "fluid-name." .. fluid }
		end
	end
end

-- 1.1 micro-final-fix: правим angels*-crushed-smelting in-place (после OV.execute,
-- чтобы OV не перезатёр). bob-*-plate остаётся скрыт силами angelssmelting.
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

-- свинец (Rubyte / ore5), олово (Bobmonium / ore6)
patch_crushed_smelting("angels-ore5-crushed-smelting", "angels-ore5-crushed", "bob-lead-plate")
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
require("tweaks.technology.spacemod-port")

-- angelspetrochem 2.0.2 ретайрнул angels-liquid-sulfuric-acid → базовый sulfuric-acid.
-- Перенаправляем рецепты, ещё ссылающиеся на мёртвый флюид.
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
