-- Legacy solar model/reporting on mocks; no Factorio generation/season/rain acceptance.
local directory = assert(arg[0]:match("^(.*[/\\])"))
package.path = directory .. "../?.lua;" .. package.path
storage = {}
local scans, samples = 0, 0
local surface = { index = 1, valid = true, pollutant_type = { name = "pollution" } }
local panel = { surface = surface, surface_index = 1, position = { x = 1, y = 0 }, quality = { level = 0 } }
surface.find_entities_filtered = function() scans = scans + 1; return { panel } end
game = { tick = 0, surfaces = { surface } }
script = { register_on_object_destroyed = function() return 100 end }
log = function() end
remote = { interfaces = { NightBrightness = { get_solar_multiplier = true } }, call = function() return 0.8 end }
Grid = { key_from_map_position = function(pos) return math.floor(pos.x / 32) end }
Pollution = { MinPollutionShown = 60, MaxPollutionShown = 1000, Exponent = 0.4,
	thickness = function() samples = samples + 1; return 1 end }
local Solar = require("scripts.solar")
assert(Solar.get_surface_status(1).availability == "pending" and next(storage) == nil)
assert(Solar.get_surface_status(2).availability == "missing_surface")
Solar.OcclusionEnabled = true
Solar.full_synchronize()
local result = Solar.get_surface_status(1)
assert(result.model == "legacy" and result.pollution_component == 0.5 and surface.solar_power_multiplier == 0.4)
assert(result.applied_tick == 0 and result.last_complete_cycle_tick == nil)
local sc, sa = scans, samples
result.curve.min = -100
for _ = 1, 4 do assert(Solar.get_surface_status(1).curve.min == 60) end
assert(scans == sc and samples == sa and surface.solar_power_multiplier == 0.4)
Solar.queue_chunks_for_update()
game.tick = 5
Solar.incrementally_update_chunks_in_queue()
assert(Solar.get_surface_status(1).last_complete_cycle_tick == 5)
Solar.on_panel_destroyed(100)
assert(Solar.get_surface_status(1).pollution_component == 1 and surface.solar_power_multiplier == 0.8)
assert(not Solar.get_surface_status(1).has_tracked_panels)
Solar.OcclusionEnabled = false
Solar.refresh_solar_multiplier(1)
assert(not Solar.get_surface_status(1).occlusion_enabled and surface.solar_power_multiplier == 0.8)
print("visible-pollutants: OK (legacy ratios retained, reporting pure, timestamps)")
