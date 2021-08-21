local ICONPATH = "__GUI_Unifyer__/graphics/icons/"

local sprites = {"placeables", "todolist", "helmod", "factoryplanner", "what-is-it-really-used-for", "creativemod_button", "beastfinder_button", "blueprint_request_button", "bobclasses_button", "bobinserters_button"}

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

local def = {0, 0, 0, 0}
local slot_button_notext = {
	type = "button_style",
	parent = "slot_button",
	default_font_color = def,
	hovered_font_color = def,
	clicked_font_color = def,
	disabled_font_color = def,
	selected_font_color = def,
	selected_hovered_font_color = def,
	selected_clicked_font_color = def,
	strikethrough_color = def,
}

data.raw["gui-style"].default["slot_button_notext"] = slot_button_notext