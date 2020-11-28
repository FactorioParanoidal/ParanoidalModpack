--~ log("Entered minime migration script 00_00_15.lua!")

local minime = require("__minime__/common")("minime")

------------------------------------------------------------------------------------
-- The dummy character we used to make a backup of a player's inventories and
-- settings was an instance of the vanilla character. That would cause problems
-- mods like bobclasses that would increase the character's main inventory.
-- In "minime" 0.15, we will use a custom character with a huge inventory as
-- dummy. (The huge inventory hopefully doesn't matter as only the script will
-- access the inventory slots.)
--
-- This script migrates the dummies from the vanilla to our custom characters.

local new_dummy, old

-- The character selector may have been disabled. If it ever was active before, we still should
-- migrate existing dummies!
if global.player_data then
  for p, player in pairs(game.players) do
    -- Make sure player_data of player exists
    global.player_data[p] = global.player_data[p] or {}

    -- Use data from existing dummy, or current data from player if the player has no dummy yet!
    old = global.player_data[p].dummy or player.character

    -- When loading a save game and the mod did not exist in that save game script.on_init() is
    -- called before the migration script is executed, so the new dummy already exists.

    -- Player is connected and either has no dummy (use current character) or another dummy -- copy it!
    if old and old.name ~= minime.dummy_character_name  then
      minime.dprint("Creating new dummy for player " .. player.name .. "!")

      new_dummy = minime.make_dummy(p)

      -- Transfer inventories
      --~ local inventory_list = { "armor", "ammo", "guns", "main", "trash" }
      local inventory_list = minime.inventory_list
      local inventory
      for i, inv in ipairs(inventory_list) do
        minime.dprint(i .. ": Transferring items from inventory " .. inv)
        inventory = defines.inventory["character_" .. inv]
        minime.transfer_inventory(old.get_inventory(inventory), new_dummy.get_inventory(inventory))
      end


      -- Copy settings/filters from Personal logistic slots
      local slots = old.character_logistic_slot_count
      new_dummy.character_logistic_slot_count = slots

      for i = 1, slots do
        new_dummy.set_personal_logistic_slot(i, old.get_personal_logistic_slot(i))
      end
      minime.dprint("Copied ".. slots .. " personal logistic slots from " ..
                    serpent.line(minime.loc_name(old)) .. " to " ..
                    serpent.line(minime.loc_name(new_dummy)) .. ".")

      new_dummy.character_personal_logistic_requests_enabled = old.character_personal_logistic_requests_enabled
      minime.dprint("Personal logistic requests are " ..
                    tostring(old.character_personal_logistic_requests_enabled and "enabled" or "disabled"))


  minime.dprint("player_data for player " .. p .. ": " .. serpent.block(global.player_data[p]))
  minime.dprint("dummy name: " .. serpent.line(minime.loc_name(global.player_data[p].dummy)))
      -- If we have an old dummy, remove it!
      if old ~= player.character then
        old.destroy()
      end

      -- Store new dummy
      global.player_data[p].dummy = new_dummy
  minime.dprint("Final player_data for player " .. p .. ": " .. serpent.block(global.player_data[p]))
  minime.dprint("Final dummy name: " .. serpent.line(minime.loc_name(global.player_data[p].dummy)))

    -- Player is not connected
    elseif not old then
      minime.dprint("Player " .. player.name .. " is not connected -- nothing to do!")
    else
      minime.dprint("Player " .. player.name .. " already has the correct dummy: nothing to do!")
    end

  end
else
  minime.dprint("global.player_data doesn't exist -- nothing to do!")
end

--~ log("End of minime migration script 00_00_15.lua!")
