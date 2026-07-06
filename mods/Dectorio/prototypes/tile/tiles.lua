-- tile/tiles

-- Some variables to reference base tiles
local base_dirt = data.raw["tile"]["dry-dirt"]
local base_stone_path = data.raw["tile"]["stone-path"]
local base_concrete = data.raw["tile"]["concrete"]
local base_hazard_left = data.raw["tile"]["hazard-concrete-left"]
local base_hazard_right = data.raw["tile"]["hazard-concrete-right"]
local base_refined_concrete = data.raw["tile"]["refined-concrete"]
local base_refined_hazard_left = data.raw["tile"]["refined-hazard-concrete-left"]
local base_refined_hazard_right = data.raw["tile"]["refined-hazard-concrete-right"]

-- Sort out the layers
local tile_layer = {
	gravel = 60,
	stone = 61,
	concrete = 62,
	paint = 63,
	-- 64 transition layer
	refined = 65,
	refined_paint = 66,
	-- 67 transition layer
	grid = 68,
	wood = 69
}

-- Return tile variants array for given set and variant
local function tile_variants(set, variant)
	return {
		main = {
			{
				picture = "__Dectorio__/graphics/terrain/" .. set .. "/" .. variant .. "/" .. set .. "1.png",
				count = 16,
				size = 1
			},
			{
				picture = "__Dectorio__/graphics/terrain/" .. set .. "/" .. variant .. "/" .. set .. "2.png",
				count = 4,
				size = 2,
				probability = 0.39
			},
			{
				picture = "__Dectorio__/graphics/terrain/" .. set .. "/" .. variant .. "/" .. set .. "4.png",
				count = 4,
				size = 4,
				probability = 1
			}
		},
		transition =
			{
				overlay_layout =
					{
					inner_corner = {
						spritesheet = "__Dectorio__/graphics/terrain/" .. set .. "/" .. variant .. "/" .. set .. "-inner-corner.png",
						count = 8
					},
					outer_corner = {
						spritesheet = "__Dectorio__/graphics/terrain/" .. set .. "/" .. variant .. "/" .. set .. "-outer-corner.png",
						count = 1
					},
					side = {
						spritesheet = "__Dectorio__/graphics/terrain/" .. set .. "/" .. variant .. "/" .. set .. "-side.png",
						count = 8
					},
					u_transition = {
						spritesheet = "__Dectorio__/graphics/terrain/" .. set .. "/" .. variant .. "/" .. set .. "-u.png",
						count = 8
					},
					o_transition = {
						spritesheet = "__Dectorio__/graphics/terrain/" .. set .. "/" .. variant .. "/" .. set .. "-o.png",
						count = 1
					}
				}
			}
	}
end

-- Return tile variants array for given set and variant
local function tile_variants_material(set, variant)
	return {
		main = base_concrete.variants.main,
		transition = {
			overlay_layout =
				{
					inner_corner = base_concrete.variants.transition.overlay_layout.inner_corner,
					outer_corner = base_concrete.variants.transition.overlay_layout.outer_corner,
					side = base_concrete.variants.transition.overlay_layout.side,
					u_transition = base_concrete.variants.transition.overlay_layout.u_transition,
					o_transition = base_concrete.variants.transition.overlay_layout.o_transition,
				}
		},
		material_background = {
			picture = "__Dectorio__/graphics/terrain/" .. set .. "/" .. variant .. "/" .. set .. ".png",
			count = 8,
			hr_version = {
				picture = "__Dectorio__/graphics/terrain/" .. set .. "/" .. variant .. "/hr-" .. set .. ".png",
				count = 8,
				scale = 0.5
			}
		}
	}
end

-- Modify decorations on base tiles
local decorative_removal_probability = DECT.CONFIG.SETTINGS["decorative_removal_probability"]
base_stone_path.decorative_removal_probability = decorative_removal_probability
base_concrete.decorative_removal_probability = decorative_removal_probability
base_hazard_left.decorative_removal_probability = decorative_removal_probability
base_hazard_right.decorative_removal_probability = decorative_removal_probability
base_refined_concrete.decorative_removal_probability = decorative_removal_probability
base_refined_hazard_left.decorative_removal_probability = decorative_removal_probability
base_refined_hazard_right.decorative_removal_probability = decorative_removal_probability

if DECT.ENABLED["landscaping"] then
	-- Make tiles unblueprintable
	local base_tiles = DECT.CONFIG.BASE_TILES
	for _, tile in pairs(base_tiles) do
		data.raw["tile"][tile].can_be_part_of_blueprint = DECT.CONFIG.SETTINGS["landscaping_blueprintable"]
	end
end

if DECT.ENABLED["wood-floor"] then
	data:extend(
		{
			{
				type = "tile",
				name = "dect-wood-floor",
				needs_correction = false,
				minable = {mining_time = 0.1, result = "dect-wood-floor"},
				mined_sound = {filename = "__Dectorio__/sound/deconstruct-wood.ogg"},
				collision_mask = {layers = {ground_tile = true}},
				walking_speed_modifier = 1.2,
				layer = tile_layer.wood,
				decorative_removal_probability = decorative_removal_probability,
				variants = tile_variants("wood", "boards"),
				walking_sound = {
					{filename = "__Dectorio__/sound/walking/wood-01.ogg", volume = 0.95},
					{filename = "__Dectorio__/sound/walking/wood-02.ogg", volume = 0.95},
					{filename = "__Dectorio__/sound/walking/wood-03.ogg", volume = 0.95},
					{filename = "__Dectorio__/sound/walking/wood-04.ogg", volume = 0.95}
				},
				map_color = {r = 139, g = 69, b = 19},
				vehicle_friction_modifier = base_stone_path.vehicle_friction_modifier
			}
		}
	)
end

if DECT.ENABLED["concrete"] then
	data:extend(
		{
			{
				type = "tile",
				name = "dect-concrete-grid",
				needs_correction = false,
				transition_merges_with_tile = "concrete",
				minable = {mining_time = 0.1, result = "dect-concrete-grid"},
				mined_sound = base_concrete.mined_sound,
				collision_mask = {layers = {ground_tile = true}},
				walking_speed_modifier = base_concrete.walking_speed_modifier,
				layer = tile_layer.grid,
				decorative_removal_probability = decorative_removal_probability,
				variants = tile_variants_material("concrete", "grid"),
				walking_sound = base_concrete.walking_sound,
				map_color = {r = 130, g = 130, b = 130},
				vehicle_friction_modifier = base_concrete.vehicle_friction_modifier
			}
		}
	)

-- Correct the offset so that concrete border is drawn on top of painted concrete
--base_concrete.transition_overlay_layer_offset = tile_layer.paint - tile_layer.concrete + 1
--base_refined_concrete.transition_overlay_layer_offset = tile_layer.refined_paint - tile_layer.refined + 1
end

if DECT.ENABLED["gravel"] then
	for _, variant in pairs(DECT.CONFIG.GRAVEL_VARIANTS) do
		data:extend(
			{
				{
					type = "tile",
					name = "dect-" .. variant.name .. "-gravel",
					needs_correction = false,
					minable = {mining_time = 0.1, result = variant.name},
					mined_sound = {filename = "__core__/sound/axe-mining-ore-3.ogg"},
					collision_mask = {layers = {ground_tile = true}},
					walking_speed_modifier = 1.1,
					layer = tile_layer.gravel,
					decorative_removal_probability = decorative_removal_probability,
					variants = tile_variants(variant.name, "gravel"),
					walking_sound = base_dirt.walking_sound,
					map_color = variant.color,
					vehicle_friction_modifier = dirt_vehicle_speed_modifier
				}
			}
		)
	end

	-- Move stone path up a layer so it sits atop gravel
	base_stone_path.layer = tile_layer.stone
end

if DECT.ENABLED["painted-concrete"] then
	local set_modifier = DECT.CONFIG.SETTINGS["painted_concrete_speed_modifier"]

	local directions = {
		{this = "left", next = "right"},
		{this = "right", next = "left"}
	}
	for _, variant in pairs(DECT.CONFIG.PAINT_VARIANTS) do
		for _, direction in pairs(directions) do
			-- Normal variant
			data:extend(
				{
					{
						type = "tile",
						name = "dect-paint-" .. variant.name .. "-" .. direction.this,
						needs_correction = false,
						next_direction = "dect-paint-" .. variant.name .. "-" .. direction.next,
						transition_merges_with_tile = "concrete",
						minable = {mining_time = 0.1, result = "dect-paint-" .. variant.name},
						mined_sound = base_concrete.mined_sound,
						collision_mask = {layers = {ground_tile = true}},
						walking_speed_modifier = base_concrete.walking_speed_modifier * set_modifier,
						layer = tile_layer.paint,
						decorative_removal_probability = decorative_removal_probability,
						variants = tile_variants_material("concrete", variant.name .. "-" .. direction.this),
						walking_sound = base_concrete.walking_sound,
						map_color = variant.color,
						vehicle_friction_modifier = base_concrete.vehicle_friction_modifier * set_modifier
					}
				}
			)

			-- Refined variant
			data:extend(
				{
					{
						type = "tile",
						name = "dect-paint-refined-" .. variant.name .. "-" .. direction.this,
						needs_correction = false,
						next_direction = "dect-paint-refined-" .. variant.name .. "-" .. direction.next,
						transition_merges_with_tile = "refined-concrete",
						minable = {mining_time = 0.1, result = "dect-paint-refined-" .. variant.name},
						mined_sound = base_refined_concrete.mined_sound,
						collision_mask = {layers = {ground_tile = true}},
						walking_speed_modifier = base_refined_concrete.walking_speed_modifier * set_modifier,
						layer = tile_layer.refined_paint,
						decorative_removal_probability = decorative_removal_probability,
						variants = tile_variants_material("refined-concrete", variant.name .. "-" .. direction.this),
						walking_sound = base_refined_concrete.walking_sound,
						map_color = variant.color,
						vehicle_friction_modifier = base_refined_concrete.vehicle_friction_modifier * set_modifier
					}
				}
			)
		end
	end

	-- Make base colored refined concrete minable and adjust some properties to align them with others
	for _, color in pairs(DECT.CONFIG.BASE_COLORS) do
		local concrete = data.raw.tile[color.name .. "-refined-concrete"]
		concrete.minable = {mining_time = 0.1, result = "dect-" .. color.name .. "-refined-concrete"}
		concrete.walking_speed_modifier = base_refined_concrete.walking_speed_modifier * set_modifier
		concrete.layer = tile_layer.refined_paint
		concrete.decorative_removal_probability = decorative_removal_probability
		concrete.vehicle_friction_modifier = base_refined_concrete.vehicle_friction_modifier * set_modifier
	end

	-- Adjust walking speeds on base hazard tiles
	base_hazard_left.walking_speed_modifier = base_concrete.walking_speed_modifier * set_modifier
	base_hazard_left.vehicle_friction_modifier = base_concrete.vehicle_friction_modifier * set_modifier
	base_hazard_right.walking_speed_modifier = base_concrete.walking_speed_modifier * set_modifier
	base_hazard_right.vehicle_friction_modifier = base_concrete.vehicle_friction_modifier * set_modifier
	base_refined_hazard_left.walking_speed_modifier = base_refined_concrete.walking_speed_modifier * set_modifier
	base_refined_hazard_left.vehicle_friction_modifier = base_refined_concrete.vehicle_friction_modifier * set_modifier
	base_refined_hazard_right.walking_speed_modifier = base_refined_concrete.walking_speed_modifier * set_modifier
	base_refined_hazard_right.vehicle_friction_modifier = base_refined_concrete.vehicle_friction_modifier * set_modifier

	-- Move all the base concretes up a layer so it sits atop stone path
	base_concrete.layer = tile_layer.concrete
	base_hazard_left.layer = tile_layer.paint
	base_hazard_right.layer = tile_layer.paint
	base_refined_concrete.layer = tile_layer.refined
	base_refined_hazard_left.layer = tile_layer.refined_paint
	base_refined_hazard_right.layer = tile_layer.refined_paint

	-- Use the Dectorio look and feel for Hazard concrete
	if not DECT.CONFIG.SETTINGS["vanilla_hazard_concrete"] then
		base_hazard_left.variants = tile_variants_material("concrete", "hazard-left")
		base_hazard_right.variants = tile_variants_material("concrete", "hazard-right")
		base_refined_hazard_left.variants = tile_variants_material("refined-concrete", "hazard-left")
		base_refined_hazard_right.variants = tile_variants_material("refined-concrete", "hazard-right")
	end
end
