LoadState="data-final-fixes"
require("prototypes.technologies").finalFixes()

if mods["5dim_compatibility"] then
	data.raw["ammo-turret"]["ion-cannon-targeter"].next_upgrade = nil
	data.raw["ammo-turret"]["ion-cannon-targeter"].fast_replaceable_group = nil
end

--Remove any collision masks mistakenly added by other mods
data.raw["ammo-turret"]["ion-cannon-targeter"].collision_mask = {}
