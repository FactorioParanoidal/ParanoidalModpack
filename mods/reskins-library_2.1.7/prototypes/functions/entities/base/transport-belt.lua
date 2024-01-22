-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

---Provides vanilla-style sprite definition for transport belt corpse `animation` field. See [Prototype/Corpse](https://wiki.factorio.com/Prototype/Corpse).
---@param tint table # [Types/Color](https://wiki.factorio.com/Types/Color)
---@return table animation # [Types/RotatedAnimationVariations](https://wiki.factorio.com/Types/RotatedAnimationVariations)
local function corpse_animation(tint)
    return
        make_rotated_animation_variations_from_sheet(2, {
            layers = {
                -- Base
                {
                    filename = reskins.lib.directory .. "/graphics/entity/base/transport-belt/remnants/transport-belt-remnants-base.png",
                    line_length = 1,
                    width = 54,
                    height = 52,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 4,
                    shift = util.by_pixel(1, 0),
                    hr_version = {
                        filename = reskins.lib.directory .. "/graphics/entity/base/transport-belt/remnants/hr-transport-belt-remnants-base.png",
                        line_length = 1,
                        width = 106,
                        height = 102,
                        frame_count = 1,
                        variation_count = 1,
                        axially_symmetrical = false,
                        direction_count = 4,
                        shift = util.by_pixel(1, -0.5),
                        scale = 0.5,
                    },
                },
                -- Mask
                {
                    filename = reskins.lib.directory .. "/graphics/entity/base/transport-belt/remnants/transport-belt-remnants-mask.png",
                    line_length = 1,
                    width = 54,
                    height = 52,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 4,
                    tint = tint,
                    shift = util.by_pixel(1, 0),
                    hr_version = {
                        filename = reskins.lib.directory .. "/graphics/entity/base/transport-belt/remnants/hr-transport-belt-remnants-mask.png",
                        line_length = 1,
                        width = 106,
                        height = 102,
                        frame_count = 1,
                        variation_count = 1,
                        axially_symmetrical = false,
                        direction_count = 4,
                        tint = tint,
                        shift = util.by_pixel(1, -0.5),
                        scale = 0.5,
                    },
                },
                -- Highlights
                {
                    filename = reskins.lib.directory .. "/graphics/entity/base/transport-belt/remnants/transport-belt-remnants-mask.png",
                    line_length = 1,
                    width = 54,
                    height = 52,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 4,
                    blend_mode = reskins.lib.blend_mode,
                    shift = util.by_pixel(1, 0),
                    hr_version = {
                        filename = reskins.lib.directory .. "/graphics/entity/base/transport-belt/remnants/hr-transport-belt-remnants-mask.png",
                        line_length = 1,
                        width = 106,
                        height = 102,
                        frame_count = 1,
                        variation_count = 1,
                        axially_symmetrical = false,
                        direction_count = 4,
                        blend_mode = reskins.lib.blend_mode,
                        shift = util.by_pixel(1, -0.5),
                        scale = 0.5,
                    },
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
    ---@type inputs.setup_standard_entity
    local inputs = {
        type = "transport-belt",
        icon_name = "transport-belt",
        base_entity_name = use_express_spritesheet and "express-transport-belt" or "transport-belt",
        mod = "lib",
        group = "base",
        particles = { ["medium"] = 1,["small"] = 2 },
        tier_labels = make_tier_labels or false,
        tint = tint and tint or reskins.lib.belt_tint_index[tier],
    }

    local entity = data.raw[inputs.type][name]
    if not entity then return end

    if reskin_vanilla_entity == false then
        reskins.lib.add_tier_labels_to_entity(name, inputs.type, tier)
        return
    end

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Fetch corpse
    local corpse = data.raw["corpse"][name .. "-remnants"]

    -- Reskin corpse
    corpse.animation = corpse_animation(inputs.tint)

    -- Reskin entity
    entity.belt_animation_set.animation_set = reskins.lib.transport_belt_animation_set(inputs.tint, use_express_spritesheet and 2 or 1).animation_set
end
