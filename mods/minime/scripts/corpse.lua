minime.entered_file()

-- If a character mod has been removed and players still were using a character
-- provided by that mod, chances are this character came with its own character-
-- corpse, and the corpses will have been removed as well.
-- In order to protect players from losing expensive equipment due to removal
-- of modded corpses, we backup the corpses and create a generic fallback corpse
-- in on_configuration_changed, if necessary.
local minime_corpse = {}


------------------------------------------------------------------------------------
--                   Compile list of character-corpse prototypes                  --
------------------------------------------------------------------------------------
minime_corpse.make_corpse_list = function()
  minime.entered_function()

  -- Find all character prototypes
  local corpses = prototypes.get_entity_filtered({
    {filter = "type", type = "character-corpse"},
  })

  -- Get prototype of our own generic corpse
  local corpse = corpses[minime.generic_corpse_name]

  -- Initialize lookup list with data of generic corpse.
  mod.minime_corpse_prototypes = {
    [minime.generic_corpse_name] = corpse and {time_to_live = corpse.time_to_live}
  }

  -- Add data for the corpses of our characters
  -- (mod.minime_character_properties may be nil if called from migration script)
  for char_name, char_data in pairs(mod.minime_character_properties or {}) do
    corpse = char_data.corpse and corpses[char_data.corpse]
    if corpse and not mod.minime_corpse_prototypes[corpse.name] then
      mod.minime_corpse_prototypes[corpse.name] = {time_to_live = corpse.time_to_live}
    end
  end
minime.show("mod.minime_corpse_prototypes", mod.minime_corpse_prototypes)

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--                         Remove corpse from player data                         --
------------------------------------------------------------------------------------
minime_corpse.remove_corpse_data = function(event)
  minime.entered_function({event})

  local char_id = event.dead_character_id
  local corpse_index = event.corpse_index

  local corpse = event.corpse or event.entity

minime.show("corpse", corpse)
minime.show("not corpse.valid", corpse and not corpse.valid)
minime.show("type(corpse)", type(corpse))

minime.show("mod.minime_corpses", mod.minime_corpses)
  local data

  -- Event data contains a pointer to a specific corpse
  if char_id and corpse_index then
minime.writeDebug("Looking for corpse using event data!")
    data = mod.minime_corpses[char_id] and mod.minime_corpses[char_id][corpse_index]
minime.show("data", data)
    if data then
      minime.writeDebug("mod.minime_corpses[%s][%s]", {char_id, corpse_index})

      -- Destroy inventory
      if data.inventory and data.inventory.valid then
        data.inventory.destroy()
        minime.writeDebug("Removed inventory of %s created on tick %s!",
                          {minime.argprint(data.entity), data.character_corpse_tick_of_death})
      end

      -- Destroy corpse: NO! We're in pre_mined, if we destroy the corpse now, we
      -- won't get the items from it!
      --~ if data.entity and data.entity.valid then
        --~ minime.writeDebug("Removing %s created on tick %s!",
                          --~ {minime.argprint(data.entity), data.character_corpse_tick_of_death})
        --~ data.entity.destroy()
      --~ end

      -- Remove all data of this corpse
      mod.minime_corpses[char_id][corpse_index] = nil
      minime.writeDebug("Removed data of mod.minime_corpses[%s][%s]!",
                        {char_id, corpse_index})
      if not next(mod.minime_corpses[char_id]) then
        mod.minime_corpses[char_id] = nil
        minime.writeDebug("Removed mod.minime_corpses[%s]!", {char_id})
      end
    end

  -- We must search our data for the right corpse
  else
minime.writeDebug("Must search corpses!")

    -- Compare data of event corpse and stored corpse
    local function compare(args)
      local ret
      local a, b, desc = args[1], args[2], args[3]
      desc = desc and desc:upper()..":\t" or ""

      if type(a) == "table" and type(b) == "table" then
        ret = util.table.compare(a, b)
minime.show(desc.."util.table.compare("..serpent.line(a)..", "..serpent.line(b)..")", ret)
      else
        ret = (a == b)
minime.show(desc..serpent.line(a).." == "..serpent.line(b), ret)
      end

      return ret
    end

    local pass_on, tests, match

    --~ for char_id, corpses in pairs(mod.minime_corpses) do
--~ minime.show("Checking corpses for character", char_id)
      --~ for c, corpse_data in pairs(corpses) do
--~ minime.show("INDEX", c)

        --~ pass_on = {dead_character_id = char_id, corpse_index = c}
        --~ -- Both event corpse and stored corpse are valid, so we can check if all
        --~ -- their properties are identical
        --~ if corpse and corpse.valid and
          --~ (corpse_data.entity and corpse_data.entity.valid and
                                  --~ corpse.name == corpse_data.name) or
          --~ (corpse.name == minime.generic_corpse_name and corpse_data.use_generic) then

          --~ minime.writeDebug("Both corpses are valid!")
          --~ tests = {
            --~ {corpse.position, corpse_data.position, "position"},
            --~ {corpse.surface.name, corpse_data.surface, "surface"},
            --~ {corpse.orientation, corpse_data.orientation, "orientation"},
            --~ {corpse.direction, corpse_data.direction, "direction"},
            --~ {corpse.character_corpse_death_cause, corpse_data.character_corpse_death_cause, "death cause"},
            --~ {corpse.character_corpse_tick_of_death, corpse_data.character_corpse_tick_of_death, "death tick"},
          --~ }
          --~ match = true
          --~ for t, test in pairs(tests) do
            --~ if not compare(test) then
              --~ match = false
              --~ minime.writeDebug("Test failed!")
              --~ break
            --~ end
          --~ end

          --~ -- Found stored data. Run this function again to remove stored corpse!
          --~ if match then
            --~ minime.writeDebug("Recurse to remove corpse %s of dead character %s!",
                              --~ {c, char_id})
            --~ minime_corpse.remove_corpse_data(pass_on)
          --~ end

        --~ -- The stored corpse has become invalid, so we can remove its data
        --~ elseif not (corpse_data.entity and corpse_data.entity.valid) then
          --~ minime.writeDebug("Remove data for invalid corpse %s of dead character %s!",
                            --~ {c, char_id})
          --~ minime_corpse.remove_corpse_data(pass_on)
        --~ end
      --~ end
    --~ end
  --~ end
    for c_id, corpses in pairs(mod.minime_corpses) do
minime.show("Checking corpses for character", c_id)
      for c, corpse_data in pairs(corpses) do
minime.show("INDEX", c)

        pass_on = {dead_character_id = c_id, corpse_index = c}
        -- Both event corpse and stored corpse are valid, so we can check if all
        -- their properties are identical
        if corpse and corpse.valid and
          (corpse_data.entity and corpse_data.entity.valid and
                                  corpse.name == corpse_data.name) or
          (corpse.name == minime.generic_corpse_name and corpse_data.use_generic) then

          minime.writeDebug("Both corpses are valid!")
          tests = {
            {corpse.position, corpse_data.position, "position"},
            {corpse.surface.name, corpse_data.surface, "surface"},
            {corpse.orientation, corpse_data.orientation, "orientation"},
            {corpse.direction, corpse_data.direction, "direction"},
            {corpse.character_corpse_death_cause, corpse_data.character_corpse_death_cause, "death cause"},
            {corpse.character_corpse_tick_of_death, corpse_data.character_corpse_tick_of_death, "death tick"},
          }
          match = true
          for t, test in pairs(tests) do
            if not compare(test) then
              match = false
              minime.writeDebug("Test failed!")
              break
            end
          end

          -- Found stored data. Run this function again to remove stored corpse!
          if match then
            minime.writeDebug("Recurse to remove corpse %s of dead character %s!",
                              {c, c_id})
            minime_corpse.remove_corpse_data(pass_on)
          end

        -- The stored corpse has become invalid, so we can remove its data
        elseif not (corpse_data.entity and corpse_data.entity.valid) then
          minime.writeDebug("Remove data for invalid corpse %s of dead character %s!",
                            {c, c_id})
          minime_corpse.remove_corpse_data(pass_on)
        end
      end
    end
  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--                         Update inventory in corpse data                        --
------------------------------------------------------------------------------------
minime_corpse.update_corpse_inventory = function(corpse_data, entity)
  minime.entered_function({corpse_data, entity and entity.name or "nil"})

  if type(corpse_data) ~= "table" or not (corpse_data.dead_character_id and corpse_data.corpse_index) then
    minime.arg_err(corpse_data, "corpse_data")
  end
  minime.check_args(entity, "LuaEntity", "character-corpse entity")

  local inventory = corpse_data.inventory
  local entity_inventory = entity.get_inventory(defines.inventory.character_corpse)

  -- Sync inventory of old entity with stored data
  if inventory and entity_inventory then

    -- Resize inventory
    if #inventory ~= #entity_inventory then
      minime.writeDebug("Changing size of stored inventory from %s to %s",
                        {#inventory, #entity_inventory})
      inventory.resize(#entity_inventory)
    end

    -- Backup items
    minime.writeDebug("Backing up inventory")
    for slot = 1, #entity_inventory do
      inventory[slot].set_stack(entity_inventory[slot])
      minime.writeDebug("Backed up slot %s: %s (%s)", {
        slot,
        inventory[slot].valid_for_read and inventory[slot].name or "empty",
        inventory[slot].valid_for_read and inventory[slot].count or "nil"
      })
    end
  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--                                 Replace corpse                                 --
------------------------------------------------------------------------------------
minime_corpse.replace_corpse = function(corpse_data, new_name, old_entity)
  minime.entered_function({corpse_data, new_name, old_entity and old_entity.name or "nil"})

  if type(corpse_data) ~= "table" or
      not (corpse_data.dead_character_id and corpse_data.corpse_index) then
    minime.arg_err(corpse_data, "corpse_data")
  end
  minime.check_args(new_name, "string", "corpse name")

  old_entity = old_entity or corpse_data.entity
minime.show("old_entity", old_entity)

  local char_id = corpse_data.dead_character_id
  local corpse_index = corpse_data.corpse_index
  local old_data = mod.minime_corpses[char_id] and
                    mod.minime_corpses[char_id][corpse_index]

  -- Only create the corpse if the surface it was on still exists. It makes no sense to
  -- fall back to player.surface because the player may be on another surface that is
  -- smaller. If the surface has been removed, the corpse will be lost, but that's not
  -- our fault! :-D
  --~ local surface = (type(old_data.surface) == "string" and game.surfaces[old_data.surface]) or
                    --~ (type(old_data.surface) == "table" and
                      --~ old_data.surface.object_name == "LuaSurface" and old_data.surface)
  local surface = minime.ascertain_surface(old_data.surface)

  local inventory = old_data.inventory

  minime.writeDebug("Found data of removed corpse \"%s\" (%s of %s) for dead character \"%s\": %s",
                    {corpse_data.name, corpse_index, table_size(mod.minime_corpses[char_id]), char_id, corpse_data})

  if surface and surface.valid and inventory and inventory.valid then
    if old_entity and old_entity.valid then
      -- Sync inventory of old entity with stored data
      minime.writeDebug("Updating stored inventory!")
      minime_corpse.update_corpse_inventory(old_data, old_entity)

      -- Remove old corpse entity
      minime.writeDebug("Removing old corpse %s!", old_entity.name)
      old_entity.destroy({raise_destroy = true})
    end

    -- Create new corpse
    local new = surface.create_entity({
      name = new_name,
      inventory_size = #inventory,
      position = old_data.position,
      direction = old_data.direction,

      raise_built = true,
      create_build_effect_smoke = false,
      spawn_decorations = true,
      move_stuck_players = true,
    })
    minime.writeDebug("Created replacement %s \"%s\" for character %s!",
                      {new.type, new.name, old_data.dead_character_id})

    -- Make sure the corpse has really been created!
    if new and new.valid then
      -- Update corpse data
      old_data.entity = new

      -- Update corpse entity
      -- This can't be nil!
      if old_data.character_corpse_player_index then
        new.character_corpse_player_index = old_data.character_corpse_player_index
      end
      new.character_corpse_tick_of_death = old_data.character_corpse_tick_of_death
      new.character_corpse_death_cause = old_data.character_corpse_death_cause
      minime.writeDebug("Set corpse player index (%s), tick (%s) and cause (%s) of death.",
                        {new.character_corpse_player_index or "nil",
                          new.character_corpse_tick_of_death,
                          new.character_corpse_death_cause})

      new.orientation = old_data.orientation
      minime.writeDebug("Changed orientation to %s", {new.orientation})

      -- Fill inventory
      if inventory then
        local new_inventory = new.get_inventory(defines.inventory.character_corpse)

        for slot = 1, #inventory do
          new_inventory[slot].set_stack(inventory[slot])
          --~ minime.writeDebug("Copied slot %s: %s (%s)",
                            --~ {slot, inventory[slot].name, inventory[slot].count})
          minime.writeDebug("Copied slot %s: %s",
                            {slot, minime.argprint(inventory[slot])})
        end
      end
      minime.writeDebug("Finished copying inventory!")
    end
  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--                              Check stored corpses                              --
------------------------------------------------------------------------------------
minime_corpse.check_corpses = function()
  minime.entered_function()

  --~ local name, corpses, current
  local name, current

  -- Entities can have more than one corpse (only relevant for modded characters)!
  for char_id, char_data in pairs(mod.minime_corpses or {}) do
    minime.writeDebugNewBlock("Checking corpses of character %s", {char_id})

    -- Check each corpse
    for c, corpse in pairs(char_data) do
      name = corpse.name

      -- Remove data of expired corpse
      --~ if corpse.corpse_expires_on_tick <= game.tick then
      if corpse.corpse_expires_on_tick and
          corpse.corpse_expires_on_tick <= game.tick then

        minime.writeDebug("Removing corpse \"%s\" (expired on tick %s)",
                          {name, corpse.corpse_expires_on_tick})
        minime_corpse.remove_corpse_data(corpse)

      -- If the corpse prototype doesn't exist, and if we didn't replace it with
      -- the generic corpse yet, do that now!
      elseif not (mod.minime_corpse_prototypes[name] or corpse.use_generic) then
        minime.writeDebug("Expected prototype \"%s\" does not exist!", {name})
        minime_corpse.replace_corpse(corpse, minime.generic_corpse_name)

        minime.writeDebug("Mark corpse as generic!")
        corpse.use_generic = true

      -- Corpse prototype exists or has already been replaced with generic corpse
      else
        current = corpse.entity
        if current.valid then
          -- Corpse prototype exists, but generic corpse is used
          if current.name ~= name and mod.minime_corpse_prototypes[name] then
            minime.writeDebug("Replacing character-corpse \"%s\" with \"%s\"!",
                              {name, current.name})
            minime_corpse.replace_corpse(corpse, name, current)

            minime.writeDebug("Remove flag for generic corpse!")
            corpse.use_generic = nil

          -- Found expected corpse. Sync inventory with stored data!
          else
            minime.writeDebug("Syncing stored inventory data with %s",
                              {current.name})
            minime_corpse.update_corpse_inventory(corpse, current)
          end
        end
      end
    end
  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--  When a character has died, get all the data we want to store with the corpse  --
--  but can't access anymore when the corpse is created in on_post_entity_died.   --
------------------------------------------------------------------------------------
minime_corpse.on_player_died = function(event)
  minime.entered_function({event})

  local player = minime.ascertain_player(event.player_index)
  local char = player.character

minime.show("player", player)
minime.show("char", char)
minime.show("char.valid", char and char.valid)

  if char and char.valid then
    local killer = event.cause
minime.show("killer.type", killer and killer.type)
minime.show("killer.name", killer and killer.name)
    if killer then
      if killer.type == "character" then
        killer = (killer.player and killer.player.name) or
                  (killer.associated_player and killer.associated_player.name)
      else
        killer = minime.loc_name(killer)
      end
    end
minime.show("killer", killer)

    -- These values will be shared by all corpses generated for this character.
    mod.minime_corpses[char.unit_number] = {
      character_corpse_player_index = player.index,
      character_corpse_death_cause = killer,
    }
minime.show("mod.minime_corpses["..char.unit_number.."]", mod.minime_corpses[char.unit_number])

  -- Nothing to do
  else
    minime.writeDebug("%s has no character!", {minime.argprint(player)})
  end

  minime.entered_function("leave")
end

------------------------------------------------------------------------------------
--  When a character has died, get all the data we want to store with the corpse  --
--  but can't access anymore when the corpse is created in on_post_entity_died.   --
------------------------------------------------------------------------------------
minime_corpse.on_entity_died = function(event)
  minime.entered_function({event})

  local entity = event.entity

minime.show("entity", entity)
minime.show("entity.player", entity.player)
minime.show("entity.associated_player", entity.associated_player)

  -- We can skip this for characters we don't care about
  if mod.minime_character_properties and
      mod.minime_character_properties[entity.name] then

    minime.writeDebug("We care about dead %s!", {minime.argprint(entity)})
    -- If the dead character was connected to a player, we've already initialized
    -- the table for this corpse!
    if not mod.minime_corpses[entity.unit_number] then
      minime.writeDebug("Initializing corpse table for dead %s", {minime.argprint(entity)})
      -- If the death was caused by a character, we want the name of the player!
      local killer = event.cause
minime.show("killer.type", killer and killer.type)
      if killer then
        if killer.type == "character" then
          killer = (killer.player and killer.player.name) or
                    (killer.associated_player and killer.associated_player.name)
        else
          killer = minime.loc_name(killer)
        end
      end
minime.show("killer", killer)

      -- Initialize the corpse table with data we get from the character. These
      -- values will be shared by all corpses generated for this character.
      mod.minime_corpses[entity.unit_number] = {
        character_corpse_player_index = entity.associated_player and
                                        entity.associated_player.index,
        character_corpse_death_cause = killer,
      }
    -- Nothing to do!
    else
      minime.writeDebug("Already initialized corpse table!")
    end
  end
minime.show("mod.minime_corpses["..entity.unit_number.."]", mod.minime_corpses[entity.unit_number])
  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
--    Back up the new corpse and update the inventory data of all other corpses   --
------------------------------------------------------------------------------------
minime_corpse.on_post_entity_died = function(event)
  minime.entered_function({event})

  ------------------------------------------------------------------------------------
  -- Back up data of the new corpse
  local corpses = event.corpses
  --~ local inventory, inventory_copy, data, proto
  local inventory, inventory_copy, proto

  local char_id = event.unit_number

  if mod.minime_corpses[event.unit_number] then
    -- There may be several corpses!
    for corpse_index, corpse in pairs(corpses) do
minime.show("game.tick", game.tick)
minime.show("corpse.character_corpse_tick_of_death", corpse.character_corpse_tick_of_death)

      inventory = corpse.get_inventory(defines.inventory.character_corpse)
      inventory_copy = inventory and game.create_inventory(#inventory)

      for s = 1, #inventory do
        inventory_copy[s].set_stack(inventory[s])
      end

      proto = mod.minime_corpse_prototypes[corpse.name] or
              minime.arg_err(proto, "corpse prototype name")

      table.insert(mod.minime_corpses[char_id], {
        entity = corpse,
        name = corpse.name,
        position = corpse.position,
        orientation = corpse.orientation,
        surface = corpse.surface.name,
        direction = corpse.direction,
        inventory = inventory_copy,

        -- Copy character-wide values to corpse data
        character_corpse_player_index = mod.minime_corpses[char_id].character_corpse_player_index,
        character_corpse_death_cause = mod.minime_corpses[event.unit_number].character_corpse_death_cause,

        character_corpse_tick_of_death = corpse.character_corpse_tick_of_death,
        --~ corpse_expires_on_tick = event.tick + (proto.time_to_live),
        corpse_expires_on_tick = (proto.time_to_live > 0) and
                                    (event.tick + proto.time_to_live) or nil,

        -- For unique identification, store unit number of dead character and index of
        -- corpse in this table
        dead_character_id = char_id,
        corpse_index = corpse_index,
      })
      minime.writeDebug("Stored %s in mod.minime_corpses[%s]!",
                        {minime.argprint(corpse), event.unit_number})
    end
    -- As these values have been copied to all corpses, we can remove the originals!
    mod.minime_corpses[char_id].character_corpse_player_index = nil
    mod.minime_corpses[char_id].character_corpse_death_cause = nil

minime.show("mod.minime_corpses["..char_id.."]", mod.minime_corpses[char_id])

  end

  minime.entered_function("leave")
end


------------------------------------------------------------------------------------
minime.entered_file("leave")

return minime_corpse
