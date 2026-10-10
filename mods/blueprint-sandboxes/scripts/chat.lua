-- Chat helpers to proxy messages between Sandboxes and the normal Surfaces
local Chat = {}

-- Proxy Chats between Sandbox Force <-> Original Force
---@param event EventData.on_console_chat
function Chat.OnChat(event)
    if Isolation.IsNone() then return end
    if event.player_index == nil then
        return
    end
    local player = game.players[event.player_index]

    if Sandbox.IsPlayerInsideSandbox(player) then
        local mainForce = Force.GetPlayerMainForce(player)
        mainForce.print(player.name .. ": " .. event.message, player.chat_color)
    else
        local sandboxForce = Force.GetPlayerSandboxForce(player)
        if sandboxForce ~= nil then
            sandboxForce.print(player.name .. ": " .. event.message, player.chat_color)
        end
    end
end

return Chat
