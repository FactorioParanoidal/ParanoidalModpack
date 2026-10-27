-- Left click with a barrel or fuel in the cursor (custom input "bnl-douse"); runs only on the click,
-- plus an on_tick every config.fire.misuse.cursor_interval while a character or a cursor is on fire.
-- * Water barrel: on a burning start wreck (or the starliner) under the cursor the fire goes out at
--   once with a big steam cloud; anywhere else the water spills over the ground and puts out
--   ordinary fires (grass, trees, fuel pools) and burning characters around the click, the scripted
--   wreck fires keep burning. What was put out stays wet for config.fire.water.calm (scripts/fire.lua):
--   it does not catch fire again, setting it alight only makes white steam.
--   One barrel per click within reach; the empty barrel goes back into the inventory.
-- * Empty barrel on a water tile within reach: every empty barrel in the inventory is filled.
-- * Fuel (a fuel or gas barrel, oxygen, solid fuel and better) on a burning wreck or burning ground:
--   a huge fireball, every building around catches fire, the player burns and, while the player's
--   character burns, the cursor burns too: whatever it points at (player.selected) catches fire and
--   shows a flame, every click sets the ground alight, a loud fire sound plays.
-- * A burning character: a harmless sticker with flames (prototypes/bnl-water.lua) and a scripted
--   fire damage of config.fire.misuse.player_burn_share of its max health every second (fire
--   resistance of the armor applies) for player_burn_ticks, or until water is poured next to it.
-- * Any other left click on a burning wreck: "too hot" (it cannot be opened, only put out).
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
local STICKER = "bnl-burning-sticker"

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

-- player index -> {char = unit number of the character whose fire it follows, last, flame, next_sound}
local function cursor_state()
    local s = storage.bnl
    if not s then return nil end
    s.cursor_fire = s.cursor_fire or {}
    return s.cursor_fire
end

-- character unit number -> {entity, until_tick, next_damage, sticker, flame}
local function burning_state()
    local s = storage.bnl
    if not s then return nil end
    s.burning_characters = s.burning_characters or {}
    return s.burning_characters
end

-- character unit number -> tick until it stays wet
local function wet_state()
    local s = storage.bnl
    if not s then return nil end
    s.wet_characters = s.wet_characters or {}
    return s.wet_characters
end

local function is_wet_character(character)
    local wet = wet_state()
    local till = wet and wet[character.unit_number]
    if till and till > game.tick then return true end
    return fire.is_wet(character.surface, character.position)
end

local function end_cursor(index, rec)
    if rec.flame and rec.flame.valid then rec.flame.destroy() end
    cursor_state()[index] = nil
end

-- The fire of a character goes out (time is up, it died, water); `wet`: by water.
local function stop_burning(id, rec, wet)
    burning_state()[id] = nil
    if rec.sticker and rec.sticker.valid then rec.sticker.destroy() end
    if rec.flame and rec.flame.valid then rec.flame.destroy() end
    local character = rec.entity
    if wet and character.valid then
        local list = wet_state()
        local tick = game.tick
        for unit, till in pairs(list) do
            if till <= tick then list[unit] = nil end
        end
        list[id] = tick + cfg.calm
        fire.steam(character.surface, character.position, 0.8, 10, "bnl-steam-small")
    end
    -- the burning cursor of its player goes out with it
    for index, cursor in pairs(cursor_state()) do
        if cursor.char == id then end_cursor(index, cursor) end
    end
end

-- Sets a character burning or, when it burns already, sets its time back to player_burn_ticks.
local function burn_character(character)
    if not (character.valid and character.destructible) then return end
    if is_wet_character(character) then
        fire.hiss(character.surface, character.position)
        return
    end
    local s = burning_state()
    if not s then return end
    local tick, id = game.tick, character.unit_number
    local rec = s[id]
    if not rec then
        rec = {entity = character, next_damage = tick + misuse.player_burn_interval}
        s[id] = rec
    end
    rec.until_tick = tick + misuse.player_burn_ticks
    if not (rec.sticker and rec.sticker.valid) then
        rec.sticker = character.surface.create_entity({name = STICKER, position = character.position, target = character})
    end
    if rec.sticker and rec.sticker.valid then rec.sticker.time_to_live = misuse.player_burn_ticks end
    if not (rec.flame and rec.flame.valid) then
        local scale = 1.1
        rec.flame = rendering.draw_animation({animation = "bnl-torch-blaze", surface = character.surface,
            target = {entity = character, offset = {0, -config.fire.torches.lift["bnl-torch-blaze"] * scale}},
            x_scale = scale, y_scale = scale, render_layer = "higher-object-under",
            animation_offset = math.random(0, 59)})
    end
    events.refresh()
end

-- Water poured at `position`: burning characters around (and the one clicked) are put out and stay wet.
local function douse_characters(surface, position, radius, target)
    local s = storage.bnl and storage.bnl.burning_characters
    if not s then return end
    for id, rec in pairs(s) do
        local character = rec.entity
        if character.valid and character.surface == surface
            and (character == target or util.distance(character.position, position) <= radius + 0.5) then
            stop_burning(id, rec, true)
        end
    end
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
        player.surface.spill_item_stack({position = player.position, stack = {name = EMPTY, count = 1},
            enable_looted = true, allow_belts = false})
    end
end

local function burning_here(surface, target, position)
    if target and target.valid and fire.is_burning(target) then return true end
    return surface.count_entities_filtered({type = "fire", position = position, radius = cfg.spill_radius, limit = 1}) > 0
end

-- Whatever the fire reaches: a character burns, a wreck catches fire, a ground fire under anything
-- else; wet things only steam.
local function set_on_fire(entity)
    if not (entity and entity.valid) then return end
    if entity.type == "character" then
        burn_character(entity)
        return
    end
    if fire.is_tracked(entity) then
        local _, why = fire.ignite(entity)
        if why == "wet" then return end
    end
    fire.make_fire(entity.surface, entity.position, 3)
end

-- The fuel hits the fire: a huge fireball, the buildings around burn, the player and the cursor too.
local function catastrophe(player, surface, position)
    surface.create_entity({name = "massive-explosion", position = position})
    for _ = 1, misuse.blasts do
        local a, r = math.random() * 2 * math.pi, misuse.fireball_radius * math.sqrt(math.random())
        local p = {x = position.x + r * math.cos(a), y = position.y + r * math.sin(a)}
        surface.create_entity({name = math.random() < 0.5 and "big-explosion" or "massive-explosion", position = p})
        fire.make_fire(surface, p, 6)
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
    if character then
        burn_character(character)
        -- the cursor burns while this character does (a wet character does not catch fire)
        local burning = storage.bnl and storage.bnl.burning_characters
        if burning and burning[character.unit_number] then
            local s = cursor_state()
            local old = s[player.index]
            if old then end_cursor(player.index, old) end
            s[player.index] = {char = character.unit_number, next_sound = game.tick}
        end
    end
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

local function too_hot(player, target)
    if target and target.valid and fire.is_burning(target) and player.can_reach_entity(target) then
        fire.too_hot(player, target)
    end
end

local function on_click(event)
    local player = game.get_player(event.player_index)
    if not (player and player.character) then return end
    local position = event.cursor_position
    local surface = player.surface
    local stack = player.cursor_stack
    local name = stack and stack.valid_for_read and stack.name or nil
    local target = player.selected
    -- a burning cursor sets every clicked spot alight (not when it pours water)
    local burning = cursor_state()
    if burning and burning[player.index] and not (name and WATER[name])
        and util.distance(player.position, position) <= player.reach_distance * 2 then
        if fire.make_fire(surface, position, 4) then
            rendering.draw_animation({animation = "bnl-torch-blaze", surface = surface,
                target = {x = position.x, y = position.y - config.fire.torches.lift["bnl-torch-blaze"] * 1.8},
                x_scale = 1.8, y_scale = 1.8, render_layer = "air-object", time_to_live = 60})
        end
    end
    if not name then
        too_hot(player, target) -- an empty hand would open it
        return
    end
    local in_reach = util.distance(player.position, position) <= player.reach_distance
    if name == EMPTY then
        if in_reach and surface.get_tile(position.x, position.y).collides_with("water_tile") then
            fill_barrels(player)
        else
            too_hot(player, target)
        end
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
        fire.wet(surface, position, cfg.spill_radius)
        douse_characters(surface, position, cfg.spill_radius, target)
        fire.steam(surface, position, 1, 4, "bnl-steam-small")
        return
    end
    if is_fuel(name) and in_reach and burning_here(surface, target, position) then
        drop_empty(player, take_one(player))
        if player.opened == target then player.opened = nil end
        catastrophe(player, surface, target and target.valid and target.position or position)
        return
    end
    too_hot(player, target) -- an item in hand would go into it
end

-- For other modules (a fire turret, a scripted fire): set a character or anything else alight the
-- same way as the misused fuel, put out burning characters around a spot as poured water does.
M.burn_character = burn_character
M.set_on_fire = set_on_fire
M.douse_characters = douse_characters

events.on("bnl-douse", on_click)
events.on(defines.events.on_gui_opened, fire.on_gui_opened)

-- Every misuse.cursor_interval ticks: burning characters take their damage once a second and go out
-- in time; a burning cursor sets whatever the player points at on fire (not the player's own
-- character) with a big flame drawn on it, the fire sound repeats while it lasts.
local function on_tick(event)
    local tick = event.tick
    -- on_tick is shared (scripts/flight.lua): nothing to do here unless something burns
    if tick % misuse.cursor_interval ~= 0 or not storage.bnl then return end
    local chars = burning_state()
    for id, rec in pairs(chars) do
        local character = rec.entity
        if character.valid and tick >= rec.next_damage then
            -- once a second including the last one: 10 s burn 30%
            rec.next_damage = tick + misuse.player_burn_interval
            character.damage(character.max_health * misuse.player_burn_share, "neutral", "fire")
        end
        if not character.valid or tick >= rec.until_tick then stop_burning(id, rec) end
    end
    local s = cursor_state()
    for index, rec in pairs(s) do
        local player = game.get_player(index)
        if not (player and player.valid and player.connected and rec.char and chars[rec.char]) then
            end_cursor(index, rec)
        else
            if rec.last and not rec.last.valid then rec.last = nil end
            local target = player.selected
            if target and not target.valid then target = nil end
            if target and target == player.character then target = nil end
            if target ~= rec.last then
                if rec.flame and rec.flame.valid then rec.flame.destroy() end
                rec.flame = nil
                if target then
                    set_on_fire(target)
                    if target.valid then
                        rec.flame = rendering.draw_animation({animation = "bnl-torch-blaze", surface = target.surface,
                            target = {entity = target, offset = {0, -0.6}}, x_scale = 1.6, y_scale = 1.6,
                            render_layer = "air-object"})
                    end
                end
            elseif target and math.random() < 0.3 then
                set_on_fire(target)
            end
            rec.last = target and target.valid and target or nil
            if tick >= rec.next_sound then
                rec.next_sound = tick + misuse.sound_interval
                player.play_sound({path = "bnl-cursor-fire", volume_modifier = 1})
            end
            player.play_sound({path = "bnl-cursor-crackle", volume_modifier = 1})
        end
    end
    if not next(s) and not next(chars) then events.refresh() end
end

events.dynamic(defines.events.on_tick, on_tick, function()
    local s = storage.bnl
    return s ~= nil and ((s.cursor_fire ~= nil and next(s.cursor_fire) ~= nil)
        or (s.burning_characters ~= nil and next(s.burning_characters) ~= nil))
end)

return M
