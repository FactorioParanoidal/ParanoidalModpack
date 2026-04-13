minime.entered_file()
--~ ------------------------------------------------------------------------------------
--~ --                   Remove old preview entities for characters                   --
--~ ------------------------------------------------------------------------------------
--~ -- This block changes makes changes for a version of minime that was never out in
--~ -- the wild. It's useful for cleaning up the tables during testing (so that I can
--~ -- reuse saves I made with the previous WIP version of minime), but it should be
--~ -- removed before release!
--~ local entity

--~ for c_name, c_data in pairs(storage.minime_characters) do
  --~ if c_data.preview then
    --~ entity = c_data.preview.entity
    --~ if entity and entity.valid then
      --~ minime.writeDebug("Removing %s", {minime.argprint(entity)})
      --~ entity.destroy()
    --~ end
  --~ end
--~ end


------------------------------------------------------------------------------------
--                     Remove corpses from storage.player_data                     --
------------------------------------------------------------------------------------
-- This block changes makes changes for a version of minime that was never out in
-- the wild. It's useful for cleaning up the tables during testing (so that I can
-- reuse saves I made with the previous WIP version of minime), but it should be
-- removed before release!
for p, p_data in pairs(storage.player_data or {}) do
  minime.writeDebug("Checking data of player %s", {p})

  --~ -- Destroy backup inventories
  --~ for c, c_data in pairs(p_data.corpses or {}) do
    --~ minime.show("Checking corpse "..c, c_data)
    --~ if c_data.inventory and c_data.inventory.valid then
      --~ c_data.inventory.destroy()
      --~ minime.writeDebug("Removed backup inventory!")
    --~ end
  --~ end

  --~ -- Remove corpse info from player data
  --~ if p_data.corpses then
    --~ p_data.corpses = nil
    --~ minime.writeDebug("Removed storage.player_data[%s].corpses", {p})
  --~ end


  -- Make sure the dummies have the same force as the player
  if p_data.dummy and p_data.dummy.valid then
minime.show("Dummy force", p_data.dummy.force)
minime.show("Player force", game.players[p] and game.players[p].force)
    p_data.dummy.force = game.players[p].force
  end
end


------------------------------------------------------------------------------------
--             Store character corpses from all surfaces in new table             --
------------------------------------------------------------------------------------
local corpses, inventory, inventory_copy, proto
local id = "migrated corpses"

minime_corpse.make_corpse_list()

storage.minime_corpses = storage.minime_corpses or {}
storage.minime_corpses[id] = storage.minime_corpses[id] or {}

for s_name, surface in pairs(game.surfaces) do
  corpses = surface.find_entities_filtered({type = "character-corpse"})

  for corpse_index, corpse in pairs(corpses) do
minime.show(corpse_index, corpse )
    proto = storage.minime_corpse_prototypes[corpse.name]
minime.show("proto", proto)

    if proto then
minime.show("corpse.character_corpse_tick_of_death", corpse.character_corpse_tick_of_death)

      inventory = corpse.get_inventory(defines.inventory.character_corpse)
      inventory_copy = inventory and game.create_inventory(#inventory)

      for s = 1, #inventory do
        inventory_copy[s].set_stack(inventory[s])
      end

      -- We are dealing with existing corpses. There's no way to find out now for
      -- what particular character entity they've been created. While we may lose
      -- some data (e.g. player index), at least we'll be able to preserve the
      -- corpse inventories!
      table.insert(storage.minime_corpses[id], {
        entity = corpse,
        name = corpse.name,
        position = corpse.position,
        orientation = corpse.orientation,
        surface = corpse.surface.name,
        direction = corpse.direction,
        inventory = inventory_copy,

        -- Copy character-wide values to corpse data
        character_corpse_player_index = corpse.character_corpse_player_index,
        character_corpse_death_cause = corpse.character_corpse_death_cause,

        character_corpse_tick_of_death = corpse.character_corpse_tick_of_death,
        corpse_expires_on_tick = corpse.character_corpse_tick_of_death +
                                  proto.time_to_live,

        -- For unique identification, store unit number of dead character and index
        -- of corpse in this table. (As we cumulate corpses from all surfaces under
        -- a common unit_number, assigning corpse_index my result in duplicate
        -- numbers, so we'd better add it once the table contains all corpses!)
        dead_character_id = id,
      })
      minime.writeDebug("Stored %s in storage.minime_corpses[\"%s\"]!",
                        {minime.argprint(corpse), id})
    else
      minime.writeDebug("%s is not a valid corpse prototype!",
                        {minime.argprint(corpse)})
    end
  end
end

-- Add corpse_index!
for c_index, c_data in pairs(storage.minime_corpses[id]) do
  c_data.corpse_index = c_index
  minime.show("Added corpse_index to \""..c_data.name.."\"", c_index )
end

-- If there were no corpses to migrate, remove the table entry
if not next(storage.minime_corpses[id]) then
  storage.minime_corpses[id] = nil
  minime.writeDebug("Removed storage.minime_corpses[\"%s\"]!", {id})
end


minime.entered_file("leave")
