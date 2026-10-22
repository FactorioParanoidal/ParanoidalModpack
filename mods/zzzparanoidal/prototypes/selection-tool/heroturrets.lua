-- Разжалование турелей HeroTurretRedux (Beta 8).
-- Кнопку панели создаёт tweaks/custom/hero-shortcut.lua в слое сборки.
local turret_types = { "ammo-turret", "electric-turret", "fluid-turret", "artillery-turret" }

data:extend({
	{
		type = "selection-tool",
		name = "hero_downgrade",
		flags = { "only-in-cursor", "not-stackable", "spawnable" },
		hidden = true,
		stack_size = 1,
		icon = "__base__/graphics/icons/tank-cannon.png",
		icon_size = 64,
		select = {
			border_color = { r = 0, g = 0, b = 1, a = 0.2 },
			mode = { "buildable-type" },
			cursor_box_type = "entity",
			entity_type_filters = turret_types,
		},
		alt_select = {
			border_color = { r = 0, g = 0, b = 0.5, a = 0.2 },
			mode = { "buildable-type" },
			cursor_box_type = "copy",
			entity_type_filters = turret_types,
		},
	},
})
