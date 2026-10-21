folderName = "__EpicWeaponSounds__/sounds/"
fileType = ".ogg"
masterVolume = 0.6

lightGunshot = "light-gunshot-"
submachineGunshot = "submachine-gunshot-"
shotGunshot = "pump-shotgun-"
turretGunshot = "gun-turret-gunshot-"
laserGunshot = "laser-"
explosion = "medium-explosion-"

-- Sadly the game only allows 3 different versions of gun sounds playing in round-robin mode.

-- Player
data.raw["gun"]["pistol"].attack_parameters.sound = {
	{
		filename = folderName .. lightGunshot .. "1" .. fileType,
		volume = masterVolume
	},
	{
		filename = folderName .. lightGunshot .. "2" .. fileType,
		volume = masterVolume
	},
	{
		filename = folderName .. lightGunshot .. "3" .. fileType,
		volume = masterVolume
	}
}

data.raw["gun"]["submachine-gun"].attack_parameters.sound = {
	{
		filename = folderName .. submachineGunshot .. "1" .. fileType,
		volume = masterVolume 
	},
	{
		filename = folderName .. submachineGunshot .. "2" .. fileType,
		volume = masterVolume
	},
	{
		filename = folderName .. submachineGunshot .. "3" .. fileType,
		volume = masterVolume
	}
}

data.raw["gun"]["shotgun"].attack_parameters.sound = {
	{
		filename = folderName .. shotGunshot .. "1" .. fileType,
		volume = masterVolume
	},
	{
		filename = folderName .. shotGunshot .. "2" .. fileType,
		volume = masterVolume
	},
	{
		filename = folderName .. shotGunshot .. "3" .. fileType,
		volume = masterVolume
	}
}


-- Turrets
data.raw["ammo-turret"]["gun-turret"].attack_parameters.sound = {
	{
		filename = folderName .. turretGunshot .. "1" .. fileType,
		volume = masterVolume
	},
	{
		filename = folderName .. turretGunshot .. "2" .. fileType,
		volume = masterVolume
	},
	{
		filename = folderName .. turretGunshot .. "3" .. fileType,
		volume = masterVolume
	}
}

data.raw["electric-turret"]["laser-turret"].attack_parameters.sound = {
	{
		filename = folderName .. laserGunshot .. "1" .. fileType,
		volume = masterVolume
	},
	{
		filename = folderName .. laserGunshot .. "2" .. fileType,
		volume = masterVolume
	},
	{
		filename = folderName .. laserGunshot .. "3" .. fileType,
		volume = masterVolume
	}
}

-- Vehicle
data.raw["gun"]["vehicle-machine-gun"].attack_parameters.sound = {
	{
		filename = folderName .. turretGunshot .. "1" .. fileType,
		volume = masterVolume
	},
	{
		filename = folderName .. turretGunshot .. "2" .. fileType,
		volume = masterVolume
	},
	{
		filename = folderName .. turretGunshot .. "3" .. fileType,
		volume = masterVolume
	}
}
-- Originally 5 different sounds, volume 0.4
data.raw["explosion"]["grenade-explosion"].sound.variations = {
	{
		filename = folderName .. explosion .. "1" .. fileType,
		volume = masterVolume
	},
	{
		filename = folderName .. explosion .. "2" .. fileType,
		volume = masterVolume
	},
	{
		filename = folderName .. explosion .. "3" .. fileType,
		volume = masterVolume
	}
}

--[[ 
data.raw["gun"]["tank-cannon"].attack_parameters.sound = {
	{
		filename = folderName .. "Tank_Turret1.ogg",
		volume = masterVolume
	},
	{
		filename = folderName .. "Tank_Turret2.ogg",
		volume = masterVolume
	},
	{
		filename = folderName .. "Tank_Turret3.ogg",
		volume = masterVolume
	}
}

data.raw["gun"]["tank-machine-gun"].attack_parameters.sound = {
	{
		filename = folderName .. "Gun_Turret1.ogg",
		volume = masterVolume
	},
	{
		filename = folderName .. "Gun_Turret2.ogg",
		volume = masterVolume
	},
	{
		filename = folderName .. "Gun_Turret2.ogg",
		volume = masterVolume
	}
}

]]