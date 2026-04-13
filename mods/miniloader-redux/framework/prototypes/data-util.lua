----------------------------------------------------------------------------------------------------
-- Data Utility - from flib
----------------------------------------------------------------------------------------------------
assert(not script)

local util = require('util')
local collision_mask_util = require('collision-mask-util')
local sprites = require('stdlib.data.modules.sprites')


---@class framework.prototypes.data_util
---@field EMPTY_LED_LIGHT_OFFSETS  Vector[]
---@field EMPTY_ENTITY_FLAGS string[]
local FrameworkDataUtil = {
    EMPTY_LED_LIGHT_OFFSETS = { { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 } },
    EMPTY_ENTITY_FLAGS = {
        'placeable-off-grid',
        'not-repairable',
        'not-on-map',
        'not-deconstructable',
        'not-blueprintable',
        'hide-alt-info',
        'not-flammable',
        'not-upgradable',
        'not-in-kill-statistics',
        'not-in-made-in'
    },
}

--- An empty image. This image is 8x8 to facilitate usage with GUI styles.
FrameworkDataUtil.empty_image = Framework.ROOT .. '/framework/graphics/empty.png'

--- A black image, for use with tool backgrounds. This image is 1x1.
FrameworkDataUtil.black_image = Framework.ROOT .. '/framework/graphics/black.png'

--- A desaturated planner image. Tint this sprite to easily add your own planners.
FrameworkDataUtil.planner_base_image = Framework.ROOT .. '/framework/graphics/planner.png'

--- A dark red button tileset. Used for the `flib_tool_button_dark_red` style.
FrameworkDataUtil.dark_red_button_tileset = Framework.ROOT .. '/framework/graphics/dark-red-button.png'

--- Copy a prototype, assigning a new name and minable properties.

---@param prototype data.EntityPrototype
---@param new_name string The new name of the entity
---@param make_invisible? boolean If true, make the entity invisble, e.g. for packed entities.
---@return data.EntityPrototype
function FrameworkDataUtil.copy_entity_prototype(prototype, new_name, make_invisible)
    if not prototype.type or not prototype.name then
        error('Invalid prototype: prototypes must have name and type properties.')
    end

    local p = util.copy(prototype) --[[ @as data.EntityPrototype ]]
    p.name = new_name

    if p.minable and p.minable.result then
        assert(not p.minable.results)
        p.minable.result = new_name
    end

    if not make_invisible then return p end

    ---@diagnostic disable: inject-field, undefined-field
    -- CombinatorPrototype
    if p.sprites then p.sprites = util.empty_sprite() end
    if p.activity_led_light_offsets then p.activity_led_light_offsets = FrameworkDataUtil.EMPTY_LED_LIGHT_OFFSETS end
    if p.activity_led_sprites then p.activity_led_sprites = util.empty_sprite() end
    if p.draw_circuit_wires then p.draw_circuit_wires = false end

    -- ConstantCombinatorPrototype
    if p.circuit_wire_connection_points then p.circuit_wire_connection_points = sprites.empty_connection_points(4) end
    if p.circuit_wire_max_distance then p.circuit_wire_max_distance = default_circuit_wire_max_distance end
    if p.draw_copper_wires then p.draw_copper_wires = false end

    if p.energy_source then
        if p.energy_source.render_no_network_icon then p.energy_source.render_no_network_icon = false end
        if p.energy_source.render_no_power_icon then p.energy_source.render_no_power_icon = false end
    end

    -- EntityWithHealthPrototype
    if p.max_health then p.max_health = 1 end

    ---@diagnostic enable: inject-field, undefined-field

    p.collision_box = nil
    p.collision_mask = collision_mask_util.new_mask()
    p.selection_box = nil
    p.flags = FrameworkDataUtil.EMPTY_ENTITY_FLAGS

    p.allow_copy_paste = false
    p.hidden = true
    p.hidden_in_factoriopedia = true
    p.minable = nil
    p.selection_box = nil
    p.selectable_in_game = false
    p.selection_priority = 1

    return p
end

---@param prototype data.Prototype
---@param new_name string The new name of the entity
---@return data.Prototype
function FrameworkDataUtil.copy_other_prototype(prototype, new_name)
    if not prototype.type or not prototype.name then
        error('Invalid prototype: prototypes must have name and type properties.')
    end

    local p = util.copy(prototype) --[[ @as data.ItemPrototype ]]
    p.name = new_name
    if p.place_result then p.place_result = new_name end
    ---@diagnostic disable: inject-field, undefined-field
    if p.result then p.result = new_name end
    ---@diagnostic enable: inject-field, undefined-field
    return p
end


--- Copy prototype.icon/icons to a new fully defined icons array, optionally adding new icon layers.
---
--- Returns `nil` if the prototype's icons are incorrectly or incompletely defined.
---@param prototype table
---@param new_layers? FrameworkIconSpecification[]
---@return FrameworkIconSpecification[]|nil
function FrameworkDataUtil.create_icons(prototype, new_layers)
    if new_layers then
        for _, new_layer in pairs(new_layers) do
            if not new_layer.icon or not new_layer.icon_size then
                return nil
            end
        end
    end

    if prototype.icons then
        local icons = {}
        for _, v in pairs(prototype.icons) do
            -- Over define as much as possible to minimize weirdness: https://forums.factorio.com/viewtopic.php?f=25&t=81980
            icons[#icons + 1] = {
                icon = v.icon,
                icon_size = v.icon_size or prototype.icon_size,
                tint = v.tint,
                scale = v.scale,
                shift = v.shift,
            }
        end
        if new_layers then
            for _, new_layer in pairs(new_layers) do
                icons[#icons + 1] = new_layer
            end
        end
        return icons
    elseif prototype.icon then
        local icons = {
            {
                icon = prototype.icon,
                icon_size = prototype.icon_size,
                tint = { r = 1, g = 1, b = 1, a = 1 },
            },
        }
        if new_layers then
            for _, new_layer in pairs(new_layers) do
                icons[#icons + 1] = new_layer
            end
        end
        return icons
    else
        return nil
    end
end

local exponent_multipliers = {
    ['y'] = 0.000000000000000000000001,
    ['z'] = 0.000000000000000000001,
    ['a'] = 0.000000000000000001,
    ['f'] = 0.000000000000001,
    ['p'] = 0.000000000001,
    ['n'] = 0.000000001,
    ['u'] = 0.000001, -- μ is invalid
    ['m'] = 0.001,
    ['c'] = 0.01,
    ['d'] = 0.1,
    [''] = 1,
    ['da'] = 10,
    ['h'] = 100,
    ['k'] = 1000,
    ['K'] = 1000, -- This isn't SI, but meh
    ['M'] = 1000000,
    ['G'] = 1000000000,
    ['T'] = 1000000000000,
    ['P'] = 1000000000000000,
    ['E'] = 1000000000000000000,
    ['Z'] = 1000000000000000000000,
    ['Y'] = 1000000000000000000000000,
}

--- Convert an energy string to base unit value + suffix.
---
--- Returns `nil` if `energy_string` is incorrectly formatted.
---@param energy_string string
---@return number?
---@return string?
function FrameworkDataUtil.get_energy_value(energy_string)
    if type(energy_string) == 'string' then
        local v, _, exp, unit = string.match(energy_string, '([%-+]?[0-9]*%.?[0-9]+)((%D*)([WJ]))')
        local value = tonumber(v)
        if value and exp and exponent_multipliers[exp] then
            value = value * exponent_multipliers[exp]
            return value, unit
        end
    end
    return nil
end

--- Build a sprite from constituent parts.
---@param name? string
---@param position? MapPosition
---@param filename? string
---@param size? Vector
---@param mods? table
---@return FrameworkSpriteSpecification
function FrameworkDataUtil.build_sprite(name, position, filename, size, mods)
    local def = {
        type = 'sprite',
        name = name,
        filename = filename,
        position = position,
        size = size,
        flags = { 'icon' },
    }
    if mods then
        for k, v in pairs(mods) do
            def[k] = v
        end
    end
    return def
end

return FrameworkDataUtil

---@class FrameworkIconSpecification
---@field icon string
---@field icon_size int
---@class FrameworkSpriteSpecification
