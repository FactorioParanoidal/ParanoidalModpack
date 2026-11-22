-----------------------
------- SPRITES -------
-----------------------

local ICONPATH = "__GUI_Unifyer__/graphics/icons/"
local sprites = {
    "bobinserters_button",
    "creativemod_button",
    "factorissimo2_button",
    "factoryplanner_button",
    "forces_button",
    "helmod_button",
    "inserterthroughput_off_button",
    "inserterthroughput_on_button",
    "moduleinserter_button",
    "picksrocketstats_button",
    "rpg_button",
    "spawncontrol_button",
    "spawncontrol_random_button",
    "teamcoop_button1",
    "todolist_button",
    "factorio_tweaks_button",
    "leaderboard_button",
    "blueprintsandboxes_button",
    "widechests_button",
    -- DORMANT |: restore only the sprites needed by the re-enabled integration.
    -- DORMANT | "248k_button",
    -- DORMANT | "actr_button",
    -- DORMANT | "attilazoommod_button",
    -- DORMANT | "beastfinder_button",
    -- DORMANT | "betterbotsfixed_button",
    -- DORMANT | "blackmarket1_button",
    -- DORMANT | "blackmarket2_button",
    -- DORMANT | "blueprint_flip_horizontal_button",
    -- DORMANT | "blueprint_flip_vertical_button",
    -- DORMANT | "blueprintalignment_button",
    -- DORMANT | "blueprintrequest_button",
    -- DORMANT | "bobclasses_button",
    -- DORMANT | "cargotrainmanager_button",
    -- DORMANT | "changemapsettings_button",
    -- DORMANT | "cleanmap_button",
    -- DORMANT | "clusterio_button",
    -- DORMANT | "commuguidemod_guide_button",
    -- DORMANT | "commuguidemod_pupil_button",
    -- DORMANT | "cursedexp_button",
    -- DORMANT | "deathcounter_button",
    -- DORMANT | "defaultwaitconditions_button",
    -- DORMANT | "diplomacy_button",
    -- DORMANT | "doingthingsbyhand_button",
    -- DORMANT | "electronic_locomotives_button",
    -- DORMANT | "facautoscreenshot_button",
    -- DORMANT | "factorissimo2_inspect_button",
    -- DORMANT | "fjei_button",
    -- DORMANT | "hive_mind_button1",
    -- DORMANT | "hive_mind_button2",
    -- DORMANT | "homeworld_redux_button",
    -- DORMANT | "howfardiditgo_button",
    -- DORMANT | "ingteb_button",
    -- DORMANT | "killlostbots_button",
    -- DORMANT | "kttrrc_button",
    -- DORMANT | "kuxblueprinteditor_button",
    -- DORMANT | "kuxcraftingtools_button",
    -- DORMANT | "kuxorbitalioncannon_button",
    -- DORMANT | "landfilleverythingu_button",
    -- DORMANT | "logisticmachines_button",
    -- DORMANT | "logisticrequestmanager_button",
    -- DORMANT | "logisticssystemfork_button",
    -- DORMANT | "markers_button",
    -- DORMANT | "mlawfulevil_button",
    -- DORMANT | "newgameplus_button",
    -- DORMANT | "notenoughtodo_button",
    -- DORMANT | "nullius_button",
    -- DORMANT | "oshahotswap_button",
    -- DORMANT | "outpostplanner_button",
    -- DORMANT | "placeables_button",
    -- DORMANT | "poweredentities_button",
    -- DORMANT | "productionmonitor_button",
    -- DORMANT | "pycoalprocessing_button",
    -- DORMANT | "quickbarexport_button",
    -- DORMANT | "quickbarimport_button",
    -- DORMANT | "quickbarimportexport_button",
    -- DORMANT | "regioncloner_button",
    -- DORMANT | "researchcounter_button",
    -- DORMANT | "resetevolpol_button",
    -- DORMANT | "richtexthelper_button",
    -- DORMANT | "ritnteleportation_button",
    -- DORMANT | "rocketsilostats_button",
    -- DORMANT | "schall_rc_button",
    -- DORMANT | "schall_sc_button",
    -- DORMANT | "schalloreconversion_button",
    -- DORMANT | "shuttle_train_button",
    -- DORMANT | "simple_circuit_trains_button",
    -- DORMANT | "smartchest_button",
    -- DORMANT | "solarcalc_button",
    -- DORMANT | "somezoom_in_button",
    -- DORMANT | "somezoom_out_button",
    -- DORMANT | "spacemod_button",
    -- DORMANT | "teamcoop_button2",
    -- DORMANT | "teleportation_button",
    -- DORMANT | "thefatcontroller_button",
    -- DORMANT | "trainlog_button",
    -- DORMANT | "trainpubsub_button",
    -- DORMANT | "trashcan_button",
    -- DORMANT | "upgradeplannernext_button",
    -- DORMANT | "usagedetector_button",
    -- DORMANT | "whatsmissing_button",
    -- DORMANT | "wiiuf_button",
    -- DORMANT | "yarm_all_button",
    -- DORMANT | "yarm_none_button",
    -- DORMANT | "yarm_warnings_button",
    -- DORMANT | "blueprintlabdesign_button",
    -- DORMANT | "recexplo_button",
    -- DORMANT | "nonwavedefense2_button",
    -- DORMANT | "dana_button",
    -- DORMANT | "remoteswitch_button",
    -- DORMANT | "tsmoutpostbuilder_button",
    -- DORMANT | "credotimelapse_button",
    -- DORMANT | "spidersentinel_button",
    -- DORMANT | "citiesofearth_button",
    -- DORMANT | "enemyracemanager_button",
    -- DORMANT | "oarcmod_button",
    -- DORMANT | "decu_button",
    -- DORMANT | "abd_on_button",
    -- DORMANT | "abd_off_button",
    -- DORMANT | "avatars_button",
    -- DORMANT | "newworlds_button",
    -- DORMANT | "quickitemmenu_button",
    -- DORMANT | "visualsignals_button",
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

-- High-resolution glyph: keep the 16 px logical size without magnifying the old small mipmap.
data:extend({{
    type = "sprite",
    name = "pd-atlas-bookmark-light",
    filename = ICONPATH .. "pd-atlas-bookmark-light.png",
    size = 128,
    scale = 0.125,
    flags = {"gui-icon"},
    priority = "extra-high-no-scale"
}})

-- Paranoidal: the WideChests button uses the build's 128 px steel chest icon at full resolution
-- (same 32 px on screen as the 64 px icons at scale 0.5).
data.raw["sprite"]["widechests_button"].width = 128
data.raw["sprite"]["widechests_button"].height = 128
data.raw["sprite"]["widechests_button"].scale = 0.25

--[=[ DORMANT: AutoTrash
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
]=]

--[=[ DORMANT: TogglePeacefulMode
--TogglePeacefulMode
if data.raw["sprite"]["tpm_button_sprite_peace"] and data.raw["sprite"]["tpm_button_sprite_war"] then
	data.raw["sprite"]["tpm_button_sprite_peace"].filename = ICONPATH .. "tpm_button_sprite_peace.png"
	data.raw["sprite"]["tpm_button_sprite_peace"].size = {64, 64}
	data.raw["sprite"]["tpm_button_sprite_war"].filename = ICONPATH .. "tpm_button_sprite_war.png"
	data.raw["sprite"]["tpm_button_sprite_war"].size = {64, 64}
end
]=]

--[=[ DORMANT: SchallEndgameEvolution
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
]=]

--[=[ DORMANT: DeleteAdjacentChunk
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
]=]

require('prototypes/button_style')
require('prototypes/frame_style')

