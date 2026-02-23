-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

---Boolean toggles to customize the type of assembling machine sprites used.
---Note that the `use_` flags are mutually exclusive, and if omitted the standard sprite set will be used.
---@class AssemblyMachineFlags
---@field is_small boolean? # When true, uses the sprites for a 2x2 tile footprint; otherwise, for a 3x3 tile footprint.
---@field lights integer? # An integer between 1 and 3, corresponding to the number of lights on the electronics assembling machine icon.
---@field sprite_set integer? # An integer between 0 and 5, corresponding to the tier of sprite set to use. If omitted, defaults to the tier.
---@field use_electronics_set boolean? # When true, uses the sprites for an electronics assembling machine.
---@field use_burner_set boolean? # When true, uses the sprites for a burner assembling machine.
---@field use_steam_set boolean? # When true, uses the sprites for a steam assembling machine.

---Prepares icon properties for the `inputs` table
---@param sprite_set integer # An integer between 0 and 5. Tier gear icon decoratives
---@param tint? data.Color
---@param flags AssemblyMachineFlags
---@return SetupStandardEntityInputs
local function icon_sets(sprite_set, tint, flags)
	---@type SetupStandardEntityInputs
	local inputs = {}

	if flags.use_electronics_set then
		-- Use the small assets
		inputs.icon_base = "mini-assembling-machine"
		inputs.icon_mask = inputs.icon_base
		inputs.icon_highlights = inputs.icon_base

		-- Add the indicator lights
		inputs.icon_extras = {
			{
				icon = "__reskins-bobs__/graphics/icons/assembly/assembling-machine/electronics-machine-" .. flags.lights .. ".png",
				icon_size = 64,
				scale = 0.5,
			},
		}

		inputs.icon_picture_extras = {
			{
				filename = "__reskins-bobs__/graphics/icons/assembly/assembling-machine/electronics-machine-" .. flags.lights .. ".png",
				flags = { "icon" },
				size = 64,
				mipmap_count = 4,
				scale = 0.5,
			},
		}
	elseif flags.use_burner_set then
		if flags.is_small then
			-- Use the small assets
			inputs.icon_base = "mini-assembling-machine"
			inputs.icon_mask = inputs.icon_base
			inputs.icon_highlights = inputs.icon_base

			-- Smoke stack
			inputs.icon_extras = {
				{
					icon = "__reskins-bobs__/graphics/icons/assembly/assembling-machine/small-smoke-stack.png",
					icon_size = 64,
					scale = 0.5,
				},
			}

			inputs.icon_picture_extras = {
				{
					filename = "__reskins-bobs__/graphics/icons/assembly/assembling-machine/smoke-stack.png",
					flags = { "icon" },
					size = 64,
					mipmap_count = 4,
					scale = 0.5,
				},
			}
		else
			-- Smoke stack
			inputs.icon_extras = {
				{
					icon = "__reskins-bobs__/graphics/icons/assembly/assembling-machine/smoke-stack.png",
					icon_size = 64,
					scale = 0.5,
				},
			}

			inputs.icon_picture_extras = {
				{
					filename = "__reskins-bobs__/graphics/icons/assembly/assembling-machine/smoke-stack.png",
					flags = { "icon" },
					size = 64,
					mipmap_count = 4,
					scale = 0.5,
				},
			}
		end
	elseif flags.use_steam_set then
		-- Smoke stack with pipe connection
		inputs.icon_extras = {
			{
				icon = "__reskins-bobs__/graphics/icons/assembly/assembling-machine/steam-smoke-stack-base.png",
				icon_size = 64,
				scale = 0.5,
			},
			{
				icon = "__reskins-bobs__/graphics/icons/assembly/assembling-machine/steam-smoke-stack-mask.png",
				icon_size = 64,
				scale = 0.5,
				tint = tint,
			},
			{
				icon = "__reskins-bobs__/graphics/icons/assembly/assembling-machine/steam-smoke-stack-highlights.png",
				icon_size = 64,
				scale = 0.5,
				tint = { 1, 1, 1, 0 },
			},
		}

		inputs.icon_picture_extras = {
			{
				filename = "__reskins-bobs__/graphics/icons/assembly/assembling-machine/steam-smoke-stack-base.png",
				flags = { "icon" },
				size = 64,
				mipmap_count = 4,
				scale = 0.5,
			},
			{
				filename = "__reskins-bobs__/graphics/icons/assembly/assembling-machine/steam-smoke-stack-mask.png",
				flags = { "icon" },
				size = 64,
				mipmap_count = 4,
				scale = 0.5,
				tint = tint,
			},
			{
				filename = "__reskins-bobs__/graphics/icons/assembly/assembling-machine/steam-smoke-stack-highlights.png",
				flags = { "icon" },
				size = 64,
				mipmap_count = 4,
				scale = 0.5,
				blend_mode = reskins.lib.settings.blend_mode,
			},
		}
	else
		if flags.is_small then
			-- Use the small assets
			inputs.icon_base = "mini-assembling-machine"
			inputs.icon_mask = inputs.icon_base
			inputs.icon_highlights = inputs.icon_base

			-- Add gears
			inputs.icon_extras = {
				{
					icon = "__reskins-bobs__/graphics/icons/assembly/assembling-machine/mini-gear-" .. sprite_set .. ".png",
					icon_size = 64,
					scale = 0.5,
				},
			}

			inputs.icon_picture_extras = {
				{
					filename = "__reskins-bobs__/graphics/icons/assembly/assembling-machine/mini-gear-" .. sprite_set .. ".png",
					flags = { "icon" },
					size = 64,
					mipmap_count = 4,
					scale = 0.5,
				},
			}
		else
			-- Add gears
			inputs.icon_extras = {
				{
					icon = "__reskins-bobs__/graphics/icons/assembly/assembling-machine/gear-" .. sprite_set .. ".png",
					icon_size = 64,
					scale = 0.5,
				},
			}

			inputs.icon_picture_extras = {
				{
					filename = "__reskins-bobs__/graphics/icons/assembly/assembling-machine/gear-" .. sprite_set .. ".png",
					flags = { "icon" },
					size = 64,
					mipmap_count = 4,
					scale = 0.5,
				},
			}
		end
	end

	return inputs
end

---Provides vanilla-style sprite definition for assembling machine corpse `animation` field. See [Prototype/Corpse](https://wiki.factorio.com/Prototype/Corpse).
---@param tint data.Color
---@return data.RotatedAnimation
local function corpse_animation(tint)
	return make_rotated_animation_variations_from_sheet(3, {
		layers = {
			-- Base
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/assembling-machine/remnants/assembling-machine-remnants-base.png",
				width = 328,
				height = 282,
				direction_count = 1,
				shift = util.by_pixel(0, 9.5),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/assembling-machine/remnants/assembling-machine-remnants-mask.png",
				width = 328,
				height = 282,
				direction_count = 1,
				shift = util.by_pixel(0, 9.5),
				tint = tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/assembling-machine/remnants/assembling-machine-remnants-highlights.png",
				width = 328,
				height = 282,
				direction_count = 1,
				shift = util.by_pixel(0, 9.5),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
		},
	})
end

---Provides vanilla-style sprite definition for assembling machine `animation` field. See [Prototype/AssemblingMachine](https://wiki.factorio.com/Prototype/AssemblingMachine).
---@param sprite_set integer # An integer between 0 and 5.
---@param tint data.Color
---@param flags any
---@return data.Animation
local function entity_animation(sprite_set, tint, flags)
	local shadow_sprite_set = (sprite_set >= 5) and 4 or sprite_set
	sprite_set = (sprite_set >= 5) and 5 or sprite_set

	---@type data.Animation
	local animation = {
		layers = {
			-- Base
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/assembling-machine/base/assembling-machine-base.png",
				priority = "high",
				width = 214,
				height = 237,
				repeat_count = 32,
				shift = util.by_pixel(0, -0.75),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/assembling-machine/base/assembling-machine-base-mask.png",
				priority = "high",
				width = 214,
				height = 237,
				repeat_count = 32,
				shift = util.by_pixel(0, -0.75),
				tint = tint,
				scale = 0.5,
			},
			-- Highlight
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/assembling-machine/base/assembling-machine-base-highlights.png",
				priority = "high",
				width = 214,
				height = 237,
				repeat_count = 32,
				shift = util.by_pixel(0, -0.75),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
			-- Animation
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/assembling-machine/animations/assembling-machine-animation-" .. sprite_set .. ".png",
				priority = "high",
				width = 214,
				height = 237,
				frame_count = 32,
				line_length = 8,
				shift = util.by_pixel(0, -0.75),
				scale = 0.5,
			},
			-- Shadow
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/assembling-machine/shadows/assembling-machine-" .. shadow_sprite_set .. "-shadow.png",
				priority = "high",
				width = 264,
				height = 165,
				frame_count = 32,
				line_length = 8,
				draw_as_shadow = true,
				shift = util.by_pixel(27, 5),
				scale = 0.5,
			},
		},
	}

	if flags.use_electronics_set then
		table.insert(
			animation.layers,
			-- Base
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/assembling-machine/electronics/electronics-base.png",
				priority = "high",
				width = 214,
				height = 237,
				repeat_count = 32,
				shift = util.by_pixel(0, -0.75),
				scale = 0.5,
			}
		)
		table.insert(
			animation.layers,
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/assembling-machine/electronics/electronics-mask.png",
				priority = "high",
				width = 214,
				height = 237,
				repeat_count = 32,
				shift = util.by_pixel(0, -0.75),
				tint = tint,
				scale = 0.5,
			}
		)
		table.insert(
			animation.layers,
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/assembling-machine/electronics/electronics-highlights.png",
				priority = "high",
				width = 214,
				height = 237,
				repeat_count = 32,
				shift = util.by_pixel(0, -0.75),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			}
		)
		table.insert(
			animation.layers,
			-- Shadow
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/assembling-machine/electronics/electronics-shadow.png",
				priority = "high",
				width = 264,
				height = 165,
				repeat_count = 32,
				draw_as_shadow = true,
				shift = util.by_pixel(27, 5),
				scale = 0.5,
			}
		)
	end

	return animation
end

---Reskins the named splitter with vanilla-style splitter sprites and color masking, and sets up appropriate corpse, explosion, and particle prototypes
---@param name data.EntityID
---@param tier integer # 1-6 are supported, 0 to disable
---@param tint? data.Color
---@param make_tier_labels? boolean
---@param flags? AssemblyMachineFlags
function reskins.lib.apply_skin.assembling_machine(name, tier, tint, make_tier_labels, flags)
	if not flags then
		flags = {}
	end

	---@type SetupStandardEntityInputs
	local inputs = util.merge({
		{
			type = "assembling-machine",
			icon_name = "assembling-machine",
			base_entity_name = "assembling-machine-1",
			mod = "bobs",
			group = "assembly",
			particles = { ["big"] = 1, ["medium"] = 2 },
			tier_labels = make_tier_labels,
			tint = tint and tint or reskins.lib.tiers.get_tint(tier),
		},
		icon_sets(flags.sprite_set or tier, tint, flags),
	})

	---@type data.AssemblingMachinePrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		return
	end

	reskins.lib.setup_standard_entity(name, tier, inputs)

	-- Fetch corpse
	local corpse = data.raw["corpse"][name .. "-remnants"]

	-- Reskin corpse
	corpse.animation = corpse_animation(inputs.tint)

	-- Reskin entity
	entity.graphics_set.animation = entity_animation(flags.sprite_set or tier, inputs.tint, flags)

	local draw_order_shift = (flags.use_electronics_set or flags.use_steam_set) and 6 or 3
	if entity.fluid_boxes then
		for _, fluid_box in pairs(entity.fluid_boxes) do
			if type(fluid_box) == "table" then
				fluid_box.pipe_picture = fluid_box.pipe_picture and reskins.bobs.assembly_pipe_pictures(inputs.tint)
				fluid_box.pipe_covers = fluid_box.pipe_covers and pipecoverspictures()
				fluid_box.secondary_draw_orders = { north = -1, east = draw_order_shift, south = draw_order_shift, west = draw_order_shift }
			end
		end
	end

	local fluid_box = entity.energy_source.fluid_box
	if fluid_box then
		fluid_box.pipe_picture = fluid_box.pipe_picture and reskins.bobs.assembly_pipe_pictures(inputs.tint)
		fluid_box.pipe_covers = fluid_box.pipe_covers and pipecoverspictures()
		fluid_box.secondary_draw_orders = { north = -1, east = draw_order_shift, south = draw_order_shift, west = draw_order_shift }
	end

	-- Handle sounds
	if tier > 3 then
		entity.working_sound.sound = {
			{
				filename = "__base__/sound/assembling-machine-t3-1.ogg",
				volume = 0.45,
			},
		}
	elseif tier > 1 then
		entity.working_sound.sound = {
			{
				filename = "__base__/sound/assembling-machine-t2-1.ogg",
				volume = 0.45,
			},
		}
	else
		entity.working_sound.sound = {
			{
				filename = "__base__/sound/assembling-machine-t1-1.ogg",
				volume = 0.5,
			},
		}
	end

	-- Rescale entity
	if flags.is_small then
		reskins.lib.prototypes.rescale_prototype(entity.graphics_set.animation, 2 / 3)
		reskins.lib.prototypes.rescale_remnants_of_prototype(entity, 2 / 3)
	end
end
