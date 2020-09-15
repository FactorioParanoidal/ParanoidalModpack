--[[ Copyright (c) 2019 npc_strider
 * For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
 * This mod may contain modified code sourced from base/core Factorio
 *
 * shortcuts.lua
 * Shortcuts and mod compatibility
--]]

-- This code has been modified by ickputzdirwech.

if settings.startup["belt-immunity-equipment"].value == true then
	data:extend(
	{
		{
			type = "shortcut",
			name = "belt-immunity-equipment",
			order = "c[toggles]-c[belt-immunity-equipment]",
			action = "lua",
			localised_name = {"item-name.belt-immunity-equipment"},
			technology_to_unlock = "belt-immunity-equipment",
			toggleable = true,
			icon =
			{
				filename = "__Shortcuts-ick__/graphics/belt-immunity-toggle-x32.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 1,
				flags = {"icon"}
			},
			small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/belt-immunity-toggle-x24.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
			disabled_icon =
			{
				filename = "__Shortcuts-ick__/graphics/belt-immunity-toggle-x32-white.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 1,
				flags = {"icon"}
			},
			disabled_small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/belt-immunity-toggle-x24-white.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
		}
	})
end

if settings.startup["night-vision-equipment"].value == true then
	data:extend(
	{
		{
			type = "shortcut",
			name = "night-vision-equipment",
			order = "c[toggles]-d[night-vision-equipment]",
			action = "lua",
			localised_name = {"equipment-name.night-vision-equipment"},
			technology_to_unlock = "night-vision-equipment",
			toggleable = true,
			icon =
			{
				filename = "__Shortcuts-ick__/graphics/night-vision-toggle-x32.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 1,
				flags = {"icon"}
			},
			small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/night-vision-toggle-x24.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
			disabled_icon =
			{
				filename = "__Shortcuts-ick__/graphics/night-vision-toggle-x32-white.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 1,
				flags = {"icon"}
			},
			disabled_small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/night-vision-toggle-x24-white.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
		},
	})
end

if settings.startup["active-defense-equipment"].value == true then
	data:extend(
	{
		{
			type = "shortcut",
			name = "active-defense-equipment",
			order = "c[toggles]-f[active-defense-equipment]",
			action = "lua",
			localised_name = {"equipment-name.personal-laser-defense-equipment"},
			technology_to_unlock = "personal-laser-defense-equipment",
			toggleable = true,
			icon =
			{
				filename = "__Shortcuts-ick__/graphics/active-defense-equipment-x32.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 1,
				flags = {"icon"}
			},
			small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/active-defense-equipment-x24.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
			disabled_icon =
			{
				filename = "__Shortcuts-ick__/graphics/active-defense-equipment-x32-white.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 1,
				flags = {"icon"}
			},
			disabled_small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/active-defense-equipment-x24-white.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
		},
	})
end
