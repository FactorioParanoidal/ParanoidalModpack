local miniloader = require "lualib.miniloader"
local util = require "lualib.util"

local configchange = {}

local version = require("version")

local all_migrations = {}

local function add_migration(migration)
  all_migrations[#all_migrations+1] = migration
end

local forall_miniloaders = miniloader.forall

add_migration{
  name = "v1_9_4_fix_mined_loaders",
  low = {0,0,0},
  high = {1,9,4},
  task = function()
    for _, surface in pairs(game.surfaces) do
      for _, inserter in pairs(surface.find_entities_filtered{type = "inserter"}) do
        if util.is_miniloader_inserter(inserter) then
          local loader_name = inserter.name:gsub("%-inserter$", "").."-loader"
          if not surface.find_entity(loader_name, inserter.position) then
            log("found miniloader-inserter without miniloader-loader at "
              ..serpent.line(inserter.position).." on "..surface.name)
            local orientation = util.orientation_from_inserters(inserter)
            surface.create_entity{
              name = loader_name,
              position = inserter.position,
              direction = orientation.direction,
              force = inserter.force,
              type = orientation.type,
              create_build_effect_smoke = false,
            }
          end
        end
      end
    end
  end,
}

add_migration{
  name = "v1_10_0_add_fake_target_chests",
  low = {0,0,0},
  high = {1,10,0},
  task = function()
    forall_miniloaders(function(surface, entity)
      surface.create_entity{
        name = "miniloader-target-chest",
        position = entity.position,
        force = entity.force,
      }
    end)
  end,
}

add_migration{
  name = "v1_10_0_add_boblogistics_basic_miniloader",
  low = {0,0,0},
  high = {1,10,0},
  task = function()
    if game.technology_prototypes["basic-miniloader"] then
      for _, f in pairs(game.forces) do
        if f.technologies["miniloader"].researched then
          f.technologies["basic-miniloader"].researched = true
        end
      end
    end
  end,
}

add_migration{
  name = "v1_11_1_remove_stray_chests",
  low = {0,0,0},
  high = {1,11,1},
  task = function()
    for _, s in pairs(game.surfaces) do
      for _, chest in pairs(s.find_entities_filtered{name = "miniloader-target-chest"}) do
        if not next(util.find_miniloaders{surface = s, position = chest.position}) then
          chest.destroy()
        end
      end
    end
  end,
}

add_migration{
  name = "v1_12_3_add_global_player_placed_blueprint",
  low = {0,0,0},
  high = {1,12,3},
  task = function()
    global.player_placed_blueprint = {}
  end,
}

add_migration{
  name = "v1_14_3_add_global_previous_opened_blueprint_for",
  low = {0,0,0},
  high = {1,14,3},
  task = function()
    global.previous_opened_blueprint_for = {}
  end,
}

function configchange.on_mod_version_changed(old)
  old = version.parse(old)
  for _, migration in ipairs(all_migrations) do
    if version.between(old, migration.low, migration.high) then
      log("running world migration "..migration.name)
      migration.task()
    end
  end
end

-- changes in other mods may affect belt speeds, and hence the required number of inserters
function configchange.fix_inserter_counts()
  forall_miniloaders(function(surface, loader)
    local inserters = util.get_loader_inserters(loader)
    if not next(inserters) then
      log("Miniloader at "..loader.position.x..", "..loader.position.y..
        " on surface "..surface.name.." has no inserters.")
        loader.destroy()
      return
    end
    miniloader.fixup(inserters[1])
  end)
end

return configchange
