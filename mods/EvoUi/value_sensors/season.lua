require "template"

-- Paranoidal: season and year of NightBrightness (remote "NightBrightness"). The season name follows
-- the player's NightBrightness setting "Season names"; wind and wire losses are read from
-- Wind-Turbines-Reforged and ElectricResistance2 when they are active.
if not script.active_mods["NightBrightness"] then return end

local sensor = ValueSensor.new("season")
sensor.mod_name = "NightBrightness"

local OPTIONS = {"show_season_day", "show_next", "show_year", "show_solar", "show_light", "show_effects"}
sensor.defaults = {
    show_season_day = true,
    show_next = false,
    show_year = true,
    show_solar = true,
    show_light = false,
    show_effects = false,
}
for _, option in ipairs(OPTIONS) do
    sensor[option] = sensor:make_on_click_checkbox_handler(option)
end

local WHITE = {r = 1, g = 1, b = 1}

local function call(interface, method, ...)
    local api = remote.interfaces[interface]
    if not (api and api[method]) then return nil end
    local ok, result = pcall(remote.call, interface, method, ...)
    if ok then return result end
    return nil
end

-- 1.33 -> {"sensor.season.decimal", "1", "33"}, 3 -> "3"
local function decimal(value)
    local text = string.format("%.2f", value):gsub("0+$", ""):gsub("%.$", "")
    local whole, fraction = text:match("^(%d+)%.(%d+)$")
    if whole then return {"sensor.season.decimal", whole, fraction} end
    return text
end

local function clock(daytime)
    local minutes = math.floor(((daytime + 0.5) % 1) * 24 * 60 + 0.5) % (24 * 60)
    return string.format("%d:%02d", math.floor(minutes / 60), minutes % 60)
end

function sensor:get_line(player)
    self.color = WHITE
    local state = call("NightBrightness", "get_state")
    if type(state) ~= "table" then return {"sensor.season.unavailable"} end
    local options = self.settings or sensor.defaults
    local function on(option)
        local value = options[option]
        if value == nil then return sensor.defaults[option] end
        return value
    end
    local year = {"sensor.season.year_part", tostring(state.year), tostring(state.day_of_year), tostring(state.period)}
    if state.disabled or not state.season then
        return {"", {"sensor.season.disabled"}, year}
    end

    local color = call("NightBrightness", "get_season_color", state.season)
    if type(color) == "table" then self.color = {r = color[1], g = color[2], b = color[3]} end
    local line = {"", call("NightBrightness", "get_season_name", state.season, player.index) or state.season}
    if on("show_season_day") then
        table.insert(line, {"sensor.season.day_part", tostring(state.season_day), tostring(state.season_length)})
    end
    if on("show_next") and state.next_season then
        local name = call("NightBrightness", "get_season_name", state.next_season, player.index) or state.next_season
        table.insert(line, {"sensor.season.next_part", name, tostring(state.days_to_next_season)})
    end
    if on("show_year") then table.insert(line, year) end
    if on("show_solar") then
        table.insert(line, {"sensor.season.solar_part", tostring(math.floor((state.active_solar or 1) * 100 + 0.5))})
    end
    if on("show_light") and state.dawn and state.dusk then
        table.insert(line, {"sensor.season.light_part", clock(state.dawn), clock(state.dusk)})
    end
    if on("show_effects") then
        local wind = call("Wind-Turbines-Reforged", "get_season_multiplier", state.season)
        if type(wind) == "number" then table.insert(line, {"sensor.season.wind_part", decimal(wind)}) end
        local kw = call("ElectricResistance2", "get_season_kw", state.season)
        if type(kw) == "number" then table.insert(line, {"sensor.season.wires_part", decimal(kw)}) end
    end
    return line
end

function sensor:settings_gui(player_index)
    local player = game.players[player_index]
    local sensor_settings = storage.EvoUi[player.name].sensor_settings[self.name] or {}
    local root_name = self:settings_root_name()

    local root = player.gui.center.add{type="frame",
                                       name=root_name,
                                       direction="vertical",
                                       caption={"sensor.season.settings.title"}}
    for _, option in ipairs(OPTIONS) do
        local state = sensor_settings[option]
        if state == nil then state = sensor.defaults[option] end
        root.add{type="checkbox", name="EvoUi_sensor_season_checkbox_" .. option,
                 caption={"sensor.season.settings." .. option}, state=state}
    end
    root.add{type="label", caption={"sensor.season.settings.names_hint"}}
    root.add{type="button", name="EvoUi_sensor_season_close", caption={"settings_close"}}
end

ValueSensor.register(sensor)
