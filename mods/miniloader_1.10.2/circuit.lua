local event = require "lualib.event"
local onwireplaced = require "lualib.onwireplaced"
local util = require "lualib.util"

local M = {}

function M.sync_filters(entity)
  local filters = {}
  local slots = entity.filter_slot_count
  local inserter_filter_mode

  for i=1,slots do
    filters[i] = entity.get_filter(i)
  end
  if entity.type == "inserter" then
    inserter_filter_mode = entity.inserter_filter_mode
  end

  local inserters = util.get_loader_inserters(entity)
  for _, ins in ipairs(inserters) do
    for j=1,slots do
      ins.set_filter(j, filters[j])
    end
    if inserter_filter_mode then
      ins.inserter_filter_mode = inserter_filter_mode
    end
  end
end

local function inserter_with_control_behavior(inserters)
  for _, inserter in ipairs(inserters) do
    if inserter.get_control_behavior() then
      return inserter
    end
  end
  return nil
end

function M.sync_behavior(inserter)
  local inserters = util.get_loader_inserters(inserter)
  for _, target in ipairs(inserters) do
    target.inserter_stack_size_override = 1
  end

  local template_inserter = inserter_with_control_behavior(inserters)
  if not template_inserter then
    return
  end
  local source_behavior = template_inserter.get_control_behavior()

  for _, target in ipairs(inserters) do
    local behavior = target.get_or_create_control_behavior()
    behavior.circuit_read_hand_contents = source_behavior.circuit_read_hand_contents
    behavior.circuit_mode_of_operation = source_behavior.circuit_mode_of_operation
    behavior.circuit_hand_read_mode = source_behavior.circuit_hand_read_mode
    behavior.circuit_set_stack_size = false
    behavior.circuit_stack_control_signal = {type="item"}
    behavior.circuit_condition = source_behavior.circuit_condition
    behavior.logistic_condition = source_behavior.logistic_condition
    behavior.connect_to_logistic_network = source_behavior.connect_to_logistic_network
  end
end

local function connected_non_partners(inserters)
  local out = {[defines.wire_type.red] = {}, [defines.wire_type.green] = {}}
  for _, inserter in ipairs(inserters) do
    local ccds = inserter.circuit_connection_definitions
    local pos = inserter.position
    for _, ccd in ipairs(ccds) do
      local otherpos = ccd.target_entity.position
      if otherpos.x ~= pos.x or otherpos.y ~= pos.y then
        table.insert(out[ccd.wire], ccd)
      end
    end
  end
  return out
end

local function count_connections_on_wire(entity, wire_type)
  local count = 0
  for _, ccd in ipairs(entity.circuit_connection_definitions) do
    if ccd.wire == wire_type then
      count = count + 1
    end
  end
  return count
end

local function partner_connections_need_sync(inserters, connections)
  local master_inserter = inserters[1]
  for wire_type, wire_connections in pairs(connections) do
    local network = master_inserter.get_circuit_network(wire_type)
    if network then
      if not next(wire_connections) then
        --log("no external connections on wire color")
        return true
      end
      local network_id = network.network_id
      for i=2,#inserters do
        local slave_inserter = inserters[i]
        local slave_network = slave_inserter.get_circuit_network(wire_type)
        if not slave_network or slave_network.network_id ~= network_id then
          --log("slave connected to no or different network")
          return true
        end
        if count_connections_on_wire(slave_inserter, wire_type) ~= 1 then
          --log("slave has bad connection count")
          return true
        end
      end
    else
      for i=2,#inserters do
        local slave_inserter = inserters[i]
        local slave_network = slave_inserter.get_circuit_network(wire_type)
        if slave_network then
          --log("slave has network connection")
          return true
        end
      end
    end
  end
  --log("no sync needed")
  return false
end

function M.sync_partner_connections(inserter)
  local inserters = util.get_loader_inserters(inserter)
  local connections = connected_non_partners(inserters)

  if not partner_connections_need_sync(inserters, connections) then
    return
  end

  M.sync_behavior(inserter)
  local master_inserter = inserters[1]
  for wire_type, ccds in pairs(connections) do
    if not next(ccds) then
      for _, ins in ipairs(inserters) do
        ins.disconnect_neighbour(wire_type)
      end
    else
      master_inserter.disconnect_neighbour(wire_type)
      for _, ccd in ipairs(ccds) do
        master_inserter.connect_neighbour(ccd)
      end
      for i=2,#inserters do
        local ins = inserters[i]
        ins.disconnect_neighbour(wire_type)
        ins.connect_neighbour{wire=wire_type, target_entity=master_inserter}
      end
    end
  end
end

local function on_wire_change(ev)
  for _, entity in ipairs{ev.entity, ev.target_entity} do
    if entity.valid and util.is_miniloader_inserter(entity) then
      M.sync_partner_connections(entity)
    end
  end
end

function M.on_init()
  event.register({onwireplaced.on_wire_added, onwireplaced.on_wire_removed}, on_wire_change)
  onwireplaced.on_init()
end

function M.on_load()
  event.register({onwireplaced.on_wire_added, onwireplaced.on_wire_removed}, on_wire_change)
  onwireplaced.on_load()
end

return M