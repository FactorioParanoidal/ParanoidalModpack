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
local WHITE = {1, 1, 1}
local slot = styles.slot_button
local yellow = styles.yellow_slot_button

local function copy(t) return t and table.deepcopy(t) or nil end

-- The clicked day: the dark cell with the orange outer glow of a hovered slot instead of the orange fill
-- of a toggled slot, so that today stays the brightest cell.
local picked = copy(slot.default_graphical_set) or {}
picked.glow = copy(slot.hovered_graphical_set and slot.hovered_graphical_set.glow)

local function day_style(color, hovered, font)
	return {
		type = "button_style",
		parent = "slot_button",
		size = 40,
		padding = 0,
		font = font or "default-bold",
		default_font_color = color,
		hovered_font_color = hovered or color,
		clicked_font_color = hovered or color,
		selected_font_color = WHITE,
		selected_hovered_font_color = WHITE,
		selected_clicked_font_color = WHITE,
		selected_graphical_set = picked,
		selected_hovered_graphical_set = copy(slot.hovered_graphical_set),
		selected_clicked_graphical_set = copy(slot.clicked_graphical_set),
	}
end

styles.rpgpm_day = day_style(TEXT, WHITE)
styles.rpgpm_day_weekend = day_style({1, 0.56, 0.45}, {1, 0.7, 0.6})
styles.rpgpm_day_past = day_style({0.5, 0.5, 0.5}, {0.75, 0.75, 0.75}, "default-semibold")
styles.rpgpm_day_past_weekend = day_style({0.58, 0.4, 0.35}, {0.8, 0.55, 0.5}, "default-semibold")

-- Today: the bright (hovered) look of the yellow slot all the time, dark digits.
local bright = copy(yellow.hovered_graphical_set)
styles.rpgpm_day_today = {
	type = "button_style",
	parent = "yellow_slot_button",
	size = 40,
	padding = 0,
	font = "default-bold",
	default_font_color = DARK,
	hovered_font_color = DARK,
	clicked_font_color = DARK,
	selected_font_color = DARK,
	selected_hovered_font_color = DARK,
	selected_clicked_font_color = DARK,
	default_graphical_set = bright,
	selected_graphical_set = copy(bright),
	selected_hovered_graphical_set = copy(bright),
}
