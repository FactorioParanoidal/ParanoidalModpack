local station_pumps = {}
local pump_name = "scrap-fluid-pump"
local status_key = "junktrain-status.wagon-only"

local function has_wagon_target(pump)
  local input_connected, output_connected = false, false
  for _, connection in pairs(pump.get_fluid_box_pipe_connections(1) or {}) do
    if connection.target and connection.target.valid then
      if connection.flow_direction == "input" then
        input_connected = true
      else
        output_connected = true
      end
    end
  end
  -- A train next to two ground connections must never enable pipeline transfer.
  if input_connected == output_connected then return false end

  local targets = output_connected and pump.pump_input_rail_targets or pump.pump_output_rail_targets
  for _, rail in pairs(targets) do
    for _, wagon in pairs(pump.surface.find_entities_filtered({area = rail.bounding_box, type = "fluid-wagon"})) do
      if wagon.train and wagon.train.speed == 0 then return true end
    end
  end
  return false
end

local function update(pump)
  local disabled = not has_wagon_target(pump)
  if pump.disabled_by_script ~= disabled then pump.disabled_by_script = disabled end
  local status = pump.custom_status
  local own_status = status and type(status.label) == "table" and status.label[1] == status_key
  if disabled and not own_status then
    pump.custom_status = {diode = defines.entity_status_diode.yellow, label = {status_key}}
  elseif not disabled and own_status then
    pump.custom_status = nil
  end
end

function station_pumps.on_built(event)
  local entity = event.entity or event.destination
  if not (entity and entity.valid) then return end
  if entity.name == pump_name then
    storage.station_pumps = storage.station_pumps or {}
    storage.station_pumps[entity.unit_number] = entity
    update(entity)
  elseif entity.fluids_count > 0 then
    -- A newly attached ground port must disable the pump before this tick's transfer.
    local box = entity.bounding_box
    for _, pump in pairs(entity.surface.find_entities_filtered({
      name = pump_name,
      area = {{box.left_top.x - 2, box.left_top.y - 2}, {box.right_bottom.x + 2, box.right_bottom.y + 2}},
    })) do
      update(pump)
    end
  end
end

function station_pumps.rebuild()
  storage.station_pumps = {}
  for _, surface in pairs(game.surfaces) do
    for _, pump in pairs(surface.find_entities_filtered({name = pump_name})) do
      storage.station_pumps[pump.unit_number] = pump
      update(pump)
    end
  end
end

function station_pumps.on_tick()
  if not storage.station_pumps then station_pumps.rebuild() end
  for id, pump in pairs(storage.station_pumps) do
    if pump.valid then update(pump) else storage.station_pumps[id] = nil end
  end
end

return station_pumps
