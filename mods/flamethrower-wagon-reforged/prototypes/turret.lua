local NAME = "flamethrower-wagon-turret"
local WAGON = "flamethrower-wagon"

local function shift_vector(vector, dx, dy)
    if vector[1] ~= nil then
        vector[1] = vector[1] + dx
        vector[2] = vector[2] + dy
    else
        vector.x = (vector.x or 0) + dx
        vector.y = (vector.y or 0) + dy
    end
end

local function shift_sprite(sprite, dx, dy)
    if sprite.shift then
        shift_vector(sprite.shift, dx, dy)
    else
        sprite.shift = { dx, dy }
    end
end

local function shift_animation(animation, dx, dy)
    if not animation then return end
    if animation.layers then
        for _, layer in pairs(animation.layers) do shift_sprite(layer, dx, dy) end
    else
        shift_sprite(animation, dx, dy)
    end
end

local ANIMATIONS = {
    "attacking_animation",
    "ending_attack_animation",
    "folded_animation",
    "folding_animation",
    "prepared_animation",
    "preparing_animation",
}

--- Moves every per-direction picture of the turret onto the wagon roof.
local function shift_direction(turret, direction, px, py)
    local dx, dy = px / 32, py / 32
    for _, key in pairs(ANIMATIONS) do
        local set = turret[key]
        if set then shift_animation(set[direction], dx, dy) end
    end
    local gun = turret.attack_parameters.gun_center_shift
    if gun and gun[direction] then shift_vector(gun[direction], dx, dy) end
    local muzzle = turret.attacking_muzzle_animation_shift
    if muzzle and muzzle.direction_shift and muzzle.direction_shift[direction] then
        shift_vector(muzzle.direction_shift[direction], dx, dy)
    end
end

local base_wagon = data.raw["fluid-wagon"]["fluid-wagon"]

local turret = table.deepcopy(data.raw["fluid-turret"]["flamethrower-turret"])
turret.name = NAME
turret.hidden = true
turret.hidden_in_factoriopedia = true
turret.placeable_by = nil
turret.next_upgrade = nil
turret.fast_replaceable_group = nil
turret.minable = { mining_time = base_wagon.minable.mining_time, result = WAGON }
turret.mined_sound = base_wagon.mined_sound

turret.attack_parameters.range = 30
turret.attack_parameters.min_range = 2.5
turret.attack_parameters.turn_range = 1

turret.prepare_range = 50
turret.preparing_speed = 0.06
turret.rotation_speed = 0.0225

-- The script fills each turret from the wagon tank; the turrets have no pipe neighbours.
turret.fluid_box.hide_connection_info = true
turret.fluid_box.production_type = "input-output"
turret.fluid_box.pipe_covers = nil
turret.fluid_box.pipe_connections = { { position = { 0, 0 }, connection_type = "linked", linked_connection_id = 0 } }
turret.fluid_box.volume = 25
turret.fluid_buffer_size = 25
turret.fluid_buffer_input_flow = 1

turret.collision_box = { { -0.75, -0.75 }, { 0.75, 0.75 } }
turret.selection_box = { { -0.85, -0.85 }, { 0.85, 0.85 } }
turret.selection_priority = 100
turret.collision_mask = { layers = {} }
turret.flags = {
    "player-creation",
    "placeable-off-grid",
    "not-on-map",
    "not-upgradable",
    "not-blueprintable",
    "not-deconstructable",
}

turret.enough_fuel_indicator_light = nil
turret.enough_fuel_indicator_picture = nil
turret.not_enough_fuel_indicator_light = nil
turret.not_enough_fuel_indicator_picture = nil

turret.gun_animation_render_layer = "higher-object-under"
turret.graphics_set.base_visualisation = nil
turret.turret_base_has_direction = true
turret.circuit_wire_max_distance = 0
turret.circuit_connector = nil

shift_direction(turret, "north", 0, 15 - 32)
shift_direction(turret, "east", -18.5, -0.5 - 32)
shift_direction(turret, "south", 0, -10 - 32)
shift_direction(turret, "west", 12, 3.5 - 32)

data:extend({ turret })
