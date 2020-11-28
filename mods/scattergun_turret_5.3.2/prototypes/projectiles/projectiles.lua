data:extend(
{

{
	type = "explosion",
	name = "w93-tlaser",
	flags = {"not-on-map"},
	animation_speed = 3,
	rotate = true,
	beam = true,
	animations =
	{
		{
			filename = "__scattergun_turret__/graphics/entity/projectiles/w93-tlaser.png",
			priority = "extra-high",
			width = 10,
			height = 1,
			frame_count = 6,
		}
	},
	light = {intensity = 1, size = 10},
	smoke = "smoke-fast",
	smoke_count = 2,
	smoke_slow_down_factor = 1
},
{
	type = "explosion",
	name = "w93-beam",
	flags = {"not-on-map"},
	animation_speed = 3,
	rotate = true,
	beam = true,
	animations =
	{
		{
			filename = "__scattergun_turret__/graphics/entity/projectiles/w93-beam.png",
			priority = "extra-high",
			width = 187,
			height = 1,
			frame_count = 6,
		}
	},
	light = {intensity = 1, size = 10},
	smoke = "smoke-fast",
	smoke_count = 2,
	smoke_slow_down_factor = 1
}
})