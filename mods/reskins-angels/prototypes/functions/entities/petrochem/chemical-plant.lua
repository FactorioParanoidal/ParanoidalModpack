-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

---Provides angel-style sprite definition for chemical plant `animation` field. See [Prototype/AssemblingMachine](https://wiki.factorio.com/Prototype/AssemblingMachine).
---@param tint data.Color
---@return data.Animation4Way
local function entity_animation(tint)
	return {
		layers = {
			-- Base
			{
				filename = "__angelspetrochemgraphics__/graphics/entity/chemical-plant/chemical-plant.png",
				priority = "extra-high",
				width = 160,
				height = 160,
				shift = { 0, 0 },
			},
			-- Mask
			{
				filename = "__reskins-angels__/graphics/entity/petrochem/chemical-plant/chemical-plant-mask.png",
				priority = "extra-high",
				width = 160,
				height = 160,
				shift = { 0, 0 },
				tint = tint,
			},
			-- Highlights
			{
				filename = "__reskins-angels__/graphics/entity/petrochem/chemical-plant/chemical-plant-highlights.png",
				priority = "extra-high",
				width = 160,
				height = 160,
				shift = { 0, 0 },
				blend_mode = reskins.lib.settings.blend_mode,
			},
		},
	}
end

---Reskins the named assembling machine with angel-style chemical plant sprites and color masking, and sets up appropriate corpse, explosion, and particle prototypes
---@param name data.EntityID
---@param tier integer # 1-6 are supported, 0 to disable
---@param tint? data.Color
---@param make_tier_labels? boolean
function reskins.lib.apply_skin.angels_chemical_plant(name, tier, tint, make_tier_labels)
	---@type SetupStandardEntityInputs
	local inputs = {
		type = "assembling-machine",
		icon_name = "chemical-plant",
		base_entity_name = "assembling-machine-1",
		mod = "angels",
		group = "petrochem",
		particles = { ["big"] = 1, ["medium"] = 2 },
		tier_labels = make_tier_labels,
		tint = tint and tint or reskins.lib.tiers.get_tint(tier),
		make_remnants = false,
	}

	---@type data.AssemblingMachinePrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		return
	end

	reskins.lib.setup_standard_entity(name, tier, inputs)

	-- Reskin entity
	entity.graphics_set.animation = entity_animation(inputs.tint)
end
