-- HeroTurretRedux runtime (Paranoidal fork). The generic event dispatcher of 1.0.38 registered
-- on_tick, three on_nth_tick, chunk, AI, trigger, train, GUI and selection events for empty
-- handler lists and called every handler on every death and build. Only the needed events are
-- registered now, each with native filters: see prototypes/scripts/turrets.lua.
heroturrets = heroturrets or {}
require("prototypes.scripts.util")
heroturrets.util = get_utils()
require("prototypes.scripts.defines")

local turrets = require("prototypes.scripts.turrets")
turrets.register()

remote.add_interface("HeroTurretRedux", {
	-- zzzparanoidal "hero_downgrade" tool: ranked turret -> base turret, kills reset.
	demote = turrets.demote,
	-- Base turret name of a ranked turret, nil for others.
	base_of = function(name)
		local info = turrets.ranked[name]
		return info and info.base
	end,
})
