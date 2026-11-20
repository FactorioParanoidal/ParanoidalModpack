-- Mod, element name, sprite, tooltip, enabled (true or a per-user setting).
return {
	--mod					button name 								sprite 							tooltip 									show button (for some there's already a setting to toggle button)
	{"FJEI",				"fjei_toggle_button",						"fjei_button",					{'guiu.fjei_button'},						true},
	{"homeworld_redux",		"Homeworld_btn",							"homeworld_redux_button",		{'guiu.homeworld_redux_button'},			true},
	{"m-lawful-evil",		"lawful_evil_button",						"mlawfulevil_button",			{'guiu.mlawfulevil_button'},				true},
	{"Trashcan",			"trashbinguibutton",						"trashcan_button",				{'guiu.trashcan_button'},					true},
	{"pycoalprocessing",	"pywiki",									"pycoalprocessing_button",		{'guiu.pycoalprocessing_button'},			true},
	{"usage-detector",		"usage_detector",							"usagedetector_button",			{'guiu.usagedetector_button'},				true},
	{"RPG",					"104",										"rpg_button",					{'guiu.rpg_button'},						true},
	{"blueprint-sandboxes",	"bpsb-toggle-gui-sb-toggle-shortcut",	"blueprintsandboxes_button",	{'guiu.blueprintsandboxes_button'},		true},
	-- Paranoidal: объединитель сундуков; нажатие обрабатывает сам WideChests по имени кнопки.
	{"WideChests",			"WideChests_merge-chest-button",		"widechests_button",			{'guiu.widechests_button'},				true},
	-- Paranoidal: ModuleInserterEx has no top button; the click opens its window via remote (on_gui_click).
	{"ModuleInserterEx",	"module_inserter_config_button",		"moduleinserter_button",		{'guiu.moduleinserter_button'},			true},
	{"what-is-missing",		"what_is_missing",							"whatsmissing_button",			{'guiu.whatsmissing_button'},				true},
	{"some-zoom",			"but_zoom_zout",							"somezoom_out_button",			{'guiu.somezoom_out_button'},				true},
	{"some-zoom",			"but_zoom_zin",								"somezoom_in_button",			{'guiu.somezoom_in_button'},				true},
	{"production-monitor",	"stats_show_settings",						"productionmonitor_button",		{'guiu.productionmonitor_button'},			true},
	{"Teleportation_Redux",	"teleportation_main_button",				"teleportation_button",			{'guiu.teleportation_button'},				true},
	{"PersonalTeleporter",	"personalTeleporter_PersonalTeleportTool",	"teleportation_button",			{'guiu.teleportation_button'},				true},
	{"inserter-throughput",	"inserter-throughput-toggle",				"inserterthroughput_off_button",{'guiu.inserterthroughput_off_button'},		true},
	{"YARM",				"YARM_filter_none",							"yarm_all_button",				{'guiu.yarm_all_button'},					true},
	{"YARM",				"YARM_filter_warnings",						"yarm_none_button",				{'guiu.yarm_none_button'},					true},
	{"YARM",				"YARM_filter_all",							"yarm_warnings_button",			{'guiu.yarm_warnings_button'},				true},
	{"RecExplo",			"b_recexplo",								"recexplo_button",				{'guiu.recexplo_button'},					true},
	{"BlueprintLab_design",	"BPL_LabButton",							"blueprintlabdesign_button",	{'guiu.blueprintlabdesign_button'},			true},
	{"CredoTimeLapseModByGalapagon","CTLM_mainbutton",					"credotimelapse_button",		{'guiu.credotimelapse_button'},				true},
	{"Decu",				"market_button",							"decu_button",					{'guiu.decu_button'},						true},
	{"rd-se-multiplayer-compat","toggle_forces",						"forces_button",				{'guiu.compatforce_button'},				true},
	{"rd-se-multiplayer-compat","toggle_spawn_gui",						"spawncontrol_button",			{'guiu.compatspawn_button'},				true},
	{"Spiderissmo",			"108",										"item/spidertron",				{'guiu.Spiderissmo_spider_button'},			true},
	{"Spiderissmo",			"minimap_button",							"credotimelapse_button",		{'guiu.Spiderissmo_minimap_button'},		true},
	{"automatic-belt-direction","abdgui",								"abd_on_button",				{'guiu.abd_on_button'},						"abd-showgui"}
}
