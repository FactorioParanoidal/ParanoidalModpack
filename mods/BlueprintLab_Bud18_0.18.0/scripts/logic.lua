require "common"
require "init-lab"

function OnLabButton(player_index)
    local player = game.players[player_index]
    local playerData = global[player_index]

    if playerData.inTheLab then
        ToTheWorld(player_index)
    else
        InitLab(player.force)
        ToTheLab(player_index)
    end

    UpdateGui(player_index)
end

function BringBlueprint(player, cursor)
    if not IsBlueprintOrBook(cursor) then return end

    player.cursor_stack.set_stack(cursor)
end

function ToTheLab(player_index)
    local player = game.players[player_index]
    local playerData = global[player_index]

    if playerData.inTheLab then
        player.print "invalid operation, player already in the lab."
        return
    end

    playerData.character = player.character
	player.set_controller({type = defines.controllers.god})
    player.teleport({0, 0}, LabName(player.force))

    BringBlueprint(player, playerData.character.cursor_stack)

    player.cheat_mode = true
	player.force.recipes["electric-energy-interface"].enabled = true
	player.force.recipes["infinity-chest"].enabled = true
	player.force.recipes["infinity-pipe"].enabled = true

    playerData.inTheLab = true
end

function ToTheWorld(player_index)
    local player = game.players[player_index]
    local playerData = global[player_index]

    if not playerData.inTheLab then
        player.print "invalid operation, player already in the world."
        return
    end

    player.cheat_mode = false
	player.force.recipes["electric-energy-interface"].enabled = false
	player.force.recipes["infinity-chest"].enabled = false
	player.force.recipes["infinity-pipe"].enabled = false

    DropBlueprints(player, player.get_main_inventory())
    local blueprint = ReturnBlueprintExport(player)

    player.teleport({0, 0}, playerData.character.surface)
	player.set_controller({type = defines.controllers.character, character = playerData.character})
    playerData.character = nil

    ReturnBlueprintImport(player, blueprint)

    playerData.inTheLab = false
end

function DropBlueprints(player, inventory)
    for i = 1, #inventory do
        local stack = inventory[i]

        if IsBlueprintOrBook(stack) and stack.export_stack() ~= EmptyBlueprintString then
            player.surface.spill_item_stack({0, 4}, stack)
        end
    end
end

function ReturnBlueprintExport(player)
    if not IsBlueprintOrBook(player.cursor_stack) then return end

    local blueprint = player.cursor_stack.export_stack()
    if blueprint == EmptyBlueprintString then return end

    return blueprint
end

function ReturnBlueprintImport(player, blueprint)
    if not blueprint then return end

    if not player.clean_cursor() then
        player.surface.spill_item_stack(player.position, player.cursor_stack)
    end

    player.cursor_stack.import_stack(blueprint)
end

function WhereAmI(player_index)
    local player = game.players[player_index]
    local playerData = global[player_index]

    if playerData.inTheLab then
        player.print "in the lab"
    else
        player.print "in the world"
    end
end

function ClearLab(player_index)
    local player = game.players[player_index]
    local playerData = global[player_index]

    if not playerData.inTheLab then
        player.print "invalid operation, player not in the lab."
        return
    end

    --player.print "clearing the lab"

    for _, entity in pairs(player.surface.find_entities()) do
		DestroyEntity(entity, player_index)
    end
    for _, tile in pairs(player.surface.find_tiles_filtered {has_hidden_tile = true}) do
        DestroyTile(tile, player.surface)
    end
	EquipLab(player.surface, player.force)
end
