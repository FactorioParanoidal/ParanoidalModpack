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
require("tweaks.entity.aai-loaders")
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
require("tweaks.recipe.groups")
require("tweaks.recipe.optera-warehouse-sort") -- Optera warehouse (6×6) и storehouse (3×3) — каждый одним рядом
require("tweaks.recipe.fuel")
require("tweaks.recipe.science-packs")
require("tweaks.recipe.warfare") -- рецепт artillery-turret: добавление artillery-turret-prototype (файл не был подключён при порте)
require("tweaks.recipe.repair-turret") -- Repair Turret: дорогой рецепт
require("tweaks.recipe.osha-containers") -- osha mini passive/storage: синхрон с большими (убрать лишний advanced-circuit)
require("tweaks.recipe.miles-bobs-expansion-port") -- MilesBobsExpansion2: восстановление богатых рецептов тиров 7-9/electronics 4-5 (1.1)
require("tweaks.recipe.inserter-cranes-port") -- Beta 8: цены кранов после перехода stack → bulk

require("tweaks.technology.metallurgy")
require("tweaks.technology.warfare")
require("tweaks.technology.pumps")
require("tweaks.technology.yuoki")
require("tweaks.technology.concrete")
require("tweaks.technology.fuel")
require("tweaks.technology.oberhaul-inserter-cost") -- 1.1 Oberhaul: дороже near/long/more-инсертер техи
require("tweaks.technology.factorissimo-recursion-clean") -- убираем пустой "+" эффект у factory-recursion-t1/t2

require("tweaks.custom.main-menu-background")
require("tweaks.custom.map-gen-presets")
require("tweaks.custom.icons")
require("tweaks.custom.selections")


require("removals.bio-modules")
require("removals.fishes")
require("removals.aai-medium-electric-pole")
require("removals.aai-basic-logistics")
require("removals.clowns-steel-c2")
require("removals.angels-valves") -- прячем Angels-flow-клапаны: заменены модом valves (inspector остаётся)

require("graphics.train.train_reskin") -- рескин поездов
-------------------------------------------------------------------------------------------------
require("final-fixes.technologies") -- Пожалуйста не добавляйте сюда новых записей. Поищите раздел в tweaks/technology или создайте там новый
require("final-fixes.recipies")-- Пожалуйста не добавляйте сюда новых записей. Поищите раздел в tweaks/recipe или создайте там новый
require("final-fixes.icon-size-fallback")
require("tweaks.recipe.angels-smelting-extended-port") -- частичный порт мода angels-smelting-extended из 1.1
require("tweaks.recipe.angels-wire-coil-insulated-port") -- port angels-wire-coil-insulated (1.1 ASE)
require("tweaks.recipe.angels-smelting-extended-gears-port") -- gear-wheel casting + dies (1.1 ASE ironworks)
-- После final-fixes.recipies: там bi-bio-farm ещё заменяет старый stone-crushed на кирпич.
require("tweaks.recipe.bi2-fixes") -- Bio_Industries_2 регрессии (stone-crushed/solid-sand renamings)
require("tweaks.recipe.marathon-port") -- 1.1 marathon-баланс (порт из 1.1 in-game)
require("tweaks.recipe.teleporters-port") -- port 1.1 paranoidal teleporter cost
require("tweaks.recipe.holographic-signs-port") -- gate hs_holo_sign behind circuit-network tech (1.1)

-- map-gen presets: на data-final-fixes, чтобы захватить autoplace-control'ы
-- любого мода, который их регистрирует в data-updates/data-final-fixes
-- (не только в data-stage).
require("prototypes.map-gen-presets")

require("tweaks.custom.uniform-recipies")
require("prototypes.entity.storage-migration")

-- final aplying of override functions
angelsmods.functions.OV.execute()

require("tweaks.technology.clowns-processing") -- Clowns-Processing: актуальный prerequisite Bob's tungsten
require("tweaks.technology.energy-balance") -- ранняя энергетика без обработанного топлива и отдельной электрификации

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

-- 1.1-цены лестницы лент поверх стока Bob+Angels
require("tweaks.recipe.belt-tier-cost")

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
require("tweaks.technology.spacemod-components-beta8")
require("tweaks.recipe.spacemod-god-module-beta8")
require("tweaks.recipe.spacemod-components-beta8")
require("removals.spacemod-beta8")
require("tweaks.technology.science-foundation-beta8")
require("tweaks.recipe.science-foundation-beta8")
require("tweaks.technology.electronics-science-beta8")
require("tweaks.recipe.bi-science-beta8")
require("tweaks.technology.early-electronics-beta8")
require("tweaks.recipe.early-electronics-beta8")
require("tweaks.recipe.early-supply-beta8")
require("tweaks.technology.red-green-infrastructure-beta8")
require("tweaks.recipe.red-green-infrastructure-beta8")
require("tweaks.technology.angels-early-beta8")
require("tweaks.recipe.angels-early-beta8")
require("tweaks.technology.gems-beta8")
require("tweaks.recipe.gems-beta8")
require("tweaks.entity.early-fluid-compatibility-beta8")
require("tweaks.technology.bio-growing-beta8")
require("tweaks.recipe.bio-growing-beta8")
require("tweaks.technology.bio-processing-beta8")
require("tweaks.recipe.bio-processing-beta8")
require("tweaks.technology.cracking-beta8")
require("tweaks.recipe.cracking-beta8")
require("removals.bio-extras-beta8")
require("tweaks.technology.military-beta8")
require("tweaks.recipe.military-beta8")
require("tweaks.recipe.warehouse-beta8")
require("tweaks.technology.chemistry-remainder-beta8")
require("tweaks.recipe.chemistry-remainder-beta8")
require("tweaks.recipe.fish-keeping-beta8")
require("tweaks.recipe.pure-ore-smelting-beta8")
require("tweaks.recipe.pure-tin-lead-beta8")
require("tweaks.recipe.fish-buildings-beta8")
require("tweaks.technology.fish-buildings-beta8")
require("tweaks.recipe.advanced-electronics-beta8")
require("tweaks.technology.advanced-electronics-beta8")
require("tweaks.technology.steam-inserter-beta8")
require("tweaks.technology.air-filter-beta8")
require("tweaks.item.gems-menu-beta8")
require("tweaks.recipe.nitrogen-remainder-beta8")
require("tweaks.technology.nitrogen-remainder-beta8")
require("tweaks.recipe.ammo-finite-beta8")
require("tweaks.technology.ammo-finite-beta8")
require("tweaks.recipe.inserter-merge-beta8")
require("tweaks.technology.inserter-merge-beta8")
require("tweaks.recipe.cobalt-components-beta8")
require("tweaks.recipe.platforms-logistics-beta8")
require("tweaks.technology.platforms-logistics-beta8")
require("tweaks.recipe.sodium-beta8")
require("tweaks.technology.sodium-beta8")
require("tweaks.recipe.equipment-erp-beta8")
require("tweaks.technology.equipment-erp-beta8")
require("prototypes.heavy-armor-beta8")
require("tweaks.item.w93-thermal-link-beta8")
require("prototypes.rcu-beta8")
require("tweaks.recipe.rcu-consumers-beta8")
require("tweaks.technology.rcu-consumers-beta8")
require("tweaks.recipe.late-biology-beta8")
require("tweaks.technology.late-biology-beta8")

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

-- PCPRedux: дубль sodium nitrate (старое ангеловское имя) → angels-solid-sodium-nitrate
require("removals.pcp-sodium-nitrate-duplicate")

-- Beta 8 start, after late overrides; preserve current machinery and agreed exceptions.
require("prototypes.torch-beta8")
require("tweaks.recipe.start-menu-beta8")
require("tweaks.custom.crafting-menu-beta8")
require("tweaks.item.angels-components-group") -- целые строки Angel's во вкладку «Компоненты»
require("tweaks.recipe.lamp-components")
require("tweaks.technology.lamp-unlocks")
require("tweaks.entity.assembler-ingredient-descriptions")
require("tweaks.entity.ore-sorting-bootstrap")
require("tweaks.recipe.frame-metallurgy-beta8")
require("tweaks.technology.frame-metallurgy-beta8")

require("tweaks.custom.restack-port") -- ReStack (Optera, 1.1) порт: размеры пачек по категориям
-- Общее масштабирование рецептов; модульный порт ниже уже содержит итоговые партии Beta 8.
require("tweaks.custom.flowfix")
require("prototypes.modules-beta8")
-- После восстановления модульных рецептов, масштабирования партий и OV.execute.
require("tweaks.recipe.platinum-wire")
require("tweaks.technology.platinum-wire")
require("tweaks.custom.super-labs-beta8") -- Отдельные Гиг-лаба и Гипер-лаба; параметры Beta 8.
require("tweaks.entity.space-data-labs") -- Космические данные принимает только центр обработки данных.
require("tweaks.item.titanium-icon") -- После reskins и поздних копирований иконок.
-- После финальных скоростей лент, стоимости AAI, restack, flowfix и OV.execute.
require("prototypes.electric-loaders")
require("prototypes.loader-shells")
-- После всех правок технологий: возврат триггерных исследований на цену банок Beta 8.
require("tweaks.technology.action-research-beta8")
-- После всех восстановлений дерева: согласованные зависимости материалов и компонентов.
require("tweaks.technology.material-component-gates")
require("tweaks.technology.disabled-zinc-prerequisites")
require("tweaks.technology.bronze-axe-beta8")
require("tweaks.technology.electricity-poles-beta8")
require("tweaks.technology.wood-phosphorus-beta8")
require("tweaks.technology.boiler-2-beta8")
require("tweaks.technology.fluid-barrels-beta8")
require("tweaks.technology.steam-engine-2-beta8")
require("tweaks.technology.heat-pipe-1-beta8")
require("tweaks.technology.scattergun-prerequisite-beta8")
require("tweaks.technology.boiler-inserter-prerequisites-beta8")
require("prototypes.seafloor-pumps.integration")
require("removals.angels-sea-pump")
-- После всех копий насосов и скрытия морского насоса Angels.
require("tweaks.entity.landfill-pumps")
require("tweaks.recipe.nickel-ammo-beta8-port")
-- После OV и всех производителей/потребителей: Bob-смола → BI-смола в банке.
require("tweaks.item.unify-resin")
-- Только согласованные иконки: после Reskins и намеренных замен титана/смолы.
require("tweaks.custom.bobicons-beta8")
-- Согласованная первая вкладка Beta 8; неразобранные рецепты пока отдельно.
require("tweaks.custom.logistics-menu-beta8")
-- Вторая вкладка: согласованные ряды Bob, без отдельных filter-дублей.
require("tweaks.custom.bob-logistics-menu-beta8")
-- Третья вкладка: логика Beta 8 с согласованными устройствами 2.0.
require("tweaks.custom.circuit-menu-beta8")
-- Четвёртая вкладка: возвращённый «Транспорт» Beta 8.
require("tweaks.custom.transport-menu-beta8")
-- Пятая вкладка: производство Beta 8 с сохранением новых устройств 2.0.
require("tweaks.custom.production-menu-beta8")
-- Шестая вкладка: модули сразу после производства, как в Beta 8.
require("tweaks.custom.modules-menu-beta8")
-- Седьмая вкладка: тематические блоки компонентов, иконки соответствий Beta 8.
require("tweaks.custom.components-menu-beta8")
-- После компонентов: отдельный Bob, оружие/оборона и оборудование по назначению.
require("tweaks.custom.bob-combat-menu-beta8")
-- Самоцветы и личное снаряжение; транспортные робопорты остаются в технике Angels.
require("tweaks.custom.gems-equipment-menu-beta8")
-- Переработка ресурсов и металлургия: только ряды рецептов и согласованные иконки.
require("tweaks.custom.refining-smelting-menu-beta8")
-- Отливка и водоочистка: компактные семейства, без изменения рецептур и механики.
require("tweaks.custom.casting-water-menu-beta8")
-- Нефтехимия и разливка: смысловые ряды и пары наполнения/опорожнения, только меню.
require("tweaks.custom.petrochem-fluid-menu-beta8")
-- Производство, транспортное оборудование и общий космос: только размещение рецептов.
require("tweaks.custom.production-space-menu")
-- Единый размер и верхний правый угол метки освещения, после замен иконок меню.
require("tweaks.custom.lighted-pole-icons")
-- Точечные исключения по скриншотам: согласованные основы иконок, метки способов сохраняются.
require("tweaks.custom.recipe-presentation")
-- После всех правок меню: иконка рецепта — эталон для однозначного предмета.
require("tweaks.custom.recipe-item-icon-sync").apply(data.raw, defines.prototypes.item, log)
-- Та же группировка для предметов, жидкостей и Factoriopedia; раскладка рецептов сохраняется.
require("tweaks.custom.recipe-product-menu-sync").apply(data.raw, defines.prototypes, log)
-- Согласованные иконки предметов по рецептам; после общих синхронизаторов, чтобы их не перезаписали.
require("tweaks.custom.recipe-presentation-items")
-- Цвета исследований жидкостей согласованы с восстановленными иконками резервуаров.
require("tweaks.technology.fluid-handling-colors")
-- Только обычная деревянная труба: без стрелок и прохода сквозь сплошной ряд.
require("tweaks.entity.wood-pipe")
-- После восстановления дерева: материалы у предков и единый паровой крекинг I.
require("tweaks.technology.early-material-prerequisites")
require("tweaks.technology.steam-cracking-merge")
require("tweaks.technology.approved-beta8-icons") -- Согласованные изображения исследований; без модулей.
-- Этот require ВСЕГДА ПОСЛЕДНИЙ: не переносить и не добавлять код ниже.
-- Все новые правки размещать выше: здесь фиксируются иконка и последнее место эффекта эволюции.
require("tweaks.technology.research-evolution-icon")
