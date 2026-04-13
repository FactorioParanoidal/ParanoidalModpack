-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

---Provides vanilla-style sprite definition for oil refinery `animation` field. See [Prototype/AssemblingMachine](https://wiki.factorio.com/Prototype/AssemblingMachine).
---@param tint data.Color
---@return table animation # [Types/Animation4Way](https://wiki.factorio.com/Types/Animation4Way)
local function entity_animation(tint)
	return reskins.lib.sprites.make_4way_animation_from_spritesheet({
		layers = {
			-- Base
			{
				filename = "__base__/graphics/entity/oil-refinery/oil-refinery.png",
				width = 386,
				height = 430,
				shift = util.by_pixel(0, -7.5),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-library__/graphics/entity/base/oil-refinery/oil-refinery-mask.png",
				width = 386,
				height = 430,
				shift = util.by_pixel(0, -7.5),
				tint = tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-library__/graphics/entity/base/oil-refinery/oil-refinery-highlights.png",
				width = 386,
				height = 430,
				shift = util.by_pixel(0, -7.5),
				blend_mode = reskins.lib.settings.blend_mode,
				scale = 0.5,
			},
			-- Shadow
			{
				filename = "__base__/graphics/entity/oil-refinery/oil-refinery-shadow.png",
				width = 674,
				height = 426,
				shift = util.by_pixel(82.5, 26.5),
				draw_as_shadow = true,
				scale = 0.5,
			},
		},
	})
end

---Provides vanilla-style sprite definition for oil refinery corpse `animation` field. See [Prototype/Corpse](https://wiki.factorio.com/Prototype/Corpse).
---@param tint data.Color
---@return data.RotatedAnimationVariations
local function corpse_animation(tint)
	---@type data.RotatedAnimation
	local animation = {
		layers = {
			-- Base
			{
				filename = "__base__/graphics/entity/oil-refinery/remnants/refinery-remnants.png",
				width = 467,
				height = 415,
				direction_count = 1,
				shift = util.by_pixel(-0.25, -0.25), --moved from -8.5 to -4.5
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-library__/graphics/entity/base/oil-refinery/remnants/refinery-remnants-mask.png",
				width = 467,
				height = 415,
				direction_count = 1,
				shift = util.by_pixel(-0.25, -0.25),
				tint = tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-library__/graphics/entity/base/oil-refinery/remnants/refinery-remnants-highlights.png",
				width = 467,
				height = 415,
				direction_count = 1,
				shift = util.by_pixel(-0.25, -0.25),
				blend_mode = reskins.lib.settings.blend_mode,
				scale = 0.5,
			},
		},
	}

	return make_rotated_animation_variations_from_sheet(1, animation)
end

---Reskins the named assembling machine with vanilla-style oil refinery sprites and color masking, and sets up appropriate corpse, explosion, and particle prototypes
---@param name string # [Prototype name](https://wiki.factorio.com/PrototypeBase#name)
---@param tier integer # 1-6 are supported, 0 to disable
---@param tint? data.Color
---@param make_tier_labels? boolean
function reskins.lib.apply_skin.oil_refinery(name, tier, tint, make_tier_labels)
	---@type SetupStandardEntityInputs
	local inputs = {
		type = "assembling-machine",
		icon_name = "oil-refinery",
		base_entity_name = "oil-refinery",
		mod = "lib",
		group = "base",
		particles = { ["big-tint"] = 5, ["medium"] = 2 },
		tier_labels = make_tier_labels,
		tint = tint and tint or reskins.lib.tiers.get_tint(tier),
	}

	---@type data.AssemblingMachinePrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		return
	end

	inputs.defer_to_data_updates = true -- angelspetrochem > 0.9.19 modifies icon in data-updates

	reskins.lib.setup_standard_entity(name, tier, inputs)

	-- Fetch corpse
	local corpse = data.raw["corpse"][name .. "-remnants"]

	-- Reskin corpse
	corpse.animation = corpse_animation(inputs.tint)

	-- Reskin entity
	entity.graphics_set.animation = entity_animation(inputs.tint)
end
