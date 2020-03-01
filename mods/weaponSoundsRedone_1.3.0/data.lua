if settings.startup["wsr-replace-submg-sound"].value then
	data.raw.gun["submachine-gun"].attack_parameters.sound = 
	{
		filename = "__weaponSoundsRedone__/sounds/submachine_fire.ogg",
		volume = 0.8
	}
else
	data.raw.gun["submachine-gun"].attack_parameters.sound = 
	{
        {
			filename = "__base__/sound/fight/light-gunshot-1.ogg",
			volume = 0.3
        },
        {
            filename = "__base__/sound/fight/light-gunshot-2.ogg",
            volume = 0.3
        },
        {
            filename = "__base__/sound/fight/light-gunshot-3.ogg",
            volume = 0.3
        }
	}
end

if settings.startup["wsr-replace-pistol-sound"].value then
	data.raw.gun.pistol.attack_parameters.sound =
	{
		filename = "__weaponSoundsRedone__/sounds/pistol_fire.ogg",
		volume = 0.5
	}
else
	data.raw.gun.pistol.attack_parameters.sound = 
	{
        {
            filename = "__base__/sound/fight/light-gunshot-1.ogg",
            volume = 0.3
        },
        {
            filename = "__base__/sound/fight/light-gunshot-2.ogg",
            volume = 0.3
        },
        {
            filename = "__base__/sound/fight/light-gunshot-3.ogg",
            volume = 0.3
        }
    }
end

if settings.startup["wsr-replace-shotg-sound"].value then
	data.raw.gun.shotgun.attack_parameters.sound = 
	{	
		filename = "__weaponSoundsRedone__/sounds/shotgun_fire.ogg",
		volume = 0.6
	}
else
	data.raw.gun.shotgun.attack_parameters.sound = 
	{
        filename = "__base__/sound/pump-shotgun.ogg",
        volume = 0.5
    }
end

if settings.startup["wsr-replace-cshotg-sound"].value then
	data.raw.gun["combat-shotgun"].attack_parameters.sound = 
	{
		filename = "__weaponSoundsRedone__/sounds/autoshotgun_fire.ogg",
		volume = 0.8
	}	
else
	data.raw.gun["combat-shotgun"].attack_parameters.sound =
	{
        filename = "__base__/sound/pump-shotgun.ogg",
        volume = 0.5
    }
end

if settings.startup["wsr-replace-turret-sound"].value then
	data.raw["ammo-turret"]["gun-turret"].attack_parameters.sound =
	{
		filename = "__weaponSoundsRedone__/sounds/turret_fire.ogg",
		volume = 0.5
	}
else
	data.raw["ammo-turret"]["gun-turret"].attack_parameters.sound =
	{
        {
            filename = "__base__/sound/fight/heavy-gunshot-1.ogg",
            volume = 0.45
        },
        {
			filename = "__base__/sound/fight/heavy-gunshot-2.ogg",
            volume = 0.45
        },
        {
            filename = "__base__/sound/fight/heavy-gunshot-3.ogg",
            volume = 0.45
        },
        {
            filename = "__base__/sound/fight/heavy-gunshot-4.ogg",
            volume = 0.45
        }
    }
end