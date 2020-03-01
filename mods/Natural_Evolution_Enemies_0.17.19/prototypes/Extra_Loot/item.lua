if settings.startup["NE_Alien_Artifacts"].value == true then

	data:extend({
	  {
		type = "item",
		name = "small-alien-artifact",
		icon = "__Natural_Evolution_Enemies__/graphics/icons/small-alien-artifact.png",
		icon_size = 32,
		subgroup = "raw-material",
		order = "g[alien-artifact]-a[pink]-a[small]",
		stack_size = 500,
		default_request_amount = 200
	  },

	})

end