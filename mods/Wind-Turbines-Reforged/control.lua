-- Wind as in Paranoidal Beta 8 (Texugo_windgenerator 9.17.0 by Texugo Maldito & Yur_Ra): one wind for the
-- whole game, recalculated every 61 ticks. There it was the temperature of fake steam in a generator
-- that only used 15..100 °C; here the same value sets the share of full power and the shown wind speed.
local tiers = require("tiers")

local UPDATE_TICKS = 61
local PERIODS = { 2, 3, 5, 7, 11, 13, 17, 19, 23, 29 }
local GUI = "twr-wind"
local diode = defines.entity_status_diode

-- Seasons of NightBrightness: the wind is stronger in winter and weaker in summer. The multiplier
-- applies to the output share and the shown speed; output may exceed the nameplate power.
-- It switches when NightBrightness announces the season (checked at every wind update).
local SEASON_MULTIPLIERS = { summer = 0.9, fall = 1, winter = 1.33, spring = 1 }
local MAX_MULTIPLIER = 1
for _, value in pairs(SEASON_MULTIPLIERS) do MAX_MULTIPLIER = math.max(MAX_MULTIPLIER, value) end

local function season_multiplier()
    local api = remote.interfaces["NightBrightness"]
    if not (api and api.get_season) then return 1 end
    local ok, season = pcall(remote.call, "NightBrightness", "get_season")
    return ok and SEASON_MULTIPLIERS[season] or 1
end

local turbine_names, owners = {}, {}
for name, tier in pairs(tiers) do
    turbine_names[#turbine_names + 1] = name
    owners[tier.pole] = name
    owners[tier.base] = name
end
local companion_names = {}
for name in pairs(owners) do companion_names[#companion_names + 1] = name end

local function step(wind)
    wind.x = wind.x + math.random() / 2
    if wind.x >= 1.8e8 then wind.x = 0 end
    local y = 1.5
    for _, period in ipairs(PERIODS) do y = y + math.sin(wind.x / period) end
    wind.t = 0.99 * wind.t + math.random() - 0.5
    wind.z = 0.9 * wind.z + 0.1 * wind.t
    local temperature = 14 * (y + 0.8 * wind.z + 3)
    wind.share = math.min(math.max((temperature - 15) / 85, 0), 1)
    -- Display scale: 3 m/s starts the turbine, 12 m/s gives full power.
    wind.speed = math.max(0, 3 + (temperature - 15) * 9 / 85)
    wind.multiplier = season_multiplier()
    wind.output = wind.share * wind.multiplier
end

local function speed_text(wind)
    return string.format("%.1f", wind.speed * (wind.multiplier or 1))
end

local function output(wind)
    return wind.output or wind.share
end

local function percent(wind)
    return math.floor(output(wind) * 100 + 0.5)
end

local function power_text(joules_per_tick)
    local kw = joules_per_tick * 60 / 1000
    if kw >= 1000 then return { "twr.mw", string.format("%.2f", kw / 1000) } end
    return { "twr.kw", string.format("%.1f", kw) }
end

-- Registers the turbine and makes sure its hidden pole and base exist. Safe to call again.
local function attach(turbine)
    local tier = tiers[turbine.name]
    local surface, position = turbine.surface, turbine.position
    -- Quality multiplier of the engine: defects (ic-more-qualities) lower it, positive tiers raise it.
    local max = tier.kw * 1000 / 60 * turbine.quality.default_multiplier
    -- The buffer holds one tick of the strongest seasonal output, otherwise it would cut it.
    turbine.electric_buffer_size = max * MAX_MULTIPLIER
    turbine.power_production = output(storage.wind) * max
    local record = { entity = turbine, name = turbine.name, surface = surface, position = position, max = max,
        seasonal_buffer = true }
    for _, name in ipairs({ tier.pole, tier.base }) do
        local companion = surface.find_entity(name, position)
            or surface.create_entity({ name = name, position = position, force = turbine.force })
        if companion then
            companion.destructible = false
            if name == tier.pole then record.pole = companion end
        end
    end
    storage.turbines[script.register_on_object_destroyed(turbine)] = record
end

-- Rebuilds the registry from the map: turbines from older saves, migrations or other mods.
local function reconcile()
    storage.turbines = {}
    for _, surface in pairs(game.surfaces) do
        for _, turbine in pairs(surface.find_entities_filtered({ name = turbine_names })) do
            attach(turbine)
        end
        for _, companion in pairs(surface.find_entities_filtered({ name = companion_names })) do
            if not surface.find_entity(owners[companion.name], companion.position) then companion.destroy() end
        end
    end
end

local function close(player_index)
    local gui = storage.guis[player_index]
    if gui and gui.frame.valid then gui.frame.destroy() end
    storage.guis[player_index] = nil
end

local function refresh(player_index)
    local gui = storage.guis[player_index]
    local record = gui.entity.valid and gui.frame.valid and storage.turbines[gui.registration]
    if not record then return close(player_index) end
    local wind = storage.wind
    gui.labels.wind.caption = { "twr.wind", speed_text(wind) }
    gui.labels.output.caption = { "twr.output", percent(wind), power_text(output(wind) * record.max) }
    gui.labels.max.caption = { "twr.max", power_text(record.max) }
    local multiplier = wind.multiplier or 1
    gui.labels.season.visible = multiplier ~= 1
    local whole, fraction = string.format("%.2f", multiplier):match("^(%d+)%.(%d+)$")
    gui.labels.season.caption = { "twr.season", whole, fraction }
end

local function open(player, turbine)
    close(player.index)
    local frame = player.gui.screen.add({ type = "frame", name = GUI, caption = turbine.localised_name, direction = "vertical" })
    frame.auto_center = true
    local inner = frame.add({ type = "frame", style = "inside_shallow_frame_with_padding", direction = "vertical" })
    local labels = {}
    for _, key in ipairs({ "wind", "output", "max", "season" }) do labels[key] = inner.add({ type = "label" }) end
    storage.guis[player.index] = {
        frame = frame,
        entity = turbine,
        registration = script.register_on_object_destroyed(turbine),
        labels = labels,
    }
    player.opened = frame
    refresh(player.index)
end

local function update()
    local wind = storage.wind
    step(wind)
    local status = {
        diode = output(wind) >= 0.5 and diode.green or wind.share > 0 and diode.yellow or diode.red,
        label = { "twr.status", speed_text(wind), percent(wind) },
    }
    for _, record in pairs(storage.turbines) do
        local turbine = record.entity
        if turbine.valid then
            if not record.seasonal_buffer then
                -- Turbines registered before the seasons had a buffer of exactly one tick at full wind.
                turbine.electric_buffer_size = record.max * MAX_MULTIPLIER
                record.seasonal_buffer = true
            end
            turbine.power_production = output(wind) * record.max
            turbine.custom_status = status
            local pole = record.pole
            if not (pole and pole.valid) then
                attach(turbine)
            elseif pole.force_index ~= turbine.force_index then
                pole.force = turbine.force -- e.g. a ruin turbine claimed by a player
            end
        end
    end
    for player_index in pairs(storage.guis) do refresh(player_index) end
end

-- Inside Factorissimo buildings there is no wind: the turbine goes back to whoever built it.
local function inside_factory(entity)
    local api = remote.interfaces["factorissimo"]
    return api and api.is_factorissimo_surface and remote.call("factorissimo", "is_factorissimo_surface", entity.surface) or false
end

local function refuse(event, turbine)
    local stack = { name = turbine.name, count = 1, quality = turbine.quality.name, health = turbine.health / turbine.max_health }
    local surface, position, force = turbine.surface, turbine.position, turbine.force
    turbine.destroy()
    local inserted = 0
    local player = event.player_index and game.get_player(event.player_index)
    local robot = event.robot
    if player then
        local inventory = player.get_main_inventory()
        if inventory then inserted = inventory.insert(stack) end
        player.create_local_flying_text({ text = { "twr.no-wind-indoors" }, position = position })
    elseif robot and robot.valid then
        local cargo = robot.get_inventory(defines.inventory.robot_cargo)
        if cargo then inserted = cargo.insert(stack) end
    end
    if inserted < 1 then
        surface.spill_item_stack({ position = position, stack = stack, enable_looted = true, force = force, allow_belts = false })
    end
end

local function on_built(event)
    local turbine = event.entity
    if inside_factory(turbine) then return refuse(event, turbine) end
    attach(turbine)
end

local function on_destroyed(event)
    local record = storage.turbines[event.registration_number]
    if not record then return end
    storage.turbines[event.registration_number] = nil
    local surface = record.surface
    -- After a fast replace the new turbine already uses the same pole and base.
    if not surface.valid or surface.find_entity(record.name, record.position) then return end
    local tier = tiers[record.name]
    for _, name in ipairs({ tier.pole, tier.base }) do
        local companion = surface.find_entity(name, record.position)
        if companion then companion.destroy() end
    end
end

script.on_init(function()
    storage.wind = { x = 0, t = 0, z = 2 }
    step(storage.wind)
    storage.guis = {}
    reconcile()
end)

script.on_configuration_changed(reconcile)
script.on_nth_tick(UPDATE_TICKS, update)

-- Read-only API: EvoUI shows the seasonal wind multiplier on request;
-- MxlChievements reads the share of the wind itself (calm and storm), before the season.
remote.add_interface("Wind-Turbines-Reforged", {
    get_season_multiplier = function(season) return SEASON_MULTIPLIERS[season] end,
    get_wind = function()
        local wind = storage.wind
        if not wind then return nil end
        return { share = wind.share, multiplier = wind.multiplier or 1, output = output(wind), speed = wind.speed }
    end,
})

local filters = {}
for _, name in ipairs(turbine_names) do filters[#filters + 1] = { filter = "name", name = name } end
for _, id in ipairs({
    defines.events.on_built_entity,
    defines.events.on_robot_built_entity,
    defines.events.script_raised_built,
    defines.events.script_raised_revive,
}) do
    script.on_event(id, on_built, filters)
end
script.on_event(defines.events.on_object_destroyed, on_destroyed)

script.on_event("twr-open-turbine", function(event)
    local player = game.get_player(event.player_index)
    local turbine = player.selected
    if turbine and tiers[turbine.name] then open(player, turbine) end
end)

script.on_event(defines.events.on_gui_closed, function(event)
    if event.element and event.element.valid and event.element.name == GUI then close(event.player_index) end
end)
