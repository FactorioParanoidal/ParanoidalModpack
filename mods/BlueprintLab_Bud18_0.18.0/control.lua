require "scripts.gui"
require "scripts.updates"
require "scripts.lab-effects"

function InitAllPlayers()
    for _, player in pairs(game.players) do
        InitPlayer(player.index)
    end
end

function InitPlayer(player_index)
    if global[player_index] then return end

    global[player_index] = {}
    CreateGui(player_index)    
end

script.on_init(function()
    InitAllPlayers()
end)

script.on_configuration_changed(function(event)
    if event.mod_changes 
        and event.mod_changes["TheBlueprintLab_bud"]
        and event.mod_changes["TheBlueprintLab_bud"].old_version == "0.0.1" then
        ClearVersion001()
        InitAllPlayers()
    end
end)

script.on_event(defines.events.on_player_created, function(event)
    InitPlayer(event.player_index)
end)

--gui
script.on_event(defines.events.on_gui_click, OnGuiClick)
script.on_event("BPL_LabButtonHotkey", OnLabButtonHotkey)

--cheats
script.on_event(defines.events.on_marked_for_deconstruction, OnMarkedForDeconstruction)
script.on_event(defines.events.on_built_entity, OnBuiltEntity)