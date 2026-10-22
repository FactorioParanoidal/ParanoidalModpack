-- Paranoidal fork: a ranked ammo turret gets the same research damage bonus as its base turret
-- (Beta 8). 1.0.38 added +25% per rank; forces keep that from researches finished before this
-- update, so the bonus is set to the base turret's value once. Other modifiers are not touched.
for name in pairs(prototypes.get_entity_filtered({{filter = "type", type = "ammo-turret"}})) do
	local base = string.match(name, "^hero%-turret%-%d+%-for%-(.+)$")
	if base and prototypes.entity[base] then
		for _, force in pairs(game.forces) do
			force.set_turret_attack_modifier(name, force.get_turret_attack_modifier(base))
		end
	end
end
