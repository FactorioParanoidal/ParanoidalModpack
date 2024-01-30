-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

---Provides angel-style sprite definition for chemical plant `animation` field. See [Prototype/AssemblingMachine](https://wiki.factorio.com/Prototype/AssemblingMachine).
---@param tint table # [Types/Color](https://wiki.factorio.com/Types/Color)
---@return table animation # [Types/Animation4Way](https://wiki.factorio.com/Types/Animation4Way)
local function entity_animation(tint)
    return
    {
        layers = {
            -- Base
            {
                filename = "__angelspetrochem__/graphics/entity/chemical-plant/chemical-plant.png",
                priority = "extra-high",
                width = 160,
                height = 160,
                shift = {0, 0}
            },
            -- Mask
            {
                filename = reskins.angels.directory.."/graphics/entity/petrochem/chemical-plant/chemical-plant-mask.png",
                priority = "extra-high",
                width = 160,
                height = 160,
                shift = {0, 0},
                tint = tint,
            },
            -- Highlights
            {
                filename = reskins.angels.directory.."/graphics/entity/petrochem/chemical-plant/chemical-plant-highlights.png",
                priority = "extra-high",
                width = 160,
                height = 160,
                shift = {0, 0},
                blend_mode = reskins.lib.blend_mode,
            },
        }
    }
end

---Reskins the named assembling machine with angel-style chemical plant sprites and color masking, and sets up appropriate corpse, explosion, and particle prototypes
---@param name string # [Prototype name](https://wiki.factorio.com/PrototypeBase#name)
---@param tier integer # 1-6 are supported, 0 to disable
---@param tint? table # [Types/Color](https://wiki.factorio.com/Types/Color)
---@param make_tier_labels? boolean
function reskins.lib.apply_skin.angels_chemical_plant(name, tier, tint, make_tier_labels)
    ---@type inputs.setup_standard_entity
    local inputs = {
        type = "assembling-machine",
        icon_name = "chemical-plant",
        base_entity_name = "assembling-machine-1",
        mod = "angels",
        group = "petrochem",
        particles = {["big"] = 1, ["medium"] = 2},
        tier_labels = make_tier_labels,
        tint = tint and tint or reskins.lib.tint_index[tier],
        make_remnants = false,
    }

    local entity = data.raw[inputs.type][name]
    if not entity then return end

    -- angelspetrochem at this version or earlier does icon work in data-final-fixes
    if reskins.lib.migration.is_version_or_older(mods["angelspetrochem"], "0.9.19") and (name == "chemical-plant") then
        inputs.defer_to_data_final_fixes = true
    end

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Reskin entity
    entity.animation = entity_animation(inputs.tint)
end