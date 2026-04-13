-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Add this mod to the reskins function host.
if not reskins.angels then
	reskins.angels = {}
end
reskins.angels.directory = "__reskins-angels__"
reskins.angels.constants = {
	recipe_corner_shift = { -10, -10 },
	recipe_corner_scale = 0.4375,
}

-- Maybe we'll use this one day?...
local function copy_icon(destination_name, destination_type, source_name, source_type)
	-- Fetch source and destination pointers
	local source = data.raw[source_type]
	local destination = data.raw[destination_type]

	-- Validate pointers
	if not (source and destination) then
		return
	end

	-- Duplicate the icon
	if source.icons then
		destination.icons = util.copy(source.icons)
	elseif source.icon then
		destination.icon = util.copy(source.icon)
	else
		return -- Fundamentally broken source definitions
	end

	-- Copy root-level properties
	destination.icon_size = source.icon_size
end

-- Check to see if the new angels numbering function is available.
local function check_add_number_icon_layer_is_available()
	return angelsmods and angelsmods.functions.add_number_icon_layer({}, 1, util.get_color_with_alpha(util.color("#000000"), 1))
end

local number_function_is_valid = pcall(check_add_number_icon_layer_is_available)

---comment
---@param tier integer
---@param mod string # The key to a specific Angel's mod sub table in the `angelsmods` global, e.g. `"smelting"`.
---@return data.IconData[]
function reskins.angels.num_tier(tier, mod)
	-- Get the tint for the given mod; fallback to black if necessary
	local tint = angelsmods and angelsmods[mod] and angelsmods[mod].number_tint or util.color("#000000")

	local icons
	if number_function_is_valid then
		icons = angelsmods and angelsmods.functions.add_number_icon_layer({}, tier, util.get_color_with_alpha(tint, 1))

		-- Strip out the scaling and shifting
		for _, icon_data in pairs(icons) do
			icon_data.scale = nil
			icon_data.shift = nil
		end
	else
		icons = {
			{
				icon = "__reskins-angels__/graphics/icons/refining/numbers/num-" .. tier .. ".png",
				icon_size = 64,
				tint = util.get_color_with_alpha(tint, 1),
				shift = { -13, 0 },
			},
		}
	end

	return icons
end
