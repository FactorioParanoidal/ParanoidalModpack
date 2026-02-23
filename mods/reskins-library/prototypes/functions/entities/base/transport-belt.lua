-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

---Provides vanilla-style sprite definition for transport belt corpse `animation` field. See [Prototype/Corpse](https://wiki.factorio.com/Prototype/Corpse).
---@param tint table # [Types/Color](https://wiki.factorio.com/Types/Color)
---@return table animation # [Types/RotatedAnimationVariations](https://wiki.factorio.com/Types/RotatedAnimationVariations)
local function corpse_animation(tint)
	return make_rotated_animation_variations_from_sheet(2, {
		layers = {
			-- Base
			{
				filename = "__reskins-library__/graphics/entity/base/transport-belt/remnants/transport-belt-remnants-base.png",
				width = 106,
				height = 102,
				direction_count = 4,
				shift = util.by_pixel(1, -0.5),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-library__/graphics/entity/base/transport-belt/remnants/transport-belt-remnants-mask.png",
				width = 106,
				height = 102,
				direction_count = 4,
				tint = tint,
				shift = util.by_pixel(1, -0.5),
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-library__/graphics/entity/base/transport-belt/remnants/transport-belt-remnants-mask.png",
				width = 106,
				height = 102,
				direction_count = 4,
				blend_mode = reskins.lib.settings.blend_mode,
				shift = util.by_pixel(1, -0.5),
				scale = 0.5,
			},
		},
	})
end

---Reskins the named transport-belt with vanilla-style transport belt sprites and color masking, and sets up appropriate corpse, explosion, and particle prototypes
---@param name string # [Prototype name](https://wiki.factorio.com/PrototypeBase#name)
---@param tier integer # 1-6 are supported, 0 to disable
---@param tint? table # [Types/Color](https://wiki.factorio.com/Types/Color)
---@param make_tier_labels? boolean
---@param use_express_spritesheet? boolean
---@param reskin_vanilla_entity? boolean
function reskins.lib.apply_skin.transport_belt(name, tier, tint, make_tier_labels, use_express_spritesheet, reskin_vanilla_entity)
	---@type SetupStandardEntityInputs
	local inputs = {
		type = "transport-belt",
		icon_name = "transport-belt",
		base_entity_name = use_express_spritesheet and "express-transport-belt" or "transport-belt",
		mod = "lib",
		group = "base",
		particles = { ["medium"] = 1, ["small"] = 2 },
		tier_labels = make_tier_labels or false,
		tint = tint and tint or reskins.lib.tiers.get_belt_tint(tier),
	}

	---@type data.TransportBeltPrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		return
	end

	if reskin_vanilla_entity == false then
		reskins.lib.tiers.add_tier_labels_to_prototype_by_reference(tier, entity)
		return
	end

	reskins.lib.setup_standard_entity(name, tier, inputs)

	-- Fetch corpse
	local corpse = data.raw["corpse"][name .. "-remnants"]

	-- Reskin corpse
	corpse.animation = corpse_animation(inputs.tint)

	-- Reskin entity
	local belt_sprite = reskins.lib.defines.belt_sprites
	entity.belt_animation_set.animation_set = reskins.lib.sprites.belts.get_belt_animation_set(use_express_spritesheet and belt_sprite.express or belt_sprite.standard, inputs.tint).animation_set
end
