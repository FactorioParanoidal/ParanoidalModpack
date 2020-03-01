-- declare trigger entities and sound at distance entities to be spawned
-- 
data:extend({
  {
    type = "explosion",
    name = "vtk-artillery-at-distance-sound-trigger-shooting",
    flags = {"not-on-map"},
    animations = {
      {
        filename = "__vtk-ta-big-bertha-artillery-sounds__/graphics/dummy.png",
        priority = "low",
        width = 32,
        height = 32,
        frame_count = 1,
        line_length = 1,
        animation_speed = 1
      },
    },
    light = {intensity = 0, size = 0},
  }, 
  {
    type = "explosion",
    name = "vtk-artillery-at-distance-sound-trigger-explosion",
    flags = {"not-on-map"},
    animations = {
      {
        filename = "__vtk-ta-big-bertha-artillery-sounds__/graphics/dummy.png",
        priority = "low",
        width = 32,
        height = 32,
        frame_count = 1,
        line_length = 1,
        animation_speed = 1
      },
    },
    light = {intensity = 0, size = 0},
  }, 
  {
    type = "sound",
    name = "vtk-artillery-at-distance-sound-shooting-close",
    filename = "__vtk-ta-big-bertha-artillery-sounds__/sounds/XPLONUK4.ogg",
    volume = 0.5,
	}, 
	{
		type = "sound",
		name = "vtk-artillery-at-distance-sound-explosion-close",
    filename = "__vtk-ta-big-bertha-artillery-sounds__/sounds/XPLONUK1.ogg",
    volume = 0.5,
	},
	{
		type = "sound",
		name = "vtk-artillery-at-distance-sound-shooting-far",
    filename = "__vtk-ta-big-bertha-artillery-sounds__/sounds/XPLONUK4.ogg",
    volume = 0.35,
	}, 
	{
		type = "sound",
		name = "vtk-artillery-at-distance-sound-explosion-far",
    filename = "__vtk-ta-big-bertha-artillery-sounds__/sounds/XPLONUK1.ogg",
    volume = 0.35,
	},
	{
		type = "sound",
		name = "vtk-artillery-at-distance-sound-shooting-horizon",
    filename = "__vtk-ta-big-bertha-artillery-sounds__/sounds/XPLONUK4.ogg",
    volume = 0.20,
	}, 
	{
		type = "sound",
		name = "vtk-artillery-at-distance-sound-explosion-horizon",
    filename = "__vtk-ta-big-bertha-artillery-sounds__/sounds/XPLONUK1.ogg",
    volume = 0.20,
	},
	{
		type = "sound",
		name = "vtk-artillery-at-distance-sound-shooting-horizon++",
    filename = "__vtk-ta-big-bertha-artillery-sounds__/sounds/XPLONUK4.ogg",
    volume = 0.10,
	}, 
	{
		type = "sound",
		name = "vtk-artillery-at-distance-sound-explosion-horizon++",
    filename = "__vtk-ta-big-bertha-artillery-sounds__/sounds/XPLONUK1.ogg",
    volume = 0.10,
	},
})
