local blueprint = require "lualib.blueprint"
local circuit = require "circuit"
local util = require "lualib.util"

local configchange = {}

local version = require("version")

local all_migrations = {}

local function add_migration(migration)
  all_migrations[#all_migrations+1] = migration
end

add_migration{
  name = "v1_1_4_inserter_cleanup",
  low = {1,1,0},
  high = {1,1,4},
  task = function()
    for _, surface in pairs(game.surfaces) do
      for _, inserter in ipairs(surface.find_entities_filtered{name="miniloader-inserter"}) do
        local loader = surface.find_entity("miniloader-loader", inserter.position)
        if not loader then
          inserter.destroy()
        end
      end
    end
  end,
}

add_migration{
  name = "v1_1_5_miniloader_force_removal",
  low = {1,0,0},
  high = {1,1,5},
  task = function()
    game.merge_forces(game.forces["miniloader"], game.forces["player"])
  end
}

add_migration{
  name = "v1_4_1_replace_legacy_undergrounds",
  low = {1,0,0},
  high = {1,4,1},
  task = function()
    for _, surface in pairs(game.surfaces) do
      for _, entity in ipairs(surface.find_entities_filtered{type="underground-belt"}) do
        local prefix = string.match(entity.name, "(.*)miniloader%-legacy%-underground$")
        if prefix then
          local orientation = util.orientation_from_inserters(entity)
          local position = entity.position
          local force = entity.force

          -- clear transport lines to prevent spill during replacement
          local from_tl = {}
          for i=1,2 do
            local tl = entity.get_transport_line(i)
            from_tl[i] = tl.get_contents()
            tl.clear()
          end

          entity.destroy()

          local new = surface.create_entity{
            name = prefix .. "miniloader-loader",
            position = position,
            direction = orientation.direction,
            force = force,
            type = orientation.type,
          }
          util.update_inserters(new)

          for i=1,2 do
            local tl = new.get_transport_line(i)
            for name, count in pairs(from_tl[i]) do
              tl.insert_at_back({name=name, count=count})
            end
          end
        end
      end
    end
  end
}

add_migration{
  name = "v1_4_1_expose_inserters",
  low = {1,0,0},
  high = {1,4,3},
  task = function()
    for _, surface in pairs(game.surfaces) do
      for _, entity in ipairs(surface.find_entities_filtered{type="loader"}) do
        if util.is_miniloader(entity) then
          local inserters = util.get_loader_inserters(entity)
          for i=1,#inserters do
            inserters[i].destructible = true
            inserters[i].health = entity.health
            inserters[i].inserter_stack_size_override = 1
          end
          entity.destructible = false
          util.update_inserters(entity)
        end
      end
    end
  end,
}

add_migration{
  name = "v1_5_2_remove_duplicate_inserters_in_blueprints",
  low = {1,0,0},
  high = {1,5,2},
  task = function()
    -- adjust all player inventories
    for _, p in pairs(game.players) do
      log("checking player " .. p.name)
      for i=1,2 do
        log("checking inventory " .. i)
        local inv = p.get_inventory(i)
        for slot=1,#inv do
          local stack = inv[slot]
          if blueprint.is_setup_bp(stack) then
            log("found blueprint in slot " .. slot)
            blueprint.filter_miniloaders(stack)
          end
        end
      end
      if blueprint.is_setup_bp(p.cursor_stack) then
        blueprint.filter_miniloaders(p.cursor_stack)
      end
    end
  end,
}

add_migration{
  name = "v1_5_11_move_onwireplaced_state_to_global",
  low = {1,0,0},
  high = {1,5,11},
  task = function()
    global.monitored_players = {}
    global.selected_ccd_set_for = {}
    circuit.on_load()
  end,
}

add_migration{
  name = "v1_7_9_fix_stack_size_overrides",
  low = {1,0,0},
  high = {1,7,9},
  task = function()
    for _, surface in pairs(game.surfaces) do
      for _, entity in ipairs(surface.find_entities_filtered{type="inserter"}) do
        if util.is_miniloader_inserter(entity) then
          entity.inserter_stack_size_override = 1
        end
      end
    end
  end,
}

add_migration{
  name = "v1_7_12_remove_orphaned",
  low = {1,0,0},
  high = {1,7,12},
  task = function()
    local removed_loaders = 0
    local removed_inserters = 0
    for _, s in pairs(game.surfaces) do
      for _, loader in pairs(s.find_entities_filtered{type = "loader"}) do
        if util.is_miniloader(loader) then
          local inserters = util.get_loader_inserters(loader)
          if not next(inserters) then
            log("Removing orphaned miniloader at "..
              loader.position.x..","..loader.position.y..
              " on surface "..loader.surface.name)
            loader.destroy()
            removed_loaders = removed_loaders + 1
          end
        end
      end
      for _, inserter in pairs(s.find_entities_filtered{type = "inserter"}) do
        if util.is_miniloader_inserter(inserter) then
          local loader = s.find_entities_filtered{type = "loader", position = inserter.position}
          if not next(loader) then
            log("Removing orphaned miniloader-inserter at "..
              inserter.position.x..","..inserter.position.y..
              " on surface "..inserter.surface.name)
            inserter.destroy()
            removed_inserters = removed_loader + 1
          end
        end
      end
    end
    log("Removed "..removed_loaders.." orphaned miniloaders without inserters.")
    log("Removed "..removed_inserters.." orphaned miniloader inserters without a loader.")
  end,
}

local function forall_miniloaders(f)
  for _, surface in pairs(game.surfaces) do
    local miniloaders = util.find_miniloaders{surface = surface}
    for _, entity in pairs(miniloaders) do
      f(surface, entity)
    end
  end
end

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
  forall_miniloaders(function(surface, miniloader)
    local inserters = util.get_loader_inserters(miniloader)
    if not next(inserters) then
      log("Miniloader at "..miniloader.position.x..", "..miniloader.position.y..
        " on surface "..surface.name.." has no inserters.")
      return
    end
    local desired_count = util.num_inserters(miniloader)

    -- remove excess inserters
    for i=desired_count+1,#inserters do
      inserters[i].destroy()
    end

    -- create missing inserters
    for i=#inserters+1,desired_count do
      local inserter = surface.create_entity{
        name = inserters[1].name,
        position = inserters[1].position,
        direction = inserters[1].direction,
        force = inserters[1].force,
      }
      inserter.inserter_stack_size_override = 1
    end
    util.update_inserters(miniloader)
    circuit.sync_behavior(inserters[1])
    circuit.sync_filters(inserters[1])
    circuit.sync_partner_connections(inserters[1])
  end)
end

return configchange