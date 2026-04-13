-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

local function create_label_sprite(label)
	data:extend({
		{
			type = "sprite",
			name = "reskins-lib-" .. label .. "-tier-label",
			filename = "__reskins-library__/graphics/icons/sprites/tier-labels/icon-" .. label .. ".png",
			flags = { "gui-icon" },
			size = 40,
			mipmap_count = 2,
		},
	})
end

local icons = {
	"chevron",
	"dots",
	"half-circle",
	"rectangle",
	"rounded-half-circle",
	"rounded-rectangle",
	"teardrop",
}

for _, v in pairs(icons) do
	create_label_sprite(v)
end
