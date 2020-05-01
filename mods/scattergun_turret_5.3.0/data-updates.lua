if settings.startup["enable-radars"].value == true then
	require("prototypes.entities.w93-radar-turret")
	require("prototypes.items.items-radar")
	require("prototypes.recipes.recipes-radar")
	require("prototypes.technology.technology-radar")
end

if settings.startup["enable-hardened-inserter"].value == true then
	require("prototypes.entities.w93-hardened-inserter")
	require("prototypes.items.items-inserter")
	require("prototypes.recipes.recipes-inserter")
	table.insert(data.raw["technology"]["w93-modular-turrets"].effects, {type = "unlock-recipe", recipe = "w93-hardened-inserter" })
end

if settings.startup["enable-extra-ammo"].value == true then
	require("prototypes.projectiles.projectiles-ammo")
	require("prototypes.items.items-ammo")
	require("prototypes.recipes.recipes-ammo")
	table.insert(data.raw["technology"]["w93-modular-turrets-gatling"].effects, {type = "unlock-recipe", recipe = "w93-slowdown-magazine" })
	table.insert(data.raw["technology"]["w93-modular-turrets-rocket"].effects, {type = "unlock-recipe", recipe = "w93-turret-rocket" })
	table.insert(data.raw["technology"]["w93-modular-turrets-rocket"].effects, {type = "unlock-recipe", recipe = "w93-turret-explosive-rocket" })
	table.insert(data.raw["technology"]["w93-modular-turrets-rocket"].effects, {type = "unlock-recipe", recipe = "w93-turret-slowdown-rocket" })
	table.insert(data.raw["technology"]["w93-modular-turrets-dcannon"].effects, {type = "unlock-recipe", recipe = "w93-turret-slowdown-shells" })
	table.insert(data.raw["technology"]["w93-modular-turrets-hcannon"].effects, {type = "unlock-recipe", recipe = "w93-turret-cannon-shells" })

	if data.raw["technology"]["uranium-ammo" ] then
		table.insert(data.raw["technology"]["uranium-ammo" ].effects, {type = "unlock-recipe", recipe = "w93-uranium-shotgun-shell"})
		table.insert(data.raw["technology"]["uranium-ammo" ].effects, {type = "unlock-recipe", recipe = "w93-turret-light-uranium-cannon-shells"})
		table.insert(data.raw["technology"]["uranium-ammo" ].effects, {type = "unlock-recipe", recipe = "w93-turret-uranium-cannon-shells"})
	end

	if data.raw["ammo"]["w93-turret-light-cannon-shells"] then
		data.raw["ammo"]["w93-turret-light-cannon-shells"].subgroup = "modular-turrets3-combat"
		data.raw["ammo"]["w93-turret-light-cannon-shells"].order = "l[modular-turrets3-combat]-b[w93-turret-light-cannon-shells]"
	end
end

if settings.startup["cannon-ammo-range-disable"].value == true then
	if data.raw["ammo"]["cannon-shell"] then
		data.raw["ammo"]["cannon-shell"].ammo_type.target_type = "position"
		data.raw["ammo"]["cannon-shell"].ammo_type.action.action_delivery.max_range = 80
	end
	if data.raw["ammo"]["explosive-cannon-shell"] then
		data.raw["ammo"]["explosive-cannon-shell"].ammo_type.target_type = "position"
		data.raw["ammo"]["explosive-cannon-shell"].ammo_type.action.action_delivery.max_range = 80
	end
	if data.raw["ammo"]["uranium-cannon-shell"] then
		data.raw["ammo"]["uranium-cannon-shell"].ammo_type.target_type = "position"
		data.raw["ammo"]["uranium-cannon-shell"].ammo_type.action.action_delivery.max_range = 80
	end
	if data.raw["ammo"]["explosive-uranium-cannon-shell"] then
		data.raw["ammo"]["explosive-uranium-cannon-shell"].ammo_type.target_type = "position"
		data.raw["ammo"]["explosive-uranium-cannon-shell"].ammo_type.action.action_delivery.max_range = 80
	end
end