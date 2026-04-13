require("mod")

require "prototypes/ion-cannon-targeter"
require "prototypes/orbital-ion-cannon"

require("prototypes/items")
require("prototypes/entities")
require("prototypes/recipes")
require("prototypes/technologies")
require("prototypes/announcers")
require("prototypes/styles")
require("prototypes/shortcuts")

data:extend({
	{
		type = "custom-input",
		name = "ion-cannon-hotkey",
		key_sequence = "I",
		consuming = "none"
	}
})
