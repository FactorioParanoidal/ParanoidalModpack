local flib_position = require("__flib__.position")

-- Mod Compatibility checks
local function is_excluded(entity)
  -- compatibility with Realistic Train Network Mod
  return entity.name == "ret-pole-wire"
end

--- @param event EventData.on_player_selected_area|EventData.on_player_alt_selected_area
--- @param alt_mode? boolean is alt select mode
local function on_selected_area(event, alt_mode)
  local unit_numbers = {}
  local x_axis = {}
  local y_axis = {}
  local distances = {}
  local network_ids = {}

  -- 1. Collect all entity unit numbers and electic network ids before they might change
  for _, entity in pairs(event.entities) do
    if is_excluded(entity) then goto continue end
    unit_numbers[entity.unit_number] = true
    network_ids[entity.unit_number] = entity.electric_network_id
    ::continue::
  end

  -- 2. Disconnect all copper wires and reconnect any required connections
  for _, entity in pairs(event.entities) do
    if is_excluded(entity) then goto continue end
    local to_reconnect = {}
    local connector = entity.get_wire_connector(defines.wire_connector_id.pole_copper, false)
    if connector == nil then goto continue end

    for _, connection in pairs(connector.connections) do
      --  if the connection is not in the selected area, we need to reconnect it
      -- this also reconnects any connections to non-pole entities like power switches
      if not unit_numbers[connection.target.owner.unit_number] then
        to_reconnect[#to_reconnect + 1] = connection
      end
    end

    connector.disconnect_all()
    for _, connection in pairs(to_reconnect) do
      connector.connect_to(connection.target, false, connection.origin)
    end

    local position = entity.position
    local x, y = position.x, position.y

    local x_entities = x_axis[x] or {}
    x_axis[x] = x_entities
    x_entities[#x_entities + 1] = entity

    local y_entities = y_axis[y] or {}
    y_axis[y] = y_entities
    y_entities[#y_entities + 1] = entity

    -- 2.1 Collect the distances between each entity
    if not alt_mode then
      for _, other in pairs(event.entities) do
        if is_excluded(other) or other == entity then goto next end
        local distance = flib_position.distance(position, other.position)
        if distances[entity.unit_number] == nil then
          distances[entity.unit_number] = {}
        end
        local entity_distances = distances[entity.unit_number]
        entity_distances[#entity_distances + 1] = { entity = other, distance = distance }
        ::next::
      end
    end
    ::continue::
  end
  -- 3. reconnect any poles that are on the same horizontal line
  for _, entities in pairs(x_axis) do
    table.sort(entities, function(a, b)
      return a.position.y < b.position.y
    end)
    for i = 2, #entities do
      if network_ids[entities[i].unit_number] == network_ids[entities[i - 1].unit_number] then
        local src = entities[i].get_wire_connector(defines.wire_connector_id.pole_copper, true)
        local dst = entities[i - 1].get_wire_connector(defines.wire_connector_id.pole_copper, true)
        src.connect_to(dst)
      end
    end
  end
  -- 4. reconnect any poles that are on the same vertical line
  for _, entities in pairs(y_axis) do
    table.sort(entities, function(a, b)
      return a.position.x < b.position.x
    end)
    for i = 2, #entities do
      if network_ids[entities[i].unit_number] == network_ids[entities[i - 1].unit_number] then
        local src = entities[i].get_wire_connector(defines.wire_connector_id.pole_copper, true)
        local dst = entities[i - 1].get_wire_connector(defines.wire_connector_id.pole_copper, true)
        src.connect_to(dst)
      end
    end
  end

  -- 5. If not in alt mode, connect the closest poles so each network connection is restored

  if not alt_mode then
    for _, entity in pairs(event.entities) do
      if is_excluded(entity) then goto continue end
      local src = entity.get_wire_connector(defines.wire_connector_id.pole_copper, true)
      if src == nil then goto continue end

      local entity_distances = distances[entity.unit_number]
      if entity_distances == nil then goto continue end

      table.sort(entity_distances, function(a, b)
        return a.distance < b.distance
      end)
      -- we try and reconnect to the 3 closest poles
      -- this should handle most cases where connects need to be restored to keep networks connected
      for _ = 1, 3 do
        for _, other in pairs(entity_distances) do
          if other.entity.valid and network_ids[entity.unit_number] == network_ids[other.entity.unit_number] then
            local dst = other.entity.get_wire_connector(defines.wire_connector_id.pole_copper, true)
            if src.network_id ~= dst.network_id then
              src.connect_to(dst)
              -- only connect to the first closest
              -- there is no limit on # of connections, only one connection is needed
              -- if none are found then the pole will remain disconnected
              goto next
            end
          end
        end
        -- if none found then no point in continuing
        break
        ::next::
      end
      ::continue::
    end
  end
end


local function on_player_selected_area(event)
  if event.item ~= "power-grid-comb" then return end
  on_selected_area(event, false)
end

local function on_player_alt_selected_area(event)
  if event.item ~= "power-grid-comb" then return end
  on_selected_area(event, true)
end

script.on_event(defines.events.on_player_selected_area, on_player_selected_area)
script.on_event(defines.events.on_player_alt_selected_area, on_player_alt_selected_area)
