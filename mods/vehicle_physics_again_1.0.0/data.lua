local hover_smoke = table.deepcopy(data.raw["trivial-smoke"]["turbine-smoke"])
hover_smoke.name = "hover-smoke"
hover_smoke.render_layer = "building-smoke"
hover_smoke.affected_by_wind = false
hover_smoke.duration = 35
hover_smoke.start_scale = 1
hover_smoke.end_scale = 1.4
hover_smoke.fade_away_duration = 30
hover_smoke.fade_in_duration = 5
hover_smoke.spread_duration = 30
hover_smoke.animation.shift = {0,0}
data:extend({hover_smoke})

--local collision = table.deepcopy(data.raw.car.car)
--    collision.collision_box[1][1]=collision.collision_box[1][1]*1.9
--    collision.collision_box[1][2]=collision.collision_box[1][2]*1.9
--    collision.collision_box[2][1]=collision.collision_box[2][1]*1.9
--    collision.collision_box[2][2]=collision.collision_box[2][2]*1.9
--    collision.name="hovercraft-collision"
--    collision.order="hovercraft-collision"
--data:extend({collision})

local marks = table.deepcopy(data.raw.corpse["small-scorchmark"])
marks.name = "drifting-tire-marks"
marks.ground_patch = nil
marks.ground_patch_higher = nil
marks.time_before_removed = math.ceil(60 * settings.startup["vehphy-tiremarks-duration"].value)
marks.animation =
	{
		width = 41,
		height = 41,
		frame_count = 1,
		direction_count = 1,
		scale = 0.5,
		filename = "__vehicle_physics_again__/tire_marks.png"
	}
data:extend({marks})

marks = table.deepcopy(marks)
marks.name = "drifting-tire-marks-faded"
marks.animation.filename = "__vehicle_physics_again__/tire_marks_faded.png"
data:extend({marks})

data:extend({
	{
		type = "sound",
		name = "vehphy-squeel-1",
		filename = "__vehicle_physics_again__/squeel1.ogg",
	},
	{
		type = "sound",
		name = "vehphy-squeel-2",
		filename = "__vehicle_physics_again__/squeel2.ogg",
	},
	{
		type = "sound",
		name = "vehphy-squeel-3",
		filename = "__vehicle_physics_again__/squeel3.ogg",
	},
	{
		type = "sound",
		name = "vehphy-dirt",
		filename = "__vehicle_physics_again__/dirt.ogg",
	},
})