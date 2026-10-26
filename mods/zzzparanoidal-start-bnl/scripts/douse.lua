-- Left click with a barrel or fuel in the cursor (custom input "bnl-douse"); runs only on the click,
-- plus a short on_tick while a cursor is on fire.
-- * Water barrel: on a burning start wreck (or the starliner) under the cursor the fire goes out at
--   once with a big steam cloud; anywhere else the water spills over the ground and puts out
--   ordinary fires (grass, trees, fuel pools) around the click, the scripted wreck fires keep burning.
--   One barrel per click within reach; the empty barrel drops next to the player.
-- * Empty barrel on a water tile within reach: every empty barrel in the inventory is filled.
-- * Fuel (a fuel or gas barrel, oxygen, solid fuel and better) on a burning wreck or burning ground:
--   a huge fireball, every building around catches fire, the player burns for a while and for
--   config.fire.misuse.cursor_ticks the cursor itself burns: whatever it points at (player.selected,
--   the player too) catches fire, every click sets the ground alight, a loud fire sound plays.
local config = require("bnl-config")
local util = require("scripts.util")
local events = require("scripts.events")
local fire = require("scripts.fire")
local M = {}
local cfg = config.fire.water
local misuse = config.fire.misuse

local WATER = {}
for _, name in ipairs(cfg.items) do WATER[name] = true end
local EMPTY = "barrel"
local FILLED = "water-barrel"

-- Fuel that must never be poured on a fire: the hazards of the wrecks (fuel and gas barrels, high-tech
-- fuel, oxygen), every barrel of a fluid that burns and every chemical fuel of at least
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

local function cursor_state()
    local s = storage.bnl
    if not s then return nil end
    s.cursor_fire = s.cursor_fire or {}
    return s.cursor_fire
end

local function take_one(player)
    local stack = player.cursor_stack
    local name = stack.name
    if stack.count > 1 then stack.count = stack.count - 1 else stack.clear() end
    return name
end

local function drop_empty(player, name)
    if name:sub(-7) == "-barrel" and prototypes.item[EMPTY] then
        player.surface.spill_item_stack({position = player.position, stack = {name = EMPTY, count = 1},
            enable_looted = true, allow_belts = false})
    end
end

local function burning_here(surface, target, position)
    if target and target.valid and fire.is_burning(target) then return true end
    return surface.count_entities_filtered({type = "fire", position = position, radius = cfg.spill_radius, limit = 1}) > 0
end

local function flames(surface, position, count)
    surface.create_entity({name = "fire-flame", position = position, initial_ground_flame_count = count or 4})
end

local function set_on_fire(entity)
    if not (entity and entity.valid) then return end
    if entity.type == "character" then
        local sticker = entity.surface.create_entity({name = "fire-sticker", position = entity.position, target = entity})
        if sticker and sticker.valid then sticker.time_to_live = misuse.player_burn_ticks end
        return
    end
    if fire.is_tracked(entity) then fire.ignite(entity) end
    flames(entity.surface, entity.position, 3)
end

-- The fuel hits the fire: a huge fireball, the buildings around burn, the player and the cursor too.
local function catastrophe(player, surface, position)
    surface.create_entity({name = "massive-explosion", position = position})
    for _ = 1, misuse.blasts do
        local a, r = math.random() * 2 * math.pi, misuse.fireball_radius * math.sqrt(math.random())
        local p = {x = position.x + r * math.cos(a), y = position.y + r * math.sin(a)}
        surface.create_entity({name = math.random() < 0.5 and "big-explosion" or "massive-explosion", position = p})
        flames(surface, p, 6)
    end
    local hit = 0
    for _, entity in pairs(surface.find_entities_filtered({position = position, radius = misuse.building_radius,
        force = {"player", "neutral"}})) do
        if hit >= misuse.max_buildings then break end
        if entity.valid and entity.type ~= "character" and (entity.is_entity_with_health or fire.is_tracked(entity)) then
            set_on_fire(entity)
            hit = hit + 1
        end
    end
    local character = player.character
    if character then set_on_fire(character) end
    local s = cursor_state()
    s[player.index] = {until_tick = game.tick + misuse.cursor_ticks, next_sound = game.tick, last = nil}
    player.play_sound({path = "bnl-cursor-fire", volume_modifier = 1})
    player.print({"bnl.fuel-on-fire"}, {color = {r = 1, g = 0.45, b = 0.15}})
    events.refresh()
end

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
            player.surface.spill_item_stack({position = player.position, stack = {name = FILLED, count = removed - inserted},
                enable_looted = true, allow_belts = false})
        end
    end
    player.play_sound({path = "utility/inventory_move"})
    return true
end

local function on_click(event)
    local player = game.get_player(event.player_index)
    if not (player and player.character) then return end
    local position = event.cursor_position
    local surface = player.surface
    -- a burning cursor sets every clicked spot alight
    local burning = cursor_state()
    if burning and burning[player.index] and util.distance(player.position, position) <= player.reach_distance * 2 then
        flames(surface, position, 4)
    end
    local stack = player.cursor_stack
    if not (stack and stack.valid_for_read) then return end
    local name = stack.name
    local target = player.selected
    local in_reach = util.distance(player.position, position) <= player.reach_distance
    if name == EMPTY then
        if in_reach and surface.get_tile(position.x, position.y).collides_with("water_tile") then fill_barrels(player) end
        return
    end
    if WATER[name] then
        if target and target.valid and fire.is_burning(target) then
            if not player.can_reach_entity(target) then return end
            drop_empty(player, take_one(player))
            fire.quench_by_hand(target)
            if player.opened == target then player.opened = nil end -- the click also opened the wreck
            return
        end
        if not in_reach then return end
        drop_empty(player, take_one(player))
        for _, flame in pairs(surface.find_entities_filtered({type = "fire", position = position, radius = cfg.spill_radius})) do
            if flame.valid then flame.destroy() end
        end
        fire.steam(surface, position, 1, 4, "bnl-steam-small")
        return
    end
    if is_fuel(name) and in_reach and burning_here(surface, target, position) then
        drop_empty(player, take_one(player))
        if player.opened == target then player.opened = nil end
        catastrophe(player, surface, target and target.valid and target.position or position)
    end
end

events.on("bnl-douse", on_click)

-- The burning cursor: every misuse.cursor_interval ticks whatever the player points at catches fire,
-- with a big flame drawn on it; the fire sound repeats while it lasts.
local function on_tick(event)
    local tick = event.tick
    if tick % misuse.cursor_interval ~= 0 then return end
    local s = cursor_state()
    for index, rec in pairs(s) do
        local player = game.get_player(index)
        if not (player and player.valid and player.connected) or tick >= rec.until_tick then
            s[index] = nil
        else
            local target = player.selected
            if target and target.valid then
                if target ~= rec.last or math.random() < 0.3 then set_on_fire(target) end
                rec.last = target
                rendering.draw_animation({animation = "bnl-torch-blaze", surface = target.surface, target = target,
                    x_scale = 1.6, y_scale = 1.6, render_layer = "air-object", time_to_live = misuse.cursor_interval + 2})
            end
            if tick >= rec.next_sound then
                rec.next_sound = tick + misuse.sound_interval
                player.play_sound({path = "bnl-cursor-fire", volume_modifier = 1})
            end
            player.play_sound({path = "bnl-cursor-crackle", volume_modifier = 1})
        end
    end
    if not next(s) then events.refresh() end
end

events.dynamic(defines.events.on_tick, on_tick, function()
    local s = storage.bnl and storage.bnl.cursor_fire
    return s ~= nil and next(s) ~= nil
end)

return M
