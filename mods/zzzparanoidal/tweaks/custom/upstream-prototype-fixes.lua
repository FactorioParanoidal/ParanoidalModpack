-- Pack compatibility belongs here; upstream mod files retain their original definitions.

local pipes = data.raw["heat-pipe"]
if pipes["bob-heat-pipe-4"] then
	pipes["bob-heat-pipe-4"].next_upgrade = nil
end

local projectile = data.raw["artillery-projectile"]["bob-atomic-artillery-projectile"]
if projectile then
	projectile.picture.width = 20
	projectile.picture.height = 60
	projectile.picture.scale = 0.5
end

-- Preserve the existing translated corpse labels without modifying locale files.
if mods["mferrari_lib"] then
	for _, unit in pairs(data.raw.unit) do
		local corpse = type(unit.corpse) == "string" and data.raw["character-corpse"][unit.corpse]
		if corpse and unit.corpse == unit.name .. "-corpse" and unit.icon == "__mferrari_lib__/graphics/icon/fake_human.png" then
			corpse.localised_name = {"entity-name.mf-fake-human-corpse", unit.localised_name or {"entity-name." .. unit.name}}
		end
	end
end
