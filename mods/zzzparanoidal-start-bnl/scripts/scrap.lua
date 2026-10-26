-- Scrap deposit: the hull scraped along the ground behind the ship (west-south-west, the way it
-- came in). Richer near the ship, ragged edges, no water, no tile that already has a resource.
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
                        local richness = 1 - 0.6 * (d - cfg.from) / (cfg.to - cfg.from)
                        local amount = math.max(20, math.floor(util.float(cfg.amount) * richness * (1 - 0.5 * edge)))
                        if surface.create_entity({name = "scrap", position = p, amount = amount, snap_to_tile_center = true}) then
                            placed = placed + 1
                        end
                    end
                end
            end
        end
    end
    return placed
end

return M
