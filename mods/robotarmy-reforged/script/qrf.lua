-- Quick reaction force: squads near a destroyed building go there, fight, and return
-- to where they were, resuming what they did before.
local config = require("script.config")
local cache = require("script.settings_cache")
local util = require("script.util")
local ai = require("script.ai")
local compat = require("script.compat")

local qrf = {}

-- Entity types that die without triggering a QRF. Biters, spitters, our own droids, robots and
-- characters are already excluded by the event filter (see qrf.event_filter).
local VEHICLES = {
  ["car"] = true, ["spider-vehicle"] = true, ["locomotive"] = true, ["cargo-wagon"] = true,
  ["fluid-wagon"] = true, ["artillery-wagon"] = true, ["infinity-cargo-wagon"] = true,
}
local WALLS = {["wall"] = true, ["gate"] = true, ["simple-entity-with-owner"] = true}

--- on_entity_died filter: not an enemy/neutral entity and not a mobile unit.
qrf.event_filter = {
  {filter = "force", force = "enemy", invert = true},
  {filter = "force", force = "neutral", invert = true, mode = "and"},
  {filter = "type", type = "unit", invert = true, mode = "and"},
  {filter = "type", type = "character", invert = true, mode = "and"},
  {filter = "type", type = "combat-robot", invert = true, mode = "and"},
  {filter = "type", type = "construction-robot", invert = true, mode = "and"},
  {filter = "type", type = "logistic-robot", invert = true, mode = "and"},
}

function qrf.on_entity_died(event)
  local radius = cache.qrf_distance
  if radius <= 0 or compat.unit_control then return end
  local entity = event.entity
  local fd = storage.forces[entity.force.index]
  if not fd or next(fd.squads) == nil then return end
  local entity_type = entity.type
  if VEHICLES[entity_type] then
    if not cache.qrf_vehicles then return end
  elseif WALLS[entity_type] then
    if not cache.qrf_walls then return end
  end

  local position = entity.position
  local surface_index = entity.surface_index
  local radius2 = radius * radius
  local coarse = (radius + 16) * (radius + 16)
  local responding, first = 0, nil
  for _, squad in pairs(fd.squads) do
    if squad.size > 0 and squad.surface_index == surface_index
      and util.distance2(squad.pos, position) <= coarse then
      local group = squad.group
      if group and group.valid and util.distance2(group.position, position) <= radius2
        and ai.start_qrf(squad, position) then
        responding = responding + 1
        first = first or squad
      end
    end
  end

  if responding > 0 and cache.qrf_alerts then
    local now = game.tick
    if not fd.qrf_alert_tick or now >= fd.qrf_alert_tick + config.QRF_ALERT_COOLDOWN then
      fd.qrf_alert_tick = now
      util.alert(fd.force, util.leader(first), util.ICON_QRF, {"robotarmy-message.qrf-alert", responding})
    end
  end
end

return qrf
