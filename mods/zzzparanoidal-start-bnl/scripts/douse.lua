-- Pouring water from the hand: left click with a water barrel in the cursor. On a burning start
-- wreck (or the starliner) under the cursor the fire goes out at once with a big steam cloud;
-- anywhere else the water spills over the ground and puts out ordinary fires (grass, trees, fuel
-- pools) around the click, the scripted wreck fires keep burning. One barrel per click, within the
-- character's reach; the empty barrel drops next to the player. Runs only on the click.
local config = require("bnl-config")
local util = require("scripts.util")
local events = require("scripts.events")
local fire = require("scripts.fire")
local M = {}
local cfg = config.fire.water

local WATER = {}
for _, name in ipairs(cfg.items) do WATER[name] = true end
local EMPTY = "barrel"

local function use_barrel(player)
    local stack = player.cursor_stack
    if stack.count > 1 then stack.count = stack.count - 1 else stack.clear() end
    if prototypes.item[EMPTY] then
        player.surface.spill_item_stack({position = player.position, stack = {name = EMPTY, count = 1},
            enable_looted = true, allow_belts = false})
    end
end

local function on_click(event)
    local player = game.get_player(event.player_index)
    if not (player and player.character) then return end
    local stack = player.cursor_stack
    if not (stack and stack.valid_for_read and WATER[stack.name]) then return end
    local target = player.selected
    if target and target.valid and fire.is_burning(target) then
        if not player.can_reach_entity(target) then return end
        use_barrel(player)
        fire.quench_by_hand(target)
        if player.opened == target then player.opened = nil end -- the click also opened the wreck
        return
    end
    local position = event.cursor_position
    if util.distance(player.position, position) > player.reach_distance then return end
    use_barrel(player)
    local surface = player.surface
    for _, flame in pairs(surface.find_entities_filtered({type = "fire", position = position, radius = cfg.spill_radius})) do
        if flame.valid then flame.destroy() end
    end
    fire.steam(surface, position, 1, 4, "bnl-steam-small")
end

events.on("bnl-douse", on_click)

return M
