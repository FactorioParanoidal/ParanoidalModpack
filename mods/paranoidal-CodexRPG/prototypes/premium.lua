-- Premium BnL (base journal): alarm sounds and the styles of the calendar days.
local sounds = require("scripts.premium.sounds")

for _, s in ipairs(sounds) do
	data:extend({{
		type = "sound",
		name = "rpgpm-" .. s.id,
		filename = s.file,
		category = "alert",
	}})
end

local styles = data.raw["gui-style"]["default"]
local TEXT = {0.9, 0.9, 0.9}
local DARK = {0.1, 0.1, 0.1}

-- selected: the clicked day; today keeps dark text on yellow.
local function day_style(parent, color, hovered, font, selected)
	selected = selected or {1, 1, 1}
	return {
		type = "button_style",
		parent = parent,
		size = 40,
		padding = 0,
		font = font or "default-bold",
		default_font_color = color,
		hovered_font_color = hovered or color,
		clicked_font_color = hovered or color,
		selected_font_color = selected,
		selected_hovered_font_color = selected,
		selected_clicked_font_color = selected,
	}
end

styles.rpgpm_day = day_style("slot_button", TEXT, {1, 1, 1})
styles.rpgpm_day_weekend = day_style("slot_button", {1, 0.56, 0.45}, {1, 0.7, 0.6})
styles.rpgpm_day_past = day_style("slot_button", {0.5, 0.5, 0.5}, {0.75, 0.75, 0.75}, "default-semibold")
styles.rpgpm_day_past_weekend = day_style("slot_button", {0.58, 0.4, 0.35}, {0.8, 0.55, 0.5}, "default-semibold")
styles.rpgpm_day_today = day_style("yellow_slot_button", DARK, DARK, nil, DARK)
