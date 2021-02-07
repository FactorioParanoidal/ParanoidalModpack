--------------------------------------------------------------------
-- If startup settings have been changed, we need to check some stuff.
-- Keep that in a separate file so the main control.lua is easier to
-- read!
--------------------------------------------------------------------

local BioInd = require('common')('Bio_Industries')

local settings_changed = {}

-- Adjust the force of hidden poles on Musk floor!
settings_changed.musk_floor = function()
  -- Look for solar panels on every surface. They determine the force poles will use
  -- if the electric grid overlay will be shown in mapview.
  local sm_panel_name = "bi-musk-mat-hidden-panel"
  local sm_pole_name = "bi-musk-mat-hidden-pole"

  -- If dummy force is not used, force of a hidden pole should be that of the hidden solar panel.
  -- That force will be "enemy" for poles/solar panels created with versions of Bio Industries
  -- prior to 0.17.45/0.18.13 because of the bug. We can fix that for singleplayer games by setting
  -- the force to player force. In multiplayer games, we can do this as well if all players are
  -- on the same force. If there are several forces that have players, it's impossible to find out
  -- which force built a certain musk floor tile, so "enemy" will still be used.
  -- (Only fix in this case: Players must remove and rebuild all existing musk floor tiles!)

  --~ local single_player_force = game.is_multiplayer() and nil or game.players[1].force.name
  local force = nil

  -- Always use dummy force if option is set
  if BioInd.UseMuskForce then
    force = BioInd.MuskForceName
  -- Singleplayer mode: use force of first player
  elseif not game.is_multiplayer() then
    force = game.players[1].force.name
  -- Multiplayer game
  else
    local count = 0
    -- Count forces with players
    for _, check_force in pairs(game.forces) do
      if next(check_force.players) then
        force = check_force.name
        count = count + 1
      end
    end
    -- Several forces with players: reset force to nil now and use force of panel later
    -- (If this happens in a game were musk floor was created the buggy way with "force == nil",
    --  it will be impossible to determine which force built it, so the force will still be
    --  the default, i.e. "enemy".)
    if count > 1 then
      force = nil
    end
  end

  for name, surface in pairs(game.surfaces) do
    BioInd.writeDebug("Looking for %s on surface %s", {sm_panel_name, name})
    local sm_panel = surface.find_entities_filtered{name = sm_panel_name}
    local sm_pole = {}

    -- Look for hidden poles on position of hidden panels
    for p, panel in ipairs(sm_panel) do
      sm_pole = surface.find_entities_filtered{
        name = sm_pole_name,
        position = panel.position,
      }

      -- If more than one hidden pole exists at that position for some reason, remove all but the first!
      if #sm_pole > 1 then
BioInd.writeDebug("Number of poles for panel %g: %g", {p, #sm_pole})
        for i = 2, #sm_pole do
BioInd.writeDebug("Destroying pole number %g", {i})
          sm_pole[i].destroy()
        end
      end

      -- Set force of the pole
      sm_pole[1].force = force or panel.force
    end
  end
  BioInd.writeDebug("Electric grid overlay of musk floor will be %s in map view.",
                    {BioInd.UseMuskForce and "hidden" or "displayed"})
end


settings_changed.bio_garden = function()
  BioInd.writeDebug("Entered function settings_changed.bio_garden!")

  -- Has this setting been changed since the last time the game was run?
  local current = BioInd.get_startup_setting("BI_Easy_Bio_Gardens")
BioInd.show("Last state of BI_Easy_Bio_Gardens", global.mod_settings.BI_Easy_Bio_Gardens)
BioInd.show("Current state of BI_Easy_Bio_Gardens", current)

  if global.mod_settings.BI_Easy_Bio_Gardens ~= current then
BioInd.writeDebug("Setting has been changed!")
    local pole, neighbours
    -- This is the unmodified table!
    local compound_entity = BioInd.compound_entities["bi-bio-garden"]
    local hidden_entities = compound_entity.hidden

    -- Check that all gardens are still valid
    for g, garden in pairs(global[compound_entity.tab]) do
      -- Base entity doesn't exist -- remove hidden entities!''
      if not (garden.base and garden.base.valid) then
        -- Remove all hidden entities!
        for hidden, h_name in pairs(compound_entity.hidden or {}) do
BioInd.show("hidden", hidden)
BioInd.writeDebug("Removing hidden entity %s %s", {
  garden[hidden] and garden[hidden].valid and garden[hidden].name or "nil",
  garden[hidden] and garden[hidden].valid and garden[hidden].unit_number or "nil"})
          BioInd.remove_entity(garden[hidden])
          garden[hidden] = nil
        end
        global[compound_entity.tab][garden.entity.unit_number] = nil
      end
    end


    -- For whatever reason, there may be hidden poles that aren't associated
    -- with any garden. We want to remove these, so lets' compile a list of all
    -- hidden poles first.
    local remove_poles = {}
    local found_poles
    local pole_type = "electric-pole"
    for s, surface in pairs(game.surfaces) do
      -- Find poles on surface
      found_poles = surface.find_entities_filtered{
        name = compound_entity.hidden[pole_type].name,
        type = "electric-pole",
      }
      -- Add them to list of removeable poles, indexed by unit_number
      for p, pole in ipairs(found_poles) do
        remove_poles[pole.unit_number] = pole
      end
    end

    -- Setting is on, so we need to create the hidden poles
    if current then
      BioInd.writeDebug("Need to create hidden poles for %s Bio Gardens!",
                        {table_size(global.bi_bio_garden_table) })

      -- Restore the list of hidden entities
      global.compound_entities["bi-bio-garden"] = BioInd.compound_entities["bi-bio-garden"]
      local base
      for g, garden in pairs(global.bi_bio_garden_table or {}) do
        -- Make sure the base entity exists!
        base = garden.base
        pole = base and garden[pole_type]
BioInd.show("pole", pole)
        -- There is a pole referenced in the table, and it is a valid entity
        if pole and pole.valid then
          -- Delete pole from list of removeable poles
          BioInd.writeDebug("Pole exists -- keep it!")
          remove_poles[pole.unit_number] = nil

        -- There is no valid pole, let's create one!
        elseif base then
          -- Create hidden poles
          pole = BioInd.create_entities(
            global[compound_entity.tab],
            base,
            {pole = hidden_entities[pole_type].name}
            --~ base.position
          )

          -- Add the new pole to the table
          if pole then
            global[compound_entity.tab][base.unit_number][pole_type] = pole
            BioInd.writeDebug("Stored %s %g in table: %s", {
              base.name,
              base.unit_number,
              global[compound_entity.tab][base.unit_number]
            })
          end
        end
      end

    -- Setting is off -- disconnect and remove hidden poles!
    else
      BioInd.writeDebug("%s Bio Gardens found -- try to disconnect hidden poles!",
                        {table_size(global.bi_bio_garden_table) })
      -- Find hidden poles of registered gardens
BioInd.show("global.bi_bio_garden_table", global.bi_bio_garden_table)
      for g, garden in pairs(global.bi_bio_garden_table or {}) do
        if garden[pole_type] then
          -- Pole really exists: destroy the entity
          if garden[pole_type].valid then
            -- Disconnect to prevent random connections of other poles when
            -- this one is removed
            garden[pole_type].disconnect_neighbour()
            -- Remove pole from the list of poles not associated with a garden
            remove_poles[garden[pole_type].unit_number] = nil
            -- Destroy pole
            BioInd.remove_entity(garden[pole_type])
            BioInd.show("Removed pole of garden", garden.base.unit_number)
          end
          garden[pole_type] = nil
          BioInd.show("Removed pole from table of garden", garden.base.unit_number)
        end
      end

      -- We don't want to create hidden poles if the setting is off,
      -- so remove the pole from hidden entities!
      global.compound_entities["bi-bio-garden"].hidden[pole_type] = nil
BioInd.show("global.compound_entities", global.compound_entities)
    end

    -- Remove any hidden poles that are not associated with a garden
    BioInd.writeDebug("Removing %s hidden poles not associated with a bio garden!",
                      {table_size(remove_poles)})
    for p, pole in pairs(remove_poles) do
      pole.destroy()
    end

    -- Update setting!
    global.mod_settings.BI_Easy_Bio_Gardens = current
    BioInd.show("Updated setting to", global.mod_settings.BI_Easy_Bio_Gardens)
  else
    BioInd.writeDebug("Nothing to do!")
  end
end

return settings_changed
