local entities_to_extend = {}

local function downscale(picture)
    if not picture then return end

    if type(picture) == "table" and picture.layers then
        for _, layer in pairs(picture.layers or {}) do
            downscale(layer)
        end
        return
    end

    picture.scale = (picture.scale or 1) / 2
    if picture.shift then
        local x, y = picture.shift[1] or picture.shift.x or 0, picture.shift[2] or picture.shift.y or 0
        picture.shift = {x = x / 2, y = y / 2}
    end
end

local function vector_downscale(vector)
    if not vector then return end

    if vector.x and type(vector.x) == "number" then vector.x = vector.x / 2 end
    if vector.y and type(vector.y) == "number" then vector.y = vector.y / 2 end
    if vector[1] and type(vector[1]) == "number" then vector[1] = vector[1] / 2 end
    if vector[2] and type(vector[2]) == "number" then vector[2] = vector[2] / 2 end

    for _, subvector in pairs(vector) do
        if type(subvector) == "table" then
            vector_downscale(subvector)
        end
    end
end

data:extend {{
    type                                    = "roboport",
    name                                    = "factory-hidden-construction-roboport",
    icon                                    = data.raw.item["roboport"].icon,
    icon_size                               = data.raw.item["roboport"].icon_size,
    flags                                   = {"not-on-map", "no-automated-item-removal"},
    health                                  = 10000,
    hidden                                  = true,
    radar_range                             = 0,
    collision_box                           = {{-0.9, -0.9}, {0.9, 0.9}},
    selection_box                           = {{-1, -1}, {1, 1}},
    collision_mask                          = {layers = {}},
    logistics_radius                        = 2,
    construction_radius                     = 0,
    energy_source                           = {type = "void"},
    energy_usage                            = "1W",
    recharge_minimum                        = "1W",
    robot_slots_count                       = 1,
    material_slots_count                    = 0,
    draw_logistic_radius_visualization      = false,
    draw_construction_radius_visualization  = false,
    logistics_connection_distance           = 2,
    icon_draw_specification                 = {scale = 0},
    quality_indicator_scale                 = 0,
    selectable_in_game                      = false,
    charging_energy                         = data.raw["roboport"]["roboport"].charging_energy,
    recharging_animation                    = table.deepcopy(data.raw["roboport"]["roboport"].recharging_animation),
    charge_approach_distance                = data.raw["roboport"]["roboport"].charge_approach_distance / 2,
    spawn_and_station_height                = data.raw["roboport"]["roboport"].spawn_and_station_height / 2,
    request_to_open_door_timeout            = data.raw["roboport"]["roboport"].request_to_open_door_timeout,
    charging_station_shift                  = table.deepcopy(data.raw["roboport"]["roboport"].charging_station_shift),
    stationing_offset                       = table.deepcopy(data.raw["roboport"]["roboport"].stationing_offset),
    charging_offsets                        = {{0, 0}},
    robots_shrink_when_entering_and_exiting = true,
}}

local hidden_construction_robot = table.deepcopy(data.raw["construction-robot"]["construction-robot"])
hidden_construction_robot.name = "factory-hidden-construction-robot"
hidden_construction_robot.minable = nil
hidden_construction_robot.next_upgrade = nil
hidden_construction_robot.placeable_by = nil
hidden_construction_robot.created_effect = {
    type = "direct",
    action_delivery = {
        type = "instant",
        source_effects = {
            {
                type = "script",
                effect_id = "factory-hidden-construction-robot-created",
            },
        }
    }
}
hidden_construction_robot.speed = 0.5
hidden_construction_robot.energy_per_move = nil
hidden_construction_robot.energy_per_tick = nil
hidden_construction_robot.localised_name = data.raw["construction-robot"]["construction-robot"].localised_name or {"entity-name.construction-robot"}
hidden_construction_robot.icon_draw_specification = {scale = 0}
hidden_construction_robot.quality_indicator_scale = 0
hidden_construction_robot.selectable_in_game = false
hidden_construction_robot.flags = {"not-on-map"}
hidden_construction_robot.health = 10000
hidden_construction_robot.hidden = true
hidden_construction_robot.idle = nil
hidden_construction_robot.in_motion = nil
hidden_construction_robot.shadow_idle = nil
hidden_construction_robot.shadow_in_motion = nil
hidden_construction_robot.working = nil
hidden_construction_robot.shadow_working = nil
hidden_construction_robot.sparks = nil
hidden_construction_robot.smoke = nil
data:extend {hidden_construction_robot}

data:extend {{
    type = "item",
    name = "factory-hidden-construction-robot",
    icon = data.raw.item["construction-robot"].icon,
    icon_size = data.raw.item["construction-robot"].icon_size,
    hidden = true,
    flags = {"only-in-cursor"},
    place_result = "factory-hidden-construction-robot",
    stack_size = 1000,
}}

local roboport = table.deepcopy(data.raw["roboport"]["roboport"])
roboport.name = "factory-construction-roboport"
roboport.collision_box = {{-0.9, -0.9}, {0.9, 0.9}}
roboport.selection_box = {{-1, -1}, {1, 1}}
roboport.recharging_light.size = roboport.recharging_light.size / 2
roboport.charging_station_count_affected_by_quality = true
roboport.logistics_connection_distance = 64
roboport.logistics_radius = 2
roboport.construction_radius = 64
roboport.robot_slots_count = 0
roboport.material_slots_count = 1
roboport.icon = "__factorissimo-2-notnotmelon__/graphics/icon/construction-chest.png"
roboport.icon_size = 64
roboport.energy_source = {type = "void"}
roboport.hidden = true
roboport.radar_range = 0
roboport.flags = {"player-creation", "placeable-player", "not-on-map"}
downscale(roboport.base)
downscale(roboport.base_patch)
downscale(roboport.frozen_patch)
downscale(roboport.base_animation)
downscale(roboport.door_animation_up)
downscale(roboport.door_animation_down)
downscale(roboport.recharging_animation)
vector_downscale(roboport.charging_station_shift)
vector_downscale(roboport.stationing_offset)
vector_downscale(roboport.charging_offsets)
entities_to_extend[#entities_to_extend + 1] = roboport

local storage_chest = table.deepcopy(data.raw["logistic-container"]["storage-chest"])
storage_chest.name = "factory-construction-chest"
storage_chest.inventory_type = "with_bar"
storage_chest.icon = "__factorissimo-2-notnotmelon__/graphics/icon/construction-chest.png"
storage_chest.icon_size = 64
storage_chest.inventory_size = 100
storage_chest.hidden = true
storage_chest.flags = {"player-creation", "placeable-player", "no-automated-item-removal", "no-automated-item-insertion", "not-on-map"}
storage_chest.animation.layers[1].filename = "__factorissimo-2-notnotmelon__/graphics/entity/construction-chest.png"
entities_to_extend[#entities_to_extend + 1] = storage_chest

for _, factory_name in pairs {"factory-1", "factory-2", "factory-3"} do
    -- all materials are delivered via the construction network. there is no need for this to be a requester.
    local requester_chest = table.deepcopy(data.raw.container["steel-chest"])
    requester_chest.name = "factory-requester-chest-" .. factory_name
    requester_chest.localised_name = {"entity-name.factory-requester-chest"}
    requester_chest.icon = data.raw["storage-tank"][factory_name].icon
    requester_chest.icon_size = data.raw["storage-tank"][factory_name].icon_size
    requester_chest.collision_box = table.deepcopy(data.raw["storage-tank"][factory_name].collision_box)
    requester_chest.selection_box = nil
    requester_chest.inventory_type = "with_custom_stack_size"
    requester_chest.inventory_properties = {stack_size_multiplier = 50}
    requester_chest.inventory_size = 100
    requester_chest.picture = nil
    requester_chest.hidden = true
    requester_chest.factoriopedia_alternative = factory_name
    requester_chest.quality_indicator_scale = 0
    requester_chest.flags = {"not-on-map", "hide-alt-info", "no-automated-item-removal", "no-automated-item-insertion", "not-in-kill-statistics", "not-rotatable"}
    entities_to_extend[#entities_to_extend + 1] = requester_chest

    local eject_chest = table.deepcopy(data.raw.container["steel-chest"])
    eject_chest.name = "factory-eject-chest-" .. factory_name
    eject_chest.inventory_size = 1
    eject_chest.localised_name = {"entity-name.factory-eject-chest"}
    eject_chest.icon = data.raw["storage-tank"][factory_name].icon
    eject_chest.icon_size = data.raw["storage-tank"][factory_name].icon_size
    eject_chest.collision_box = table.deepcopy(data.raw["storage-tank"][factory_name].collision_box)
    eject_chest.selection_box = nil
    eject_chest.picture = nil
    eject_chest.hidden = true
    eject_chest.factoriopedia_alternative = factory_name
    eject_chest.quality_indicator_scale = 0
    eject_chest.flags = {"not-on-map", "hide-alt-info", "no-automated-item-removal", "no-automated-item-insertion", "not-in-kill-statistics", "not-rotatable"}
    entities_to_extend[#entities_to_extend + 1] = eject_chest
end

for _, prototype in pairs(entities_to_extend) do
    prototype.collision_mask = {layers = {}}
    prototype.fast_replaceable_group = nil
    prototype.next_upgrade = nil
    prototype.surface_conditions = nil
    prototype.max_health = 500
    prototype.minable = nil
    prototype.placeable_by = nil
    prototype.heating_energy = nil
end

data:extend(entities_to_extend)

-- This is required to allow the roboport to exist in blueprints.
data:extend {{
    type = "item",
    name = "factory-construction-roboport",
    icon = data.raw.item["roboport"].icon,
    icon_size = data.raw.item["roboport"].icon_size,
    stack_size = 1,
    hidden = true,
    hidden_in_factoriopedia = true,
    flags = {"not-stackable", "only-in-cursor"},
    place_result = "factory-construction-roboport"
}}

-- This is required to allow the construction chest to exist in blueprints.
data:extend {{
    type = "item",
    name = "factory-construction-chest",
    icon = "__factorissimo-2-notnotmelon__/graphics/icon/construction-chest.png",
    icon_size = 64,
    stack_size = 1,
    hidden = true,
    hidden_in_factoriopedia = true,
    flags = {"not-stackable", "only-in-cursor"},
    place_result = "factory-construction-chest"
}}
