------------------------------------------------------------------------
-- data phase 3
------------------------------------------------------------------------

require('lib.init')

local util = require('util')

local const = require('lib.constants')

require 'circuit-connector-generated-definitions'
require 'circuit-connector-sprites'

local function create_legacy_miniloader_entity(name)
    local source_inserter = data.raw['inserter'][const:with_prefix(const.name)]
    assert(source_inserter)

    local loader_inserter = {
        type = 'inserter',
        name = name,
        icon = const:png('item/icon-base'),
        icon_size = 64,
        collision_box = { { -0.2, -0.2 }, { 0.2, 0.2 } },
        selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
        selection_priority = 50,
        allow_custom_vectors = true,
        energy_per_movement = '.0000001J',
        energy_per_rotation = '.0000001J',
        energy_source = {
            type = 'void',
        },
        extension_speed = 1,
        rotation_speed = 0.5,
        pickup_position = { 0, 0 },
        insert_position = { 0, 0 },
        draw_held_item = false,
        draw_inserter_arrow = false,
        circuit_wire_max_distance = default_circuit_wire_max_distance,
        circuit_connector = source_inserter.circuit_connector,
    }

    data:extend { loader_inserter }
end

local function create_legacy_technology(technology_name)
    local technology = {
        type = 'technology',
        name = technology_name,
        icons = { util.empty_icon() },
        visible_when_disabled = false,
        research_trigger = {
            type = 'craft-item',
            item = 'iron-plate',
            count = 50
        }
    }

    data:extend { technology }
end

if Framework.settings:startup_setting(const.settings_names.migrate_loaders) then
    for prefix in pairs(const:migrations()) do
        local ml_name = prefix .. 'miniloader-inserter'
        if not data.raw['inserter'][ml_name] then
            create_legacy_miniloader_entity(ml_name)
        end
        -- patch up all entities to support filters.
        data.raw['inserter'][ml_name].filter_count = 5

        if not (prefix:match('chute') or prefix:match('filter')) then
            local technology_name = prefix .. 'miniloader'
            if not data.raw['technology'][technology_name] then
                create_legacy_technology(technology_name)
            end
        end
    end
end

if Framework.settings:startup_setting(const.settings_names.sanitize_loaders) then
    for _, loader in pairs(data.raw['loader-1x1']) do
        if loader.collision_mask then
            loader.collision_mask.layers.transport_belt = true
        end
    end
end

-- TEMPORARY SE FIX
if space_collision_layer then
    local data_util = require('__space-exploration__.data_util')

    for _, entity_type in pairs { 'loader-1x1', 'inserter' } do
        for _, prototype in pairs(data.raw[entity_type]) do
            -- if a prototype has an explicit "se_allow_in_space = false" (not just missing or true), then make it collide
            -- with the space collision layer
            if prototype.se_allow_in_space ~= nil and not prototype.se_allow_in_space and prototype.collision_mask then
                prototype.collision_mask.layers[space_collision_layer] = true
                data_util.collision_description(prototype)
            end
        end
    end
end

Framework.post_data_final_fixes_stage()
