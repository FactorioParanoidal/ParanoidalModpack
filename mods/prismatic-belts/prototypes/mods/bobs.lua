-- Copyright (c) Kirazy
-- Part of Prismatic Belts
--
-- See LICENSE.md in the project directory for license information.

local api = require("prototypes.api")

if not mods["boblogistics"] then
	return
end

local tiers = {
	["bob-basic-"] = { tint = util.color("7d7d7dd1"), variant = api.defines.belt_sprites.standard, technology = "logistics-0" },
	["bob-turbo-"] = { tint = util.color("a510e5d1"), variant = api.defines.belt_sprites.fast, technology = "logistics-4" },
	["bob-ultimate-"] = { tint = util.color("16f263d1"), variant = api.defines.belt_sprites.fast, technology = "logistics-5" },
}

-- Compatibility with Artisanal Reskins 1.1.3+
if mods["reskins-library"] and not (reskins.bobs and (reskins.bobs.triggers.logistics.entities == false)) then
	-- Setup standard properties
	tiers["bob-basic-"].tier = 0
	tiers["bob-turbo-"].tier = 4
	tiers["bob-ultimate-"].tier = 5

	tiers["bob-basic-"].tint = reskins.lib.tiers.get_belt_tint(0)
	tiers["bob-turbo-"].tint = reskins.lib.tiers.get_belt_tint(4)
	tiers["bob-ultimate-"].tint = reskins.lib.tiers.get_belt_tint(5)

	-- Check for custom colors, update tint and tier information if so
	if reskins.lib.settings.get_value("reskins-lib-customize-tier-colors") then
		tiers[""] = {
			tint = reskins.lib.tiers.get_belt_tint(1),
			variant = api.defines.belt_sprites.standard,
			loader = "",
			tier = 1,
			technology = "logistics",
		}
		tiers["fast-"] = {
			tint = reskins.lib.tiers.get_belt_tint(2),
			variant = api.defines.belt_sprites.fast,
			loader = "fast-",
			tier = 2,
			technology = "logistics-2",
		}
		tiers["express-"] = {
			tint = reskins.lib.tiers.get_belt_tint(3),
			variant = api.defines.belt_sprites.fast,
			loader = "express-",
			tier = 3,
			technology = "logistics-3",
		}
	end
end

-- Setup all the entities to use the updated belt animation sets
for prefix, properties in pairs(tiers) do
	-- Fetch entities
	local entities = {
		belt = data.raw["transport-belt"][prefix .. "transport-belt"],
		splitter = data.raw["splitter"][prefix .. "splitter"],
		underground = data.raw["underground-belt"][prefix .. "underground-belt"],
		loader = data.raw["loader"][prefix .. "loader"],

		-- Miniloader
		miniloader = data.raw["loader-1x1"][prefix .. "miniloader-loader"],
		filter_miniloader = data.raw["loader-1x1"][prefix .. "filter-miniloader-loader"],

		-- Deadlock Stacking Beltboxes and Compact loaders
		deadlock_loader = data.raw["loader-1x1"][prefix .. "transport-belt-loader"],

		-- Loaders Modernized
		mdrn_loader = data.raw["loader-1x1"][prefix .. "mdrn-loader"],
		mdrn_loader_split = data.raw["loader-1x1"][prefix .. "mdrn-loader-split"],

		-- AAI Loaders
		aai_loader = data.raw["loader-1x1"]["aai-" .. prefix .. "loader"],
	}

	-- Reskin the belt item
	local belt_item = data.raw["item"][prefix .. "transport-belt"]
	if belt_item then
		-- Setup icons
		---@type data.IconData[]
		local icon_data = api.get_transport_belt_icon({
			mask_tint = properties.tint,
		})

		-- Append tier labels for reskins-library
		if mods["reskins-library"] and not (reskins.bobs and (reskins.bobs.triggers.logistics.entities == false)) then
			local do_labels = reskins.lib.settings.get_value("reskins-bobs-do-belt-entity-tier-labeling") == true

			---@type DeferrableIconData
			local deferrable_icon = {
				name = prefix .. "transport-belt",
				type_name = "transport-belt",
				icon_data = do_labels and reskins.lib.tiers.add_tier_labels_to_icons(properties.tier, icon_data) or icon_data,
				pictures = do_labels and reskins.lib.sprites.create_sprite_from_icons(icon_data, 1.0) or nil,
			}

			reskins.lib.icons.assign_deferrable_icon(deferrable_icon)
		else
			belt_item.icons = icon_data

			-- Update entity icon to match
			if entities.belt then
				entities.belt.icons = belt_item.icons
			end
		end
	end

	-- Reskin all related entity types
	for _, entity in pairs(entities) do
		if entity then
			entity.belt_animation_set = api.get_transport_belt_animation_set({
				mask_tint = properties.tint,
				tint_mask_as_overlay = true,
				variant = properties.variant,
			})
		end
	end

	-- Setup remnants
	if entities.belt then
		api.create_remnant(prefix .. "transport-belt", {
			mask_tint = properties.tint,
			tint_mask_as_overlay = true,
		})
	end

	-- Setup logistics technologies
	local technology = data.raw["technology"][properties.technology]

	if technology then
		technology.icons = api.get_transport_belt_technology_icon({
			mask_tint = properties.tint,
			tint_mask_as_overlay = true,
		})
	end
end
