-- A local colony, not mferrari_lib's boss. Reuse the neutral hull's geometry and artwork.
local hull = data.raw.container["pd-infected-ship-wreck"]
local nest = table.deepcopy(data.raw["unit-spawner"]["biter-spawner"])
nest.name = "pd-infected-ship-nest"
nest.localised_name = {"entity-name.pd-infected-ship-nest"}
nest.localised_description = {"entity-description.pd-infected-ship-nest"}
nest.icon = hull.icon
nest.icons = nil
nest.flags = {"placeable-enemy", "placeable-off-grid", "not-repairable", "not-rotatable", "not-blueprintable"}
nest.hidden = false
nest.max_health = 1500
nest.healing_per_tick = 0.01
nest.minable = nil
nest.loot = nil
nest.autoplace = nil
nest.corpse = nil
nest.dying_explosion = "big-explosion"
nest.dying_trigger_effect = nil
nest.time_to_capture = nil
nest.captured_spawner_entity = nil
nest.collision_box = table.deepcopy(hull.collision_box)
nest.selection_box = table.deepcopy(hull.selection_box)
nest.map_generator_bounding_box = table.deepcopy(hull.collision_box)
nest.graphics_set = {
  animations = {table.deepcopy(hull.picture)},
  integration = table.deepcopy(hull.integration_patch),
}
nest.max_count_of_owned_units = 6
nest.max_count_of_owned_defensive_units = 6
nest.max_friends_around_to_spawn = 6
nest.max_defensive_friends_around_to_spawn = 6
nest.spawning_cooldown = {720, 360}
nest.spawning_radius = 12
nest.spawning_spacing = 3
nest.max_spawn_shift = 0
nest.call_for_help_radius = 32
nest.spawn_decoration = nil
nest.spawn_decorations_on_expansion = false
-- result_units is refreshed from the ordinary nests in data-final-fixes.
data:extend({nest})
