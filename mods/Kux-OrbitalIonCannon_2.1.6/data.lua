modFolder="__Kux-OrbitalIonCannon__" -- Orbital Ion Cannon
LoadState="data"
require("prototypes.items")
require("prototypes.entities")
require("prototypes.recipes")
require("prototypes.technologies").init()
require("prototypes.announcers")
require("prototypes.styles")
require("prototypes.shortcuts")
data:extend({
	{
		type = "custom-input",
		name = "ion-cannon-hotkey",
		key_sequence = "I",
		consuming = "none"
	}
})

