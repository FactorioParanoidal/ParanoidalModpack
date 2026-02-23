-- добавляем зависимости в техологии для последовательности развития
bobmods.lib.tech.add_prerequisite("bob-electronics-machine-1", "steel-processing")
bobmods.lib.tech.add_prerequisite("radar", "electronics")
bobmods.lib.tech.add_prerequisite("electric-lab", "electronics")
bobmods.lib.tech.add_prerequisite("logistic-science-pack", "electronics")
bobmods.lib.tech.add_prerequisite("logistic-science-pack", "angels-bronze-smelting-1")
bobmods.lib.tech.add_prerequisite("angels-bio-wood-processing", "bi-tech-bio-farming")
bobmods.lib.tech.add_prerequisite("angels-metallurgy-1", "angels-ore-crushing")
bobmods.lib.tech.add_prerequisite("angels-lead-smelting-1", "angels-basic-chemistry-2")
-- bobmods.lib.tech.add_prerequisite("JunkTrain_tech", "steel-processing")
--зеленые банки к зеленым банкам
bobmods.lib.tech.add_prerequisite("warehouse-research", "logistic-science-pack")
bobmods.lib.tech.add_prerequisite("OilBurning", "logistic-science-pack")
bobmods.lib.tech.add_prerequisite("bob-steel-axe-2", "logistic-science-pack")
bobmods.lib.tech.add_prerequisite("bob-area-drills-1", "logistic-science-pack")
bobmods.lib.tech.add_prerequisite("fluid-handling", "logistic-science-pack")
bobmods.lib.tech.add_prerequisite("remelting-alloy-mixer-1", "logistic-science-pack")
bobmods.lib.tech.add_prerequisite("bob-chemical-processing-2", "logistic-science-pack")
bobmods.lib.tech.add_prerequisite("angels-ironworks-1", "logistic-science-pack")
bobmods.lib.tech.add_prerequisite("bi-tech-bio-farming-2", "logistic-science-pack")
bobmods.lib.tech.add_prerequisite("adv-seed-extraction", "logistic-science-pack")
bobmods.lib.tech.add_prerequisite("nanobots-cliff", "logistic-science-pack")
--синие банки
bobmods.lib.tech.add_prerequisite("remelting-alloy-mixer-2", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite("bio-nutrient-paste-2", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite("bio-refugium-fish-3", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite("bio-refugium-hatchery-2", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite("worker-robots-speed-1", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite("Rubber-Processing", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite("worker-robots-battery-1", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite("bet-tech", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite("roboport-interface", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite("bio-farm-3", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite("toolbelt-2", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite("worker-robots-storage-1", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite("bob-steel-axe-4", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite("research-speed-3", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite("inserter-capacity-bonus-3", "chemical-science-pack")
-- bobmods.lib.tech.add_prerequisite("OilBurning-3", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite("advanced-aerodynamics", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite("mining-productivity-2", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite("CW-air-filter-cleaning-3", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite("CW-air-filtering-3", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite("inserter-stack-size-bonus-2", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite("bio-refugium-butchery-3", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite("physical-projectile-damage-5", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite("refined-flammables-3", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite("weapon-shooting-speed-5", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite("laser-shooting-speed-3", "chemical-science-pack")

--bobmods.lib.tech.add_prerequisite ("xxx", "chemical-science-pack")

--фиолетовые
bobmods.lib.tech.add_prerequisite("water-washing-3", "production-science-pack")

--bobmods.lib.tech.add_prerequisite ("xxx", "production-science-pack")

--убираем некоторые зависимости
bobmods.lib.tech.remove_prerequisite("angels-metallurgy-1", "bob-electricity")
bobmods.lib.tech.remove_prerequisite("angels-nickel-smelting-1", "angels-ore-crushing")
bobmods.lib.tech.remove_prerequisite("angels-lead-smelting-1", "angels-ore-crushing")
bobmods.lib.tech.remove_prerequisite("angels-lead-smelting-1", "angels-basic-chemistry")
--убираем рецепты из технологий
bobmods.lib.tech.remove_recipe_unlock("angels-stone-smelting-1", "angels-stone-pipe-casting")
bobmods.lib.tech.remove_recipe_unlock("angels-stone-smelting-1", "angels-stone-pipe-to-ground-casting")
--перенос электролиза дальше по дереву
bobmods.lib.tech.remove_recipe_unlock("angels-basic-chemistry", "angels-electrolyser")
bobmods.lib.tech.remove_recipe_unlock("angels-basic-chemistry", "angels-dirt-water-separation")
bobmods.lib.tech.remove_recipe_unlock("angels-basic-chemistry", "angels-catalyst-metal-carrier")
bobmods.lib.tech.remove_recipe_unlock("angels-basic-chemistry", "angels-catalyst-metal-red")

bobmods.lib.tech.add_recipe_unlock("angels-basic-chemistry-2", "angels-electrolyser")
bobmods.lib.tech.add_recipe_unlock("angels-basic-chemistry-2", "angels-dirt-water-separation")
bobmods.lib.tech.add_recipe_unlock("angels-basic-chemistry-2", "angels-catalyst-metal-carrier")
bobmods.lib.tech.add_recipe_unlock("angels-basic-chemistry-2", "angels-catalyst-metal-red")
--###############################################################################################
--целюлозное волокно в переработку древесины
bobmods.lib.tech.add_recipe_unlock("angels-bio-wood-processing", "angels-cellulose-fiber-raw-wood")
-------------------------------------------------------------------------------------------------
--ремкомплект в электричество
data.raw["recipe"]["repair-pack"].enabled = false
bobmods.lib.tech.add_recipe_unlock("bob-electricity", "repair-pack")
-------------------------------------------------------------------------------------------------
--конденсатор в электричество
data.raw["recipe"]["condensator"].enabled = false
bobmods.lib.tech.add_recipe_unlock("bob-electricity", "condensator")
-------------------------------------------------------------------------------------------------
--паровой манипулятор в автоматику
data.raw["recipe"]["bob-steam-inserter"].enabled = false
bobmods.lib.tech.add_recipe_unlock("basic-automation", "bob-steam-inserter")
-------------------------------------------------------------------------------------------------
--стекло из кварца в сортировку
bobmods.lib.tech.add_recipe_unlock("angels-ore-crushing", "bob-glass")
-------------------------------------------------------------------------------------------------
--стекло из дробленки сортировку
bobmods.lib.tech.add_recipe_unlock("angels-ore-crushing", "glass-from-ore4")

--убираем неправильные зависимости
bobmods.lib.tech.remove_prerequisite("angels-solid-cement", "concrete") --бетон
bobmods.lib.tech.remove_prerequisite("angels-stone-smelting-2", "concrete") --бетон
bobmods.lib.tech.remove_prerequisite("angels-plastic-1", "plastics") --пластик

-- добавляем зависимости в техологии для последовательности развития
bobmods.lib.tech.add_prerequisite("concrete", "angels-stone-smelting-2") --бетон
bobmods.lib.tech.add_prerequisite("bi-tech-wooden-storage-1", "bi-tech-resin-extraction") --деревянный ящик
bobmods.lib.tech.add_prerequisite("angels-steel-smelting-1", "angels-nitrogen-processing-1") --сталь
bobmods.lib.tech.add_prerequisite("angels-steel-smelting-1", "angels-flare-stack") --сталь
bobmods.lib.tech.add_prerequisite("angels-invar-smelting-1", "bob-zinc-processing") --сталь
bobmods.lib.tech.add_prerequisite("plastics", "angels-plastic-1") --пластик

--Фикс магния
bobmods.lib.tech.remove_prerequisite("advanced-magnesium-smelting", "angels-powder-metallurgy-1") --удаляем лишнюю
bobmods.lib.tech.add_prerequisite("advanced-magnesium-smelting", "angels-ore-processing-4") --добавить пресс гранулятор мк4
bobmods.lib.tech.add_prerequisite("advanced-magnesium-smelting", "angels-metallurgy-4") --добавить доменки мк4

--Фикс обеднённого урана и осмия by Kiska Ra
bobmods.lib.tech.remove_prerequisite("advanced-depleted-uranium-smelting-1", "angels-powder-metallurgy-1") --удаляем лишнюю
bobmods.lib.tech.remove_prerequisite("advanced-osmium-smelting", "angels-powder-metallurgy-1")

--Фикс техи турбины
bobmods.lib.tech.remove_recipe_unlock("nuclear-power", "steam-turbine") --удаляем вторую турбину мк1 (AKMF)
bobmods.lib.tech.add_prerequisite("bob-steam-turbine-1", "nuclear-power") --добавить теху в ядерку

bobmods.lib.tech.add_prerequisite("bob-radar-2", "radar") --Добавим радар1 к радару2

bobmods.lib.tech.remove_recipe_unlock("bob-tungsten-alloy-processing", "bob-tungsten-carbide-2x")
data.raw["recipe"]["bob-tungsten-carbide-2x"].hidden = true

data.raw["recipe"]["bob-copper-tungsten-pipe"].hidden = true
data.raw["recipe"]["bob-copper-tungsten-pipe-to-ground"].hidden = true
data.raw["recipe"]["bob-tungsten-pipe"].hidden = true
data.raw["recipe"]["bob-tungsten-pipe-to-ground"].hidden = true

bobmods.lib.tech.remove_recipe_unlock("angels-copper-tungsten-smelting-1", "angels-copper-tungsten-pipe-casting")
bobmods.lib.tech.remove_recipe_unlock(
	"angels-copper-tungsten-smelting-1",
	"angels-copper-tungsten-pipe-to-ground-casting"
)
bobmods.lib.tech.remove_recipe_unlock("bob-tungsten-alloy-processing", "angels-copper-tungsten-pipe-casting")
bobmods.lib.tech.remove_recipe_unlock("bob-tungsten-alloy-processing", "angels-copper-tungsten-pipe-to-ground-casting")
bobmods.lib.tech.remove_recipe_unlock("angels-tungsten-smelting-1", "angels-tungsten-pipe-casting")
bobmods.lib.tech.remove_recipe_unlock("angels-tungsten-smelting-1", "angels-tungsten-pipe-to-ground-casting")

--фикс кривых исследований углерода
bobmods.lib.tech.remove_recipe_unlock("angels-coal-processing-2", "coke-purification-3")
bobmods.lib.tech.remove_recipe_unlock("angels-coal-processing-3", "angels-coke-purification-2")
bobmods.lib.tech.add_recipe_unlock("angels-coal-processing-3", "coke-purification-3")

--фикс недоступности исследования артиллерии
bobmods.lib.tech.remove_prerequisite("artillery", "radar")

--удалены зеленые катализаторы из дублирующего исследования (теперь он в шлаке где и должен быть)
bobmods.lib.tech.remove_recipe_unlock("angels-geode-processing-2", "angels-catalysator-green")

--Перенос Каркаса 1 в Металлургию 1 (AKMF)
bobmods.lib.tech.remove_recipe_unlock("steel-processing", "basic-structure-components")
bobmods.lib.tech.add_recipe_unlock("angels-metallurgy-1", "basic-structure-components")

--Перенос Каркаса 2, примитивного Цинка и Никеля в Металлургию 2 (AKMF)
bobmods.lib.tech.remove_recipe_unlock("angels-zinc-smelting-1", "bob-zinc-electrolysis-x")
bobmods.lib.tech.remove_recipe_unlock("angels-nickel-smelting-1", "bob-nickel-electrolysis-x")
bobmods.lib.tech.remove_recipe_unlock("angels-invar-smelting-1", "bob-invar-alloy-x")
bobmods.lib.tech.add_recipe_unlock("angels-metallurgy-2", "bob-zinc-electrolysis-x")
bobmods.lib.tech.add_recipe_unlock("angels-metallurgy-2", "bob-nickel-electrolysis-x")
bobmods.lib.tech.add_recipe_unlock("angels-metallurgy-2", "bob-invar-alloy-x")
bobmods.lib.tech.remove_recipe_unlock("angels-invar-smelting-1", "intermediate-structure-components")
bobmods.lib.tech.add_recipe_unlock("angels-metallurgy-2", "intermediate-structure-components")

--Перенос Каркаса 3, примитивного Титана и Кобальта в Металлургию 3 (AKMF https://discord.com/channels/569536773701500928/1196117081691795496)
bobmods.lib.tech.remove_recipe_unlock("angels-cobalt-smelting-1", "cobalat-electrolysis-x")
bobmods.lib.tech.remove_recipe_unlock("angels-cobalt-steel-smelting-1", "bob-cobalt-steel-alloy-x")
bobmods.lib.tech.remove_recipe_unlock("angels-titanium-smelting-1", "bob-titanium-electrolysis-x")
bobmods.lib.tech.add_recipe_unlock("angels-metallurgy-3", "cobalat-electrolysis-x")
bobmods.lib.tech.add_recipe_unlock("angels-metallurgy-3", "bob-cobalt-steel-alloy-x")
bobmods.lib.tech.add_recipe_unlock("angels-metallurgy-3", "bob-titanium-electrolysis-x")
bobmods.lib.tech.remove_recipe_unlock("bob-titanium-processing", "advanced-structure-components")
bobmods.lib.tech.add_recipe_unlock("angels-metallurgy-3", "advanced-structure-components")

--фикс технологий: Продвинутое исследование после турбо пакетников (AKMF)
bobmods.lib.tech.remove_prerequisite("bob-advanced-research", "bob-express-inserter")
bobmods.lib.tech.add_prerequisite("bob-advanced-research", "bob-bulk-inserter-3")

-- --Добавлен дополнительный уровень технологий для Жидк.Бойлеров 4, 5 в соответсвии с их рецептом (AKMF)
if data.raw.technology["OilBurning-4"] then
	data.raw.technology["OilBurning-4"].unit.ingredients = {
		{"automation-science-pack", 2 },
		{"logistic-science-pack", 2 },
		{"chemical-science-pack", 2 },
		{"production-science-pack", 2 },
	}
end
if data.raw.technology["OilBurning-5"] then
	data.raw.technology["OilBurning-5"].unit.ingredients = {
		{"automation-science-pack", 2 },
		{"logistic-science-pack", 2 },
		{"chemical-science-pack", 2 },
		{"production-science-pack", 2 },
		{"utility-science-pack", 2 },
	}
end
--Ремонт дерева исследований
bobmods.lib.tech.add_prerequisite("nuclear-power", "bob-boiler-4") --Ставим ядерку под Бойлер МК4
bobmods.lib.tech.add_prerequisite("water-pumpjack-1", "bob-electricity") --помпа
bobmods.lib.tech.add_prerequisite("gun-turret", "bob-electricity") --турель
bobmods.lib.tech.add_prerequisite("logistics", "bob-electricity") --логистика1
bobmods.lib.tech.add_prerequisite("angels-basic-chemistry-2", "angels-metallurgy-1") --базовая химия 2
bobmods.lib.tech.add_prerequisite("angels-bio-processing-green", "angels-metallurgy-1") --водоросли 2
bobmods.lib.tech.add_prerequisite("angels-bio-processing-green", "electronics") --водоросли 2
-- bobmods.lib.tech.remove_prerequisite("bi-tech-resin-extraction", "bi-tech-timber") --убираем смолу
bobmods.lib.tech.remove_prerequisite("bi-tech-wooden-storage-1", "bi-tech-resin-extraction") --убираем смолу
if data.raw.technology["bi-tech-resin-extraction"] then
	data.raw.technology["bi-tech-resin-extraction"].hidden = true --убираем смолу
end
if data.raw.technology["bi-tech-timber"] then
	data.raw.technology["bi-tech-timber"].unit.count = 30 --совмещаем смолу и теплицы
end
bobmods.lib.tech.add_prerequisite("bi-tech-wooden-storage-1", "bi-tech-timber") --ящики под теплицу
bobmods.lib.tech.add_prerequisite("angels-steel-smelting-2", "angels-strand-casting-1") --сталь 2 под МНЛЗ
bobmods.lib.tech.add_prerequisite("CW-air-filtering-1", "automation-2") --фильтры под автомат 2
bobmods.lib.tech.add_prerequisite("angels-water-treatment-2", "angels-metallurgy-2") --гидростанцию 2 под металлургию 2
bobmods.lib.tech.add_prerequisite("angels-advanced-chemistry-1", "angels-metallurgy-2") --химию 2 под металлургию 2
bobmods.lib.tech.add_prerequisite("angels-gas-processing", "angels-metallurgy-2") --газ под металлургию 2
bobmods.lib.tech.add_prerequisite("railloader", "miniloader") --автопогрузчик под минипогрузчик
bobmods.lib.tech.add_prerequisite("CW-air-filtering-2", "advanced-circuit") --фильтры 2 под контроллеры
bobmods.lib.tech.remove_prerequisite("angels-zinc-smelting-1", "angels-metallurgy-2") --металлургия 2 под латунь
bobmods.lib.tech.remove_prerequisite("bob-zinc-processing", "angels-sulfur-processing-1") --металлургия 2 под латунь
bobmods.lib.tech.remove_prerequisite("bob-zinc-processing", "angels-zinc-smelting-1") --металлургия 2 под латунь
bobmods.lib.tech.remove_prerequisite("angels-brass-smelting-1", "angels-zinc-smelting-1") --металлургия 2 под латунь
-- bobmods.lib.tech.add_prerequisite("angels-metallurgy-2", "bob-zinc-processing") ----металлургия 2 под латунь
bobmods.lib.tech.add_prerequisite("angels-zinc-smelting-1", "angels-metallurgy-2") --цинк под металлургию 2
bobmods.lib.tech.add_prerequisite("angels-water-washing-2", "angels-metallurgy-2") --промывка 2  под металлургию 2
bobmods.lib.tech.add_prerequisite("angels-ore-powderizer", "angels-stone-smelting-1") --измельчитель под кирпич
bobmods.lib.tech.add_prerequisite("bi-tech-garden-2", "chemical-science-pack") --биосад под химпакеты
bobmods.lib.tech.remove_prerequisite("advanced-circuit", "offshore-mk2-pump") --убираем насосы из электроники
bobmods.lib.tech.add_prerequisite("offshore-mk2-pump", "advanced-circuit") --ставим их вниз
bobmods.lib.tech.add_prerequisite("angels-bio-refugium-fish-2", "advanced-circuit") --аквариум 2 под электронику 2
bobmods.lib.tech.add_prerequisite("bob-drills-2", "angels-cobalt-steel-smelting-1") --буры3 под кобальт
bobmods.lib.tech.add_prerequisite("bob-area-drills-2", "angels-cobalt-steel-smelting-1") --буры3 под кобальт
bobmods.lib.tech.add_prerequisite("warehouse-logistics-research-1", "construction-robotics") --склады под роботов
bobmods.lib.tech.add_prerequisite("warehouse-logistics-research-1", "logistic-robotics") --склады под роботов
bobmods.lib.tech.add_prerequisite("Ducts", "bob-ceramics") --большие трубы под нитрид кремния
bobmods.lib.tech.add_prerequisite("bio-refugium-fish-3", "processing-unit") --аквариум 3 под титан
bobmods.lib.tech.add_prerequisite("bio-refugium-fish-3", "angels-titanium-smelting-1") --аквариум 3 под титан
bobmods.lib.tech.add_prerequisite("bio-refugium-butchery-3", "angels-titanium-smelting-1") --бойня 3 под титан
bobmods.lib.tech.add_prerequisite("bio-refugium-butchery-3", "processing-unit") --бойня 3 под титан
bobmods.lib.tech.add_prerequisite("remelting-alloy-mixer-3", "production-science-pack") --смешиватель мк3 под производственн пакеты
bobmods.lib.tech.add_prerequisite("offshore-mk3-pump", "angels-titanium-smelting-1") --насос 3 под титан
bobmods.lib.tech.add_prerequisite("logistics-3", "angels-titanium-smelting-1") --логистика 3 под титан
bobmods.lib.tech.add_prerequisite("CW-air-filtering-4", "processing-unit") --фильтры 3 под электронику 3
bobmods.lib.tech.add_prerequisite("CW-air-filtering-4", "angels-titanium-smelting-1") --фильтры 3 под титан
bobmods.lib.tech.add_prerequisite("CW-air-filtering-4", "production-science-pack") --фильтры 3 под производственн пакеты
bobmods.lib.tech.add_prerequisite("gunships", "angels-cobalt-steel-smelting-1") --самолёты под кобальт
bobmods.lib.tech.add_prerequisite("bi-tech-cellulose-2", "production-science-pack") --целлюлоза 2 под производственн пакеты
bobmods.lib.tech.add_prerequisite("CW-air-filter-cleaning-4", "production-science-pack") --фильтры 4 под производственн пакеты
bobmods.lib.tech.add_prerequisite("afterburner", "utility-science-pack") --форсаж под утилити пакеты
bobmods.lib.tech.add_prerequisite("angels-advanced-bio-processing", "production-science-pack") --водоросли 5 под производственн пакеты
bobmods.lib.tech.add_prerequisite("angels-advanced-bio-processing", "utility-science-pack") --водоросли 5 под утилити пакеты
-- bobmods.lib.tech.add_prerequisite("OilBurning-4", "production-science-pack") --жидк котёл 4 под производственн пакеты
-- bobmods.lib.tech.add_prerequisite("OilBurning-4", "angels-titanium-smelting-1") --жидк котёл 4 под титан
bobmods.lib.tech.add_prerequisite("angels-stone-smelting-4", "angels-titanium-smelting-1") --титановый кирпич под титан
bobmods.lib.tech.add_prerequisite("bob-steel-axe-5", "production-science-pack") --кирка 5 под производственн пакеты
bobmods.lib.tech.add_prerequisite("bob-steel-axe-6", "utility-science-pack") --кирка 6 под утилити пакеты
bobmods.lib.tech.add_prerequisite("bi-tech-biomass-reprocessing-2", "production-science-pack") --биомасса под производственн пакеты
bobmods.lib.tech.add_prerequisite("logistics-3", "angels-ironworks-3") --логистика 3 под титан
bobmods.lib.tech.add_prerequisite("angels-advanced-chemistry-5", "bob-advanced-processing-unit") --продв химия 5 под контроллеры
bobmods.lib.tech.add_prerequisite("water-treatment-5", "bob-advanced-processing-unit") --очистка воды 5 под контроллеры 3
bobmods.lib.tech.add_prerequisite("offshore-mk4-pump", "bob-advanced-processing-unit") --насос 4  под контроллеры 3
bobmods.lib.tech.add_prerequisite("CW-air-filtering-4", "bob-advanced-processing-unit") --фильтры 4  под контроллеры 3
bobmods.lib.tech.add_prerequisite("Schall-pickup-tower-4", "bob-advanced-processing-unit") --башня сбора 4  под контроллеры 3
bobmods.lib.tech.add_prerequisite("bob-electric-energy-accumulators-3", "bob-advanced-processing-unit") --аккумуляторы 3  под контроллеры 3
bobmods.lib.tech.add_prerequisite("Schall-pickup-tower-4", "utility-science-pack") --башня сбора 4  под утилити пакеты
bobmods.lib.tech.add_prerequisite("railway", "concrete") --рельсы под БЕТОН наконец-то
bobmods.lib.tech.add_prerequisite("worker-robot-battery-1", "chemical-science-pack") --батареи роботов под синие банки
bobmods.lib.tech.add_prerequisite("worker-robot-battery-4", "production-science-pack") --батареи роботов под производственн пакеты
bobmods.lib.tech.add_prerequisite("worker-robot-battery-8", "utility-science-pack") --батареи роботов под утилити пакеты
bobmods.lib.tech.add_prerequisite("bi-tech-organic-plastic", "production-science-pack") --биопластик под производственн пакеты
bobmods.lib.tech.add_prerequisite("advanced-circuit", "angels-aluminium-smelting-1") --контроллер 2 под алюминий
bobmods.lib.tech.add_prerequisite("weapon-shooting-speed-2", "logistic-science-pack") --скорострельность 2 под зеленые банки
bobmods.lib.tech.add_prerequisite("weapon-shooting-speed-3", "military-science-pack") --скорострельность 3 под военные банки
bobmods.lib.tech.add_prerequisite("stronger-explosives-2", "military-science-pack") --урон гранат 2  под военные банки
bobmods.lib.tech.add_prerequisite("weapon-shooting-speed-6", "utility-science-pack") --скорострельность 6 под утилити банки
bobmods.lib.tech.add_prerequisite("follower-robot-count-3", "chemical-science-pack") --боевых роботов под синие банки
bobmods.lib.tech.add_prerequisite("stronger-explosives-3", "chemical-science-pack") --урон гранат 3  под военные банки
bobmods.lib.tech.remove_prerequisite("bi-tech-garden-3", "angels-stone-smelting-4") --убираем огромные сады из под цемента 4
if data.raw.technology["angels-stone-smelting-4"] then
	data.raw.technology["angels-stone-smelting-4"].unit.count = 200 --меняем цену на цемент 4
	data.raw.technology["angels-stone-smelting-4"].unit.ingredients = {
		{"automation-science-pack", 1 },
		{"logistic-science-pack", 1 },
		{"chemical-science-pack", 1 },
	} --меняем цену на цемент 4
end
-- bobmods.lib.tech.add_prerequisite("production-science-pack", "angels-stone-smelting-4") -- производственн пакеты под цемент 4
bobmods.lib.tech.add_prerequisite("bi-tech-garden-3", "production-science-pack") --огромные сады под производственн пакеты
--08.07.24
bobmods.lib.tech.add_prerequisite("angels-metallurgy-4", "processing-unit") -- Промышленная металлургия 4 под Продвинутую электронику 2
bobmods.lib.tech.add_prerequisite("angels-strand-casting-1", "angels-stone-smelting-1") -- Машины непрерывного литья 1 под кирпичи 1
bobmods.lib.tech.add_prerequisite("angels-brass-smelting-1", "angels-ore-floatation") -- Латунь под Гидропромывку 1
--21.07.24
bobmods.lib.tech.add_prerequisite("angels-metallurgy-3", "angels-ore-leaching") -- Промышленную металлургию 3 под Химическую обработку руды(кристаллы)
bobmods.lib.tech.add_prerequisite("modules", "angels-gold-smelting-1") -- Модули под Золото!
if data.raw.technology["modules"] then
	data.raw.technology["modules"].unit.ingredients = {
		{ "automation-science-pack", 1 },
		{ "logistic-science-pack", 1 },
		{ "chemical-science-pack", 1 },
	} --модули теперь за синие банки (как и должно быть)
end
-- bobmods.lib.tech.add_prerequisite("OilBurning-2", "bob-boiler-2") -- Сжигание жидкого и газообразного топлива 2 под Бойлер 2
-- bobmods.lib.tech.add_prerequisite("OilBurning-3", "bob-boiler-3") -- Сжигание жидкого и газообразного топлива 3 под Бойлер 3
-- bobmods.lib.tech.add_prerequisite("OilBurning-4", "bob-boiler-4") -- Сжигание жидкого и газообразного топлива 4 под Бойлер 4
-- bobmods.lib.tech.add_prerequisite("OilBurning-5", "bob-boiler-5") -- Сжигание жидкого и газообразного топлива 5 под Бойлер 5
if data.raw.technology["bob-drills-2"] then
	data.raw.technology["bob-drills-2"].unit.ingredients = {
		{ "automation-science-pack", 1 },
		{ "logistic-science-pack", 1 },
		{ "chemical-science-pack", 1 },
	} --синие банки для буров мк3
end
if data.raw.technology["bob-area-drills-2"] then
	data.raw.technology["bob-area-drills-2"].unit.ingredients = {
		{ "automation-science-pack", 1 },
		{ "logistic-science-pack", 1 },
		{ "chemical-science-pack", 1 },
	} --синие банки для буров мк3
end
bobmods.lib.tech.add_prerequisite("energy-weapons-damage-4", "chemical-science-pack") -- Урон энергетического оружия под правильные банки
bobmods.lib.tech.add_prerequisite("energy-weapons-damage-5", "utility-science-pack") -- Урон энергетического оружия под правильные банки
bobmods.lib.tech.add_prerequisite("ober-nuclear-processing", "utility-science-pack") -- Высокотемпературная переработка сырья под правильные банки
bobmods.lib.tech.add_prerequisite("refined-flammables-4", "utility-science-pack") -- Высокотемпературная переработка сырья под правильные банки
bobmods.lib.tech.add_prerequisite("advanced-uranium-processing-1", "utility-science-pack") -- Продвинутая переработка урана 1 под правильные банки
data.raw.technology["warehouse-logistics-research-2"].unit.ingredients = {
	{"automation-science-pack", 1 },
	{"logistic-science-pack", 1 },
	{"chemical-science-pack", 1 },
	{"bob-advanced-logistic-science-pack", 1 },
} --Складская логистика 2 делаем правильные банки

bobmods.lib.tech.remove_recipe_unlock("lamp", "deadlock-large-lamp") --лампы
bobmods.lib.tech.remove_recipe_unlock("lamp", "deadlock-floor-lamp") --лампы
bobmods.lib.tech.add_recipe_unlock("electronics", "deadlock-large-lamp") --лампы
bobmods.lib.tech.add_recipe_unlock("electronics", "deadlock-floor-lamp") --лампы
bobmods.lib.tech.remove_recipe_unlock("angels-water-treatment", "angels-liquifier") --убираем второй разжижитель
bobmods.lib.tech.add_recipe_unlock("bi-tech-timber", "bi-resin-pulp") --смола в теплицу
bobmods.lib.tech.add_recipe_unlock("bi-tech-timber", "bi-wood-from-pulp") --смола в теплицу
bobmods.lib.tech.remove_recipe_unlock("angels-iron-smelting-1", "angels-iron-gear-wheel-stack-casting") --убираем заготовки из 1 расплавки
bobmods.lib.tech.remove_recipe_unlock("angels-iron-smelting-1", "angels-iron-gear-wheel-stack-converting") --убираем заготовки из 1 расплавки
bobmods.lib.tech.remove_recipe_unlock("angels-iron-smelting-2", "angels-iron-gear-wheel-stack-casting-fast") --убираем заготовки из 2 расплавки
bobmods.lib.tech.add_recipe_unlock("angels-iron-casting-2", "angels-iron-gear-wheel-stack-casting") --заготовки во 1 литье железа
bobmods.lib.tech.add_recipe_unlock("angels-iron-casting-2", "angels-iron-gear-wheel-stack-converting") --заготовки во 1 литье железа
bobmods.lib.tech.add_recipe_unlock("angels-iron-casting-3", "angels-iron-gear-wheel-stack-casting-fast") --заготовки шестеренок в 2  литье железа
bobmods.lib.tech.remove_recipe_unlock("angels-steel-smelting-1", "angels-steel-gear-wheel-stack-casting") --убираем заготовки шестеренок из 1 стали
bobmods.lib.tech.remove_recipe_unlock("angels-steel-smelting-1", "angels-steel-gear-wheel-stack-converting") --убираем заготовки шестеренок из 1 стали
bobmods.lib.tech.remove_recipe_unlock("angels-steel-smelting-2", "angels-steel-gear-wheel-stack-casting-fast") --убираем заготовки шестеренок из 2 стали
bobmods.lib.tech.add_recipe_unlock("angels-steel-smelting-2", "angels-steel-gear-wheel-stack-casting") --рецепты заготовок во 2 сталь
bobmods.lib.tech.add_recipe_unlock("angels-steel-smelting-2", "angels-steel-gear-wheel-stack-converting") --рецепты заготовок во 2 сталь
bobmods.lib.tech.add_recipe_unlock("angels-steel-smelting-3", "angels-steel-gear-wheel-stack-casting-fast") --рецепты заготовок во 3 сталь
bobmods.lib.tech.remove_recipe_unlock("angels-ore-floatation", "bob-silver-plate") --удаление простого рецепта серебра
bobmods.lib.tech.remove_recipe_unlock("angels-advanced-chemistry-4", "advanced-chemical-plant-3") --удаляем хим завод 3 из химии 4
bobmods.lib.tech.add_recipe_unlock("angels-advanced-chemistry-5", "advanced-chemical-plant-3") --добавляем хим завод 3 в химию 5

--унификация рецептов манипуляторов и ковееров (AKMF)
bobmods.lib.recipe.replace_ingredient("fast-inserter", "bob-cobalt-steel-bearing", "bob-titanium-bearing")
bobmods.lib.recipe.replace_ingredient("stack-inserter", "bob-cobalt-steel-bearing", "bob-titanium-bearing")
bobmods.lib.recipe.replace_ingredient("fast-inserter", "bob-cobalt-steel-bearing", "bob-titanium-bearing")
bobmods.lib.recipe.replace_ingredient("stack-filter-inserter", "bob-cobalt-steel-bearing", "bob-titanium-bearing")
bobmods.lib.recipe.replace_ingredient("fast-inserter", "bob-cobalt-steel-gear-wheel", "bob-titanium-gear-wheel")
bobmods.lib.recipe.replace_ingredient("stack-inserter", "bob-cobalt-steel-gear-wheel", "bob-titanium-gear-wheel")
bobmods.lib.recipe.replace_ingredient("fast-inserter", "bob-cobalt-steel-gear-wheel", "bob-titanium-gear-wheel")
bobmods.lib.recipe.replace_ingredient("stack-filter-inserter", "bob-cobalt-steel-gear-wheel", "bob-titanium-gear-wheel")
bobmods.lib.recipe.replace_ingredient("bob-turbo-inserter", "bob-titanium-bearing", "bob-cobalt-steel-bearing")
bobmods.lib.recipe.replace_ingredient("bob-turbo-bulk-inserter", "bob-titanium-bearing", "bob-cobalt-steel-bearing")
bobmods.lib.recipe.replace_ingredient("bob-turbo-inserter", "bob-titanium-bearing", "bob-cobalt-steel-bearing")
bobmods.lib.recipe.replace_ingredient("bob-turbo-bulk-inserter", "bob-titanium-bearing", "bob-cobalt-steel-bearing")
bobmods.lib.recipe.replace_ingredient("bob-turbo-inserter", "bob-titanium-gear-wheel", "bob-cobalt-steel-gear-wheel")
bobmods.lib.recipe.replace_ingredient(
	"bob-turbo-bulk-inserter",
	"bob-titanium-gear-wheel",
	"bob-cobalt-steel-gear-wheel"
)
bobmods.lib.recipe.replace_ingredient("bob-turbo-inserter", "bob-titanium-gear-wheel", "bob-cobalt-steel-gear-wheel")
bobmods.lib.recipe.replace_ingredient(
	"bob-turbo-bulk-inserter",
	"bob-titanium-gear-wheel",
	"bob-cobalt-steel-gear-wheel"
)
bobmods.lib.recipe.replace_ingredient("bob-turbo-transport-belt", "bob-nitinol-bearing", "bob-cobalt-steel-bearing")
bobmods.lib.recipe.replace_ingredient(
	"bob-turbo-transport-belt",
	"bob-nitinol-gear-wheel",
	"bob-cobalt-steel-gear-wheel"
)
bobmods.lib.recipe.replace_ingredient("bob-turbo-underground-belt", "bob-nitinol-bearing", "bob-cobalt-steel-bearing")
bobmods.lib.recipe.replace_ingredient(
	"bob-turbo-underground-belt",
	"bob-nitinol-gear-wheel",
	"bob-cobalt-steel-gear-wheel"
)
bobmods.lib.recipe.replace_ingredient("bob-turbo-splitter", "bob-nitinol-bearing", "bob-cobalt-steel-bearing")
bobmods.lib.recipe.replace_ingredient("bob-turbo-splitter", "bob-nitinol-gear-wheel", "bob-cobalt-steel-gear-wheel")
bobmods.lib.recipe.replace_ingredient("nco-wide-crane", "bob-cobalt-steel-gear-wheel", "bob-titanium-gear-wheel")
bobmods.lib.recipe.replace_ingredient("nco-wide-crane", "bob-cobalt-steel-bearing", "bob-titanium-bearing")
bobmods.lib.recipe.replace_ingredient("nco-wide-filter-crane", "bob-cobalt-steel-gear-wheel", "bob-titanium-gear-wheel")
bobmods.lib.recipe.replace_ingredient("nco-wide-filter-crane", "bob-cobalt-steel-bearing", "bob-titanium-bearing")
bobmods.lib.recipe.replace_ingredient("nco-crane", "bob-cobalt-steel-gear-wheel", "bob-titanium-gear-wheel")
bobmods.lib.recipe.replace_ingredient("nco-crane", "bob-cobalt-steel-bearing", "bob-titanium-bearing")
bobmods.lib.recipe.replace_ingredient("nco-filter-crane", "bob-cobalt-steel-gear-wheel", "bob-titanium-gear-wheel")
bobmods.lib.recipe.replace_ingredient("nco-filter-crane", "bob-cobalt-steel-bearing", "bob-titanium-bearing")
bobmods.lib.recipe.replace_ingredient("nco-wide-turbo-crane", "bob-titanium-gear-wheel", "bob-cobalt-steel-gear-wheel")
bobmods.lib.recipe.replace_ingredient("nco-wide-turbo-crane", "bob-titanium-bearing", "bob-cobalt-steel-bearing")
bobmods.lib.recipe.replace_ingredient(
	"nco-wide-turbo-filter-crane",
	"bob-titanium-gear-wheel",
	"bob-cobalt-steel-gear-wheel"
)
bobmods.lib.recipe.replace_ingredient("nco-wide-turbo-filter-crane", "bob-titanium-bearing", "bob-cobalt-steel-bearing")
bobmods.lib.recipe.replace_ingredient("nco-turbo-crane", "bob-titanium-gear-wheel", "bob-cobalt-steel-gear-wheel")
bobmods.lib.recipe.replace_ingredient("nco-turbo-crane", "bob-titanium-bearing", "bob-cobalt-steel-bearing")
bobmods.lib.recipe.replace_ingredient(
	"nco-turbo-filter-crane",
	"bob-titanium-gear-wheel",
	"bob-cobalt-steel-gear-wheel"
)
bobmods.lib.recipe.replace_ingredient("nco-turbo-filter-crane", "bob-titanium-bearing", "bob-cobalt-steel-bearing")

--ремонт рецепта материнской бактерии (AKMF)
if data.raw["recipe"]["bacterial-growth-seed-cultivation-2"] then
	data.raw["recipe"]["bacterial-growth-seed-cultivation-2"].category = "angels-advanced-chemistry"
end
--ремонт рецепта высокооктанового обогащенного топлива (AKMF)
if data.raw["recipe"]["high-octane-enriched-fuel"] then
	data.raw["recipe"]["high-octane-enriched-fuel"].category = "angels-advanced-chemistry"
end

--добавление цепочки рецептов для утилизации Хлорида кальция(AKMF)
data:extend({
	{
		type = "recipe",
		name = "Calcium-chloride-Calcium-carbonate",
		category = "chemistry",
		subgroup = "angels-petrochem-sulfur",
		energy_required = 4,
		enabled = false,
		ingredients = {
			{ type = "item", name = "angels-solid-calcium-chloride", amount = 1 },
			{ type = "item", name = "angels-solid-sodium-carbonate", amount = 1 },
		},
		localised_name = "Реакция обмена: Хлорид кальция в Карбонат кальция",
		results = {
			{ type = "item", name = "angels-solid-calcium-carbonate", amount = 1 },
			{ type = "item", name = "angels-solid-salt", amount = 2 },
		},
		icon = "__angelsbioprocessinggraphics__/graphics/icons/solid-calcium-carbonate.png",
		icon_size = 32,
		order = "h",
	},
	{
		type = "recipe",
		name = "Calcium-carbonate-Calcium-sulfate",
		category = "chemistry",
		subgroup = "angels-petrochem-sulfur",
		energy_required = 4,
		enabled = false,
		ingredients = {
			{ type = "item", name = "angels-solid-calcium-carbonate", amount = 1 },
			{ type = "fluid", name = "angels-liquid-sulfuric-acid", amount = 50 },
		},
		localised_name = "Нейтрализация Карбоната кальция до Сульфата кальция",
		results = {
			{ type = "item", name = "angels-solid-calcium-sulfate", amount = 1 },
			{ type = "fluid", name = "water", amount = 50 },
			{ type = "fluid", name = "angels-gas-carbon-dioxide", amount = 50 },
		},
		icon = "__angelspetrochemgraphics__/graphics/icons/solid-calcium-sulfate.png",
		icon_size = 32,
		order = "h",
	},
})
bobmods.lib.tech.add_recipe_unlock("angels-sodium-processing-2", "Calcium-chloride-Calcium-carbonate")
bobmods.lib.tech.add_recipe_unlock("angels-bio-processing-red", "Calcium-carbonate-Calcium-sulfate")

--Рокировка рецептов нитинольных труб (AKMF)
bobmods.lib.tech.add_recipe_unlock("angels-nitinol-smelting-1", "bob-nitinol-pipe")
bobmods.lib.tech.remove_recipe_unlock("bob-nitinol-processing", "bob-nitinol-pipe")
bobmods.lib.tech.remove_recipe_unlock("angels-nitinol-smelting-1", "angels-nitinol-pipe-casting")
bobmods.lib.tech.add_recipe_unlock("bob-nitinol-processing", "angels-nitinol-pipe-casting")
bobmods.lib.tech.add_recipe_unlock("angels-nitinol-smelting-1", "bob-nitinol-pipe-to-ground")
bobmods.lib.tech.remove_recipe_unlock("bob-nitinol-processing", "bob-nitinol-pipe-to-ground")
bobmods.lib.tech.remove_recipe_unlock("angels-nitinol-smelting-1", "angels-nitinol-pipe-to-ground-casting")
bobmods.lib.tech.add_recipe_unlock("bob-nitinol-processing", "angels-nitinol-pipe-to-ground-casting")

--Для сборщика электроники нужны фиол. манипуляторы (AKMF)
bobmods.lib.tech.add_prerequisite("bob-electronics-machine-3", "bob-turbo-inserter")

--Финальный Ремонт дерева исследований
bobmods.lib.tech.remove_prerequisite("radar", "electronics") --фикс радара
-- bobmods.lib.tech.add_prerequisite ("radar", "bob-electricity") --фикс радара
bobmods.lib.recipe.set_ingredients("radar", {
	{ type = "item", name = "electric-motor", amount = 12 },
	{ type = "item", name = "bob-basic-circuit-board", amount = 20 },
	{ type = "item", name = "stone-brick", amount = 20 },
	{ type = "item", name = "iron-plate", amount = 20 },
}) --фикс радара
bobmods.lib.tech.add_prerequisite("bob-nuclear-power-2", "centrifuging-1") --ториевая энергетика под Продвинутое центрифугирование 1
bobmods.lib.tech.add_prerequisite("bob-area-drills-2", "bob-drills-2") --фикс буров
bobmods.lib.tech.add_prerequisite("bob-area-drills-3", "bob-drills-3") --фикс буров
bobmods.lib.tech.add_prerequisite("rocket-silo", "bob-area-drills-3") --фикс буров
bobmods.lib.tech.add_prerequisite("bob-battery-3", "angels-powder-metallurgy-5") --Аккумулятор 3 поставить под Порошковая металлургия 4
bobmods.lib.tech.remove_recipe_unlock("bob-advanced-processing-unit", "intelligent-io") -- Интеллектуальное арифметико-логическое устройство под Квантовые модули 1
bobmods.lib.tech.add_recipe_unlock("bob-god-module", "intelligent-io") -- Интеллектуальное арифметико-логическое устройство под Квантовые модули 1
bobmods.lib.tech.remove_recipe_unlock("bi-tech-resin-extraction", "bi-resin-pulp") --прячем лишнюю смолу
bobmods.lib.tech.remove_recipe_unlock("bi-tech-resin-extraction", "bi-wood-from-pulp") --прячем лишнюю смолу
if data.raw.technology["bi-tech-resin-extraction"] then
	data.raw.technology["bi-tech-resin-extraction"].hidden = true --прячем лишнюю смолу
end
bobmods.lib.tech.add_prerequisite("hiend_train", "bob-fluid-wagon-3") -- привязать магнитный локомотив и вагоны к вагонам и цистернам мк3
bobmods.lib.tech.add_prerequisite("angels-water-chemistry-2", "bob-thorium-fuel-reprocessing") -- привязатьо дейтериевую энергетику к Переработки тория (нет ядерного катализатора)
bobmods.lib.tech.add_prerequisite("extremely-advanced-rocket-payloads", "space-lab") -- Привязать КОсмический челнок к Космическая лаборатория (Данные с космической станции недоступны)
bobmods.lib.recipe.add_ingredient("offshore-pump", { type = "item", name = "offshore-mk0-pump", amount = 2 }) -- к Электрический береговой насос добавляем Твердотопливный береговой насос 2 штуки

--###############################################################################################
--Финальный Ремонт дерева исследований от ЮШРАКА прости Господи
bobmods.lib.tech.add_prerequisite("physical-projectile-damage-2", "logistic-science-pack")
bobmods.lib.tech.add_prerequisite("physical-projectile-damage-3", "military-science-pack")
bobmods.lib.tech.add_prerequisite("physical-projectile-damage-6", "utility-science-pack")
bobmods.lib.tech.add_prerequisite("stronger-explosives-4", "utility-science-pack")
bobmods.lib.tech.add_prerequisite("refined-flammables-4", "utility-science-pack")
bobmods.lib.tech.add_prerequisite("energy-weapons-damage-4", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite("energy-weapons-damage-5", "utility-science-pack")
bobmods.lib.tech.add_prerequisite("laser-shooting-speed-5", "utility-science-pack")
bobmods.lib.tech.add_prerequisite("follower-robot-count-5", "utility-science-pack")
bobmods.lib.tech.add_prerequisite("inserter-capacity-bonus-5", "bob-advanced-logistic-science-pack")
bobmods.lib.tech.add_prerequisite("inserter-capacity-bonus-7", "utility-science-pack")
bobmods.lib.tech.add_prerequisite("logistic-science-pack", "logistics")
bobmods.lib.tech.add_prerequisite("steel-processing", "electric-mining")
bobmods.lib.tech.add_prerequisite("logistics", "electronics")
bobmods.lib.tech.add_prerequisite("chemical-science-pack", "engine")
bobmods.lib.tech.add_prerequisite("military-science-pack", "gun-turret")
bobmods.lib.tech.add_prerequisite("production-science-pack", "electric-engine")
bobmods.lib.tech.add_prerequisite("utility-science-pack", "nuclear-power")
bobmods.lib.tech.add_prerequisite("utility-science-pack", "logistics-3")
bobmods.lib.tech.add_prerequisite("advanced-circuit", "angels-sulfur-processing-2")
bobmods.lib.tech.add_prerequisite("braking-force-3", "bob-advanced-logistic-science-pack")
bobmods.lib.tech.add_prerequisite("braking-force-6", "utility-science-pack")
bobmods.lib.tech.add_prerequisite("logistics-3", "bob-titanium-processing")
bobmods.lib.tech.add_prerequisite("research-speed-5", "production-science-pack")
bobmods.lib.tech.add_prerequisite("research-speed-6", "utility-science-pack")
bobmods.lib.tech.add_prerequisite("electric-energy-distribution-2", "concrete")
bobmods.lib.tech.add_prerequisite("effect-transmission", "concrete")
bobmods.lib.tech.add_prerequisite("electric-engine", "engine")
bobmods.lib.tech.add_prerequisite("worker-robots-speed-3", "bob-advanced-logistic-science-pack")
bobmods.lib.tech.add_prerequisite("worker-robots-speed-5", "utility-science-pack")
bobmods.lib.tech.add_prerequisite("worker-robots-storage-2", "bob-advanced-logistic-science-pack")
bobmods.lib.tech.add_prerequisite("worker-robots-storage-3", "utility-science-pack")
bobmods.lib.tech.add_prerequisite("energy-shield-equipment", "electric-engine")
bobmods.lib.tech.add_prerequisite("battery-equipment", "electric-engine")
bobmods.lib.tech.add_prerequisite("fusion-reactor-equipment", "bob-solar-panel-equipment-4")
bobmods.lib.tech.add_prerequisite("personal-roboport-equipment", "processing-unit")
bobmods.lib.tech.add_prerequisite("mining-productivity-3", "production-science-pack")
bobmods.lib.tech.add_prerequisite("mining-productivity-3", "utility-science-pack")
bobmods.lib.tech.add_prerequisite("autonomous-space-mining-drones", "bob-drills-4")
bobmods.lib.tech.add_prerequisite("robot-attrition-explosion-safety", "utility-science-pack")
bobmods.lib.tech.add_prerequisite("bob-nitinol-processing", "utility-science-pack")
bobmods.lib.tech.add_prerequisite("bob-electronics-machine-2", "fast-inserter")
bobmods.lib.tech.add_prerequisite("bob-power-armor-3", "space-science-pack")
bobmods.lib.tech.add_prerequisite("miniloader", "angels-steel-smelting-1")
bobmods.lib.tech.add_prerequisite("fast-miniloader", "fast-inserter")
bobmods.lib.tech.add_prerequisite("express-miniloader", "bob-express-inserter")
bobmods.lib.tech.add_prerequisite("turbo-miniloader", "bob-turbo-inserter")
bobmods.lib.tech.add_prerequisite("ultimate-miniloader", "bob-ultimate-inserter")
bobmods.lib.tech.add_prerequisite("angels-advanced-ore-refining-3", "bob-titanium-processing")
bobmods.lib.tech.add_prerequisite("angels-advanced-ore-refining-4", "bob-advanced-processing-unit")
bobmods.lib.tech.add_prerequisite("bob-speed-module-5", "bob-advanced-processing-unit")
bobmods.lib.tech.add_prerequisite("bob-efficiency-module-5", "bob-advanced-processing-unit")
bobmods.lib.tech.add_prerequisite("bob-productivity-module-5", "bob-advanced-processing-unit")
bobmods.lib.tech.add_prerequisite("bob-pollution-clean-module-5", "bob-advanced-processing-unit")
bobmods.lib.tech.add_prerequisite("bob-pollution-create-module-5", "bob-advanced-processing-unit")


-- Hide starting bob-burner-lab tech
bobmods.lib.tech.hide("bob-burner-lab")
bobmods.lib.tech.remove_prerequisite("automation-science-pack", "bob-burner-lab")
-- fix research trigger from bob-burner-lab -> burner-lab
data.raw.technology["automation-science-pack"].research_trigger.item = "burner-lab"

-- add electric-motor recipe unlock to electricity tech
bobmods.lib.tech.add_recipe_unlock("electricity", "electric-motor")
bobmods.lib.tech.add_recipe_unlock("electricity", "pipe")
bobmods.lib.tech.add_recipe_unlock("electricity", "pipe-to-ground")
