-- Creates the upgrade chains early, so other mods (zzzparanoidal icon markers, research_evolution_factor
-- tooltips) see them in their own stages.
local chain = require("lib.chain")

for _, description in ipairs(require("prototypes.chains")) do
    data:extend(chain.build(description))
end
