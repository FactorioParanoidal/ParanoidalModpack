require "template"

local sensor = ValueSensor.new("pollution_around_player")
local cache_tick, cache = nil, {}
local reported_error = false

local function status(player)
    if cache_tick ~= game.tick then cache_tick, cache = game.tick, {} end
    if cache[player.index] ~= nil then return cache[player.index] end
    local api = remote.interfaces.toxic_pollution
    local result = false
    if api and api.get_player_status then
        local ok, value = pcall(remote.call, "toxic_pollution", "get_player_status", player.index)
        if ok and type(value) == "table" then
            result = value
        elseif not reported_error then
            log("EvoUi: toxic_pollution.get_player_status failed")
            reported_error = true
        end
    end
    cache[player.index] = result -- one read per player per GUI update, even with two labels
    return result
end

function sensor:get_line(player)
    local pollution = player.surface.get_pollution(player.position)
    local whole = math.floor(pollution)
    local decimal = whole .. "." .. math.floor((pollution - whole) * 10)
    self.color = { r = 255, g = 255, b = 255 }
    self.tooltip = { "sensor.pollution_around_player.environment" }
    local sample = status(player)
    if sample and sample.description then
        self.tooltip = { "", { "sensor.pollution_around_player.personal" }, "\n", sample.description }
    elseif sample and sample.availability == "no_character" then
        self.tooltip = { "sensor.pollution_around_player.no_character" }
    end
    return { self.format_key, decimal }
end

-- Only this sensor needs the detailed tooltip; leave other sensors' update paths untouched.
function sensor:update_ui(owner)
    local player = game.players[owner.player_index]
    local label = owner[self.name]
    label.caption = self:get_line(player)
    label.tooltip = self.tooltip
    label.style.font_color = self.color
end

ValueSensor.register(sensor)
