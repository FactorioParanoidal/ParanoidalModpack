require("chance-increment")

ic.conf = {
  level_multiplier = settings.startup["ic-more-qualities-multiplier"].value,
}

function ic.create_quality(in_name, in_icon_name, in_level, in_order, in_next_quality_name, in_beacon_power_usage_multiplier,
                              in_mining_drill_resource_drain_multiplier, in_science_pack_drain_multiplier, in_color)

  if in_icon_name == nil then
    in_icon_name = in_name
  end

  local entity = {
    type = "quality",
    name = in_name,
    level = math.floor(in_level * ic.conf.level_multiplier),
    color = in_color,
    order = in_order,
    next = in_next_quality_name,
    next_probability = ic.get_chance(),
    subgroup = "qualities",
    icon = "__ic-more-qualities__/graphics/icons/quality-" .. in_icon_name .. ".png",
    beacon_power_usage_multiplier = in_beacon_power_usage_multiplier,
    mining_drill_resource_drain_multiplier = in_mining_drill_resource_drain_multiplier,
    science_pack_drain_multiplier = in_science_pack_drain_multiplier
  }
  return entity
end