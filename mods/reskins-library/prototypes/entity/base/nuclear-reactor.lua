-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

if not (mods["angelsindustries"] or mods["bobpower"]) then
	return
end

local reactors = {
	"nuclear-reactor",
	"bob-nuclear-reactor-2",
	"bob-nuclear-reactor-3",
}

-- Fix lighting
for _, name in pairs(reactors) do
	local entity = data.raw.reactor[name]

	if not entity then
		goto continue
	end

	-- Lights
	entity.working_light_picture = {
		filename = "__reskins-library__/graphics/entity/base/nuclear-reactor/reactor-lights.png",
		blend_mode = "additive",
		draw_as_glow = true,
		width = 320,
		height = 320,
		scale = 0.5,
		shift = { -0.03125, -0.1875 },
	}

	-- Handle ambient-light
	entity.energy_source.light_flicker = {
		color = { 0, 0, 0 },
		minimum_light_size = 0,
		light_intensity_to_size_coefficient = 0,
	}

	entity.use_fuel_glow_color = true

	::continue::
end
