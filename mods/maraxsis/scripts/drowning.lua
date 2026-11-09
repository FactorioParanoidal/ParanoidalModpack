local FULL_BREATH_NUM_TICKS = 10 * 60 * 60 -- ten minutes before you start drowning
local TRENCH_LUNG_REDUCTION = 40 -- trench kills you 40x faster
local BREATH_REGENERATION_FACTOR = 60 -- while in an air bubble, you regen air 60x faster than you would lose it
local UPDATE_RATE = 20

local function stringify_oxygen_stats(player)
    local breath = storage.breath[player.index] or FULL_BREATH_NUM_TICKS
    local time_left = breath / 60

    local surface_name = player.physical_surface.name
    local is_trench = not not maraxsis_constants.MARAXSIS_TRENCH_SURFACES[surface_name]
    if is_trench then
        time_left = time_left / TRENCH_LUNG_REDUCTION
    end
    time_left = math.ceil(time_left)

    local minutes = math.floor(time_left / 60)
    if minutes <= 9 then
        minutes = "0" .. minutes
    end
    local seconds = time_left % 60
    if seconds <= 9 then
        seconds = "0" .. seconds
    end

    return {"gui.oxygen-meter", minutes, seconds}
end

local function get_gui(player)
    local screen = player.gui.screen
    if screen.oxygen_meter then return screen.oxygen_meter end

    local frame = screen.add {
        type = "frame",
        name = "oxygen_meter",
        direction = "vertical",
        style = "invisible_frame",
        index = 1
    }

    frame.style.horizontal_align = "right"
    frame.style.vertically_squashable = true
    frame.style.natural_height = 30000
    frame.ignored_by_interaction = true

    frame.add {type = "empty-widget"}.style.vertically_stretchable = true

    frame = frame.add {
        type = "frame",
        name = "frame",
        direction = "horizontal",
    }

    frame.style.padding = 0
    frame.style.bottom_margin = 96

    local height = 12
    local oxygen = frame.add {
        type = "progressbar",
        value = 1,
        name = "oxygen",
        caption = stringify_oxygen_stats(player),
    }
    oxygen.style.bar_width = height
    oxygen.style.height = height
    oxygen.style.width = 180
    oxygen.style.color = {0.2, 0.2, 0.85}
    oxygen.style.top_padding = -3
    

    return screen.oxygen_meter
end

local function calc_color(bar_fill)
    if bar_fill == 1 then
        return {0.2, 0.2, 0.85}
    else
        return {0.85-0.65*bar_fill, 0.2+0.65*bar_fill, 0.2}
    end
    
end


local function update_gui(player)
    local breath = storage.breath[player.index] or FULL_BREATH_NUM_TICKS
    local bar_fill = breath / FULL_BREATH_NUM_TICKS
    get_gui(player).frame.oxygen.value = bar_fill
    
    get_gui(player).frame.oxygen.style.color = calc_color(bar_fill)
    
    get_gui(player).frame.oxygen.caption = stringify_oxygen_stats(player)
end

local function toggle_gui(player)
    local should_show_oxygen_bar = not not maraxsis_constants.MARAXSIS_SURFACES[player.physical_surface.name]

    if player.controller_type ~= defines.controllers.character then
        should_show_oxygen_bar = false
    end

    get_gui(player).visible = should_show_oxygen_bar
    if should_show_oxygen_bar then update_gui(player) end
end

maraxsis.on_event(maraxsis.events.on_init(), function()
    storage.breath = storage.breath or {}

    for _, player in pairs(game.players) do
        if player.gui.screen.oxygen_meter then
            player.gui.screen.oxygen_meter.destroy()
        end
        toggle_gui(player)
    end
end)

local is_abyssal_diving_gear = {
    ["maraxsis-abyssal-diving-gear"] = true,
    ["maraxsis-abyssal-diving-gear-disabled"] = true,
}

local function change_breath_amount_by(player, amount)
    local breath = storage.breath[player.index] or FULL_BREATH_NUM_TICKS
    if not amount then return end
    local delta = UPDATE_RATE * amount
    
    
    local new_breath = (breath or FULL_BREATH_NUM_TICKS) + delta
    local new_breath = math.min(FULL_BREATH_NUM_TICKS, math.max(0, new_breath))
    
    if breath == new_breath then
        return
    end

    storage.breath[player.index] = new_breath
    update_gui(player)
end

maraxsis.on_nth_tick(UPDATE_RATE, function()
    for unit_number, player in pairs(game.connected_players) do
        local character = player.character
        if not character then goto continue end
        local position = character.position
        local surface = character.surface
        local surface_name = surface.name
        local player_surface_index = surface.index

        if not maraxsis_constants.MARAXSIS_SURFACES[surface_name] then
            goto continue
        end
        local vehicle = player.physical_vehicle
        if vehicle and maraxsis_constants.SUBMARINES[vehicle.name] then
            if vehicle.energy > 0 or not vehicle.get_fuel_inventory().is_empty() then
                change_breath_amount_by(player, BREATH_REGENERATION_FACTOR)
                goto continue
            end
        end

        for _, pressure_dome_data in pairs(storage.pressure_domes) do
            local surface = pressure_dome_data.surface
            if not surface.valid then goto continue_2 end
            local surface_index = surface.index
            if surface_index ~= player_surface_index then goto continue_2 end
            local prototype = maraxsis_constants.PRESSURE_DOMES[pressure_dome_data.prototype]
            local regulator_fluidbox = pressure_dome_data.regulator_fluidbox
            if not regulator_fluidbox or not regulator_fluidbox.valid then goto continue_2 end
            local powered_and_has_fluid = (regulator_fluidbox.get_fluid_count("maraxsis-atmosphere") > 0) and regulator_fluidbox.is_crafting()
            if not powered_and_has_fluid then goto continue_2 end

            local dome_position = pressure_dome_data.position
            local x, y = position.x - dome_position.x, position.y - dome_position.y
            if is_point_in_polygon(x, y,prototype) then
                change_breath_amount_by(player, BREATH_REGENERATION_FACTOR)
                goto continue
            end

            ::continue_2::
        end

        local grid = character.grid
        if grid then
            for _, equipment in pairs(grid.equipment) do
                if is_abyssal_diving_gear[equipment.name] and equipment.energy ~= 0 then
                    change_breath_amount_by(player, BREATH_REGENERATION_FACTOR * equipment.energy / equipment.max_energy)
                end
            end
        end

        local is_trench = not not maraxsis_constants.MARAXSIS_TRENCH_SURFACES[surface_name]
        if is_trench then
            change_breath_amount_by(player, -TRENCH_LUNG_REDUCTION)
        else
            change_breath_amount_by(player, -1)
        end
        
        if breath_change ~= 0 then
            change_breath_amount_by(player, breath_change,has_abyssal_gear)
        end
        
        if storage.breath[player.index] <= 0 then
            player.play_sound{
                path = "maraxsis-submerge",
                volume_modifier = 0.5,
                override_sound_type = "weapon"
            }
            character.damage(math.min(100, math.max(10, character.max_health * 0.1)),"neutral","drowning")
        end
        if has_abyssal_gear and breath_change < 0 then
            has_abyssal_gear = false
        end
        
        ::continue::
    end
end)

maraxsis.on_event({
    defines.events.on_player_changed_surface,
    defines.events.on_player_died,
    defines.events.on_player_respawned,
    defines.events.on_player_created,
    defines.events.on_player_controller_changed,
    defines.events.on_player_toggled_map_editor,
}, function(event)
    local factors = {
        [defines.events.on_player_changed_surface] = "carry",
        [defines.events.script_raised_teleported] = "carry",
        [defines.events.on_player_died] = 0,
        [defines.events.on_player_respawned] = 0.25,
        [defines.events.on_player_created] = 1,
        [defines.events.on_player_controller_changed] = "carry",
        [defines.events.on_player_toggled_map_editor] = 1,
    }

    local player = game.get_player(event.player_index)
    if not player or not player.valid then return end

    if maraxsis_constants.MARAXSIS_SURFACES[player.physical_surface.name] then
        if factors[event.name] ~= "carry" then
            storage.breath[player.index] = FULL_BREATH_NUM_TICKS * factors[event.name]
        end
    else
        storage.breath[player.index] = nil
    end

    toggle_gui(player)
end)

maraxsis.on_event(defines.events.on_player_died, function(event)
    local player = game.get_player(event.player_index)
    if not player or not player.valid then return end
    get_gui(player).visible = false

    if player.physical_surface.name ~= maraxsis_constants.TRENCH_SURFACE_NAME then return end

    local character = player.character
    if not character then return end

    character.teleport({0, 0}, "maraxsis")
end)
