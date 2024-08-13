--red_light = {
--    type = "lamp",
--    name = "rr-red-light",
--	order = "z",
--	alert_icon_scale =0,
--    icon = "__UnrealisticReactors__/graphics/lamps/red.png",
--    icon_size = 32,
--	collision_mask={"layer-13"},
--    flags = {"placeable-neutral", "player-creation", "placeable-off-grid","not-deconstructable"},
--    max_health = 100,
--    corpse = "small-remnants",
--    --collision_box = {{-1.4, -1.9}, {1.4, 1.4}}, +0,62 -0,6
--    collision_box = {{-0.78, -2.1}, {2.02, 0.8}},
--    --selection_box = {{-0.78, -2.1}, {2.02, 0.8}},
--    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
--    energy_source ={
--      type = "electric",
--      usage_priority = "lamp",
--	  render_no_power_icon =  false ,
--      render_no_network_icon = false,},
--    energy_usage_per_tick = "5KW",
--    darkness_for_all_lamps_on = 0.00001,
--    darkness_for_all_lamps_off = 0,
--    light = {intensity = 0.6, size = 3, color = {r=1.0, g=0.0, b=0.0}},
--    light_when_colored = {intensity = 1, size = 6, color = {r=1.0, g=1.0, b=1.0}},
--    glow_size = 2,
--    glow_color_intensity = 0.135,
--    picture_off =
--    {
--      layers =
--      {
--        {
--          filename = "__UnrealisticReactors__/graphics/transparent32.png",
--          priority = "high",
--          width = 32,
--          height = 32,
--          frame_count = 1,
--          axially_symmetrical = false,
--          direction_count = 1,
--		  --shift = {-0.62, 0.6}
--        },
--      }
--    },
--    picture_on =
--    {
--      filename = "__UnrealisticReactors__/graphics/transparent32.png",
--      priority = "high",
--      width = 32,
--      height = 32,
--      frame_count = 1,
--      axially_symmetrical = false,
--      direction_count = 1,
--    },
--  }-----------------------------------------------------------------------------------------------------------------------------------------------
local function setfilename(picture, filename)
	if picture.filename then
		picture.filename = filename
	end
	for _,layer in pairs(picture.layers or {}) do
		setfilename(layer, filename)
	end
end


local orange_light = {
	type = "explosion",
	name = "rr-red-light",
	flags = {"not-on-map", "placeable-off-grid"},
	animations =
	{
		{
			filename = "__UnrealisticReactors__/graphics/transparent32.png",
			priority = "high",
			width = 1,
			height = 1,
			frame_count = 255,
			line_length = 32,
			shift = {-0.56, -0.96},
			animation_speed = 0.0000001
		}
	},
	light = {intensity = 0.6, size = 1, color = {r=1.0, g=0.7, b=0.0}},
}
local orange_lamp = {
	type = "simple-entity-with-force",
	name = "rr-red-lamp",
	flags = {"placeable-neutral", "player-creation", "placeable-off-grid","not-deconstructable"},
	render_layer = "object",
	collision_mask={"layer-13"},
	icon = "__base__/graphics/icons/steel-chest.png",
	icon_size = 32,
	order = "s-e-w-f",
	max_health = 100,
	corpse = "small-remnants",
	picture = {layers={
		{
			filename = "__UnrealisticReactors__/graphics/lamps/red.png",
			priority = "extra-high",
			width = 32,
			height = 32,
			scale = 0.41, --0.3542
			--shift = {-0.5, -0.5}
		},
		{
			filename = "__UnrealisticReactors__/graphics/lamps/red.png",
			priority = "extra-high",
			width = 32,
			height = 32,
			scale = 0.41, --0.3542
			--shift = {-0.5, -0.5}
			draw_as_light = true,
		},
	}}
}


yellow_light = table.deepcopy(orange_light)
yellow_light.name="rr-yellow-light"
yellow_light.light = {intensity = 0.6, size = 1, color = {r=1.0, g=1.0, b=0.0}}
--yellow_light.icon = "__UnrealisticReactors__/graphics/lamps/yellow.png"

yellow_lamp = table.deepcopy(orange_lamp)
yellow_lamp.name="rr-yellow-lamp"
setfilename(yellow_lamp.picture, "__UnrealisticReactors__/graphics/lamps/yellow.png")



green_light = table.deepcopy(orange_light)
green_light.name="rr-green-light"
green_light.light = {intensity = 0.6, size = 1, color = {r=0.0, g=1.0, b=0.0}}
--green_light.icon = "__UnrealisticReactors__/graphics/lamps/green.png"

green_lamp = table.deepcopy(orange_lamp)
green_lamp.name="rr-green-lamp"
setfilename(green_lamp.picture, "__UnrealisticReactors__/graphics/lamps/green.png")



red_light = table.deepcopy(orange_light)
red_light.name="rr-black-light"
red_light.light = {intensity = 0.6, size = 1, color = {r=1, g=0, b=0}}
--orange_light.icon = "__UnrealisticReactors__/graphics/lamps/black.png"

red_lamp = table.deepcopy(orange_lamp)
red_lamp.name="rr-black-lamp"
setfilename(red_lamp.picture, "__UnrealisticReactors__/graphics/lamps/black.png")

ruin_glow = table.deepcopy(orange_light)
ruin_glow.name = "rr-ruin-glow"
ruin_glow.light = {intensity = 0.22, size = 6.5, shift = {0.0, 0.0}, color = {r = 0.35, g = 0.8, b = 1.0}}


ruin_glow.animations = {
	{
		filename = "__UnrealisticReactors__/graphics/transparent32.png",
		priority = "high",
		width = 1,
		height = 1,
		frame_count = 255,
		line_length = 32,
		--shift = {-0.56, -0.96},
		animation_speed = 0.0000001,
	},
}


data:extend{
red_light,
red_lamp,
yellow_light,
yellow_lamp,
green_light,
green_lamp,
orange_light,
orange_lamp,
ruin_glow,
}
