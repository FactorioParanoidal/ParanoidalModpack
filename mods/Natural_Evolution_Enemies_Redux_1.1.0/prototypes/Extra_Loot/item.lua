local NEEnemies = require('common')('Natural_Evolution_Enemies_Redux')
local ICONPATH = NEEnemies.modRoot .. "/graphics/icons/"

if settings.startup["NE_Alien_Artifacts"].value == true then

	data:extend({
	  {
		type = "item",
		name = "small-alien-artifact",
		icon = ICONPATH .. "small-alien-artifact.png",
		icon_size = 64,
		icons = {
		  {
			icon = ICONPATH .. "small-alien-artifact.png",
			icon_size = 64,
		  }
		},
		subgroup = "raw-material",
		order = "g[alien-artifact]-a[pink]-a[small]",
		stack_size = 500,
		default_request_amount = 200
	  },

	})

end