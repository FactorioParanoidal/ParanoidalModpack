--------------------------------------------------------------------
-- If startup settings have been changed, we need to check some stuff.
-- Keep that in a separate file so the main control.lua is easier to
-- read!
--------------------------------------------------------------------

local BioInd = require('common')('Bio_Industries')

local settings_changed = {}

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
