-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["aai-loaders"] then
	return
end

local loaders = {
	["aai-basic-loader"] = { tier = 0 },
	["aai-loader"] = { tier = 1 },
	["aai-fast-loader"] = { tier = 2 },
	["aai-express-loader"] = { tier = 3 },
	["aai-turbo-loader"] = { tier = 4 },
	["aai-ultimate-loader"] = { tier = 5 },
}

local function aai_blend_tint()
	local blend = 0.25
	return { blend, blend, blend, 0 }
end

---@param structure_direction data.Sprite4Way
---@param tint data.Color
local function patch_sheet_tint(structure_direction, tint)
	local highlight_patch_sheet = nil
	if structure_direction.sheets then
		for _, sheet in pairs(structure_direction.sheets) do
			if sheet.filename and sheet.filename:find("_tint.png") then
				highlight_patch_sheet = util.copy(sheet)
				sheet.tint = tint
			end
		end

		-- Add an analogue of the highlights layer to help soften the saturation
		-- and better align with Artisanal Reskins color handling.
		if highlight_patch_sheet then
			highlight_patch_sheet.tint = aai_blend_tint()
			highlight_patch_sheet.blend_mode = "additive-soft"
			table.insert(structure_direction.sheets, highlight_patch_sheet)
		end
	end
end

---@param icons data.IconData[]
---@param tint data.Color
local function patch_icons_tint(icons, tint)
	local highlight_patch_layer = nil
	for _, layer in pairs(icons) do
		if layer.icon and layer.icon:find("_mask") then
			highlight_patch_layer = util.copy(layer)
			layer.tint = tint
		end
	end

	-- Add an analogue of the highlights layer to help soften the saturation
	-- and better align with Artisanal Reskins color handling.
	if highlight_patch_layer then
		highlight_patch_layer.tint = aai_blend_tint()
		table.insert(icons, highlight_patch_layer)
	end
end

for name, map in pairs(loaders) do
	-- AAI Loaders sets the icon only on the entity.
	local loader = data.raw["loader-1x1"][name]
	if not loader then
		goto continue
	end

	local tint = reskins.lib.tiers.get_belt_tint(map.tier)

	if reskins.bobs and (reskins.bobs.triggers.logistics.entities == true) then
		if loader.structure then
			patch_sheet_tint(loader.structure.direction_in, tint)
			patch_sheet_tint(loader.structure.direction_out, tint)
		end

		if loader.icons then
			-- Use deferrable_icon workflow to ensure icons are properly updated on the loader and related prototypes.
			local icon = reskins.lib.icons.get_icon_from_prototype_by_reference(loader)
			patch_icons_tint(icon, tint)

			local icon_with_tier = reskins.lib.tiers.add_tier_labels_to_icons(map.tier, icon)

			---@type DeferrableIconData
			local deferrable_icon = {
				name = loader.name,
				type_name = loader.type,
				icon_data = icon_with_tier,
				pictures = reskins.lib.sprites.create_sprite_from_icons(icon),
			}

			reskins.lib.icons.assign_deferrable_icon(deferrable_icon)
		end
	end

	local technology = data.raw["technology"][name]
	if reskins.bobs and (reskins.bobs.triggers.logistics.technologies == true) then
		if technology and technology.icons then
			patch_icons_tint(technology.icons, tint)
		end
	end

	::continue::
end
