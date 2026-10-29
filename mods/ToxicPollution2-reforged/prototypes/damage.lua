local C = require("shared.config")

data:extend({
	-- Kept name: armor resistance to toxins is the share of smog the armor filters.
	{ type = "damage-type", name = C.RESIST_TYPE },
	-- Health damage of intoxication. Nothing resists it: protection works before, by filtering the air.
	{ type = "damage-type", name = C.DAMAGE_TYPE },
})
