if not settings.startup["nanobots-auto"].value then return end

require('nanobots-common')

NanobotsAuto = {}

local Position = require('__stdlib2__/stdlib/area/position')
local table = require('__stdlib2__/stdlib/utils/table')
local Queue = require('scripts/hash_queue')

local max = math.max

local config = require('config')
require('scripts/armor-mods')
local network_limit = true --keeping this here in case i decide to bring this option back

--- Failed queue tasks are skipped at most this many times per player and tick; the rest wait
--- for the next tick. A whole queue failing in one tick (the player walked away, ran out of
--- items) used to be one long freeze.
local MAX_TRIES_PER_TICK = 10

--- A refill classifies at most this many search results. A large blueprint the player can't
--- afford used to be classified in full every second, in one tick; now each refill takes the
--- next part, starting where the previous one stopped.
local MAX_CANDIDATES_PER_FILL = 250
--- Unfinished refills in a row before the scan counts as done (sound, back to the 1 s poll):
--- together they cover more than the 707 tiles of the largest radius.
local MAX_UNFINISHED_SCANS = 3

-- ----local function forward declarations---- --
local nano_network_check
local get_gun_ammo_name
local nano_state
local forget_state
local cooldown

local queue_constructor_targets
local queue_leveler_targets
local queue_valid_targets


-- ----Public functions---- --

--- Ticks between two shots of the emitter
--- @param player LuaPlayer
--- @return number
cooldown = function(player)
    return max(1, config.get_auto_speed(player.force.get_gun_speed_modifier('nano-ammo')))
end

--- Refill an empty queue, or run its next task
--- @param player LuaPlayer
--- @param pdata table
--- @param tick uint
local function process_player(player, pdata, tick)
    local queue = pdata.queue
    if not queue then
        queue = Queue()
        pdata.queue = queue
    end

    if (pdata.next_auto_tick or tick) > tick then
        return
    end

    if not queue.active then
        --attempt refill if player *was* active
        if pdata.active then
            local unfinished = NanobotsAuto.fill_player_queue(player)
            local scans = pdata.unfinished_scans or 0
            if queue.active then
                pdata.unfinished_scans = nil
            elseif unfinished and scans < MAX_UNFINISHED_SCANS then
                -- the scan stopped at its budget without a target: go on later, no sound yet
                pdata.unfinished_scans = scans + 1
                pdata.next_auto_tick = tick + cooldown(player)
            else
                pdata.unfinished_scans = nil
                if not settings.get_player_settings(player)["nanobots-mute-launcher"].value then
                    if pdata.lacking_supplies then
                        player.play_sound({path = "nano-sound-error"})
                    else
                        player.play_sound({path = "nano-sound-complete"})
                    end
                end
                pdata.active = false
            end
        end
        return
    end

    --queue has tasks
    pdata.active = true
    pdata.lacking_supplies = false

    if not nano_state(player) then
        -- No emitter with ammo, or a construction network covers the player: every task
        -- would fail its first check, so drop them all at once. The refill on the next tick
        -- plays the sound, as it did when the tasks failed one by one.
        Queue.clear(queue)
        return
    end

    --do actions until one works, the queue runs out or the per-tick budget is spent
    local success, tries = false, 0
    repeat
        success = Queue.execute(queue)
        tries = tries + 1
    until success or not queue.active or tries >= MAX_TRIES_PER_TICK

    if success or not queue.active then
        -- After a success the launcher has to cool down. A queue that ran dry on failures
        -- waits as long before the next scan, instead of rescanning the area every tick.
        pdata.next_auto_tick = tick + cooldown(player)
        if config.DEBUG then
            game.print("next_auto_tick: " .. pdata.next_auto_tick)
        end
    end
end

--- @param tick uint
--- @param players LuaPlayer[]? game.connected_players, if the caller already has it
NanobotsAuto.process_queue_tasks = function(tick, players)
    if config.DEBUG then
        game.print("In process_queue_tasks")
    end

    for _, player in pairs(players or game.connected_players) do
        -- Dead or detached player: no character to check or fire from, wait for respawn.
        local pdata = player.character and storage.players[player.index]
        if pdata then
            process_player(player, pdata, tick)
        end
    end
end

--- @param player LuaPlayer
--- @return boolean unfinished the scan stopped at its budget; the rest of the area is for the next refill
NanobotsAuto.fill_player_queue = function(player)
    local pdata = storage.players[player.index]
    local queue = pdata and pdata.queue
    if not pdata or queue and Queue.length(queue) >= config.MAX_QUEUE_SIZE then
        -- nothing could be added, so don't scan
        return false
    end
    local state = nano_state(player)
    if not state then return false end
    --- @class NanoScan
    local scan = { left = MAX_CANDIDATES_PER_FILL, offset = pdata.scan_offset or 0, examined = 0, unfinished = false }
    if state.ammo_name == 'ammo-nano-constructors' then
        queue_constructor_targets(player, state, scan)
    elseif state.ammo_name == 'ammo-nano-levelers' then
        queue_leveler_targets(player, state, scan)
    end
    pdata.scan_offset = scan.unfinished and scan.offset + scan.examined or nil
    return scan.unfinished
end

-- ----Local functions---- --

--- The player-level checks every queued task used to repeat: a character, no construction
--- network around it, the emitter selected with ammo, and the ammo radius. Worked out once per
--- player and tick; the network check alone is a network search, and it gave the same answer for
--- every target (it is made at the character's position).
--- @class NanoState
--- @field character LuaEntity
--- @field position MapPosition the character's
--- @field surface_index uint the character's
--- @field ammo LuaItemStack
--- @field ammo_name string
--- @field radius number

local state_tick = -1
---@type table<uint, NanoState|false>
local states = {}

--- @param player LuaPlayer
--- @return NanoState?
nano_state = function(player)
    local tick = game.tick
    if tick ~= state_tick then
        state_tick = tick
        states = {}
    end
    local state = states[player.index]
    if state == nil then
        state = false
        local character = player.character
        if character and (not network_limit or nano_network_check(character)) then
            local gun, ammo, ammo_name = get_gun_ammo_name(character, 'gun-nano-emitter')
            if gun then
                state = {
                    character = character,
                    position = character.position,
                    surface_index = character.surface_index,
                    ammo = ammo,
                    ammo_name = ammo_name,
                    radius = get_ammo_radius(player, ammo),
                }
            end
        end
        states[player.index] = state
    end
    return state or nil
end

--- After an action spent ammo the cached state may be stale
--- @param player LuaPlayer
forget_state = function(player)
    states[player.index] = nil
end

--- The player's state, if they are using this kind of nanobot ammo
--- @param player LuaPlayer?
--- @param target_ammo_name string "constructors" or "levelers"
--- @return NanoState?
local function player_using_ammo(player, target_ammo_name)
    local state = player and nano_state(player)
    if state and state.ammo_name == 'ammo-nano-' .. target_ammo_name then
        return state
    end
    return nil
end

local function has_powered_equipment(character, eq_name)
    local grid = character.grid
    if grid then
        local eq = grid.find(eq_name)
        return eq and eq.energy > 0
    end
end

--- Is the player character not in a logistic network or has a working nano-interface
--- @param character LuaEntity
--- @return boolean
nano_network_check = function(character)
    if has_powered_equipment(character, 'equipment-bot-chip-nanointerface') then
        return true
    else
        local c = character
        local networks = c.surface.find_logistic_networks_by_construction_area(c.position, c.force)
        -- Con bots in network
        local cell = c.logistic_cell
        local pnetwork = cell and cell.mobile and cell.logistic_network
        local has_pbots = cell and cell.construction_radius > 0 and cell.logistic_network and
                              cell.logistic_network.all_construction_robots > 0
        local has_nbots = table.any(networks, function(network)
            return network ~= pnetwork and network.all_construction_robots > 0
        end)
        return not (has_pbots or has_nbots)
    end
end

--- Get the gun, ammo and ammo name for the named gun: will return nil for all returns if there is no ammo for the gun.
--- @param character LuaEntity
--- @param gun_name string
--- @return LuaItemStack|nil
--- @return LuaItemStack|nil
--- @return string|nil
get_gun_ammo_name = function(character, gun_name)
    local index = character.selected_gun_index
    local gun = character.get_inventory(defines.inventory.character_guns)[index]
    local ammo = character.get_inventory(defines.inventory.character_ammo)[index]

    if gun and gun.valid_for_read and ammo.valid_for_read then
        return gun, ammo, ammo.name
    end
    return nil, nil, nil
end

--- Is the target within the ammo radius of the character? The character, not the player: in
--- remote view the player's position and surface are the camera's.
--- @param target LuaEntity|LuaTile
--- @param state NanoState
--- @return boolean
local function within_radius(position, state)
    return Position.distance(position, state.position) <= state.radius
end

--- within_radius, and on the character's surface (a queued target may be on the surface the
--- player left)
--- @param target LuaEntity|LuaTile
--- @param state NanoState
--- @return boolean
local function in_reach(target, state)
    return target.surface.index == state.surface_index and within_radius(target.position, state)
end

--[[Nano Emitter Queue Handler --]]
-- Queued items are handled one at a time,
-- check validity of all stored objects at this point, They could have become
-- invalidated between the time they were entered into the queue and now.

--- @param data Nanobots.data
--- @param ammo_kind string "constructors" or "levelers"
--- @param target_finder function
--- @return boolean success
local function run_task(data, ammo_kind, target_finder)
    local entity = data.entity
    local player = game.get_player(data.player_index)

    --perform ALL the checks again
    local state = player_using_ammo(player, ammo_kind)
    if not state or not entity.valid then
        return false
    end

    local target_type = target_finder(entity, player)
    if target_type ~= data.target_type then
        return false
    end

    if config.DEBUG then
        game.print("Dequeued " .. target_type .. " action")
    end

    if not in_reach(entity, state) then
        return false
    end

    if not is_valid_nanobot_target(entity, target_type, player) then
        --target is not valid for some reason, e.g., non-minable or already being repaired
        return false
    end

    if not has_supplies_for_nanobot_action(entity, target_type, player) then
        --player doesn't have the supplies necessary
        return false
    end

    if perform_nanobot_action(entity, target_type, player) then
        ammo_drain(player, state.ammo, 1)
        forget_state(player)
        if config.DEBUG then
            game.print("Action succeeded: " .. target_type)
        end
        return true
    end
    game.print("Nanobots error: " .. target_type .. " action failed")
    return false
end

--- @param data Nanobots.data
function Queue.constructor(data)
    if not run_task(data, "constructors", NanobotsCommon.get_constructor_target_type) then
        return false
    end
    local target_type = data.target_type
    if target_type == "empty" or target_type == "clear_ground" or target_type == "insert_request"
                              or target_type == "removal_request" then
        --these actions repeatedly target the same entity, so should be re-queued to save us polling
        --the region over and over
        local entity, player = data.entity, game.get_player(data.player_index)
        data.target_type = entity.valid and NanobotsCommon.get_constructor_target_type(entity, player)
        if data.target_type then
            Queue.insert(storage.players[player.index].queue, data)
        end
    end
    return true
end

--- @param data Nanobots.data
function Queue.leveler(data)
    return run_task(data, "levelers", NanobotsCommon.get_leveler_target_type)
end

--- Search the area around the character with the given filter
--- @param state NanoState
--- @param filter EntitySearchFilters
--- @return LuaEntity[]
local function search(state, filter)
    filter.position = state.position
    filter.radius = state.radius
    return state.character.surface.find_entities_filtered(filter)
end

--- Search the area around the player for constructor targets and queue them.
--- The engine picks the targets out: everything marked for deconstruction, then the player's
--- force's marked upgrades, ghosts and item requests, then its damaged entities. One unfiltered
--- search used to bring back every entity in reach - trees, ore, belts - every second, and each
--- one was classified in Lua. Every target is still classified by get_constructor_target_type,
--- so what counts as a target is unchanged; only the queueing order now follows these groups.
--- @param player LuaPlayer
--- @param state NanoState
queue_constructor_targets = function(player, state, scan)
    if config.DEBUG then
        game.print("In queue_constructor_targets")
    end

    local force = player.force
    local finder = NanobotsCommon.get_constructor_target_type
    local ghost_types = settings.get_player_settings(player)["nanobots-nano-build-tiles"].value
        and { "entity-ghost", "tile-ghost" } or "entity-ghost"

    if queue_valid_targets(search(state, { to_be_deconstructed = true }), finder, player, state, "constructor", scan)
    or queue_valid_targets(search(state, { to_be_upgraded = true, force = force }), finder, player, state, "constructor", scan)
    or queue_valid_targets(search(state, { type = ghost_types, force = force }), finder, player, state, "constructor", scan)
    or queue_valid_targets(search(state, { name = "item-request-proxy", force = force }), finder, player, state, "constructor", scan) then
        return
    end

    -- Repairs: the only group without an engine filter. One API call drops an undamaged entity.
    local damaged = {}
    for _, entity in pairs(search(state, { force = force })) do
        local ratio = entity.get_health_ratio()
        if ratio and ratio < 1 then
            damaged[#damaged + 1] = entity
        end
    end
    queue_valid_targets(damaged, finder, player, state, "constructor", scan)
end

--- Search the area around the player for leveler targets and queue them.
--- @param player LuaPlayer
--- @param state NanoState
queue_leveler_targets = function(player, state, scan)
    if config.DEBUG then
        game.print("In queue_leveler_targets")
    end

    local finder = NanobotsCommon.get_leveler_target_type

    -- Trees and cliffs only: the limit used to be spent on any neutral entity, so an ore patch
    -- in reach could hide every tree.
    if queue_valid_targets(search(state, { type = { "tree", "cliff" }, force = "neutral",
                                           limit = config.MAX_QUEUE_SIZE * 1.2 }),
                           finder, player, state, "leveler", scan)
    or queue_valid_targets(search(state, { type = "simple-entity" }), finder, player, state, "leveler", scan) then
        return
    end

    if settings.get_player_settings(player)["nanobots-levelers-place-landfill"].value then
        local water = state.character.surface.find_tiles_filtered({ position = state.position,
                                                              radius = state.radius,
                                                              collision_mask = "water_tile" })
        queue_valid_targets(water, finder, player, state, "leveler", scan)
    end

    --The structure here does mean trees and cliffs both will ALWAYS be processed before rocks,
    --which is kind of annoying, but whatever.

    --Also, all three of those are processed before landfill, but that part seems fine.
end

--- Key under which a supply check can be shared by targets of one fill: the items to place
--- depend only on the ghost's prototype and quality, and the inventory does not change meanwhile.
local SHARED_SUPPLY_ACTIONS = { build = true, build_tile = true, upgrade_tile = true }

--Given an array of potential targets, places all valid ones (up to MAX_QUEUE_SIZE) into the given player's queue.
--- @param possible_targets LuaEntity[]|LuaTile[]
--- @param target_finder function(LuaEntity|LuaTile, LuaPlayer) -> string
--- @param player LuaPlayer
--- @param state NanoState
--- @param ammo_type string The type of ammo, used to determine which function the queue passes into
--- @param scan NanoScan the budget of this refill
--- @return boolean stop the queue is full or the budget is spent
queue_valid_targets = function(possible_targets, target_finder, player, state, ammo_type, scan)
    local pdata = storage.players[player.index]
    local queue = pdata.queue
    if not queue then
        queue = Queue()
        pdata.queue = queue
    end

    local supplies = {}
    local index = player.index

    --- Queue one target if it qualifies; cheapest checks first: already queued, then in reach,
    --- then what it is and what it needs. The search ran on the character's surface, so only the
    --- distance needs checking here.
    local function consider(target)
        local position = target.position
        if Queue.get_hash_at(queue, position) or not within_radius(position, state) then
            return
        end

        local target_type = target_finder(target, player)
        if target_type == nil then
            return
        end

        local key = SHARED_SUPPLY_ACTIONS[target_type] and target.ghost_name .. "|" .. target.quality.name
        if key and supplies[key] == false and pdata.lacking_supplies then
            -- Known to lack supplies and already reported: the checks below could only end the same
            -- way. Saves the placement test for every ghost of a blueprint the player can't afford.
            return
        end

        if not is_valid_nanobot_target(target, target_type, player) then
            --target is not valid for some reason, e.g., non-minable or already being repaired
            return
        end

        local has_supplies
        if key then
            has_supplies = supplies[key]
            if has_supplies == nil then
                has_supplies = has_supplies_for_nanobot_action(target, target_type, player)
                supplies[key] = has_supplies
            end
        else
            has_supplies = has_supplies_for_nanobot_action(target, target_type, player)
        end
        if not has_supplies then
            --player doesn't have the supplies necessary
            pdata.lacking_supplies = true
            return
        end

        --- @class Nanobots.data
        Queue.insert(queue, {
            player_index = index,
            entity = target,
            target_type = target_type,
            action = ammo_type
        })
    end

    -- start where the previous, unfinished refill stopped
    local count = #possible_targets
    local start = count > 0 and scan.offset % count or 0
    for step = 0, count - 1 do
        if Queue.length(queue) >= config.MAX_QUEUE_SIZE then
            --not allowed to queue any more tasks
            return true
        end
        if scan.left <= 0 then
            scan.unfinished = true
            return true
        end
        scan.left = scan.left - 1
        scan.examined = scan.examined + 1
        consider(possible_targets[(start + step) % count + 1])
    end
    return false
end
