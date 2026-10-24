-- Legendary ruins: entry point used by control.lua. Returns the event handlers; control.lua owns
-- the registration (one handler per event for the whole mod).
local C = require("legendary.config")
local K = require("legendary.kit")
local S = require("legendary.site")
local R = require("legendary.relics")
local kinds = require("legendary.kinds")

-- Late-bound site functions for the kinds (site.lua requires the kinds, so they cannot require it).
K.solve = S.solve
K.ruin = S.ruin
K.watch = S.watch

local M = {}

M.kinds = kinds

function M.on_init()
  S.state()
  S.setup_force()
end

function M.on_configuration_changed()
  S.state()
  S.setup_force()
end

function M.on_tick(event)
  S.on_tick(event)
  R.on_tick(event.tick)
end

function M.on_chunk_generated(event) S.on_chunk_generated(event) end

function M.on_built(event)
  local entity = event.entity
  if not (entity and entity.valid) then return end
  if entity.name:sub(1, #R.PREFIX) == R.PREFIX then R.on_built(entity) end
  S.on_built(event)
end

function M.on_built_tile(event) S.on_built_tile(event) end

function M.on_mined_tile(event) S.on_mined_tile(event) end

function M.on_mined(event) S.on_mined(event) end

function M.on_marked_for_deconstruction(event) S.on_marked_for_deconstruction(event) end

function M.on_object_destroyed(event)
  if not R.on_object_destroyed(event) then S.on_object_destroyed(event) end
end

function M.on_player_changed_position(event)
  S.on_player_changed_position(event)
  local player = game.get_player(event.player_index)
  if player then R.on_player_changed_position(player) end
end

function M.on_pre_player_died(event)
  local player = game.get_player(event.player_index)
  if player then R.on_pre_player_died(player) end
end

function M.on_player_respawned(event)
  local player = game.get_player(event.player_index)
  if player then R.on_player_respawned(player) end
end

function M.on_chunk_deleted(event) S.on_chunk_deleted(event) end

function M.on_surface_removed(surface_index) S.on_surface_removed(surface_index) end

function M.on_force_created() if storage.legend then S.setup_force() end end

function M.on_setting_changed(name)
  if name == "pd-legendary-ferocity" then S.setup_force() end
end

---Is the position inside a legendary site that must not be touched (RSO mines, etc.)?
function M.reserved(surface_index, position, margin)
  local site = S.site_at(surface_index, position, margin or 0)
  return site ~= nil and site.state ~= "lost"
end

-- Statistics for /ruins: found legendary types of a force and the total.
function M.found(found_force) return S.found_count(found_force) end
function M.total() return #kinds.list end

M.site = S
M.config = C
M.relic_names = R.names

return M
