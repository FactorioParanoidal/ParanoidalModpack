-------------------------------------------------------------------------------
--[[Roboport Interface]] -- Logistic Network roboport interface module
-------------------------------------------------------------------------------
local Data = require('__stdlib__/stdlib/data/data')
local Recipe = require('__stdlib__/stdlib/data/recipe')
--Roboport with custom GFX no zones, no recharge, radar with nil gfx, cc with nil gfx - selectable
--256 x 224

Data {
    type = 'technology',
    name = 'roboport-interface',
    icon = '__Nanobots__/graphics/technology/roboport-interface.png',
    icon_size = 128,
    effects = {},
    prerequisites = {'construction-robotics', 'logistics', 'circuit-network'},
    unit = {
        count = 100,
        ingredients = {
            {'automation-science-pack', 1}
        },
        time = 30
    },
    order = 'a-b-ba'
}

--Main recipe.
Recipe {
    type = 'recipe',
    name = 'roboport-interface',
    enabled = false,
    ingredients = {
        {'constant-combinator', 1},
        {'roboport', 1},
        {'radar', 1}
    },
    result = 'roboport-interface',
    energy_required = 30
}:add_unlock('roboport-interface')

Data {
    type = 'item',
    name = 'roboport-interface',
    icons = {
        {icon = '__Nanobots__/graphics/icons/roboport-interface.png', icon_size = 32}
    },
    icon_size = 32,
    subgroup = 'logistic-network',
    order = 'c[signal]-a[roboport]-interface',
    place_result = 'roboport-interface-main',
    stack_size = 5
}

Data {
    type = 'item',
    name = 'roboport-interface-cc',
    icons = {
        {icon = '__Nanobots__/graphics/icons/roboport-interface-cc.png', icon_size = 32}
    },
    icon_size = 32,
    flags = {'hidden'},
    subgroup = 'logistic-network',
    order = 'c[signal]-a[roboport]-interface-cc',
    place_result = 'roboport-interface-cc',
    stack_size = 1000
}

--[[
Three entities need placing:
Main roboport type entity to show connections/animations.
Hidden radar entity, Fires the on sector scanned scripts
Constant-Combinator interface for setting the signals.
--]]
local ri_cc = Data('constant-combinator', 'constant-combinator'):copy('roboport-interface-cc')
ri_cc.icon = nil
ri_cc.icons = {
    {icon = '__Nanobots__/graphics/icons/roboport-interface-cc.png'}
}
ri_cc.icon_size = 32
ri_cc.item_slot_count = 5
ri_cc.flags = {'not-deconstructable', 'player-creation', 'placeable-off-grid'}
ri_cc.collision_mask = {}
ri_cc.minable = nil
ri_cc.selection_box = {{0.0, 0.0}, {1, 1}}
ri_cc.collision_box = {{-0.9, -0.9}, {0.9, 0.9}}
for index, direction in pairs({'north', 'east', 'south', 'west'}) do
    ri_cc.sprites[direction] = Data.Sprites.empty_sprite()
    ri_cc.activity_led_sprites[direction] = {
        filename = '__Nanobots__/graphics/entity/roboport-interface/combinator-led-constant-south.png',
        width = 11,
        height = 11,
        frame_count = 1,
        shift = {0, -.75}
    }

    ri_cc.activity_led_light_offsets[index] = {-0, -0.75}

    ri_cc.circuit_wire_connection_points[index] = {
        shadow = {
            red = {0.75, 0.5625},
            green = {0.21875, 0.5625}
        },
        wire = {
            red = {0.5, -0.05},
            green = {0.2, 0.15}
        }
    }
end
ri_cc.circuit_wire_max_distance = 9
ri_cc.activity_led_light = {
    intensity = 0.8,
    size = 1
}

local ri_radar = Data('radar', 'radar'):copy('roboport-interface-scanner')
ri_radar.flags = {'not-deconstructable', 'player-creation', 'placeable-off-grid'}
ri_radar.icon = '__Nanobots__/graphics/icons/roboport-interface.png'
ri_radar.icon_size = 32
ri_radar.minable = nil
ri_radar.collision_mask = {}
ri_radar.selection_box = {{-1, -0.0}, {0.0, 1}}
ri_radar.collision_box = {{-0.9, -0.9}, {0.9, 0.9}}
ri_radar.pictures = Data.Sprites.empty_pictures()
ri_radar.max_distance_of_sector_revealed = 0
ri_radar.max_distance_of_nearby_sector_revealed = 1
ri_radar.energy_per_sector = '20MJ'
ri_radar.energy_per_nearby_scan = '250kJ'
ri_radar.energy_usage = '300kW'

Data {
    type = 'roboport',
    name = 'roboport-interface-main',
    icon = '__Nanobots__/graphics/icons/roboport-interface.png',
    icon_size = 32,
    flags = {'placeable-player', 'player-creation'},
    minable = {hardness = 0.2, mining_time = 0.5, result = 'roboport-interface'},
    max_health = 500,
    corpse = 'small-remnants',
    collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
    selection_box = {{-1, -1}, {1, 0}},
    dying_explosion = 'medium-explosion',
    energy_source = {
        type = 'electric',
        usage_priority = 'secondary-input',
        input_flow_limit = '50kW',
        buffer_capacity = '500KJ'
    },
    recharge_minimum = '50KJ',
    energy_usage = '25kW',
    -- per one charge slot
    charging_energy = '1kW',
    logistics_radius = 0,
    construction_radius = 0,
    charge_approach_distance = 0,
    robot_slots_count = 0,
    material_slots_count = 0,
    stationing_offset = nil,
    charging_offsets = nil,
    base = Data.Sprites.empty_picture(),
    base_animation = {
        filename = '__Nanobots__/graphics/entity/roboport-interface/roboport-interface.png',
        scale = .50,
        priority = 'medium',
        width = 256,
        height = 448,
        apply_projection = false,
        animation_speed = .15,
        frame_count = 32,
        line_length = 8,
        shift = {0.4, -2.0}
    },
    base_patch = Data.Sprites.empty_animation(),
    door_animation_up = Data.Sprites.empty_animation(),
    door_animation_down = Data.Sprites.empty_animation(),
    recharging_animation = Data.Sprites.empty_animation(),
    recharging_light = nil,
    request_to_open_door_timeout = 15,
    spawn_and_station_height = 1.75,
    draw_logistic_radius_visualization = false,
    draw_construction_radius_visualization = false,
    radius_visualisation_picture = nil,
    construction_radius_visualisation_picture = nil
}
