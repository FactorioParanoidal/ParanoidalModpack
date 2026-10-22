local path = "__OreRadar__/graphics/"
local icons = {{icon = path .. "ore_radar_icon.png", icon_size = 64}}

-- Preserve Paranoidal 1.1 gameplay values; take current engine sounds/effects from base.
local radar = table.deepcopy(data.raw.radar.radar)
radar.name = "ore-radar"
radar.icon = nil
radar.icons = icons
radar.minable = {mining_time = 0.1, result = "ore-radar"}
radar.max_health = 250
radar.resistances = {{type = "fire", percent = 70}, {type = "impact", percent = 30}}
radar.collision_box = {{-1.2, -1.2}, {1.2, 1.2}}
radar.selection_box = {{-1.5, -1.5}, {1.5, 1.5}}
radar.energy_usage = "1200kW"
radar.energy_per_sector = "100MJ"
-- 1.1's 10kJ re-charts nine nearby chunks every tick at 1.2MW.
radar.energy_per_nearby_scan = "1MJ"
radar.max_distance_of_sector_revealed = 1
radar.max_distance_of_nearby_sector_revealed = 1
radar.energy_source = {type = "electric", usage_priority = "secondary-input"}
radar.rotation_speed = 0.0008
radar.integration_patch = nil
radar.connects_to_other_radars = false
radar.localised_description = {"entity-description.ore-radar"}
radar.pictures = {layers = {}}
local layers = {
  {"left.png", 64, 302, 32, -32, -26},
  {"mid.png", 64, 302, 32, 0, -26},
  {"right.png", 64, 302, 32, 32, -26},
  {"left-sh.png", 128, 160, 16, -16, 11, true},
  {"right-sh.png", 128, 160, 16, 41, 11, true}
}
for _, layer in ipairs(layers) do
  radar.pictures.layers[#radar.pictures.layers + 1] = {
    filename = path .. layer[1], priority = "low", width = layer[2], height = layer[3],
    direction_count = 180, line_length = layer[4], shift = util.by_pixel(layer[5], layer[6]),
    scale = 0.5, apply_projection = false, draw_as_shadow = layer[7]
  }
end

data:extend({radar, {
  type = "item", name = "ore-radar", icons = icons,
  subgroup = "defensive-structure", order = "d[radar]-b[ore-radar]",
  place_result = "ore-radar", stack_size = 10
}, {
  type = "recipe", name = "ore-radar",
  ingredients = {
    {type = "item", name = data.raw.item["bob-basic-circuit-board"] and "bob-basic-circuit-board"
      or data.raw.item["basic-circuit-board"] and "basic-circuit-board" or "electronic-circuit", amount = 10},
    {type = "item", name = "iron-gear-wheel", amount = 10},
    {type = "item", name = "iron-plate", amount = 50},
    {type = "item", name = "radar", amount = 1}
  },
  results = {{type = "item", name = "ore-radar", amount = 1}}
}})

-- Radars have no window of their own; a click on the ore radar opens its mode window.
data:extend({{
  type = "custom-input", name = "ore-radar-open", key_sequence = "",
  linked_game_control = "open-gui", consuming = "none"
}})
