-- Recompute the exploration science pack conditions after every other mod has
-- had a chance to add planets, recipes, alternative recipes and technologies.
-- The data-updates pass in prototypes/mod-data/interstellar-science-pack.lua
-- is only an early snapshot; this pass is authoritative.
Muluna.exploration_science.refresh()
