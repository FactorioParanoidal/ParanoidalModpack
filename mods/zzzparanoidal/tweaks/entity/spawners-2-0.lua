-- Factorio 2.1 (user decision G2 "A", 2026-11-03): spawners work as in 2.0.
-- 2.1.7 changed the vanilla biter and spitter spawners: spawning_radius 10 -> 2 and spawning_spacing 3 -> 1 ("spawning
-- range reduced, precision increased") and the new spawn_blocked_trigger, an acid cloud when no spawn position is free.
-- The copies of the vanilla spawner in the build (bobenemies tier 0, Big-Monsters, mferrari_lib bosses) inherited it; the
-- other spawner families (RampantFixed, Bob, mferrari_lib) set their own radius and spacing, and no spawner of the 2.0
-- build had a spawn_blocked_trigger. Keep 2.0 for all: no spawner gets the acid cloud, and a spawner left with the 2.1
-- vanilla radius and spacing (2 and 1, never used in the 2.0 build) gets the 2.0 vanilla values (10 and 3).
local restored, untriggered = {}, {}
for name, spawner in pairs(data.raw["unit-spawner"] or {}) do
	if spawner.spawn_blocked_trigger ~= nil then
		spawner.spawn_blocked_trigger = nil
		untriggered[#untriggered + 1] = name
	end
	if spawner.spawning_radius == 2 and spawner.spawning_spacing == 1 then
		spawner.spawning_radius = 10
		spawner.spawning_spacing = 3
		restored[#restored + 1] = name
	end
end
table.sort(restored)
table.sort(untriggered)
log("zzzparanoidal: spawners as in 2.0: spawning radius/spacing 10/3 on " .. #restored .. " (" .. table.concat(restored, ", ")
	.. "), no spawn_blocked_trigger on " .. #untriggered .. " (" .. table.concat(untriggered, ", ") .. ")")
