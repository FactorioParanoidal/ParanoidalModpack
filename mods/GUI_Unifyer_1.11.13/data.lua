-----------------------
------- SPRITES -------
-----------------------

local ICONPATH = "__GUI_Unifyer__/graphics/icons/"
local sprites = {
"248k_button", "actr_button", "attilazoommod_button", "beastfinder_button", "betterbotsfixed_button", "blackmarket1_button", "blackmarket2_button", "blueprint_flip_horizontal_button",
"blueprint_flip_vertical_button", "blueprintalignment_button", "blueprintrequest_button", "bobclasses_button", "bobinserters_button", "cargotrainmanager_button", "changemapsettings_button", "cleanmap_button", "clusterio_button",
"commuguidemod_guide_button", "commuguidemod_pupil_button", "creativemod_button", "cursedexp_button", "deathcounter_button", "defaultwaitconditions_button", "diplomacy_button",
"doingthingsbyhand_button", "electronic_locomotives_button", "facautoscreenshot_button", "factorissimo2_button", "factorissimo2_inspect_button", "factoryplanner_button", "fjei_button", "forces_button", "helmod_button",
"hive_mind_button1", "hive_mind_button2", "homeworld_redux_button", "howfardiditgo_button", "ingteb_button", "inserterthroughput_off_button", "inserterthroughput_on_button", "killlostbots_button", "kttrrc_button",
"kuxblueprinteditor_button", "kuxcraftingtools_button", "kuxorbitalioncannon_button", "landfilleverythingu_button", "logisticmachines_button", "logisticrequestmanager_button", "logisticssystemfork_button", "markers_button",
"mlawfulevil_button", "moduleinserter_button", "newgameplus_button", "notenoughtodo_button", "nullius_button", "oshahotswap_button", "outpostplanner_button",
"picksrocketstats_button", "placeables_button", "poweredentities_button", "productionmonitor_button", "pycoalprocessing_button", "quickbarexport_button", "quickbarimport_button", "quickbarimportexport_button",
"regioncloner_button", "researchcounter_button", "resetevolpol_button", "richtexthelper_button", "ritnteleportation_button", "rocketsilostats_button", "rpg_button", "schall_rc_button", "schall_sc_button",
"schalloreconversion_button", "shuttle_train_button", "simple_circuit_trains_button", "smartchest_button", "solarcalc_button", "somezoom_in_button", "somezoom_out_button", "spacemod_button", "spawncontrol_button",
"spawncontrol_random_button", "teamcoop_button1", "teamcoop_button2", "teleportation_button", "thefatcontroller_button", "todolist_button", "trainlog_button", "trainpubsub_button",
"trashcan_button", "upgradeplannernext_button", "usagedetector_button", "whatsmissing_button", "wiiuf_button", "yarm_all_button", "yarm_none_button", "yarm_warnings_button",
"blueprintlabdesign_button", "recexplo_button", "nonwavedefense2_button", "dana_button", "factorio_tweaks_button", "remoteswitch_button", "tsmoutpostbuilder_button", "credotimelapse_button", "spidersentinel_button",
"citiesofearth_button", "enemyracemanager_button", "oarcmod_button", "decu_button", "leaderboard_button", "abd_on_button", "abd_off_button", "avatars_button", "newworlds_button",
}

for _, i in pairs(sprites) do
	local p = {}
	p.type = "sprite"
	p.name = i
	p.filename = ICONPATH .. i .. ".png"
	p.flags = { "gui-icon" }
	p.width = 64
	p.height = 64
	p.scale = 0.5
	p.priority = "extra-high-no-scale"
	data:extend({p})
end

--Autotrash
if data.raw["sprite"]["autotrash_trash"] and data.raw["sprite"]["autotrash_trash_paused"] and data.raw["sprite"]["autotrash_requests_paused"] and data.raw["sprite"]["autotrash_both_paused"] then
  data.raw["sprite"]["autotrash_trash"].filename = ICONPATH .. "autotrash_button.png"
  data.raw["sprite"]["autotrash_trash"].size = 64
  data.raw["sprite"]["autotrash_trash_paused"] = {
    type = "sprite",
    name = "autotrash_trash_paused",
    flags = {"icon"},
    layers = {
      {filename = ICONPATH .. "autotrash_button.png", size = 64},
      {filename = ICONPATH .. "autotrash_red_button.png", size = 64}
    },
  }
  data.raw["sprite"]["autotrash_requests_paused"] = {
    type = "sprite",
    name = "autotrash_requests_paused",
    flags = {"icon"},
    layers = {
      {filename = ICONPATH .. "autotrash_button.png", size = 64},
      {filename = ICONPATH .. "autotrash_yellow_button.png", size = 64}
    },
  }
  data.raw["sprite"]["autotrash_both_paused"] = {
    type = "sprite",
    name = "autotrash_both_paused",
    flags = {"icon"},
    layers = {
      {filename = ICONPATH .. "autotrash_button.png", size = 64},
      {filename = ICONPATH .. "autotrash_redyellow_button.png", size = 64}
    },
  }
end

--TogglePeacefulMode
if data.raw["sprite"]["tpm_button_sprite_peace"] and data.raw["sprite"]["tpm_button_sprite_war"] then
	data.raw["sprite"]["tpm_button_sprite_peace"].filename = ICONPATH .. "tpm_button_sprite_peace.png"
	data.raw["sprite"]["tpm_button_sprite_peace"].size = {64, 64}
	data.raw["sprite"]["tpm_button_sprite_war"].filename = ICONPATH .. "tpm_button_sprite_war.png"
	data.raw["sprite"]["tpm_button_sprite_war"].size = {64, 64}
end

--  SchallEndgameEvolution make icons more or less red depending on tier, relative to max tier setting
if mods["SchallEndgameEvolution"] then
	local max_tier = settings.startup["endgameevolution-alien-tier-max"] and settings.startup["endgameevolution-alien-tier-max"].value or 20
	for i = 1,max_tier do
		local p = {}
		local whiteness = (((max_tier + 2) - i) / (max_tier + 2))
		p.type = "sprite"
		p.name = "sprite-Schall-tier-"..i
		p.layers = {
			{filename = ICONPATH .. "schallendgameevolution_button.png", size = 64, scale = 0.5, tint = {1, whiteness, whiteness}},
			{filename = "__SchallEndgameEvolution__/graphics/gui/tier-"..i..".png", size = 32, scale = 0.7}
		}
		p.flags = { "gui-icon" }
		p.priority = "extra-high-no-scale"
		data:extend({p})
	end
end

data:extend({
	{
    type = "sprite",
    name = "DeleteAdjacentChunk_player",
    filename = "__GUI_Unifyer__/graphics/gui/deleteadjacentchunks_center.png",
    priority = "extra-high-no-scale",
    width = 40,
    height = 26,
    scale = 0.5,
	},
})

require('prototypes/button_style')
require('prototypes/frame_style')

