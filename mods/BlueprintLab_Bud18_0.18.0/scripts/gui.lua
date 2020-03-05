require "logic"
require "init-lab"

function CreateGui(player_index)
    local player = game.players[player_index]
    local playerData = global[player_index]

    playerData.flow = player.gui.left.add {type = "flow", name = "BPL_Flow"}
    playerData.button = playerData.flow.add {type = "button", name = "BPL_LabButton", 
        caption = {"bpl.LabButton"}, tooltip = {"bpl.LabButtonTooltip"}}
    --playerData.flow.add {type = "button", name = "BPL_StateButton", caption = {"bpl.StateButton"}}
end

function UpdateGui(player_index)
    local player = game.players[player_index]
    local playerData = global[player_index]

    if playerData.inTheLab then
        playerData.button.caption = {"bpl.LabButtonReturn"}
        playerData.clearButton = playerData.flow.add {type = "button", name = "BPL_ClearButton", 
            caption = {"bpl.ClearButton"}, tooltip = {"bpl.ClearButtonTooltip"}}
    else
        playerData.button.caption = {"bpl.LabButton"}
        playerData.clearButton.destroy()
    end
end

function OnGuiClick(event)
    if event.element.name == "BPL_LabButton" then
        OnLabButton(event.player_index)
    elseif event.element.name == "BPL_StateButton" then
        WhereAmI(event.player_index)
    elseif event.element.name == "BPL_ClearButton" then
        ClearLab(event.player_index)
    end
end

function OnLabButtonHotkey(event)
    OnLabButton(event.player_index)
end