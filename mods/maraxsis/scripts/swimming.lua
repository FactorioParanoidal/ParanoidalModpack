local rro = require("__PlanetsLib__.lib.remove-replace-object")
local function transfer_equipment_grid(old_armor, new_armor)
    local old_armor_grid = old_armor.grid
    local new_armor_grid = new_armor.grid

    if not old_armor_grid then return end
    assert(new_armor_grid)

    for _, equipment in pairs(old_armor_grid.equipment) do
        local is_ghost = equipment.type == "equipment-ghost"
        local new_equipment = new_armor_grid.put {
            name = is_ghost and equipment.ghost_name or equipment.name,
            position = equipment.position,
            quality = equipment.quality,
            ghost = is_ghost, -- vanilla bug: this just deletes the ghosts if true
        }
        if not new_equipment then goto continue end
        new_equipment.energy = equipment.energy
        if equipment.type == "energy-shield-equipment" then
            new_equipment.shield = equipment.shield
        elseif equipment.type == "generator-equipment" and equipment.burner then
            new_equipment.burner.heat = equipment.burner.heat
            new_equipment.burner.currently_burning = equipment.burner.currently_burning
            new_equipment.burner.remaining_burning_fuel = equipment.burner.remaining_burning_fuel
            for target_inventory, source_inventory in pairs{
                [new_equipment.burner.inventory] = equipment.burner.inventory,
                [new_equipment.burner.burnt_result_inventory] = equipment.burner.burnt_result_inventory,
            } do
                for i = 1, #source_inventory do
                    local stack = source_inventory[i]
                    if stack and stack.valid_for_read then
                        stack.swap_stack(target_inventory[i])
                    end
                end
            end
        end
        ::continue::
    end

    new_armor_grid.inhibit_movement_bonus = old_armor_grid.inhibit_movement_bonus
end

local function reset_inventory_slots_bonus(force)
    if not force.valid then return end
    force.character_inventory_slots_bonus = math.max(10, force.character_inventory_slots_bonus - 5000)
end
maraxsis.register_delayed_function("reset_inventory_slots_bonus", reset_inventory_slots_bonus)

local function transfer_armor_item(player, armor, target_armor_name)
    if not player.valid then return end
    if not armor.valid or not armor.valid_for_read then return end
    if not prototypes.item[target_armor_name] then return end

    local force = player.force
    local temp_inventory = game.create_inventory(1)
    local stack = temp_inventory[1]

    stack.set_stack {
        name = target_armor_name,
        count = 1,
        quality = armor.quality,
        health = armor.health,
        spoil_percent = armor.spoil_percent
    }

    transfer_equipment_grid(armor, stack)
    force.character_inventory_slots_bonus = force.character_inventory_slots_bonus + 5000
    armor.set_stack(stack)
    temp_inventory.destroy()
    maraxsis.execute_later("reset_inventory_slots_bonus", 1, force)
end
maraxsis.register_delayed_function("transfer_armor_item", transfer_armor_item)

-- in order for the swimming animation to work, we must swap the players armor to an identical armor prototype but with mech suit flight
local function update_armor(player)
    local armor_inventory
    if player.controller_type == defines.controllers.editor then
        armor_inventory = player.get_inventory(defines.inventory.editor_armor)
    else
        armor_inventory = player.get_inventory(defines.inventory.character_armor)
    end
    if not armor_inventory or armor_inventory.is_empty() then return end

    local armor = armor_inventory[1]
    if not armor.valid_for_read then return end

    local armor_name = armor.name
    local target_armor_name
    local physical_surface = player.physical_surface
    local started_swimming = not not maraxsis_constants.MARAXSIS_SURFACES[physical_surface.name]
    if started_swimming then
        target_armor_name = armor_name .. "-maraxsis-swimming"
    else
        target_armor_name = armor_name:gsub("%-maraxsis%-swimming", "")
    end

    if armor_name == target_armor_name then return end

    -- teleport the player to a safe location
    if not started_swimming and player.character then
        local character = player.character

        local currently_collides = character.surface.entity_prototype_collides(character.name, character.position, false)
        if currently_collides then
            local safe_location = character.surface.find_non_colliding_position(character.name, character.position, 32, 0.5)
            if safe_location then
                character.teleport(safe_location)
                maraxsis.execute_later("transfer_armor_item", 30, player, armor, target_armor_name)
                return
            end
        end
    end

    transfer_armor_item(player, armor, target_armor_name)
end

maraxsis.on_event({
    defines.events.on_player_changed_surface,
    defines.events.on_player_respawned,
    defines.events.on_player_driving_changed_state,
    defines.events.on_player_armor_inventory_changed,
    defines.events.on_player_cheat_mode_enabled,
    defines.events.on_player_controller_changed,
}, function(event)
    local player = game.get_player(event.player_index)
    update_armor(player)
end)

maraxsis.on_nth_tick(537, function(event)
    for _, player in pairs(game.connected_players) do
        update_armor(player)
    end
end)

maraxsis.on_event(defines.events.on_player_cursor_stack_changed, function(event)
    local player = game.get_player(event.player_index)
    local cursor_stack = player.cursor_stack
    if not cursor_stack.valid_for_read then return end

    local cursor_stack_name = cursor_stack.name
    if not cursor_stack_name:find("-maraxsis-swimming", 1, true) then return end

    local target_stack_name = cursor_stack_name:gsub("%-maraxsis%-swimming", "")
    transfer_armor_item(player, cursor_stack, target_stack_name)
end)

local function get_other_surface(surface)
    if surface.name == "maraxsis" then 
        return "maraxsis-trench"
    elseif surface.name == "maraxsis-trench" then
        return "maraxsis"
    else
        return nil
    end

end

local function switch_surface(player)
    
    if player.selected then return end
    if player.controller_type ~= defines.controllers.remote then return end
    local surface = player.surface
    local to_surface = get_other_surface(surface)
    
    if not to_surface then
        return
    end
    
    --if not tile.valid then return end
    --if tile.name ~= "maraxsis-trench-entrance" then return end

    local trench = game.planets[to_surface].surface
    if not trench then return end
    local old_zoom = player.zoom
    player.set_controller {
        position = player.position,
        surface = trench,
        type = defines.controllers.remote,
        zoom = player.zoom,
    }
    player.zoom=old_zoom
end
-- https://github.com/notnotmelon/maraxsis/issues/255 <- Rest in peace :(
maraxsis.on_event("factory-open-outside-surface-to-remote-view", function(event)
    local player = game.get_player(event.player_index)
    switch_surface(player)
end)

local switch_surface_button_name = "maraxsis-switch-surface-button"
local switch_surface_button_pattern =  "maraxsis%-switch%-surface%-button"


maraxsis.on_event({defines.events.on_player_controller_changed,defines.events.on_player_changed_surface},function(event)
    local player = game.players[event.player_index]
    local top = player.gui.top
    local surface = player.surface
    if not rro.contains({"maraxsis","maraxsis-trench"},surface.name) then 
        if top[switch_surface_button_name] then
            top[switch_surface_button_name].destroy()
        end
        return

    end
    if player.controller_type == defines.controllers.remote then
        if top[switch_surface_button_name] then
            top[switch_surface_button_name].destroy()
        end
        local other_surface_prototype = game.planets[get_other_surface(surface)].prototype
        if not game.planets[get_other_surface(surface)].surface then return end
        local width = maraxsis.get_gui_locale(player.locale).switch_surface_button_width
        local switch_surface_button = top.add{
            type="button",
            name = switch_surface_button_name,
            caption = {"gui.maraxsis-change-surfaces",other_surface_prototype.localised_name,other_surface_prototype.name},
            tooltip = {"gui-tooltip.maraxsis-change-surfaces"},
        }
        
        switch_surface_button.style.minimal_width = width
        switch_surface_button.style.maximal_width = width
    else
        if top[switch_surface_button_name] then
            top[switch_surface_button_name].destroy()
        end
        
    end

end)

_G.gui_events[defines.events.on_gui_click][switch_surface_button_pattern] = function(event)
    local player = game.get_player(event.player_index)
    switch_surface(player)



end
