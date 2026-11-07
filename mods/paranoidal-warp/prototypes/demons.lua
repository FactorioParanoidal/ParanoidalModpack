-- Demons of the four sins of consumption (stage 3, user 2026-11-07): vanilla biters and spitters recoloured, three
-- sizes each, no loot. They appear only on warp ships whose comfort field is weak (control.lua).
local shared = require("shared")
local warp_util = require("prototypes.util")

local demons = {}
for _, sin in ipairs(shared.sins) do
	for size, spec in ipairs(shared.demon_sizes) do
		local source = data.raw.unit[spec.source .. "-" .. sin.base]
		if source then
			local demon = table.deepcopy(source)
			demon.name = shared.demon(sin, size)
			demon.localised_name = {"paranoidal-warp.demon-size-" .. size, {"paranoidal-warp.sin-" .. sin.id}}
			demon.localised_description = {"paranoidal-warp.demon-description-" .. sin.id}
			demon.order = "z[paranoidal-warp]-" .. sin.id .. "-" .. size
			demon.icon = nil
			demon.icons = warp_util.icons(source, sin.tint1)
			demon.max_health = spec.health * sin.health
			demon.movement_speed = spec.speed * sin.speed
			demon.loot = nil
			warp_util.tint_masks(demon.run_animation, sin.tint1, sin.tint2)
			warp_util.tint_masks(demon.attack_parameters and demon.attack_parameters.animation, sin.tint1, sin.tint2)
			demons[#demons + 1] = demon
		end
	end
end
data:extend(demons)
