-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

-- Make our function host
if not reskins then reskins = {} end
if not reskins.lib then reskins.lib = {} end

-- Library directory
reskins.lib.directory = "__reskins-library__"

-- Setup reskin logging TODO: Actually log things...
reskins.lib.status = {}

-- Setup migration module
---@diagnostic disable-next-line: different-requires
reskins.lib.migration = require("migration")

---Validates startup settings and returns their value
---@param name string
---@return any setting.value
function reskins.lib.setting(name)
    local startup_setting
    if settings.startup[name] then
        startup_setting = settings.startup[name].value
    else
        startup_setting = nil
    end

    return startup_setting
end

---@alias mod_settings
---| '"angelsaddons-cab"'
---| '"angelsaddons-mobility"'
---| '"angelsaddons-storage"'
---| '"angelsbioprocessing"'
---| '"angelsexploration"'
---| '"angelsindustries"'
---| '"angelspetrochem"'
---| '"angelsrefining"'
---| '"angelssmelting"'
---| '"bobassembly"'
---| '"bobelectronics"'
---| '"bobenemies"'
---| '"bobequipment"'
---| '"bobgreenhouse"'
---| '"boblogistics"'
---| '"bobmining"'
---| '"bobmodules"'
---| '"bobores"'
---| '"bobplates"'
---| '"bobpower"'
---| '"bobrevamp"'
---| '"bobtech"'
---| '"bobvehicleequipment"'
---| '"bobwarfare"'

---@alias reskin_mods
---| '"angels"'
---| '"bobs"'
---| '"lib"'
---| '"compatibility"'

---@alias sprite_scopes
---| '"entities"'
---| '"equipment"'
---| '"items-and-fluids"'
---| '"technologies"'

---Checks to see if the reskin-toggle is enabled for a given setting, and if it is, checks if the given scope is also enabled.
---Returns true if both are true, returns false if one is false, and nil otherwise.
---@param scope sprite_scopes
---@param mod reskin_mods
---@param setting mod_settings
---@return boolean|nil
function reskins.lib.check_scope(scope, mod, setting)
    if reskins.lib.setting("reskins-"..mod.."-do-"..setting) == true then
        if reskins.lib.setting("reskins-lib-scope-"..scope) == true then
            return true
        else
            return false
        end
    elseif reskins.lib.setting("reskins-"..mod.."-do-"..setting) == false then
        return false
    else
        return nil
    end
end

-- Setup pack function hosts and import triggers
if mods["reskins-angels"] then
    reskins.angels = {
    triggers = require("__reskins-angels__/prototypes/functions/triggers")
}
end

if mods["reskins-bobs"] then
    reskins.bobs = {
    triggers = require("__reskins-bobs__/prototypes/functions/triggers")
}
end

if mods["reskins-compatibility"] then
    reskins.compatibility = {
        triggers = require("__reskins-compatibility__/prototypes/functions/triggers")
    }
end


-- Fetch blend mode, default `"additive"`. May be overridden in `settings-updates.lua` by uncommenting the line.
---@type string
reskins.lib.blend_mode = reskins.lib.setting("reskins-lib-blend-mode")

---@class inputs.setup_standard_entity : inputs.parse_inputs, inputs.create_explosions_and_particles, inputs.create_remnant, inputs.construct_icons

---Most entities have a common process for reskinning, so consolidate the other functions under one superfunction for ease of use
---@param name string # [Prototype name](https://wiki.factorio.com/PrototypeBase#name)
---@param tier integer # 1-6 are supported, 0 to disable
---@param inputs inputs.setup_standard_entity
function reskins.lib.setup_standard_entity(name, tier, inputs)
    -- Parse inputs
    reskins.lib.parse_inputs(inputs)

    -- Create particles and explosions
    if inputs.make_explosions then
        reskins.lib.create_explosions_and_particles(name, inputs)
    end

    -- Create remnants
    if inputs.make_remnants then
        reskins.lib.create_remnant(name, inputs)
    end

    -- Create icons
    if inputs.make_icons then
        reskins.lib.construct_icon(name, tier, inputs)
    end
end

---@class inputs.parse_inputs
---@field icon_size? integer # Default 64
---@field icon_mipmaps? integer # Default 4
---@field technology_icon_size? integer # Default 128
---@field technology_icon_mipmaps? integer # Default 1
---@field make_explosions? boolean # Default true, create explosions in `standard_setup_entity`
---@field make_remnants? boolean # Default true, create corpses in `standard_setup_entity`
---@field make_icons? boolean # Default true, create icons in `standard_setup_entity`
---@field tier_labels? boolean # Default true, displays tier labels on icons
---@field make_icon_pictures? boolean # Default true

---Sets the default parameters on the standard inputs table if not already set
---@param inputs inputs.parse_inputs
---@return inputs.parse_inputs inputs @
---```
--- inputs = {
---     icon_size integer -- Default 64
---     icon_mipmaps integer -- Default 4
---     technology_icon_size integer -- Default 128
---     technology_icon_mipmaps integer -- Default 1
---     make_explosions boolean -- Default true, create explosions in `standard_setup_entity`
---     make_remnants boolean -- Default true, create corpses in `standard_setup_entity`
---     make_icons boolean -- Default true, create icons in `standard_setup_entity`
---     tier_labels boolean -- Default true, displays tier labels on icons
---     make_icon_pictures boolean -- Default true
---     ...
--- }
---```
function reskins.lib.parse_inputs(inputs)
    inputs.icon_size = inputs.icon_size or 64 -- Pixel size of icons
    inputs.icon_mipmaps = inputs.icon_mipmaps or 4 -- Number of mipmaps present in the icon image file
    inputs.technology_icon_size = inputs.technology_icon_size or 128 -- Pixel size of technology icons
    inputs.technology_icon_mipmaps = inputs.technology_icon_mipmaps or 1 -- Number of mipmaps present in the technology icon image file
    inputs.make_explosions = (inputs.make_explosions ~= false) -- Create explosions; default true
    inputs.make_remnants = (inputs.make_remnants ~= false) -- Create remnant; default true
    inputs.make_icons = (inputs.make_icons ~= false) -- Create icons; default true
    inputs.tier_labels = (inputs.tier_labels ~= false) -- Display tier labels; default true
    inputs.make_icon_pictures = (inputs.make_icon_pictures ~= false) -- Define the pictures icon field when possible

    return inputs
end

---@class inputs.assign_order
---@field type? string # [Prototype](https://wiki.factorio.com/Prototype_definitions)
---@field sort_order? string # [Types/Order](https://wiki.factorio.com/Types/Order)
---@field sort_group? string # Unclear; may be deprecated or unused in Factorio
---@field sort_subgroup? string # The name of the subgroup this entity should be sorted into in the map editor building selection

---Assigns a consistent `order` property to a given entity prototype and the associated items, explosions, and remnants if they exist
---@param name string
---@param inputs inputs.assign_order
function reskins.lib.assign_order(name, inputs)
    -- Initialize paths
    local entity
    if inputs.type then
        entity = data.raw[inputs.type][name]
    end
    local item = data.raw["item"][name]
    local explosion = data.raw["explosion"][name.."-explosion"]
    local remnant = data.raw["corpse"][name.."-remnants"]

    if entity then
        entity.order = inputs.sort_order
        entity.group = inputs.sort_group
        entity.subgroup = inputs.sort_subgroup
    end

    if item then
        item.order = inputs.sort_order
        item.group = inputs.sort_group
        item.subgroup = inputs.sort_subgroup
    end

    if explosion then
        explosion.order = inputs.sort_order
        explosion.group = inputs.sort_group
        explosion.subgroup = inputs.sort_subgroup
    end

    if remnant then
        remnant.order = inputs.sort_order
        remnant.group = inputs.sort_group
        remnant.subgroup = inputs.sort_subgroup
    end
end

---@class inputs.create_remnant
---@field base_entity_name string # Name of Factorio reference entity to copy from, e.g. `stone-furnace`
---@field type string # [Prototype](https://wiki.factorio.com/Prototype_definitions)

---@class remnant # See [Prototype/Corpse](https://wiki.factorio.com/Prototype/Corpse)

---Copies the Factorio corpse specified by `inputs.base_entity_name`, extends `data` with a new
---corpse with the name `[name]-remnants`, and assigns it to the named entity
---@param name string
---@param inputs inputs.create_remnant
---```
--- inputs = {
---     base_entity_name = string -- Name of Factorio reference entity to copy from, e.g. `stone-furnace`
---     type = string -- See https://wiki.factorio.com/Prototype_definitions
--- }
---```
function reskins.lib.create_remnant(name, inputs)
    ---@type remnant
    local remnant = util.copy(data.raw["corpse"][inputs.base_entity_name.."-remnants"])
    remnant.name = name.."-remnants"
    data:extend({remnant})

    -- Assign corpse to originating entity
    data.raw[inputs.type][name]["corpse"] = remnant.name
end

---@class inputs.create_explosion : inputs.create_remnant

---Copies the Factorio explosion specified by `inputs.base_entity_name`, extends `data` with a new
---explosion with the name `[name]-explosion`, and assigns it to the named entity
---@param name string
---@param inputs inputs.create_explosion
---```
--- inputs = {
---     base_entity_name = string -- Name of Factorio reference entity to copy from, e.g. `stone-furnace`
---     type = string -- See https://wiki.factorio.com/Prototype_definitions
--- }
---```
function reskins.lib.create_explosion(name, inputs)
    local explosion = util.copy(data.raw["explosion"][inputs.base_entity_name.."-explosion"])
    explosion.name = name.."-explosion"
    data:extend({explosion})

    -- Assign explosion to originating entity
    data.raw[inputs.type][name]["dying_explosion"] = explosion.name
end

---Copies the Factorio particle specified by `base_entity_name`, applies tints, extends `data`
---with a new particle with the name `[name]-[base-particle-name]-tinted`, and assigns it to the named explosion
---@param name string # [Prototype name](https://wiki.factorio.com/PrototypeBase#name)
---@param base_entity_name string # Name of Factorio reference entity to copy from, e.g. `stone-furnace`
---@param base_particle_name string # Key for `reskins.lib.particle_index`
---@param key integer # Index corresponding to the particle within the `explosion` prototype
---@param tint table # [Types/Color](https://wiki.factorio.com/Types/Color)
function reskins.lib.create_particle(name, base_entity_name, base_particle_name, key, tint)
    local particle = util.copy(data.raw["optimized-particle"][base_entity_name.."-"..base_particle_name])
    particle.name = name.."-"..base_particle_name.."-tinted"
    particle.pictures.sheet.tint = tint
    particle.pictures.sheet.hr_version.tint = tint
    data:extend({particle})

    -- Assign particle to originating explosion
    data.raw["explosion"][name.."-explosion"]["created_effect"]["action_delivery"]["target_effects"][key].particle_name = particle.name
end

---@class inputs.create_explosions_and_particles : inputs.create_explosion
---@field particles? table # Table of keys for `reskins.lib.particle_index` and the target index within the explosion particle table to copy
---@field tint table # [Types/Color](https://wiki.factorio.com/Types/Color)

---Batches the `create_explosion` and `create_particle` function together for ease of use
---@param name string # [Prototype name](https://wiki.factorio.com/PrototypeBase#name)
---@param inputs inputs.create_explosions_and_particles @
---```
--- inputs = {
---     base_entity_name = string -- Name of Factorio reference entity to copy from, e.g. `stone-furnace`
---     type = string -- See https://wiki.factorio.com/Prototype_definitions
---     tint = table -- See https://wiki.factorio.com/Types/Color
---     particles? = {
---         [string] = integer, -- reskins.lib.particle_index key, and associated target particle index
---         ...
---     }
--- }
---```
function reskins.lib.create_explosions_and_particles(name, inputs)
    reskins.lib.create_explosion(name, inputs)

    if inputs.particles then
        for particle, key in pairs(inputs.particles) do
            -- Create and assign the particle
            reskins.lib.create_particle(name, inputs.base_entity_name, reskins.lib.particle_index[particle], key, inputs.tint)
        end
    end
end

reskins.lib.particle_index = {
    ["tiny-stone"] = "stone-particle-tiny",
    ["small"] = "metal-particle-small",
    ["small-stone"] = "stone-particle-small",
    ["medium"] = "metal-particle-medium",
    ["medium-long"] = "long-metal-particle-medium",
    ["medium-stone"] = "stone-particle-medium",
    ["big"] = "metal-particle-big",
    ["big-stone"] = "stone-particle-big",
    ["big-tint"] = "metal-particle-big-tint",
}

function reskins.lib.make_4way_animation_from_spritesheet(animation)
    local function make_animation_layer(idx, anim)
        local start_frame = (anim.frame_count or 1) * idx
        local x = 0
        local y = 0
        if anim.vertically_oriented then
            if anim.line_length then
                y = idx * anim.height * math.floor(start_frame / (anim.line_length or 1))
            else
                y = idx * anim.height
            end
        else
            if anim.line_length then
                y = anim.height * math.floor(start_frame / (anim.line_length or 1))
            else
                x = idx * anim.width
            end
        end
        return
        {
            filename = anim.filename,
            priority = anim.priority or "high",
            flags = anim.flags,
            x = x,
            y = y,
            width = anim.width,
            height = anim.height,
            frame_count = anim.frame_count or 1,
            line_length = anim.line_length,
            repeat_count = anim.repeat_count,
            run_mode = anim.run_mode,
            frame_sequence = anim.frame_sequence,
            shift = anim.shift,
            draw_as_shadow = anim.draw_as_shadow,
            draw_as_light = anim.draw_as_light,
            draw_as_glow = anim.draw_as_glow,
            force_hr_shadow = anim.force_hr_shadow,
            apply_runtime_tint = anim.apply_runtime_tint,
            animation_speed = anim.animation_speed,
            scale = anim.scale or 1,
            tint = anim.tint,
            blend_mode = anim.blend_mode
        }
    end

    local function make_animation_layer_with_hr_version(idx, anim)
        local anim_parameters = make_animation_layer(idx, anim)
        if anim.hr_version and anim.hr_version.filename then
            anim_parameters.hr_version = make_animation_layer(idx, anim.hr_version)
        end
        return anim_parameters
    end

    local function make_animation(idx)
        if animation.layers then
            local tab = { layers = {} }
            for k,v in ipairs(animation.layers) do
            table.insert(tab.layers, make_animation_layer_with_hr_version(idx, v))
            end
            return tab
        else
            return make_animation_layer_with_hr_version(idx, animation)
        end
    end

    return
    {
        north = make_animation(0),
        east = make_animation(1),
        south = make_animation(2),
        west = make_animation(3)
    }
end

-- Connecting north/south oriented pipe shadow overlay
function reskins.lib.vertical_pipe_shadow(shift)
    return
    {
        filename = reskins.lib.directory.."/graphics/entity/common/pipe-patches/vertical-pipe-shadow-patch.png",
        priority = "high",
        width = 64,
        height = 64,
        repeat_count = 36,
        draw_as_shadow = true,
        shift = shift,
        hr_version = {
            filename = reskins.lib.directory.."/graphics/entity/common/pipe-patches/hr-vertical-pipe-shadow-patch.png",
            priority = "high",
            width = 128,
            height = 128,
            repeat_count = 36,
            draw_as_shadow = true,
            shift = shift,
            scale = 0.5,
        }
    }
end

-- TRANSPORT BELT PICTURES
function reskins.lib.transport_belt_animation_set(tint, variant)
    local transport_belt_animation_set
    if variant == 1 then
        transport_belt_animation_set = {
            animation_set = {
                layers = {
                    -- Base
                    {
                        filename = reskins.lib.directory.."/graphics/entity/base/transport-belt/transport-belt-1-base.png",
                        priority = "extra-high",
                        width = 64,
                        height = 64,
                        frame_count = 16,
                        direction_count = 20,
                        hr_version = {
                            filename = reskins.lib.directory.."/graphics/entity/base/transport-belt/hr-transport-belt-1-base.png",
                            priority = "extra-high",
                            width = 128,
                            height = 128,
                            scale = 0.5,
                            frame_count = 16,
                            direction_count = 20
                        }
                    },
                    -- Mask
                    {
                        filename = reskins.lib.directory.."/graphics/entity/base/transport-belt/transport-belt-1-mask.png",
                        priority = "extra-high",
                        width = 64,
                        height = 64,
                        frame_count = 16,
                        tint = tint,
                        direction_count = 20,
                        hr_version = {
                            filename = reskins.lib.directory.."/graphics/entity/base/transport-belt/hr-transport-belt-1-mask.png",
                            priority = "extra-high",
                            width = 128,
                            height = 128,
                            scale = 0.5,
                            frame_count = 16,
                            tint = tint,
                            direction_count = 20
                        }
                    },
                    -- Highlights
                    {
                        filename = reskins.lib.directory.."/graphics/entity/base/transport-belt/transport-belt-1-highlights.png",
                        priority = "extra-high",
                        width = 64,
                        height = 64,
                        frame_count = 16,
                        blend_mode = reskins.lib.blend_mode,
                        direction_count = 20,
                        hr_version = {
                            filename = reskins.lib.directory.."/graphics/entity/base/transport-belt/hr-transport-belt-1-highlights.png",
                            priority = "extra-high",
                            width = 128,
                            height = 128,
                            scale = 0.5,
                            frame_count = 16,
                            blend_mode = reskins.lib.blend_mode,
                            direction_count = 20
                        }
                    },
                }
            }
        }
    else
        transport_belt_animation_set = {
            animation_set = {
                layers = {
                    -- Base
                    {
                        filename = reskins.lib.directory.."/graphics/entity/base/transport-belt/transport-belt-2-base.png",
                        priority = "extra-high",
                        width = 64,
                        height = 64,
                        frame_count = 32,
                        direction_count = 20,
                        hr_version = {
                            filename = reskins.lib.directory.."/graphics/entity/base/transport-belt/hr-transport-belt-2-base.png",
                            priority = "extra-high",
                            width = 128,
                            height = 128,
                            scale = 0.5,
                            frame_count = 32,
                            direction_count = 20
                        }
                    },
                    -- Mask
                    {
                        filename = reskins.lib.directory.."/graphics/entity/base/transport-belt/transport-belt-2-mask.png",
                        priority = "extra-high",
                        width = 64,
                        height = 64,
                        frame_count = 32,
                        tint = tint,
                        direction_count = 20,
                        hr_version = {
                            filename = reskins.lib.directory.."/graphics/entity/base/transport-belt/hr-transport-belt-2-mask.png",
                            priority = "extra-high",
                            width = 128,
                            height = 128,
                            scale = 0.5,
                            frame_count = 32,
                            tint = tint,
                            direction_count = 20
                        }
                    },
                    -- Highlights
                    {
                        filename = reskins.lib.directory.."/graphics/entity/base/transport-belt/transport-belt-2-highlights.png",
                        priority = "extra-high",
                        width = 64,
                        height = 64,
                        frame_count = 32,
                        blend_mode = reskins.lib.blend_mode,
                        direction_count = 20,
                        hr_version = {
                            filename = reskins.lib.directory.."/graphics/entity/base/transport-belt/hr-transport-belt-2-highlights.png",
                            priority = "extra-high",
                            width = 128,
                            height = 128,
                            scale = 0.5,
                            frame_count = 32,
                            blend_mode = reskins.lib.blend_mode,
                            direction_count = 20
                        }
                    },
                }
            }
        }
    end
    return transport_belt_animation_set
end