-- Landing sequence of a new player. The first player's freeplay crash cutscene is replaced by a
-- longer flight along the debris trail (from the west-south-west to the ship, with the last
-- explosions of the break-up under the camera); when it ends - or right away for other players -
-- the profession choice opens. The BnL landing message is printed at once.
-- Replacing: the freeplay cutscene is exited one tick after creation (its own cancel handler
-- restores the character as usual), the flight starts on the next tick, so freeplay never sees it.
-- One on_tick handler exists only for these two or three ticks.
local config = require("bnl-config")
local util = require("scripts.util")
local scheduler = require("scripts.scheduler")
local events = require("scripts.events")
local professions = require("scripts.professions")
local M = {}
local cfg = config.intro

local function state()
    return storage.bnl and storage.bnl.intro
end

function M.init()
    storage.bnl.intro = storage.bnl.intro or {pending = {}, flying = {}}
    -- The landing message and the profession window replace the freeplay intro dialog.
    if remote.interfaces.freeplay and remote.interfaces.freeplay.set_skip_intro then
        remote.call("freeplay", "set_skip_intro", true)
    end
end

local function welcome(player)
    local name = player.name
    if not name or name == "" then name = {"bnl.fallback-player-name"} end
    player.print({"bnl.player-crash-landed", name}, {color = util.CHAT_COLOR})
end

function M.on_player_created(player)
    local s = state()
    if not s then return end
    if not storage.bnl.landing_tick then welcome(player) end -- the players of the landing
    if not professions.allowed(player) then professions.passenger(player) end
    s.pending[player.index] = {tick = game.tick, stage = "created"}
    events.refresh()
end

local function explosions(surface, start_tick)
    local ship = util.ship_position()
    local angle = util.trail_angle()
    local n = cfg.explosions
    for k = 1, n do
        local along = cfg.start_distance * (1 - k / (n + 1))
        local p = util.add(ship, util.vector(angle, along))
        p = util.add(p, util.vector(angle + 0.25, (math.random() - 0.5) * 16))
        scheduler.at(start_tick + math.floor(cfg.transition * k / (n + 1)), "intro-boom",
            {surface = surface.index, position = p, big = k % 2 == 0})
    end
end

scheduler.handler("intro-boom", function(job)
    local surface = game.get_surface(job.surface)
    if not surface then return end
    surface.create_entity({name = job.big and "massive-explosion" or "big-explosion", position = job.position})
    if math.random() < 0.6 then
        surface.create_entity({name = "fire-flame", position = job.position, initial_ground_flame_count = 4})
    end
end)

local function label(player, show)
    local screen = player.gui.screen
    if screen.bnl_skip_label then screen.bnl_skip_label.destroy() end
    if not show then return end
    local l = screen.add({type = "label", name = "bnl_skip_label", caption = {"skip-cutscene"}})
    l.style.horizontal_align = "center"
    local resolution = player.display_resolution
    l.style.width = resolution.width / player.display_scale
    l.location = {0, resolution.height - 28 * player.display_scale}
end

local function fly(player)
    local character = player.character
    if not character then return false end
    local ship = util.ship_position()
    local from = util.add(ship, util.vector(util.trail_angle(), cfg.start_distance))
    player.set_controller({
        type = defines.controllers.cutscene,
        waypoints = {
            {position = {x = ship.x, y = ship.y + 2}, transition_time = cfg.transition, zoom = 1.6, time_to_wait = cfg.wait},
            {target = character, transition_time = 150, zoom = 1.5, time_to_wait = 0},
        },
        start_position = from,
        start_zoom = 0.7,
    })
    character.destructible = false
    label(player, true)
    explosions(player.surface, game.tick)
    return true
end

local function after_landing(player)
    label(player, false)
    if player.character then player.character.destructible = true end
    professions.show(player)
end

-- pending[index] = {tick, stage}: "created" -> (exit freeplay cutscene) "fly" -> flight or choice.
local function on_tick(event)
    local s = storage.bnl.intro
    local tick = event.tick
    for index, entry in pairs(s.pending) do
        if tick > entry.tick then
            local player = game.get_player(index)
            if not (player and player.valid) then
                s.pending[index] = nil
            elseif entry.stage == "created" then
                local flight = index == 1 and player.controller_type == defines.controllers.cutscene
                    and player.character and util.enabled("bnl-start-intro")
                if flight then
                    player.exit_cutscene()
                    entry.stage, entry.tick = "fly", tick
                elseif index == 1 and player.controller_type == defines.controllers.cutscene then
                    -- intro switched off: the freeplay cutscene plays, the choice opens after it
                    s.flying[index] = tick
                    s.pending[index] = nil
                else
                    s.pending[index] = nil
                    after_landing(player)
                end
            else
                s.pending[index] = nil
                if fly(player) then
                    s.flying[index] = tick
                else
                    after_landing(player)
                end
            end
        end
    end
    if not next(s.pending) then events.refresh() end
end

events.dynamic(defines.events.on_tick, on_tick, function()
    local s = storage.bnl and storage.bnl.intro
    return s ~= nil and next(s.pending) ~= nil
end)

local function on_cutscene_end(event)
    local s = state()
    local started = s and s.flying[event.player_index]
    if not started or event.tick <= started then return end
    s.flying[event.player_index] = nil
    local player = game.get_player(event.player_index)
    if player then after_landing(player) end
end

events.on(defines.events.on_cutscene_finished, on_cutscene_end)
events.on(defines.events.on_cutscene_cancelled, on_cutscene_end)

-- Tab skips our flight like the freeplay one.
events.on("crash-site-skip-cutscene", function(event)
    local s = state()
    if not (s and s.flying[event.player_index]) then return end
    local player = game.get_player(event.player_index)
    if player and player.controller_type == defines.controllers.cutscene then player.exit_cutscene() end
end)

return M
