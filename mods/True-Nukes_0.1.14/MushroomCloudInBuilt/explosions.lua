data:extend({
    	{
		type = "sound",
		name = "nuclear-detonation-close-proximity",
		filename = "__True-Nukes__/MushroomCloudInBuilt/sound/nuclear_detonation_close_proximity.ogg",
		volume = 2.0
	},
    	{
		type = "sound",
		name = "nuclear-detonation-in-vincinity",
		variations = {
			{
				filename = "__True-Nukes__/MushroomCloudInBuilt/sound/nuclear_detonation_in_vincinity_1.ogg",
				volume = 1.50
			},
			{
                		filename = "__True-Nukes__/MushroomCloudInBuilt/sound/nuclear_detonation_in_vincinity_2.ogg",
                		volume = 1.75
            		}
		}
	},
	{
		type = "sound",
		name = "nuclear-detonation-distant-boom",
		variations = {
            		{
				filename = "__True-Nukes__/MushroomCloudInBuilt/sound/nuclear_explosion_distant_boom_1.ogg",
				volume = 1.75
    			},
		    	{
				filename = "__True-Nukes__/MushroomCloudInBuilt/sound/nuclear_explosion_distant_boom_2.ogg",
				volume = 1.6
		    	},
		    	{
				filename = "__True-Nukes__/MushroomCloudInBuilt/sound/nuclear_explosion_distant_boom_3.ogg",
				volume = 1.75
		    	}   
		}
	},
    	{
		type = "sound",
		name = "nuclear-detonation-far-away",
		filename = "__True-Nukes__/MushroomCloudInBuilt/sound/nuclear_detonation_far_away.ogg",
		volume = 2.0
	}
})

local nuclear_crater = util.table.deepcopy(data.raw["corpse"]["big-scorchmark"])
nuclear_crater.name = "nuclear-scorchmark"
nuclear_crater.order = "d[remnants]-b[scorchmark]-b[nuclear]"
--nuclear_crater.animation.scale = 8
nuclear_crater.ground_patch.sheet.scale = 4
nuclear_crater.ground_patch.sheet.hr_version.scale = 4
nuclear_crater.ground_patch_higher.sheet.scale = 4
nuclear_crater.ground_patch_higher.sheet.hr_version.scale = 4

data:extend({nuclear_crater})
