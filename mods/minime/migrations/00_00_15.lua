minime.entered_file()
--~ local minime = require("__minime__/common")("minime")

------------------------------------------------------------------------------------
-- The dummy character we used to make a backup of a player's inventories and
-- settings was an instance of the vanilla character. That would cause problems with
-- mods like "Bob's classes" that would increase the character's main inventory.
-- In "minime" 0.15, we will use a custom character with a huge inventory as
-- dummy. (The huge inventory hopefully doesn't matter as only the script will
-- access the inventory slots.)
--
-- This script migrates the dummies from the vanilla to our custom characters.

local new_dummy, old

-- The character selector may have been disabled. If it ever was active before, we
-- still should migrate existing dummies!
if storage.player_data then
  for p, player in pairs(game.players) do
    -- Make sure player_data of player exists
    storage.player_data[p] = storage.player_data[p] or {}

    -- Use data from existing dummy, or current data from player if the player has
    -- no dummy yet!
    old = storage.player_data[p].dummy or player.character

    -- When loading a save game and the mod did not exist in that save game.
    -- script.on_init() is called before the migration script is executed, so the
    -- new dummy already exists.

    -- Player is connected and either has no dummy (use current character) or
    -- another dummy -- copy it!
    if old and old.valid and old.name ~= minime.dummy_character_name then
      minime.writeDebug("Creating new dummy for player %s!", {player.name})

      --~ new_dummy = minime_character.make_dummy(p)
      new_dummy = minime_player.make_dummy(p)

      -- Transfer inventories
      local inventory_list = minime.inventory_list
      local inventory
      for i, inv in ipairs(inventory_list) do
        minime.writeDebug("%s: Transferring items from inventory %s", {i, inv})
        inventory = defines.inventory["character_" .. inv]
        minime_inventories.transfer_inventory(old.get_inventory(inventory),
                                              new_dummy.get_inventory(inventory))
      end


      -- Copy settings/filters from Personal logistic slots
      local slots = old.character_logistic_slot_count
      new_dummy.character_logistic_slot_count = slots

      for i = 1, slots do
        new_dummy.set_personal_logistic_slot(i, old.get_personal_logistic_slot(i))
      end
      minime.writeDebug("Copied %s personal logistic slots from \"%s\" to \"%s\".",
                    {slots, minime.loc_name(old), minime.loc_name(new_dummy)})
      local personal_logistics = "character_personal_logistic_requests_enabled"
      --~ new_dummy.character_personal_logistic_requests_enabled = old.character_personal_logistic_requests_enabled
      --~ minime.writeDebug("Personal logistic requests are %s.",
                    --~ {old.character_personal_logistic_requests_enabled and "enabled" or "disabled"})
      new_dummy[personal_logistics] = old[personal_logistics]
      minime.writeDebug("Personal logistic requests are %s.",
                        {old[personal_logistics] and "enabled" or "disabled"})


      minime.writeDebug("player_data for player %s: ", {p, storage.player_data[p]})
minime.show("dummy name", minime.loc_name(storage.player_data[p].dummy))
      -- If we have an old dummy, remove it!
      if old ~= player.character then
        old.destroy()
      end

      -- Store new dummy
      storage.player_data[p].dummy = new_dummy
      minime.writeDebug("Final player_data for player %s: %s", {p, storage.player_data[p]})
minime.show("Final dummy name", minime.loc_name(storage.player_data[p].dummy))

    -- Player is not connected
    elseif not old then
      minime.writeDebug("Player %s is not connected -- nothing to do!",
                        {player.name})
    else
      minime.writeDebug("Player %s already has the correct dummy: nothing to do!",
                        {player.name})
    end

  end
else
  minime.writeDebug("storage.player_data doesn't exist -- nothing to do!")
end

minime.entered_file("leave")
