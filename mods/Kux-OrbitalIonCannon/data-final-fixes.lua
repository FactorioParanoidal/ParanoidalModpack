require("mod")

--revert changes made by other mods. only a workoround not a solution!
if mods["5dim_core"] then
	data.raw["ammo-turret"]["ion-cannon-targeter"].next_upgrade = nil
	data.raw["ammo-turret"]["ion-cannon-targeter"].fast_replaceable_group = nil
	data.raw["ammo-turret"]["ion-cannon-targeter"].collision_mask = {layers={}}
	data.raw["ammo-turret"]["ion-cannon-targeter"].next_upgrade = nil
	data.raw["ammo-turret"]["ion-cannon-targeter-mk2"].next_upgrade = nil
	data.raw["ammo-turret"]["ion-cannon-targeter-mk2"].fast_replaceable_group = nil
	data.raw["ammo-turret"]["ion-cannon-targeter-mk2"].collision_mask = {layers={}}
	data.raw["ammo-turret"]["ion-cannon-targeter-mk2"].next_upgrade = nil
	data.raw["radar"]["orbital-ion-cannon"].next_upgrade = nil
	data.raw["radar"]["orbital-ion-cannon"].fast_replaceable_group = nil
	data.raw["radar"]["orbital-ion-cannon-mk2"].next_upgrade = nil
	data.raw["radar"]["orbital-ion-cannon-mk2"].fast_replaceable_group = nil
end
