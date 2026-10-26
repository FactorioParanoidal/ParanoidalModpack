-- What the ground holds, by profession:
-- * the geologist charts the land around the crash site and marks the nearest deposit of every ore
--   (map tags with icons only), and sees the scrap deposit and the rich vein of the anomaly at once;
--   without a geologist they are marked when the flight recorder is decoded;
-- * hand mining: a geologist gets the ore twice in half of the cases, a biologist the wood of a tree.
-- The mining bonus is one filtered event handler that only looks at the profession table.
local config = require("bnl-config")
local util = require("scripts.util")
local tags = require("scripts.tags")
local events = require("scripts.events")
local M = {}
local cfg = config.geology

local function chosen(index)
    local p = storage.bnl and storage.bnl.professions
    return p and p.chosen[index]
end

-- Icon of a resource: its first mining product.
local function resource_icon(name)
    local prototype = prototypes.entity[name]
    local products = prototype and prototype.mineable_properties and prototype.mineable_properties.products
    local product = products and products[1]
    if not product then return nil end
    return {type = product.type == "fluid" and "fluid" or "item", name = product.name}
end

-- Scrap deposit and the rich vein: map tags and charted around them, once per map.
function M.reveal()
    local s = storage.bnl
    if not s or s.deposits_revealed then return end
    if not s.landing_tick then -- chosen before the crash site is filled: on_start_ready
        s.reveal_pending = true
        return
    end
    s.deposits_revealed = true
    local force = util.player_force()
    local scrap = s.scrap
    if scrap then
        local surface = game.get_surface(scrap.surface)
        if surface then
            util.chart(force, surface, scrap.center, cfg.reveal_chart)
            if prototypes.item.scrap then
                tags.set("deposit-scrap", force, surface, scrap.center, "scrap", {type = "item", name = "scrap"})
            end
        end
    end
    local vein = s.anomaly and s.anomaly.vein
    if vein then
        local surface = game.get_surface(vein.surface)
        local icon = resource_icon(vein.ore)
        if surface then
            util.chart(force, surface, vein.center, cfg.reveal_chart)
            if icon then tags.set("deposit-vein", force, surface, vein.center, "vein", icon) end
        end
    end
end

-- The crash site is filled (control.lua, after the scrap and the anomaly are placed).
function M.on_start_ready()
    local s = storage.bnl
    if s and s.reveal_pending then
        s.reveal_pending = nil
        M.reveal()
    end
end

-- Resource prototypes worth a tag (not infinite, not scrap); built once per load.
local ores
local function ore_names()
    if ores then return ores end
    ores = {}
    for name, prototype in pairs(prototypes.get_entity_filtered({{filter = "type", type = "resource"}})) do
        if not prototype.infinite_resource and name ~= "scrap" and resource_icon(name) then ores[#ores + 1] = name end
    end
    table.sort(ores)
    return ores
end

-- The geologist: the land around the ship is charted and the nearest deposit of every ore marked.
-- A ring search with limit 1 per ring and ore: a few dozen cheap queries, no full scan.
function M.prospect()
    local s = storage.bnl
    if not s or s.prospected then return end
    s.prospected = true
    local surface = util.nauvis()
    if not surface then return end
    local force = util.player_force()
    local center = util.ship_position()
    util.chart(force, surface, center, cfg.chart_radius)
    for _, name in ipairs(ore_names()) do
        for radius = cfg.ring, cfg.chart_radius, cfg.ring do
            local found = surface.find_entities_filtered({name = name, position = center, radius = radius, limit = 1})[1]
            if found then
                tags.set("ore-" .. name, force, surface, found.position, name, resource_icon(name))
                break
            end
        end
    end
    M.reveal()
end

-- Hand mining bonus: the whole result once more.
local function on_mined(event)
    local profession = chosen(event.player_index)
    if not profession then return end
    local entity = event.entity
    local kind = entity.type
    if not ((kind == "resource" and profession == "geologist") or (kind == "tree" and profession == "biologist")) then
        return
    end
    if math.random() >= cfg.double_chance then return end
    local buffer = event.buffer
    if not (buffer and buffer.valid) then return end
    for _, item in ipairs(buffer.get_contents()) do
        buffer.insert({name = item.name, count = item.count, quality = item.quality})
    end
end

events.on(defines.events.on_player_mined_entity, on_mined, {{filter = "type", type = "resource"}, {filter = "type", type = "tree"}})

return M
