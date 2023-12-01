local table = require("__flib__.table")

local constants = require("constants")

local global_data = {}

function global_data.init()
  global.forces = {}
  global.players = {}
  global.prototypes = {}
end

function global_data.build_prototypes()
  global.forces = table.shallow_copy(game.forces)

  local prototypes = {}

  for key, filters in pairs(constants.prototypes.filtered_entities) do
    prototypes[key] = table.shallow_copy(game.get_filtered_entity_prototypes(filters))
  end
  for _, type in pairs(constants.prototypes.straight_conversions) do
    prototypes[type] = table.shallow_copy(game[type .. "_prototypes"])
  end

  global.prototypes = prototypes
end

function global_data.update_sync_data()
  global.sync_data = {
    active_mods = script.active_mods,
    settings = table.map(settings.startup, function(v)
      return v
    end),
  }
end

function global_data.add_force(force)
  table.insert(global.forces, force)
end

function global_data.check_should_load()
  local sync_data = global.sync_data or { active_mods = {}, settings = {} }

  if
    global.prototypes
    and table.deep_compare(sync_data.active_mods, script.active_mods)
    and table.deep_compare(sync_data.settings, settings.startup)
  then
    for _, prototypes in pairs(global.prototypes) do
      for _, prototype in pairs(prototypes) do
        if not prototype.valid then
          return false
        end
      end
    end
    return true
  end

  return false
end

return global_data
