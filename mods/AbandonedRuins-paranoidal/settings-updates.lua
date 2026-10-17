-- Register the "paranoidal" ruin set in the core's selection box and make it the default.
-- Runs after AbandonedRuins-base (optional dependency), so this default wins.
local utils = require("__AbandonedRuins_updated_fork__/lua/utilities")
utils.register_ruin_set("paranoidal", true)
