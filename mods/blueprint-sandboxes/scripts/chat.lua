-- Chat helpers to proxy messages between Sandboxes and the normal Surfaces
local Chat = {}

-- Proxy Chats between Sandbox Force <-> Original Force
function Chat.OnChat(event)
    if event.player_index == nil then
        return
    end
    local player = game.players[event.player_index]
    local playerData = global.players[event.player_index]

    if Sandbox.IsPlayerInsideSandbox(player) then
        game.forces[playerData.forceName].print(player.name .. ": " .. event.message, player.chat_color)
    else
        local sandboxForce = game.forces[playerData.sandboxForceName]
        if sandboxForce ~= nil then
            sandboxForce.print(player.name .. ": " .. event.message, player.chat_color)
        end
    end
end

return Chat
