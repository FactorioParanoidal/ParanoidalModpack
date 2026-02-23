-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

if not (reskins.bobs and reskins.bobs.triggers.ores.entities) then
	return
end

local ores = {
	-- Pure Bob's
	-- ["gem-ore"] = { key = "bobs", subfolder = "ores" },
	["bob-lead-ore"] = { key = "lib", subfolder = "shared" }, -- 404040
	["bob-rutile-ore"] = { key = "bobs", subfolder = "ores" },
	["bob-sulfur"] = { key = "bobs", subfolder = "ores" },
	["bob-thorium-ore"] = { key = "bobs", subfolder = "ores", is_light = true },
	["bob-tin-ore"] = { key = "lib", subfolder = "shared", num_variations = 8 },

	-- Shared with Angel's
	["bob-bauxite-ore"] = { key = "lib", subfolder = "shared", num_variations = 8 },
	["bob-cobalt-ore"] = { key = "lib", subfolder = "shared" },
	["bob-gold-ore"] = { key = "lib", subfolder = "shared" },
	["bob-nickel-ore"] = { key = "lib", subfolder = "shared" }, -- 408073
	["bob-quartz"] = { key = "lib", subfolder = "shared" }, -- 999999
	["bob-silver-ore"] = { key = "lib", subfolder = "shared" },
	["bob-tungsten-ore"] = { key = "lib", subfolder = "shared", num_variations = 8 },
	["bob-zinc-ore"] = { key = "lib", subfolder = "shared" },
}

for name, params in pairs(ores) do
	local entity = data.raw["resource"][name]
	if not entity then
		goto continue
	end

	if name == "bob-sulfur" then
		reskins.lib.icons.assign_deferrable_icon({
			name = entity.name,
			type_name = entity.type,
			icon_datum = {
				icon = "__base__/graphics/icons/sulfur.png",
				icon_size = 64,
				scale = 0.5,
			},
		})
	else
		reskins.lib.icons.assign_deferrable_icon({
			name = entity.name,
			type_name = entity.type,
			icon_data = {
				{
					icon = reskins[params.key].directory .. "/graphics/icons/" .. params.subfolder .. "/ores/" .. name .. "/" .. name .. ".png",
					icon_size = 64,
					scale = 0.5,
				},
			},
			pictures = reskins.internal.create_sprite_variations(params.key, params.subfolder .. "/ores", name, params.num_variations or 4, params.is_light),
		})
	end

	entity.stages = {
		sheet = {
			filename = "__reskins-bobs__/graphics/entity/ores/" .. name .. "/" .. name .. ".png",
			priority = "extra-high",
			size = 128,
			frame_count = 8,
			variation_count = 8,
			scale = 0.5,
		},
	}

	-- Radioactive glow
	if name == "bob-thorium-ore" then
		entity.stages_effect = {
			sheet = {
				filename = "__reskins-bobs__/graphics/entity/ores/" .. name .. "/" .. name .. "-glow.png",
				priority = "extra-high",
				width = 128,
				height = 128,
				frame_count = 8,
				variation_count = 8,
				scale = 0.5,
				blend_mode = "additive",
				flags = { "light" },
			},
		}
	end

	::continue::
end
