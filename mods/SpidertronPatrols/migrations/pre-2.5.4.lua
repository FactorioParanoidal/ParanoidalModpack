---@diagnostic disable: undefined-field, inject-field
for _, patrol_data in pairs(storage.patrol_data or {}) do
  for _, waypoint in pairs(patrol_data.waypoints) do
    if waypoint.type == "item-count" then
      if waypoint.item_count_info then
        waypoint.item_condition_info = {
          elem = {name = waypoint.item_count_info.item_name, quality = "normal"},
          count = waypoint.item_count_info.count,
          condition = waypoint.item_count_info.condition,
        }
        waypoint.item_count_info = nil
      end
    elseif waypoint.type == "circuit-condition" then
      if waypoint.item_count_info then
        waypoint.circuit_condition_info = {
          elem = waypoint.item_count_info.item_name,
          count = waypoint.item_count_info.count,
          condition = waypoint.item_count_info.condition,
        }
        waypoint.item_count_info = nil
      end
    end
  end
end