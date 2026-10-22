-- Code for teleporting players
local Teleport = {}

-- Center the player on the current surface
---@param player LuaPlayer
---@param surface LuaSurface
---@param position MapPosition
local function TeleportToPositionOnSurface(player, surface, position)
    if player.controller_type == defines.controllers.remote then
        player.set_controller({
            type = defines.controllers.remote,
            surface = surface,
            position = position,
        })
    else
        player.teleport(position, surface)
    end
end

-- Center the player on the current surface
---@param player LuaPlayer
function Teleport.ToCenterOfSurface(player)
    TeleportToPositionOnSurface(player, player.surface, { 0, 0 })
end

-- Moves the player to a new position on a different surface
---@param player LuaPlayer
---@param surface LuaSurface
---@param position MapPosition
function Teleport.ToPositionOnSurface(player, surface, position)
    TeleportToPositionOnSurface(player, surface, position)
end

return Teleport
