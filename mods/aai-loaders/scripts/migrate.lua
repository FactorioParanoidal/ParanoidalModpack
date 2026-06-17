local Migrate = {}

-------------------------------------------------------
-- MOD SPECIFIC PARAMETERS
-- If you're copying this file to another mod, 
-- make sure to modify the constants and methods below.
-------------------------------------------------------

local function added_to_existing_game()
  -- No action
end

---------------------------------------------------------------
-- Mod-specific parameters end here, migration code starts here
---------------------------------------------------------------


--Converts the default version string to one that can be lexographically compared using string comparisons
---@param ver string String in a version format of 'xxx.xxx.xxx' where each xxx is in the range 0-65535
---@return string version Version number with leading padded 0's for use in string comparisons
function Migrate.version_to_comparable_string(ver)
  return string.format("%05d.%05d.%05d", string.match(ver, "^(%d+)%.(%d+)%.(%d+)$"))
end

--Converts the lexographically coaprable version string to default, human readable format
---@param ver string String in a version format of 'xxxxx.xxxxx.xxxxx' where each xxxxx is a number with potential leading 0's
---@return string version Version number with leading 0's stripped
function Migrate.comparable_string_to_version(ver)
  return (string.gsub(ver, "^0*(%d-%d).0*(%d-%d).0*(%d-%d)$", "%1.%2.%3"))
end

---@param event ConfigurationChangedData
function Migrate.do_migrations(event)
  local mod_name = script.mod_name

  --check if we changed versions
  local mod_changes = event.mod_changes[mod_name]
  if mod_changes and mod_changes.old_version ~= mod_changes.new_version then
    if mod_changes.old_version == nil then
      added_to_existing_game()
      return
    end
    local old_ver_string = Migrate.version_to_comparable_string(mod_changes.old_version)
    local versions_to_migrate = {} --array of lexographically comparible migration version strings that need running
    local migrations = {} --migration version to migration function map
    --look for needed migrations
    for migrate_version, migration in pairs(Migrate.migrations) do
      local migrate_ver_string = Migrate.version_to_comparable_string(migrate_version)
      if migrate_ver_string > old_ver_string then
        table.insert(versions_to_migrate, migrate_ver_string)
        migrations[migrate_ver_string] = migration
      end
    end

    if next(versions_to_migrate) then
      log(mod_name.. ": Starting migrations from "..mod_changes.old_version.." to "..mod_changes.new_version.." " .. (script.level.is_simulation and "(simulation)" or ""))

      --ensure migrations run in the correct order
      table.sort(versions_to_migrate)

      --do migrations
      for _, version_to_migrate in pairs(versions_to_migrate) do
        log(mod_name..": Running migration "..Migrate.comparable_string_to_version(version_to_migrate))
        migrations[version_to_migrate](event)
      end
    end

    --do any test migrations
    for migration_name, migration in pairs(Migrate.test_migrations) do
      if not is_debug_mode then
        --there should never be any test migrations if not in debug mode
        local msg = "[color=red]WARNING:[/color] Test migration scripts exist while not in debug mode. These should be moved to live migrations with version labels prior to live release."
        log(msg)
        game.print(msg)
      end
      local msg = mod_name..": Running test migration: "..migration_name
      log(msg)
      game.print(msg)
      migration(event)
    end
  end
end

Migrate.migrations = {
  ["0.1.5"] = function()
    -- Need to add the `next_wet_check` field, and remove the `surface_index`
    local function find_next_check(loader)
      for next_check, wet_loaders in pairs(storage.wet_loaders) do
        for _, other_loader in pairs(wet_loaders) do
          if loader == other_loader then
            return next_check
          end
        end
      end
    end

    if storage.loaders then -- Those don't exist in non-lubricated modes
      storage.wet_loaders = storage.wet_loaders or {} -- Shouldn't happen but just in case
      for _, loader in pairs(storage.loaders) do
        loader.surface_index = nil

        if loader.wet and not loader.next_wet_check then
          -- Find this entry in the wet loaders list
          loader.next_wet_check = find_next_check(loader)
        end
      end
    end
  end,

  ["0.2.1"] = function()
    -- Redraw all dry loaders' render objects because the way to interact
    -- with them changed between 1.1 and 2.0
    rendering.clear("aai-loaders")
    for _, loader in pairs(storage.dry_loaders or { }) do
      loader.alert = rendering.draw_sprite{
        surface = loader.loader.surface,
        target = loader.loader,
        forces = {loader.loader.force},
        sprite = Loader.name_fluid_alert_sprite,
        x_scale = 0.33,
        y_scale = 0.33,
      }
    end
  end,

  ["0.2.10"] = function()
    storage.previous_belt_stacking_mode = "off"
  end,
}

Migrate.test_migrations = {
  --[[
  --Add migrations for testing in the following format with a custom named key.
  --When ready for release, change the name to the current version number and move to Migration.migrations above.
  ["My debug migrations"] = function()
    do_stuff()
  end,
  --]]
}

return Migrate
