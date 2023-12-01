local prev_position = nil
local prev_tick = nil

local function round256(float)
    return math.floor(float * 256 + 0.5) / 256
end

local function floor256(float)
    return math.floor(float * 256) / 256
end

local function getVehicleMaxSpeed(vehicle)
    local vehiclePrototype = vehicle.prototype
    local max_speed
    --[[
    vehicle.type vehicle.name
    car car
    car tank
    locomotive locomotive
    spider-vehicle spidertron

    car hover-car
    car hover-car-mk2
    car raven-1
    car heli-entity-_-
    car cargo-plane
    car better-cargo-plane
    car even-better-cargo-plane
    car flying-fortress
    car gunship
    car jet

    ]]

    if vehicle.type == "car" then

        local vehicle_weight = vehiclePrototype.weight
        local friction_force = vehiclePrototype.friction_force
        local terrain_friction_modifier = vehiclePrototype.terrain_friction_modifier
        local average_tile_friction_modifier = 1.6 -- Average of tile Friction is a calc of all tiles the bounding box of the vehicle resides over
        local car_friction_modifier = 1
        local sticker_friction_modifier = 1
        local combined_friction = 1 - friction_force *
                                      (1 + terrain_friction_modifier * (average_tile_friction_modifier - 1)) *
                                      car_friction_modifier * sticker_friction_modifier

        local combined_friction_square = combined_friction * combined_friction

        local vehicle_consumption = vehiclePrototype.consumption
        local vehicle_consumption_modifier = 1
        local vehicle_effectivity = vehiclePrototype.effectivity
        local fuel_acceleration_multiplier = 1
        local fuel_top_speed_multiplier = 1
        local speed_bonus = 1
        local sticker_bonus = 1

        local energy_per_tick = vehicle_consumption * vehicle_consumption_modifier * vehicle_effectivity *
                                    fuel_acceleration_multiplier * fuel_top_speed_multiplier * speed_bonus *
                                    sticker_bonus

        local max_energy = energy_per_tick * combined_friction_square / (1 - combined_friction_square)

        max_speed = (max_energy * 2 / vehicle_weight) ^ 0.5 * 3.6
    elseif vehicle.type == "locomotive" then
        max_speed = round256(vehicle.train.max_forward_speed) * 60 * 3.6
    elseif vehicle.type == "spider-vehicle" then
        if (vehicle.name == "spidertron") then
            max_speed_default = 41

            grid_movement_bonus = 0.0
            for i, e in ipairs(vehicle.grid.equipment) do
                grid_movement_bonus = grid_movement_bonus + e.movement_bonus
            end

            max_speed = max_speed_default * (1 + grid_movement_bonus)

            -- vehicle.grid.inhibit_movement_bonus -- no not work

        else
            max_speed = 0
        end
    else
        max_speed = 0
    end
    return max_speed

end

local function shortE(e)
    suffix = "TJ"
    if (e > 1e12) then
        suffix = "TJ"
        e = e / 1e12;
    elseif (e > 1e9) then
        suffix = "GJ"
        e = e / 1e9;
    elseif (e > 1e6) then
        suffix = "MJ"
        e = e / 1e6;
    elseif (e > 1e3) then
        suffix = "kJ"
        e = e / 1e3;
    else
        suffix = "J"
    end

    if (e > 100) then
        return string.format("%.0f%s", e, suffix)
    elseif (e > 10) then
        return string.format("%.1f%s", e, suffix)
    else
        return string.format("%.2f%s", e, suffix)
    end

end

local function sensor(player)
    if not player.mod_settings["statsgui-ms-show-sensor"].value or player.character == nil then
        return
    end

    if prev_position and prev_tick then

        time = game.tick - prev_tick
        local dx = player.position.x - prev_position.x
        local dy = player.position.y - prev_position.y
        distance = (dx ^ 2 + dy ^ 2) ^ 0.5
    end

    prev_position = player.position
    prev_tick = game.tick

    local gui_title = ""
    local gui_value = ""
    local current_speed = "000"

    if (distance ~= nil and time ~= nil) then
        current_speed = string.format("%03.0f", distance / time * 60 * 3.6)
    end

    -- player.character_running_speed_modifier -- cheat
    -- player.vehicle.speed -- vehicle speed in stock gui
    -- player.surface.get_tile(player.position.x, player.position.y).name, player.surface
    -- player.surface.get_tile(player.position.x, player.position.y).prototype.walking_speed_modifier, player.surface
    -- player.surface.get_tile(player.position.x, player.position.y).prototype.vehicle_friction_modifier)

    if (player.driving and player.vehicle) then
        gui_title = {"statsgui-ms.title-vehicle"}

        if (player.mod_settings["statsgui-ms-max-speed-vehicle"].value) then
            max_speed = getVehicleMaxSpeed(player.vehicle)

            if (max_speed ~= 0) then
                local max = string.format("%03.0f km/h", max_speed)
                gui_value = string.format("%s/%s", current_speed, max)
            else
                gui_value = string.format("%s km/h", current_speed)
            end
        else
            gui_value = string.format("%s km/h", current_speed)
        end

    else
        if player.mod_settings["statsgui-ms-jet-fuel"] and script.active_mods["jetpack"] and
            remote.call("jetpack", "is_jetpacking", player) then
            local energy_in_inventory = 0;

            gui_title = {"statsgui-ms.title-jet"}
            local current_fuel = remote.call("jetpack", "get_current_fuel_for_character", player) -- name -- energy -- thrust
            -- local current_fuels_array = remote.call("jetpack", "get_current_fuels")
            if (current_fuel) then
                local fuels = remote.call("jetpack", "get_fuels")
                local main_inventory = player.get_inventory(defines.inventory.character_main)

                for i, fuel in pairs(fuels) do
                    if game.item_prototypes[fuel.fuel_name] then
                        stack = main_inventory.find_item_stack(fuel.fuel_name)
                        if (stack) then
                            count = main_inventory.get_item_count(fuel.fuel_name)
                            energy_in_inventory = energy_in_inventory + count * stack.prototype.fuel_value
                        end
                    end
                end
                energy_in_inventory = energy_in_inventory + current_fuel.energy
                gui_value = string.format("%s km/h, %s", current_speed, shortE(energy_in_inventory))
            end
        else
            gui_title = {"statsgui-ms.title-player"}
            if (player.mod_settings["statsgui-ms-max-speed-player"].value) then
                max_speed = floor256(player.character_running_speed) * 60 * 3.6
                relative_max_speed = player.character_running_speed / 0.15 * 100 - 100;

                if (max_speed ~= 0) then
                    local max = string.format("%03.0f km/h (+%.0f%%)", max_speed, relative_max_speed)
                    gui_value = string.format("%s/%s", current_speed, max)
                else
                    gui_value = string.format("%s km/h", current_speed)
                end
            else
                gui_value = string.format("%s km/h", current_speed)
            end
        end
    end

    return {"", gui_title, gui_value}

end

local function register_sensor()
    -- always call the `version` function first to avoid crashes if the interface changes in the future
    if script.active_mods["StatsGui"] and remote.call("StatsGui", "version") == 1 then
        remote.call("StatsGui", "add_sensor", "StatsGui-MovementSpeed", "speed_sensor")
    end
end

script.on_init(function()
    register_sensor()
end)

script.on_load(function()
    register_sensor()
end)

remote.add_interface("StatsGui-MovementSpeed", {
    speed_sensor = sensor
})

--[[
script.on_event(defines.events.on_player_driving_changed_state, function(event)
    local player = game.players[event.player_index]

end)
]]
