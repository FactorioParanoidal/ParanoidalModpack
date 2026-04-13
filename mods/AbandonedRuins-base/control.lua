local base_util = require("__core__/lualib/util")
local main = require("libs/main")

local RUINSET_NAME = "base"

---@type boolean
debug_log = settings.global["ruins-enable-debug-log"].value

local ruin_set = require("ruins/ruin_set")

local function make_ruin_set()
  -- If your ruin set is the origin of other sets aka. "stand-alone" mod:
  local new_ruins = ruin_set

  -- ------------ BEGIN ------------
  -- If your ruin set mod expands an other ruin set:
  --local new_ruins = remote.call("AbandonedRuins", "get_ruin_set", RUINSET_NAME)

  -- Add custom base ruins to existing ruins.
  -- for size, ruins in pairs(ruin_set) do
  --   for _, ruin in pairs(ruins) do
  --     table.insert(new_ruins[size], ruin)
  --   end
  -- end
  -- ------------ FINISH ------------

  -- After weapon remodeling, turrets use krastorio2 ammo instead of ammo from the base game.
  -- So, replace these items created in the ruins.
  -- if settings.startup["kr-more-realistic-weapon"].value then
  --   main.replace_item_name_in_all_ruins(new_ruins, "firearm-magazine", "rifle-magazine")
  --   main.replace_item_name_in_all_ruins(new_ruins, "piercing-rounds-magazine", "armor-piercing-rifle-magazine")
  -- end

  -- With fuel recycling, vehicles use krastorio2 fuel instead of the solid fuel from the base game.
  -- So, replace these items appearing in the ruins.
  -- if settings.startup["kr-rebalance-vehicles&fuels"].value then
  --   main.replace_item_name_in_all_ruins(new_ruins, "solid-fuel", "fuel")
  -- end

  -- Provide an expanded and modified set of ruins as a “base” set. Or choose your ruin-set name here, e.g. "krastorio2"
  remote.call("AbandonedRuins", "add_ruin_sets", RUINSET_NAME, new_ruins)
end

-- A ruin set is always created when loading the game, as ruin sets are not saved/loaded by AbandonedRuins.
-- Since on_load is used here, we need to make sure it always produces the same result for everyone.
-- Fortunately, you can make changes to ruins based on the launch settings here, as they can't change during the game.
script.on_init(make_ruin_set)
script.on_load(make_ruin_set)
