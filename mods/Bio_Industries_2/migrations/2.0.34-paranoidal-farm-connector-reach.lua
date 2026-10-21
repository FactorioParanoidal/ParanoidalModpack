-- Paranoidal: the hidden connector pole of Bio farms got a longer wire reach (5 -> 10).
-- Poles keep their wires after a prototype change, so recreate the connectors of
-- existing farms: a new pole auto-connects to the poles now in reach, as on building.
local name = "bi-bio-farm-hidden-connector_pole"
if not prototypes.entity[name] then return end

local recreated = 0
for _, entry in pairs(storage.bi_bio_farm_table or {}) do
  local base = entry.base
  if base and base.valid then
    local old = entry.connector
    local position = (old and old.valid) and old.position or base.position
    if old and old.valid then
      old.destroy()
    end
    local pole = base.surface.create_entity({
      name = name,
      position = position,
      force = base.force,
    })
    if pole then
      pole.minable = false
      pole.destructible = false
      recreated = recreated + 1
    end
    entry.connector = pole
  end
end
log("Bio farm connectors recreated with the new wire reach: " .. recreated)
