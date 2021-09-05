local ICONPATH = "__GUI_Unifyer__/graphics/icons/"

local sprites = {"placeables_button", "todolist_button", "helmod_button", "factoryplanner_button", "moduleinserter_button", "wiiuf_button", "creativemod_button", "beastfinder_button",
"blueprintrequest_button", "bobclasses_button", "bobinserters_button", "cleanmap_button", "deathcounter_button", "ingteb_button", "outpostplanner_button",
"quickbarimportexport_button", "quickbarimport_button", "quickbarexport_button", "rocketsilostats_button", "schall_sc_button",

"actr_button", "attachnotes_button", "attilazoommod_button", "avatars_button", "betterbotsfixed_button", "blackmarket1_button", "blackmarket2_button",
"changemapsettings_button", "dana_button", "deleteadjacentchunk_button", "doingthingsbyhand_button",
"facautoscreenshot_button", "factorissimo2_button", "factorissimo2_inspect_button", "killlostbots_button",
"kttrrc_button", "kuxcraftingtools_button", "kuxorbitalioncannon_button", "landfilleverythingu_button",
"markers_button", "modmashsplinterboom_button", "modmashsplinternewworlds_button", "notenoughtodo_button", "nullius_button",
"oshahotswap_button", "picksrocketstats_button", "poweredentities_button", "researchcounter_button",
"richtexthelper_button", "ritnteleportation_button", "schallendgameevolution_button", "solarcalc_button",
"spacemod_button",
"thefatcontroller_button", "trainlog_button", "trainpubsub_button", "upgradeplannernext_button", "whatsmissing_button", "schall_rc_button",
"commuguidemod_guide_button", "commuguidemod_pupil_button", "blueprint_flip_horizontal_button", "blueprint_flip_vertical_button", "fjei_button",

"248k_button", "blueprintalignment_button", "cargotrainmanager_button", "clusterio_button", "cursedexp_button", "defaultwaitconditions_button",
"diplomacy_button", "electronic_locomotives_button", "forces_button", "hive_mind_button1", "hive_mind_button2", "howfardiditgo_button", "kuxblueprinteditor_button",
"logisticmachines_button", "logisticrequestmanager_button", "regioncloner_button", "resetevolutionpollution_button",
"schalloreconversion_button", "shuttle_train_continued_button", "simple_circuit_trains_button", "smartchest_button", "teamcoop_button1", "teamcoop_button2", "trainschedulesignals_button",

"homeworld_redux_button", "mlawfulevil_button", "trashcan_button", "pycoalprocessing_button", "usagedetector_button", "rpg_button", "spawncontrol_button", "spawncontrol_random_button", "whatismissing_button",

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
	data.raw["sprite"]["autotrash_trash_paused"].layers[1].filename = ICONPATH .. "autotrash_button.png"
	data.raw["sprite"]["autotrash_requests_paused"].layers[1].filename = ICONPATH .. "autotrash_button.png"
	data.raw["sprite"]["autotrash_both_paused"].layers[1].filename = ICONPATH .. "autotrash_button.png"
end

--TogglePeacefulMode
if data.raw["sprite"]["tpm_button_sprite_peace"] and data.raw["sprite"]["tpm_button_sprite_war"] then
	data.raw["sprite"]["tpm_button_sprite_peace"].filename = ICONPATH .. "tpm_button_sprite_peace.png"
	data.raw["sprite"]["tpm_button_sprite_peace"].size = {64, 64}
	data.raw["sprite"]["tpm_button_sprite_war"].filename = ICONPATH .. "tpm_button_sprite_war.png"
	data.raw["sprite"]["tpm_button_sprite_war"].size = {64, 64}
end

------------------
-- BUTTON STYLE --
------------------

local nothing = {0, 0, 0, 0}
local white = {1, 1, 1, 0.9}
local black = {0, 0, 0, 0.9}
local slot_button_notext = {
	type = "button_style",
	parent = "slot_button",
	default_font_color = nothing,
	hovered_font_color = nothing,
	clicked_font_color = nothing,
	disabled_font_color = nothing,
	selected_font_color = nothing,
	selected_hovered_font_color = nothing,
	selected_clicked_font_color = nothing,
	strikethrough_color = nothing,
}
local slot_button_whitetext = {
	type = "button_style",
	parent = "slot_button",
	default_font_color = white,
	hovered_font_color = white,
	clicked_font_color = white,
	disabled_font_color = white,
	selected_font_color = white,
	selected_hovered_font_color = white,
	selected_clicked_font_color = white,
	strikethrough_color = white,
}
local slot_sized_button_notext = {
	type = "button_style",
	parent = "slot_sized_button",
	default_font_color = nothing,
	hovered_font_color = nothing,
	clicked_font_color = nothing,
	disabled_font_color = nothing,
	selected_font_color = nothing,
	selected_hovered_font_color = nothing,
	selected_clicked_font_color = nothing,
	strikethrough_color = nothing,
}
local slot_sized_button_blacktext = {
	type = "button_style",
	parent = "slot_sized_button",
	default_font_color = black,
	hovered_font_color = black,
	clicked_font_color = black,
	disabled_font_color = black,
	selected_font_color = black,
	selected_hovered_font_color = black,
	selected_clicked_font_color = black,
	strikethrough_color = black,
}

data.raw["gui-style"].default["slot_button_notext"] = slot_button_notext
data.raw["gui-style"].default["slot_button_whitetext"] = slot_button_whitetext
data.raw["gui-style"].default["slot_sized_button_notext"] = slot_sized_button_notext
data.raw["gui-style"].default["slot_sized_button_blacktext"] = slot_sized_button_blacktext
--data.raw["gui-style"].default["attach-notes-add-button"]
--data.raw["gui-style"].default["attach-notes-edit-button"]
--data.raw["gui-style"].default["attach-notes-view-button"]

------------------
-- FRAME STYLES --
------------------

local invisible_frame =
{
  type = "frame_style",
  use_header_filler = false,
  padding = 0,
  margin = 0,
  graphical_set =
  {
    base =
    {
      position = {0, 0},
      corner_size = 1,
      center = {position = {42, 8},
      size = {1, 1}},
      draw_type = "outer",
      opacity = 0,
    },
  },
  header_flow_style =
  {
    type = "horizontal_flow_style",
    bottom_padding = 0
  },
  horizontal_flow_style =
  {
    type = "horizontal_flow_style",
    --space between page buttons and icon slots
    horizontal_spacing = 0
  },
}

local barebone_frame =
{
  type = "frame_style",
  padding = 0,
  margin = 0,
  use_header_filler = false,
  header_flow_style =
  {
    type = "horizontal_flow_style",
    bottom_padding = 0
  },
  horizontal_flow_style =
  {
    type = "horizontal_flow_style",
    --space between page buttons and icon slots
    horizontal_spacing = 0
  },
}

data.raw["gui-style"].default["invisible_frame"] = invisible_frame
data.raw["gui-style"].default["barebone_frame"] = barebone_frame