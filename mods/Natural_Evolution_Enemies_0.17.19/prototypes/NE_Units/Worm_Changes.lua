-- Worm Adjustments
if NE_Enemies.Settings.NE_Adjust_Vanilla_Worms then

	----- Small Worms	
	data.raw["turret"]["small-worm-turret"].max_health = 200 + 100 * NE_Enemies.Settings.NE_Difficulty
	data.raw["turret"]["small-worm-turret"].attack_parameters.range = 24 + NE_Enemies.Settings.NE_Difficulty
	data.raw["turret"]["small-worm-turret"].resistances = Resistances.Small_Worm

	----- Medium Worms
	data.raw["turret"]["medium-worm-turret"].attack_parameters = Worm_Attack_Stream(
						{
							range = 29 + NE_Enemies.Settings.NE_Difficulty,
							cooldown = 8 - NE_Enemies.Settings.NE_Difficulty,
							damage_modifier = 4,
						})
	data.raw["turret"]["medium-worm-turret"].max_health = 200 + 200 * NE_Enemies.Settings.NE_Difficulty
	data.raw["turret"]["medium-worm-turret"].resistances = Resistances.Medium_Worm
	data.raw["turret"]["medium-worm-turret"].call_for_help_radius = 100 + (NE_Enemies.Settings.NE_Difficulty * 2)

	----- Big Worms	
	data.raw["turret"]["big-worm-turret"].attack_parameters = Worm_Attack_Projectile_NH(
						{
							range = 35 + NE_Enemies.Settings.NE_Difficulty,
							cooldown = 46 - NE_Enemies.Settings.NE_Difficulty,
							damage_modifier = 5,
							projectile="Worm-Unit-Projectile"
						})
	data.raw["turret"]["big-worm-turret"].max_health = 500 + 200 * NE_Enemies.Settings.NE_Difficulty
	data.raw["turret"]["big-worm-turret"].resistances = Resistances.Big_Worm
	data.raw["turret"]["big-worm-turret"].call_for_help_radius = 150 + (NE_Enemies.Settings.NE_Difficulty * 2)


	----- Behemoth Worms	
	data.raw["turret"]["behemoth-worm-turret"].attack_parameters.range = 47 + NE_Enemies.Settings.NE_Difficulty
	data.raw["turret"]["behemoth-worm-turret"].attack_parameters.cooldown = 10 - NE_Enemies.Settings.NE_Difficulty
	data.raw["turret"]["behemoth-worm-turret"].max_health = 700 + 200 * NE_Enemies.Settings.NE_Difficulty
	data.raw["turret"]["behemoth-worm-turret"].resistances = Resistances.Behemoth_Worm
	data.raw["turret"]["behemoth-worm-turret"].call_for_help_radius = 180 + (NE_Enemies.Settings.NE_Difficulty * 2)	

	--[[
	if data.raw["turret"]["medium-worm-turret-player"] then
	data.raw["turret"]["medium-worm-turret-player"].attack_parameters = Worm_Attack_Stream(
						{
							range = 29 + NE_Enemies.Settings.NE_Difficulty,
							cooldown = 8 - NE_Enemies.Settings.NE_Difficulty,
							damage_modifier = 4,
						})
	end

	if data.raw["turret"]["behemoth-worm-turret-player"] then
	data.raw["turret"]["behemoth-worm-turret-player"].attack_parameters = Worm_Attack_Projectile_NH(
						{
							range = 40 + NE_Enemies.Settings.NE_Difficulty,
							cooldown = 46 - NE_Enemies.Settings.NE_Difficulty,
							damage_modifier = 5,
							projectile="Worm-Unit-Projectile"
						})
	end
	]]
end
