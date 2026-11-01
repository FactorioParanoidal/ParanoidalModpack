-------------------------------------------------------------------------------
--[[Roboport Interface]] -- Logistic Network roboport interface module
-------------------------------------------------------------------------------
-- Empty sprites, the same tables the stdlib2 Data.Sprites helpers returned.
local function empty_picture()
    return {filename = '__core__/graphics/empty.png', priority = 'extra-high', width = 1, height = 1}
end

local function empty_animation()
    return {
        filename = '__core__/graphics/empty.png',
        width = 1,
        height = 1,
        line_length = 1,
        frame_count = 1,
        shift = {0, 0},
        animation_speed = 1,
        direction_count = 1
    }
end
--Roboport with custom GFX no zones, no recharge, radar with nil gfx, cc with nil gfx - selectable
--256 x 224

data:extend{{
    type = 'technology',
    name = 'roboport-interface',
    icon = '__nanobots-refined-reforged__/graphics/technology/roboport-interface.png',
    icon_size = 256,
    effects = {},
    prerequisites = {'construction-robotics', 'circuit-network'},
    unit = {
        count = 110,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1}
        },
        time = 30
    },
    order = 'a-b-ba'
}}

--Main recipe.
local ingredients = {
    {type = 'item', name = 'constant-combinator', amount = 1},
    {type = 'item', name = 'radar', amount = 1},
    {type = 'item', name = 'roboport', amount = 1}
}

data:extend{{
    type = 'recipe',
    name = 'roboport-interface',
    enabled = false,
    ingredients = {
        {type = 'item', name = 'constant-combinator', amount = 1},
        {type = 'item', name = 'radar', amount = 1},
        {type = 'item', name = 'roboport', amount = 1}
    },
    results = {{type = 'item', name='roboport-interface', amount = 1}},
    energy_required = 30
}}
table.insert(data.raw.technology['roboport-interface'].effects, {type = 'unlock-recipe', recipe = 'roboport-interface'})

data:extend{{
    type = 'item',
    name = 'roboport-interface',
    icon = '__nanobots-refined-reforged__/graphics/icons/roboport-interface.png',
    icon_size = 64,
    icon_mipmaps = 1,
    subgroup = 'logistic-network',
    order = 'c[signal]-a[roboport]-interface',
    place_result = 'roboport-interface-main',
    stack_size = 5
}}

data:extend{{
    type = 'item',
    name = 'roboport-interface-cc',
    icon = '__nanobots-refined-reforged__/graphics/icons/roboport-interface-cc.png',
    icon_size = 64,
    icon_mipmaps = 1,
    hidden = true,
    subgroup = 'logistic-network',
    order = 'c[signal]-a[roboport]-interface-cc',
    place_result = 'roboport-interface-cc',
    stack_size = 1000
}}

--[[
Three entities need placing:
Main roboport type entity to show connections/animations.
Hidden radar entity, Fires the on sector scanned scripts
Constant-Combinator interface for setting the signals.
--]]
local ri_cc = table.deepcopy(data.raw['constant-combinator']['constant-combinator'])
ri_cc.name = 'roboport-interface-cc'
if ri_cc.minable and ri_cc.minable.result then
    ri_cc.minable.result = 'roboport-interface-cc'
end
ri_cc.icon = '__nanobots-refined-reforged__/graphics/icons/roboport-interface-cc.png'
ri_cc.icon_mipmaps = 1
ri_cc.icon_size = 64
ri_cc.item_slot_count = 5
ri_cc.flags = {'not-deconstructable', 'player-creation', 'placeable-off-grid'}
ri_cc.collision_mask = {layers = {item = true, meltable = true, object = true, player = true, water_tile = true, is_object = true, is_lower_object = true}}
ri_cc.minable = nil
ri_cc.selection_box = {{0.0, 0.0}, {1, 1}}
ri_cc.collision_box = {{-0.9, -0.9}, {0.9, 0.9}}
for index, direction in pairs({'north', 'east', 'south', 'west'}) do
    ri_cc.sprites[direction] = empty_picture()
    ri_cc.activity_led_sprites[direction] = {
        filename = '__nanobots-refined-reforged__/graphics/entity/roboport-interface/combinator-led-constant-south.png',
        width = 11,
        height = 11,
        frame_count = 1,
        draw_as_glow = true,
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
data:extend{ri_cc}

local ri_radar = table.deepcopy(data.raw['radar']['radar'])
ri_radar.name = 'roboport-interface-scanner'
if ri_radar.minable and ri_radar.minable.result then
    ri_radar.minable.result = 'roboport-interface-scanner'
end
ri_radar.flags = {'not-deconstructable', 'player-creation', 'placeable-off-grid'}
ri_radar.icon = '__nanobots-refined-reforged__/graphics/icons/roboport-interface.png'
ri_radar.icon_size = 64
ri_radar.icon_mipmaps = 1
ri_radar.minable = nil
ri_radar.next_upgrade = nil
ri_radar.collision_mask = {layers = {item = true, meltable = true, object = true, player = true, water_tile = true, is_object = true, is_lower_object = true}}
ri_radar.selection_box = {{-1, 0}, {0, 1}}
ri_radar.collision_box = {{-0.9, -0.9}, {0.9, 0.9}}
ri_radar.pictures = empty_animation()
ri_radar.max_distance_of_sector_revealed = 0
ri_radar.max_distance_of_nearby_sector_revealed = 1
ri_radar.energy_per_sector = '20MJ'
ri_radar.energy_per_nearby_scan = '250kJ'
ri_radar.energy_usage = '300kW'
data:extend{ri_radar}

data:extend{{
    type = 'roboport',
    name = 'roboport-interface-main',
    icon = '__nanobots-refined-reforged__/graphics/icons/roboport-interface.png',
    icon_size = 64,
    icon_mipmaps = 1,
    flags = {'placeable-player', 'player-creation'},
    minable = {mining_time = 0.5, result = 'roboport-interface'},
    max_health = 500,
    corpse = 'small-remnants',
    collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
    selection_box = {{-1, -1}, {1, 0}},
    dying_explosion = 'medium-explosion',
    energy_source = {
        type = 'electric',
        usage_priority = 'secondary-input',
        input_flow_limit = '50kW',
        buffer_capacity = '500kJ'
    },
    recharge_minimum = '50kJ',
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
    base = empty_picture(),
    base_animation = {
        layers = {
            {
                    filename = '__nanobots-refined-reforged__/graphics/entity/roboport-interface/hr-roboport-interface-base.png',
                    scale = 0.5,
                    priority = 'medium',
                    width = 256,
                    height = 448,
                    animation_speed = 0.15,
                    repeat_count = 16,
                    shift = {0.5, -2.0},
                },
            {
                    filename = '__nanobots-refined-reforged__/graphics/entity/roboport-interface/hr-roboport-interface.png',
                    scale = 0.5,
                    priority = 'medium',
                    width = 256,
                    height = 448,
                    animation_speed = 0.15,
                    frame_count = 16,
                    line_length = 8,
                    shift = {0.5, -2.0},
                },
            {
                    filename = '__nanobots-refined-reforged__/graphics/entity/roboport-interface/hr-roboport-interface-base-shadow.png',
                    scale = 0.5,
                    priority = 'medium',
                    width = 422,
                    height = 448,
                    animation_speed = 0.15,
                    repeat_count = 16,
                    shift = {0.5, -2.0},
                    draw_as_shadow = true,
                },
            {
                    filename = '__nanobots-refined-reforged__/graphics/entity/roboport-interface/hr-roboport-interface-shadow.png',
                    scale = 0.5,
                    priority = 'medium',
                    width = 256,
                    height = 448,
                    animation_speed = 0.15,
                    frame_count = 16,
                    line_length = 8,
                    shift = {2.5, -2.0},
                    draw_as_shadow = true,
                },
            {
                    filename = '__nanobots-refined-reforged__/graphics/entity/roboport-interface/hr-roboport-interface-glow.png',
                    scale = 0.5,
                    priority = 'medium',
                    width = 256,
                    height = 448,
                    animation_speed = 0.15,
                    frame_count = 16,
                    line_length = 8,
                    shift = {0.5, -2.0},
                    draw_as_light = true,
                },
        }

    },
    base_patch = empty_animation(),
    door_animation_up = empty_animation(),
    door_animation_down = empty_animation(),
    recharging_animation = empty_animation(),
    recharging_light = nil,
    request_to_open_door_timeout = 15,
    spawn_and_station_height = 1.75,
    draw_logistic_radius_visualization = false,
    draw_construction_radius_visualization = false,
    radius_visualisation_picture = nil,
    construction_radius_visualisation_picture = nil
}}
