local ICONPATH = "__GUI_Unifyer__/graphics/icons/"

local sprites = {"placeables_button", "todolist_button", "helmod_button", "factoryplanner_button", "moduleinserter_button", "wiiuf_button", "creativemod_button", "beastfinder_button",
"blueprintrequest_button", "bobclasses_button", "bobinserters_button", "cleanmap_button", "deathcounter_button", "ingteb_button", "outpostplanner_button",
"quickbarimportexport_button", "quickbarimport_button", "quickbarexport_button", "rocketsilostats_button", "schallsatellitecontroller_button",

"actualcrafttimesremade_button", "attachnotes_button", "attilazoommod_button", "avatars_button", "betterbotsfixed_button", "blackmarket2_button",
"blueprintalignment_button", "changemapsettings_button", "dana_button", "deleteadjacentchunk_button", "doingthingsbyhand_button",
"facautoscreenshot_button", "factorissimo2_button", "factorissimo2_inspect_button", "killlostbots_button",
"kraskaskatotalrawresourcescalc_button", "kuxcraftingtools_button", "kuxorbitalioncannon_button", "landfilleverythingu_button",
"markers_button", "modmashsplinterboom_button", "modmashsplinternewworlds_button", "newgameplus_button", "notenoughtodo_button", "nullius_button",
"oshahotswap_button", "pickerinventorytools_button", "picksrocketstats_button", "poweredentities_button", "researchcounter_button",
"richtexthelper_button", "ritnteleportation_button", "schallendgameevolution_button", "solarcalc_button", "solarratio_button", "spacemod_button",
"thefatcontroller_button", "trainlog_button", "trainpubsub_button", "upgradeplannernext_button", "whatsmissing_button",
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

if data.raw["sprite"]["autotrash_trash"] and data.raw["sprite"]["autotrash_trash_paused"] and data.raw["sprite"]["autotrash_requests_paused"] and data.raw["sprite"]["autotrash_both_paused"] then
	data.raw["sprite"]["autotrash_trash"].filename = ICONPATH .. "autotrash_button.png"
	data.raw["sprite"]["autotrash_trash_paused"].layers[1].filename = ICONPATH .. "autotrash_button.png"
	data.raw["sprite"]["autotrash_requests_paused"].layers[1].filename = ICONPATH .. "autotrash_button.png"
	data.raw["sprite"]["autotrash_both_paused"].layers[1].filename = ICONPATH .. "autotrash_button.png"
end

if data.raw["sprite"]["tpm_button_sprite_peace"] and data.raw["sprite"]["tpm_button_sprite_war"] then
	data.raw["sprite"]["tpm_button_sprite_peace"].filename = ICONPATH .. "tpm_button_sprite_peace.png"
	data.raw["sprite"]["tpm_button_sprite_peace"].size = {64, 64}
	data.raw["sprite"]["tpm_button_sprite_war"].filename = ICONPATH .. "tpm_button_sprite_war.png"
	data.raw["sprite"]["tpm_button_sprite_war"].size = {64, 64}
end




local nothing = {0, 0, 0, 0}
local white = {1, 1, 1, 0.9}
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

data.raw["gui-style"].default["slot_button_notext"] = slot_button_notext
data.raw["gui-style"].default["slot_button_whitetext"] = slot_button_whitetext