-- Shared helpers of the BnL start: positions, random ranges, chat messages and chart tags.
local config = require("bnl-config")
local M = {}

M.CHAT_COLOR = {r = 1, g = 0.72, b = 0.25}

function M.pos(p)
    return {x = p.x or p[1], y = p.y or p[2]}
end

-- 0 = east, 0.25 = south, 0.5 = west (turns).
function M.vector(turns, length)
    local a = turns * 2 * math.pi
    return {x = length * math.cos(a), y = length * math.sin(a)}
end

function M.add(a, b)
    return {x = a.x + b.x, y = a.y + b.y}
end

function M.distance(a, b)
    local dx, dy = a.x - b.x, a.y - b.y
    return math.sqrt(dx * dx + dy * dy)
end

function M.int(range)
    if type(range) == "number" then return range end
    if range[2] <= range[1] then return range[1] end
    return math.random(range[1], range[2])
end

function M.float(range)
    if type(range) == "number" then return range end
    return range[1] + (range[2] - range[1]) * math.random()
end

-- Entry {.., weight} of a list by the weight at index `index`.
function M.weighted(list, index)
    local total = 0
    for _, entry in ipairs(list) do total = total + entry[index] end
    local pick = math.random() * total
    for _, entry in ipairs(list) do
        pick = pick - entry[index]
        if pick < 0 then return entry end
    end
    return list[#list]
end

-- Ticks since the landing (the crash site was filled); 0 before it. On a dedicated server the
-- landing is when the first player arrives, not the map start.
function M.since_landing()
    local landing = storage.bnl and storage.bnl.landing_tick
    if not landing then return 0 end
    return math.max(0, game.tick - landing)
end

function M.landing_tick()
    return storage.bnl and storage.bnl.landing_tick or game.tick
end

function M.ship_position()
    return M.pos(config.ship_position)
end

function M.trail_angle()
    local s = storage.bnl
    return s and s.trail_angle or config.entry_angle
end

function M.gps(position, surface)
    return string.format("[gps=%d,%d,%s]", math.floor(position.x), math.floor(position.y), surface and surface.name or "nauvis")
end

function M.item_exists(name)
    return prototypes.item[name] ~= nil
end

function M.entity_exists(name)
    return prototypes.entity[name] ~= nil
end

-- Rotating texts: a message has several variants "bnl.<base>-1..n" (locale), one is picked at random
-- (math.random: the same in multiplayer). Lines of the objectives window pick once per stage.
M.JOKES = {
    ["brief-fire"] = 3, ["brief-antenna"] = 3, ["antenna-found"] = 4, ["antenna-found-extra"] = 3, ["antenna-all"] = 3,
    ["distress-interrupted"] = 3, ["falling-warning-medium"] = 4,
    ["safe-no-signal"] = 3, ["safe-wrong-code"] = 4, ["safe-latched"] = 4,
    ["first-quench"] = 3, ["first-stack-lost"] = 3, ["water-out"] = 3,
    ["goal-recorder-find"] = 3, ["goal-recorder-decode"] = 3, ["goal-recorder-decoding"] = 3,
    ["goal-recorder-done"] = 3, ["goal-recorder-lost"] = 3,
    ["goal-antenna-parts"] = 4, ["goal-antenna-build"] = 3, ["goal-antenna-power"] = 3,
    ["goal-antenna-waiting"] = 4, ["goal-antenna-done"] = 3,
    ["goal-safe-partial"] = 3, ["goal-safe-code"] = 3, ["goal-safe-done"] = 3,
}

function M.variant(base)
    return math.random(M.JOKES[base] or 1)
end

-- {"bnl.<base>-N", ...}: a random variant with the parameters.
function M.joke(base, ...)
    return {"bnl." .. base .. "-" .. M.variant(base), ...}
end

-- Chat message with the BnL prefix and the radio sound (nil sound = radio, false = silent).
function M.say(message, sound, target)
    local settings = {color = M.CHAT_COLOR}
    if sound ~= false then settings.sound_path = sound or "bnl-radio" end
    local line = {"", {"bnl.prefix"}, " ", message}
    if target then
        target.print(line, settings)
    else
        game.print(line, settings)
    end
end

-- Language of a force for chart tag texts (chart tags are plain strings).
function M.language(force)
    for _, player in pairs(force.connected_players) do
        return player.locale == "ru" and "ru" or "en"
    end
    for _, player in pairs(force.players) do
        return player.locale == "ru" and "ru" or "en"
    end
    return "en"
end

M.TAGS = {
    beacon = {ru = "Аварийный маяк BnL", en = "BnL emergency beacon"},
    reactor = {ru = "Реакторный отсек", en = "Reactor compartment"},
    medbay = {ru = "Медотсек", en = "Medical bay"},
    armory = {ru = "Оружейная", en = "Armory"},
    hydroponics = {ru = "Гидропонный отсек", en = "Hydroponics bay"},
    engineering = {ru = "Инженерный отсек (в озере)", en = "Engineering bay (in the lake)"},
    recorder = {ru = "Сигнал бортового самописца", en = "Flight recorder signal"},
    expedition = {ru = "Corpse: Инженер №7; Time: 6666:06", en = "Corpse: Engineer #7; Time: 6666:06"},
    pod = {ru = "Капсула BnL", en = "BnL pod"},
    turret = {ru = "Ветеран крушения", en = "Crash veteran"},
    escape = {ru = "Спасательная капсула", en = "Escape pod"},
}

function M.tag_text(force, key, suffix)
    local texts = M.TAGS[key]
    local text = texts and texts[M.language(force)] or key
    if suffix then text = text .. " " .. suffix end
    return text
end

function M.chart(force, surface, position, radius)
    local r = radius or 16
    force.chart(surface, {{position.x - r, position.y - r}, {position.x + r, position.y + r}})
end

-- Removes trees, rocks and decoratives where something big lands or is placed.
function M.clear(surface, area)
    for _, entity in pairs(surface.find_entities_filtered({area = area, type = {"tree", "simple-entity"}})) do
        if entity.valid and (entity.type == "tree" or entity.prototype.count_as_rock_for_filtered_deconstruction) then
            entity.destroy()
        end
    end
    surface.destroy_decoratives({area = area})
end

function M.area(position, radius)
    return {{position.x - radius, position.y - radius}, {position.x + radius, position.y + radius}}
end

-- Weathered BnL logo on the crashed starliner; once per ship (also added to older saves).
function M.ship_decal(ship)
    local s = storage.shipwreck
    if not (s and ship and ship.valid) or (s.decal and s.decal.valid) then return end
    if not helpers.is_valid_sprite_path("bnl-logo-weathered") then return end
    local d = config.ship_decal
    local scale = d.width * 32 / (256 * 0.5) -- the sprite is 256 px at scale 0.5
    s.decal = rendering.draw_sprite({sprite = "bnl-logo-weathered", surface = ship.surface,
        target = {entity = ship, offset = d.offset}, x_scale = scale, y_scale = scale, orientation = d.orientation,
        tint = {r = d.tint[1], g = d.tint[2], b = d.tint[3], a = d.tint[4]}, render_layer = "cargo-hatch"})
end

function M.player_force()
    return game.forces.player
end

function M.nauvis()
    return game.surfaces.nauvis
end

function M.enabled(name)
    local setting = settings.global[name]
    return setting == nil or setting.value ~= false
end

return M
