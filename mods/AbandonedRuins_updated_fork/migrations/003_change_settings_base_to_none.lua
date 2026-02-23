local constants = require("__AbandonedRuins_updated_fork__/lua/constants")

local current = settings.global[constants.CURRENT_RUIN_SET_KEY].value

if not script.active_mods["AbandonedRuins-base"] and current == "base" then
  -- Change "base" -> none
  current = constants.NONE
end
