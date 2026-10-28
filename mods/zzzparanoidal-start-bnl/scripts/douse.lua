-- Left click with a barrel or fuel in the cursor (custom input "bnl-douse"). The click handler (and
-- the "too hot" guard of opened GUIs) exists only during the start fires: while the fire watch runs
-- or anything burns (scripts/fire.lua refreshes the events when both end); after that nothing of
-- this listens any more.
-- * Water barrel: a click anywhere within reach puts out everything within config.fire.water.radius
--   of the spot: every burning start wreck (or the starliner) reaching into it (big steam cloud) and
--   the ordinary fires (grass, trees, fuel pools). What was put out stays wet for
--   config.fire.water.calm (scripts/fire.lua): it does not catch fire again, setting it alight only
--   makes white steam. One barrel per click; the empty barrel goes back into the inventory.
-- * Empty barrel on a water tile within reach: every empty barrel in the inventory is filled.
-- * Fuel (a fuel or gas barrel, oxygen, solid fuel and better) thrown on a burning wreck or burning
--   ground: it flares up as config.fire.misuse.fires ordinary ground fires around the spot; each goes
--   out by itself after misuse.seconds and meanwhile burns and lights what is next to it by the usual
--   rules of fire.
-- * Any other left click on a burning wreck: "too hot" (it cannot be opened, only put out).
local config = require("bnl-config")
local util = require("scripts.util")
local events = require("scripts.events")
local fire = require("scripts.fire")
local scheduler = require("scripts.scheduler")
local M = {}
local cfg = config.fire.water
local misuse = config.fire.misuse

local WATER = {}
for _, name in ipairs(cfg.items) do WATER[name] = true end
local EMPTY = "barrel"
local FILLED = "water-barrel"

-- Fuel that must never be thrown into a fire: the hazards of the wrecks (fuel and gas barrels,
-- high-tech fuel, oxygen), every barrel of a fluid that burns and every chemical fuel of at least
-- misuse.min_fuel_value (solid fuel and better, also in canisters). Coal, wood and coke do not count.
local fuel_cache = {}
local listed = {}
for _, kind in ipairs({"barrel", "gas", "fuel", "oxygen"}) do
    local spec = config.fire.hazards[kind]
    for _, entry in ipairs(spec and spec.items or {}) do listed[entry[1]] = true end
end
local function is_fuel(name)
    local known = fuel_cache[name]
    if known ~= nil then return known end
    local item = prototypes.item[name]
    local result = false
    if item and not WATER[name] then
        if listed[name] then
            result = true
        elseif item.fuel_value >= misuse.min_fuel_value and item.fuel_category ~= "nuclear" then
            result = true
        elseif name:sub(-7) == "-barrel" then
            local fluid = prototypes.fluid[name:sub(1, -8)]
            result = fluid ~= nil and fluid.fuel_value > 0
        end
    end
    fuel_cache[name] = result
    return result
end

local function take_one(player)
    local stack = player.cursor_stack
    local name = stack.name
    if stack.count > 1 then stack.count = stack.count - 1 else stack.clear() end
    return name
end

-- The empty barrel goes back into the inventory (ready to be filled at water), onto the ground only
-- when there is no room.
local function drop_empty(player, name)
    if name:sub(-7) == "-barrel" and prototypes.item[EMPTY] then
        local character = player.character
        if character and character.insert({name = EMPTY, count = 1}) > 0 then return end
        character.surface.spill_item_stack({position = character.position, stack = {name = EMPTY, count = 1},
            enable_looted = true, allow_belts = false})
    end
end

local function burning_here(surface, target, position)
    if target and target.valid and fire.is_burning(target) then return true end
    return surface.count_entities_filtered({type = "fire", position = position, radius = cfg.spill_radius, limit = 1}) > 0
end

-- The fuel hits the fire: a flare-up and ordinary ground fires around that go out by themselves.
local function flare_up(player, surface, position)
    surface.create_entity({name = "big-explosion", position = position})
    local fires = {}
    for _ = 1, util.int(misuse.fires) do
        local p = util.add(position, util.vector(math.random(), util.float(misuse.radius)))
        local flame = fire.make_fire(surface, p, misuse.flames)
        if flame then fires[#fires + 1] = flame end
    end
    for _, flame in ipairs(fires) do
        scheduler.after(util.int({misuse.seconds[1] * 60, misuse.seconds[2] * 60}), "douse-fire-out", {fire = flame})
    end
    player.print({"bnl.fuel-on-fire"}, {color = {r = 1, g = 0.45, b = 0.15}})
end

scheduler.handler("douse-fire-out", function(job)
    local flame = job.fire
    if flame and flame.valid then flame.destroy() end
end)

local function fill_barrels(player)
    local character = player.character
    local inventory = character and character.get_main_inventory()
    if not (inventory and prototypes.item[FILLED]) then return false end
    local count = player.cursor_stack.count + inventory.get_item_count(EMPTY)
    if count <= 0 then return false end
    player.cursor_stack.set_stack({name = FILLED, count = player.cursor_stack.count})
    local removed = inventory.remove({name = EMPTY, count = count})
    if removed > 0 then
        local inserted = inventory.insert({name = FILLED, count = removed})
        if inserted < removed then
            character.surface.spill_item_stack({position = character.position, stack = {name = FILLED, count = removed - inserted},
                enable_looted = true, allow_belts = false})
        end
    end
    player.play_sound({path = "utility/inventory_move"})
    return true
end

local function too_hot(player, target)
    if target and target.valid and fire.is_burning(target) and player.can_reach_entity(target) then
        fire.too_hot(player, target)
    end
end

local function on_click(event)
    local player = game.get_player(event.player_index)
    -- only the body acts: in the remote view (map, camera) the cursor is far from the character
    if not (player and player.character and player.controller_type == defines.controllers.character) then return end
    local character = player.character
    local position = event.cursor_position
    local surface = character.surface
    if surface ~= player.surface then return end
    local stack = player.cursor_stack
    local name = stack and stack.valid_for_read and stack.name or nil
    local target = player.selected
    if not name then
        too_hot(player, target) -- an empty hand would open it
        return
    end
    local in_reach = util.distance(character.position, position) <= player.reach_distance
    if name == EMPTY then
        if in_reach and surface.get_tile(position.x, position.y).collides_with("water_tile") then
            fill_barrels(player)
        else
            too_hot(player, target)
        end
        return
    end
    if WATER[name] then
        if not in_reach then return end
        drop_empty(player, take_one(player))
        if fire.quench_area(surface, position, cfg.radius) > 0 then
            if target and player.opened == target then player.opened = nil end -- the click also opened the wreck
        end
        fire.steam(surface, position, 1, 4, "bnl-steam-small")
        return
    end
    if is_fuel(name) and in_reach and burning_here(surface, target, position) then
        drop_empty(player, take_one(player))
        if player.opened == target then player.opened = nil end
        flare_up(player, surface, target and target.valid and target.position or position)
        return
    end
    too_hot(player, target) -- an item in hand would go into it
end

-- The start fires are on: the fire watch runs or something burns (storage only, see events.lua).
local function start_fires()
    local s = storage.bnl and storage.bnl.fire
    return s ~= nil and (s.watching == true or s.ticking == true)
end

events.dynamic("bnl-douse", on_click, start_fires)
events.dynamic(defines.events.on_gui_opened, fire.on_gui_opened, start_fires)

return M
