-- Blueprints keep the normal locomotive names, so they stay valid without this mod.
-- (An MU twin in a blueprint would still be built from the normal item through placeable_by.)
local catalog = require("script.catalog")

local M = {}

local function is_blueprint(target)
  if not (target and target.valid) then return false end
  if target.object_name == "LuaItemStack" then
    return target.valid_for_read and target.is_blueprint and target.is_blueprint_setup()
  end
  return target.type == "blueprint" and target.is_blueprint_setup()
end

function M.remap(target)
  if not is_blueprint(target) then return false end
  local entities = target.get_blueprint_entities()
  if not entities then return false end
  local changed = false
  for _, entity in pairs(entities) do
    local std = catalog.std(entity.name)
    if std then
      entity.name = std
      changed = true
    end
  end
  if changed then target.set_blueprint_entities(entities) end
  return changed
end

function M.on_setup(event)
  local player = game.get_player(event.player_index)
  local targets = {event.stack, event.record, player and player.blueprint_to_setup, player and player.cursor_stack}
  for i = 1, 4 do
    local target = targets[i]
    if is_blueprint(target) then
      M.remap(target)
      return
    end
  end
end

function M.on_configured(event)
  local player = game.get_player(event.player_index)
  if player then M.remap(player.cursor_stack) end
end

return M
