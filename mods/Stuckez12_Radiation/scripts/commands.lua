local player_management = require("scripts.player_management")
local mod_addons = require("scripts.mod_integrations")
local chunk_func = require("scripts.chunk_func")
local item_window = require("scripts.gui_item")

commands.add_command("radiation_add_self", "Add current character to radiation damage list", function(command)
    if command.player_index then
        local player = game.get_player(command.player_index)

        if player and player.valid and player.character.valid then
            player_management.add_character_reference(player.character)

            player.print("Stuckez12 Radiation: Player Character Added To Radiation Calculations")
            log("Player character added to radiation calculations")
        end
    end
end)


commands.add_command("radiation_remove_self", "Removes current character from radiation damage list", function(command)
    if command.player_index then
        local player = game.get_player(command.player_index)

        if player and player.valid and player.character.valid then
            player_management.remove_character_reference(player.character)

            player.print("Stuckez12 Radiation: Player Character Removed From Radiation Calculations")
            log("Player character removed from radiation calculations")
        end
    end
end)


commands.add_command("radiation_display_items", "Logs and prints all items/units that are currently classified as radiative", function(command)
    game.print("Radiative Items: -")
    game.print(serpent.block(storage.radiation_items))
    log("Radiative Items: -")
    log(serpent.block(storage.radiation_items))

    game.print("\nRadiative Fluids: -")
    game.print(serpent.block(storage.radiation_fluids))
    log("Radiative Fluids: -")
    log(serpent.block(storage.radiation_fluids))

    game.print("\nRadiative Units: -")
    game.print(serpent.block(storage.biters))
    log("Radiative Units: -")
    log(serpent.block(storage.biters))
end)


commands.add_command("radiation_refresh", "Refreshes radiation list", function(command)
    mod_addons.integrate_mods()
    game.print("Stuckez12 Radiation: Radiation item list refreshed")
    log("Radiation item list refreshed")
end)


commands.add_command("chest_migrate", "Add all chests to storage", function(command)
    storage.chunk_data = {}

    for name, surface in pairs(game.surfaces) do
        local all_chests = surface.find_entities_filtered{type = {"container", "logistic-container"}}

        for _, chest in pairs(all_chests) do
            chunk_func.add_chest(surface.index, math.floor(chest.position.x / 32), math.floor(chest.position.y / 32), chest)
            chunk_func.update_chunk_data(surface.index, math.floor(chest.position.x / 32), math.floor(chest.position.y / 32))
        end
    end

    game.print("Stuckez12 Radiation: Added all chests to memory")
    log("Adding all chests to feature memory")
end)

commands.add_command("modify_items", "Creates GUI window to change individual item radiation values", function(command)
    if command.player_index then
        
        local player = game.get_player(command.player_index)

        if player and player.valid and player.character.valid then
            item_window.create_window(player)

            log("Fluid/Item config GUI window created")
        end
    end
end)
