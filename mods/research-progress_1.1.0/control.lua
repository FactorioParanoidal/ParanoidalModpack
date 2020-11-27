----------------
-- GUI methods
----------------

function update_gui_frame(player)
    frame = player.gui.left["research-progress-frame"]

    if frame then
        frame.destroy()
        return
    end

    ------------------
    -- Caluclate ETA
    ------------------

    current_percentage_value = game.forces.player.research_progress
    delta_percentage_value = current_percentage_value - global.last_percentage
    remaining_percentage_value = 1 - current_percentage_value
    remaining_percentage_chunks = remaining_percentage_value / delta_percentage_value
    remaining_time_seconds = 2 * remaining_percentage_chunks


    --------------
    -- Build gui
    --------------

    frame = player.gui.left.add{
        type = "frame",
        caption = {""},
        name = "research-progress-frame",
        direction = "horizontal" --drd
        -- direction = "vertical"
    }

    frame.add{
        type = "label",
        caption = round(game.forces.player.research_progress * 100, 3) .. "% / " .. build_clock_string(remaining_time_seconds)
    }
end

function refresh_gui()
    for _, player in pairs(game.players) do
        frame = player.gui.left["research-progress-frame"]
        if frame then
            frame.destroy()
            update_gui_frame(player)
        end
    end
end

function on_tick()
    refresh_gui()
    global.last_percentage = game.forces.player.research_progress
end

local function on_player_created(event)
  update_gui_frame(game.players[event.player_index])
end

local function on_init()
    global.research_progress = 0
    global.last_percentage = 0
    for _, player in pairs(game.players) do
        update_gui_frame(player)
    end
end

local function on_research_started()
    global.research_progress = 0
    global.last_percentage = 0
    refresh_gui()
end

local function on_research_finished()
    global.research_progress = 0
    global.last_percentage = 0
    refresh_gui()
end

-------------------
-- Helper methods
-------------------

function isInfinite(value)
    -- Returns 1 if given value is a positive infinity or -1 if given value is a negative infinity;
    -- otherwise 0 or nil if value is not of type string nor number.
    if type(value) == "string" then
        value = tonumber(value)
        if value == nil then
            return nil
        end
    elseif type(value) ~= "number" then
        return nil
    end

    if value == math.huge then
        return 1
    end

    if value == -math.huge then
        return -1
    end

    return 0
end

function build_clock_string(remaining_time_seconds)
    local remaining_time_seconds = tonumber(remaining_time_seconds)
    if isInfinite(remaining_time_seconds) == 1 or isInfinite(remaining_time_seconds) == -1 or remaining_time_seconds <= 0 or not remaining_time_seconds or remaining_time_seconds == nil then
        return "--:--:--";
    end

    hours = string.format("%02.f", math.floor(remaining_time_seconds / 3600));
    mins = string.format("%02.f", math.floor(remaining_time_seconds / 60 - (tonumber(hours) * 60)));
    secs = string.format("%02.f", math.floor(remaining_time_seconds - tonumber(hours) * 3600 - tonumber(mins) * 60));
    return "" .. hours .. ":" .. mins .. ":" .. secs;
end

function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

--------------------
-- Register events
--------------------

script.on_event(defines.events.on_research_started, on_research_started)
script.on_event(defines.events.on_research_finished, on_research_finished)
script.on_event(defines.events.on_player_created, on_player_created)
script.on_nth_tick(120, on_tick)
script.on_init(on_init)
