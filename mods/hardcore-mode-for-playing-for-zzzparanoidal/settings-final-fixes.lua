local function set_settings_default_value(settings_type, settings_name, settings_default_value)
	if not settings_type or type(settings_type) ~= "string" or not settings_name or type(settings_name) ~= "string" then
		error(
			"settings_type "
				.. tostring(settings_type)
				.. " settings_name "
				.. tostring(settings_name)
				.. " has wrong signature!"
		)
	end
	if
		type(settings_default_value) == "table"
		or type(settings_default_value) == "function"
		or type(settings_default_value) == "thread"
		or type(settings_default_value) == "userdata"
	then
		error("default value must be have only primitive type such as boolean, string, number")
	end
	if not data.raw[settings_type][settings_name] then
		error("mod setting data.raw['" .. settings_type .. "']['" .. settings_name .. "'] not exists!")
	end
	data.raw[settings_type][settings_name].default_value = settings_default_value
	log(
		"setting data.raw['"
			.. settings_type
			.. "']['"
			.. settings_name
			.. "'].default_value to "
			.. tostring(settings_default_value)
	)
end

--helmod - КАЖДЫЙ САМ НАСТРАИВАЕТ ПОД СЕБЯ, если использует. СТАНДАРТНЫХ НАСТРОЕК НЕТ!
--runtime.global влияют на всю карту
-- руины
if mods["AbandonedRuins"] then
	set_settings_default_value("string-setting", "AbandonedRuins-set", "base")
	set_settings_default_value("double-setting", "ruins-large-ruin-chance", 0.0025)
	set_settings_default_value("double-setting", "ruins-medium-ruin-chance", 0.01)
	set_settings_default_value("int-setting", "ruins-min-distance-from-spawn", 400)
	set_settings_default_value("double-setting", "ruins-small-ruin-chance", 0.025)
end
--ритег
if mods["__RITEG__"] then
	set_settings_default_value("int-setting", "__RITEG__autodeconstruct-health-threshold", 15)
end
--биг монстры
if mods["Big-Monsters"] then
	set_settings_default_value("double-setting", "bm-biterzilla-min_evo", 0.4)
	set_settings_default_value("double-setting", "bm-brutals-min_evo", 0.3)
	set_settings_default_value("int-setting", "bm-difficulty-level", 5)
	set_settings_default_value("int-setting", "bm-invasion-chance", 0)
	set_settings_default_value("double-setting", "bm-invasion-min_evo", 0.4)
	set_settings_default_value("double-setting", "bm-soldiers-min_evo", 0.2)
	set_settings_default_value("bool-setting", "bm-spawn_near_nests", true)
	set_settings_default_value("int-setting", "bm-spidertron-chance", 20)
	set_settings_default_value("int-setting", "bm-swarm-chance", 20)
	set_settings_default_value("int-setting", "bm-volcano-chance", 0)
	set_settings_default_value("double-setting", "bm-volcano-max_evo", 1)
	set_settings_default_value("int-setting", "bm-worms-chance", 0)
end
-- DeleteChuncks
if mods["DeleteEmptyChunks"] then
	set_settings_default_value("int-setting", "DeleteEmptyChunks_radius", 1)
end
--Factorissimo2
if mods["factorissimo-2-notnotmelon"] or mods["Factorissimo2"] then
	set_settings_default_value("bool-setting", "Factorissimo2-better-recursion-2", false)
end
--even-distribution
if mods["even-distribution"] then
	set_settings_default_value("int-setting", "global-max-inventory-cleanup-range", 100)
end
--ltn-cleanup
if mods["ltn-cleanup"] then
	set_settings_default_value("bool-setting", "ltn-cleanup-failed-trains", true)
	set_settings_default_value("int-setting", "ltn-dispatcher-nth_tick", 6)
	set_settings_default_value("bool-setting", "ltn-interface-message-gps", true)
	set_settings_default_value("string-setting", "ltn-interface-console-level", "0")
	set_settings_default_value("bool-setting", "ltn-interface-message-gps", true)
end
if mods["LTN_Content_Reader"] then
	set_settings_default_value("int-setting", "ltn_content_reader_update_interval", 240)
end
if mods["LtnManager"] then
	set_settings_default_value("int-setting", "ltnm-iterations-per-tick", 2)
end
if mods["deep-storage-unit"] or mods["fluid-memory-storage"] then
	set_settings_default_value("string-setting", "memory-unit-power-usage", "480kW")
end
if mods["ModuleInserter"] then
	set_settings_default_value("int-setting", "module_inserter_proxies_per_tick", 10)
end
if mods["namelists"] then
	set_settings_default_value("bool-setting", "namelists-backer-stations", true)
end
if mods["NightBrightness"] then
	set_settings_default_value("int-setting", "night_brightness_period_days", 24)
end
if mods["Noxys_Trees"] then
	set_settings_default_value("int-setting", "Noxys_Trees-maximum-trees-per-chunk", 256)
	set_settings_default_value("int-setting", "Noxys_Trees-ticks-between-operations", 61)
end
if mods["OverloadedTrains"] then
	set_settings_default_value("double-setting", "OT_realism", 1)
end
if mods["Picks-Inserter"] then
	set_settings_default_value("int-setting", "PI_clear_max", 1)
	set_settings_default_value("bool-setting", "PI_target_selection", false)
	set_settings_default_value("bool-setting", "PI_target_train_stop", false)
	set_settings_default_value("bool-setting", "PI_temp_unlock", false)
end
if mods["PickerInventoryTools"] then
	set_settings_default_value("bool-setting", "picker-autodeconstruct", true)
	set_settings_default_value("bool-setting", "picker-autodeconstruct-target", true)
	set_settings_default_value(
		"string-setting",
		"picker-carousel-registry",
		"{['medium-electric-pole'] = 'big-electric-pole', ['big-electric-pole'] = 'substation'}"
	)
	set_settings_default_value("bool-setting", "picker-copy-between-surfaces", false)
	set_settings_default_value("bool-setting", "picker-get-out-of-the-way", false)
	set_settings_default_value("bool-setting", "picker-train-honk", false)
end
if mods["QualityOfLife"] then
	set_settings_default_value("double-setting", "qol-logistic-slots-flat-bonus", 0)
	set_settings_default_value("double-setting", "qol-logistic-slots-multiplier", 1)
	set_settings_default_value("double-setting", "qol-toolbelts-flat-bonus", 0)
	set_settings_default_value("double-setting", "qol-toolbelts-multiplier", 1)
end
if mods["railloader"] then
	set_settings_default_value("string-setting", "railloader-allowed-items", "any")
	set_settings_default_value("bool-setting", "railloader-show-configuration-messages", false)
end
if mods["RampantFixed"] then
	set_settings_default_value("int-setting", "rampantFixed--attackWaveMaxSize", 55)
	set_settings_default_value("int-setting", "rampantFixed--maxNumberOfBuilders", 25)
	set_settings_default_value("int-setting", "rampantFixed--maxNumberOfSquads", 20)

	set_settings_default_value("bool-setting", "rampantFixed--safeBuildings-bigElectricPole", true)
	set_settings_default_value("bool-setting", "rampantFixed--safeBuildings-curvedRail", true)
	set_settings_default_value("bool-setting", "rampantFixed--safeBuildings-lamps", true)
	set_settings_default_value("bool-setting", "rampantFixed--safeBuildings-railChainSignals", true)
	set_settings_default_value("bool-setting", "rampantFixed--safeBuildings-railSignals", true)
	set_settings_default_value("bool-setting", "rampantFixed--safeBuildings-straightRail", true)
	set_settings_default_value("bool-setting", "rampantFixed--safeBuildings-trainStops", true)
end
if mods["TimedSpawnControl"] then
	set_settings_default_value("bool-setting", "random-spawn", false)
	set_settings_default_value("int-setting", "respawn-timer", 60)
	set_settings_default_value("bool-setting", "unstuck-button", false)
end
if mods["robot-attrition"] then
	set_settings_default_value("double-setting", "robot-attrition-factor", 0.4)
end
if mods["rso-mod"] then
	set_settings_default_value("double-setting", "rso-infinite-ore-threshold", 0.99)
	set_settings_default_value("bool-setting", "rso-remove-trees", true)
	set_settings_default_value("bool-setting", "rso-use-donuts", true)
end
-- end runtime.global
-- runtime.per_user влияют на каждого игрока в отдельности
if mods["PMRPGsystem"] then
	set_settings_default_value("bool-setting", "charxpmod_hide_xp_panel", true)
end
if mods["LogisticTrainNetwork"] then
	set_settings_default_value("bool-setting", "ltn-interface-factorio-alerts", false)
end
if mods["PickerInventoryTools"] then
	set_settings_default_value("bool-setting", "picker-auto-sort-inventory", false)
	set_settings_default_value("bool-setting", "picker-filter-filters", false)
	set_settings_default_value("bool-setting", "picker-filter-requests", false)
	set_settings_default_value("bool-setting", "picker-find-orphans", false)
	set_settings_default_value("bool-setting", "picker-manual-train-keys", true)
	set_settings_default_value("bool-setting", "picker-use-bar-limit", false)
end
if mods["PipeVisualizer"] then
	set_settings_default_value("double-setting", "pv-overlay-opacity", 0.6)
end
if mods["reskins-library"] then
	set_settings_default_value("bool-setting", "reskins-lib-display-notifications", false)
end
-- end runtime.per_user
-- startup влияют на прототипы(сущности, предметы, рецепты, технологии и их связи между собой)
-- Отключаем тестирование ядерных бомб и компании
--set_settings_default_value("bool-setting", "enable-nuclear-tests", false)
-- end startup
