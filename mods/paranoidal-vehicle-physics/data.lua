-- Prototype names are kept from the merged mods (vehicle_physics, VehicleSnap, Shield-FX).
local path = "__paranoidal-vehicle-physics__/"

-- Drift dust (vehicle_physics).
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
hover_smoke.animation.shift = {0, 0}

-- Tire marks (vehicle_physics).
local marks = table.deepcopy(data.raw.corpse["small-scorchmark"])
marks.name = "drifting-tire-marks"
marks.ground_patch = nil
marks.ground_patch_higher = nil
marks.time_before_removed = math.ceil(60 * settings.startup["vehphy-tiremarks-duration"].value)
marks.animation = {
	width = 41,
	height = 41,
	frame_count = 1,
	direction_count = 1,
	scale = 0.5,
	filename = path .. "graphics/tire-marks.png",
}

data:extend({
	hover_smoke,
	marks,
	{type = "sound", name = "vehphy-squeel-1", filename = path .. "sounds/squeal-1.ogg"},
	{type = "sound", name = "vehphy-squeel-2", filename = path .. "sounds/squeal-2.ogg"},
	{type = "sound", name = "vehphy-squeel-3", filename = path .. "sounds/squeal-3.ogg"},
	{type = "sound", name = "vehphy-dirt", filename = path .. "sounds/dirt.ogg"},

	-- Angle snapping toggle (VehicleSnap).
	{
		type = "custom-input",
		name = "VehicleSnap-toggle",
		key_sequence = "SHIFT + V",
		consuming = "none",
	},
	{
		type = "shortcut",
		name = "VehicleSnap-shortcut",
		order = "v[vehiclesnap]",
		action = "lua",
		localised_name = {"shortcut-name.VehicleSnap-shortcut"},
		associated_control_input = "VehicleSnap-toggle",
		toggleable = true,
		icon = path .. "graphics/vehicle-snap-shortcut.png",
		icon_size = 32,
		small_icon = path .. "graphics/vehicle-snap-shortcut.png",
		small_icon_size = 32,
	},
})

-- Shield hit effects (Shield-FX).
require("prototypes.shield-effects")
