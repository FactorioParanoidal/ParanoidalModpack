if not mods["Natural_Evolution_Buildings"] and BI.Settings.Bio_Cannon then
	-- Don't duplicate what NE does
	if not mods["Natural_Evolution_Buildings"] then

		table.insert(data.raw.technology["physical-projectile-damage-1"].effects,{type = "ammo-damage", ammo_category = "Bio_Cannon_Ammo", modifier = 0.1})
		table.insert(data.raw.technology["physical-projectile-damage-2"].effects,{type = "ammo-damage", ammo_category = "Bio_Cannon_Ammo", modifier = 0.2})
		table.insert(data.raw.technology["physical-projectile-damage-3"].effects,{type = "ammo-damage", ammo_category = "Bio_Cannon_Ammo", modifier = 0.2})
		table.insert(data.raw.technology["physical-projectile-damage-4"].effects,{type = "ammo-damage", ammo_category = "Bio_Cannon_Ammo", modifier = 0.3})
		table.insert(data.raw.technology["physical-projectile-damage-5"].effects,{type = "ammo-damage", ammo_category = "Bio_Cannon_Ammo", modifier = 0.3})
		table.insert(data.raw.technology["physical-projectile-damage-6"].effects,{type = "ammo-damage", ammo_category = "Bio_Cannon_Ammo", modifier = 0.4})
		table.insert(data.raw.technology["physical-projectile-damage-7"].effects,{type = "ammo-damage", ammo_category = "Bio_Cannon_Ammo", modifier = 0.4})

	end

end

