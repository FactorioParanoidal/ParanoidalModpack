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
        local valid = ok and type(value) == "table" and value.schema_version == 1
            and type(value.availability) == "string"
        if valid and value.availability == "ok" then
            for _, key in ipairs({ "sample_tick", "surface_index", "chunk_x", "chunk_y", "pollution",
                "tolerance", "inhaled", "rate", "intoxication" }) do
                if type(value[key]) ~= "number" then valid = false end
            end
            valid = valid and type(value.description) == "table"
            if value.armor then
                valid = valid and type(value.armor) == "table" and type(value.armor.resource) == "number"
                    and type(value.armor.max) == "number" and value.armor.max > 0
            end
        end
        if valid then
            result = value
        else
            result = { availability = "pending" }
            if not reported_error then
                log("EvoUi: toxic_pollution.get_player_status unavailable or incompatible")
                reported_error = true
            end
        end
    end
    cache[player.index] = result -- including absent/error: one request per GUI update, not per label
    return result
end

function sensor:get_line(player)
    local pollution = player.surface.get_pollution(player.position)
    local whole = math.floor(pollution)
    local decimal = whole .. "." .. math.floor((pollution - whole) * 10)
    local base = { self.format_key, decimal }
    self.color = { r = 255, g = 255, b = 255 }
    self.tooltip = { "sensor.pollution_around_player.environment" }
    local sample = status(player)
    if not sample then return base end
    if sample.availability ~= "ok" then
        local key = sample.availability == "no_character" and "no_character" or "pending"
        self.tooltip = { "sensor.pollution_around_player." .. key }
        return { "", base, " · ", self.tooltip }
    end
    local same = player.surface.index == sample.surface_index
        and math.floor(player.position.x / 32) == sample.chunk_x
        and math.floor(player.position.y / 32) == sample.chunk_y
    local protection
    if sample.armor and sample.protected then
        protection = sample.armor.infinite and { "sensor.pollution_around_player.protected" }
            or { "sensor.pollution_around_player.resource", tostring(math.floor(sample.armor.resource / sample.armor.max * 100 + 0.5)) }
    elseif sample.inhaled <= sample.tolerance then
        protection = { "sensor.pollution_around_player.tolerable" }
    else
        protection = { "sensor.pollution_around_player.unprotected" }
    end
    local trend = sample.rate > 0 and " ↑" or (sample.intoxication > 0 and " ↓" or "")
    local body = { "sensor.pollution_around_player.body", protection, tostring(math.floor(sample.intoxication + 0.5)), trend }
    self.tooltip = { "", { "sensor.pollution_around_player.sample", tostring(math.max(0, game.tick - sample.sample_tick)) },
        "\n", sample.description, "\n", { "sensor.pollution_around_player.scope" } }
    if not same then
        self.tooltip = { "", { "sensor.pollution_around_player.different" }, "\n", self.tooltip }
        return { "", { "sensor.pollution_around_player.view", decimal }, " · ", body }
    end
    return { "", { "sensor.pollution_around_player.air", tostring(math.floor(sample.pollution + 0.5)) }, " · ", body }
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
