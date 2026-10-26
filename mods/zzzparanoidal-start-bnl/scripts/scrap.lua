-- Scrap deposit: the hull scraped along the ground behind the ship (west-south-west, the way it
-- came in). The whole deposit 1000-10000 at random, richer near the ship, ragged edges, no water, no tile that already has a resource.
-- Placed once when the crash site is ready.
local config = require("bnl-config")
local util = require("scripts.util")
local M = {}
local cfg = config.scrap

function M.place(surface)
    if not util.entity_exists("scrap") then return 0 end
    local origin = util.ship_position()
    local angle = util.trail_angle()
    local dir = util.vector(angle, 1)
    local side = util.vector(angle + 0.25, 1)
    local seen, placed = {}, 0
    local tiles, total_weight = {}, 0
    local half_width = util.float(cfg.width)
    for d = cfg.from, cfg.to, 0.5 do
        -- the furrow narrows away from the ship and wobbles
        local w = half_width * (1.15 - 0.5 * (d - cfg.from) / (cfg.to - cfg.from)) * (0.85 + 0.3 * math.random())
        for s = -w, w, 0.5 do
            local x = math.floor(origin.x + dir.x * d + side.x * s)
            local y = math.floor(origin.y + dir.y * d + side.y * s)
            local key = x .. ":" .. y
            if not seen[key] then
                seen[key] = true
                local edge = math.abs(s) / w
                if math.random() > edge * edge * (1 + cfg.noise) then
                    local tile = surface.get_tile(x, y)
                    local p = {x = x + 0.5, y = y + 0.5}
                    if tile.valid and not tile.collides_with("water_tile")
                        and surface.count_entities_filtered({type = "resource", position = p, radius = 0.4, limit = 1}) == 0 then
                        -- richer near the ship and in the middle of the furrow
                        local weight = (1 - 0.6 * (d - cfg.from) / (cfg.to - cfg.from)) * (1 - 0.5 * edge)
                        tiles[#tiles + 1] = {position = p, weight = weight}
                        total_weight = total_weight + weight
                    end
                end
            end
        end
    end
    -- The whole deposit holds a random total (cfg.amount), split over the tiles by weight; map
    -- settings do not apply. Remainders go one by one to random tiles, empty tiles are skipped.
    if not tiles[1] then return 0 end
    local total = util.int(cfg.amount)
    local given = 0
    for _, tile in ipairs(tiles) do
        tile.amount = math.floor(total * tile.weight / total_weight)
        given = given + tile.amount
    end
    for _ = 1, total - given do
        local tile = tiles[math.random(#tiles)]
        tile.amount = tile.amount + 1
    end
    for _, tile in ipairs(tiles) do
        if tile.amount > 0 and surface.create_entity({name = "scrap", position = tile.position, amount = tile.amount,
            snap_to_tile_center = true}) then
            placed = placed + 1
        end
    end
    return placed
end

return M
