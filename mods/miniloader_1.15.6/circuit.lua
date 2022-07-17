local event = require "lualib.event"
local onwireplaced = require "lualib.onwireplaced"
local util = require "lualib.util"

local M = {}

local function get_inserter_filters(inserter)
  local slots = inserter.filter_slot_count
  local filters = {}
  for i=1,slots do
    filters[i] = inserter.get_filter(i)
  end
  return filters
end

local function copy_inserter_filters(source_inserter, dest_inserter, filters)
  local slots = dest_inserter.filter_slot_count
  local inserter_filter_mode = source_inserter.inserter_filter_mode

  if inserter_filter_mode then
    dest_inserter.inserter_filter_mode = inserter_filter_mode
  end

  if not filters then
    filters = get_inserter_filters(source_inserter)
  end

  for i=1,slots do
    dest_inserter.set_filter(i, filters[i])
  end
end

function M.sync_filters(entity)
  local inserters = util.get_loader_inserters(entity)
  local source_inserter = inserters[1]

  if #inserters < 2 then return end

  if not util.is_output_miniloader_inserter(entity)
  or not global.split_lane_configuration[source_inserter.unit_number] then
    -- sync left and right lanes
    copy_inserter_filters(entity, inserters[2])
  end
  for i = 1, #inserters, 2 do
    copy_inserter_filters(source_inserter, inserters[i])
  end
  source_inserter = inserters[2]
  for i = 4, #inserters, 2 do
    copy_inserter_filters(source_inserter, inserters[i])
  end
end

local function copy_inserter_behavior(source_inserter, target)
  local source_behavior = source_inserter.get_or_create_control_behavior()
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

function M.copy_inserter_settings(source, target)
  copy_inserter_filters(source, target)
  copy_inserter_behavior(source, target)
end

function M.sync_behavior(inserter)
  local inserters = util.get_loader_inserters(inserter)
  local stack_size_override = settings.global["miniloader-lock-stack-sizes"].value
    and 1 or inserters[1].inserter_stack_size_override
  for _, target in ipairs(inserters) do
    target.inserter_stack_size_override = stack_size_override
  end

  if #inserters < 2 then return end

  local source_inserter = inserters[1]
  if not util.is_output_miniloader_inserter(source_inserter)
  or not global.split_lane_configuration[source_inserter.unit_number] then
    -- sync left and right lanes
    copy_inserter_behavior(source_inserter, inserters[2])
  end
  for i = 1, #inserters, 2 do
    copy_inserter_behavior(source_inserter, inserters[i])
  end
  source_inserter = inserters[2]
  for i = 4, #inserters, 2 do
    copy_inserter_behavior(source_inserter, inserters[i])
  end
end

local function ccds_match(ccd1, ccd2)
  if ccd1 == nil or ccd2 == nil then return false end
  return
       ccd1.entity == ccd2.entity        and ccd1.target_entity == ccd2.target_entity
    or ccd1.entity == ccd2.target_entity and ccd1.target_entity == ccd2.entity
end

local function connected_non_partners(inserters, removed)
  local out = {[defines.wire_type.red] = {}, [defines.wire_type.green] = {}}
  for _, inserter in ipairs(inserters) do
    local ccds = inserter.circuit_connection_definitions
    local pos = inserter.position
    for _, ccd in ipairs(ccds) do
      ccd.entity = inserter
      local otherpos = ccd.target_entity.position
      if (otherpos.x ~= pos.x or otherpos.y ~= pos.y) and not ccds_match(ccd, removed) then
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
  if not master_inserter then
    return false
  end
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

function M.sync_partner_connections(inserter, removed)
  local inserters = util.get_loader_inserters(inserter)
  local connections = connected_non_partners(inserters, removed)

  if not partner_connections_need_sync(inserters, connections) then
    return
  end

  M.sync_behavior(inserter)
  local master_inserter = inserters[1]
  local other_miniloader_inserters = {}
  for wire_type, ccds in pairs(connections) do
    if not next(ccds) then
      for _, ins in ipairs(inserters) do
        ins.disconnect_neighbour(wire_type)
      end
    else
      master_inserter.disconnect_neighbour(wire_type)
      for _, ccd in ipairs(ccds) do
        master_inserter.connect_neighbour(ccd)
        if util.is_miniloader_inserter(ccd.target_entity) then
          other_miniloader_inserters[#other_miniloader_inserters+1] = ccd.target_entity
        end
      end
      for i=2,#inserters do
        local ins = inserters[i]
        ins.disconnect_neighbour(wire_type)
        ins.connect_neighbour{wire=wire_type, target_entity=master_inserter}
      end
    end
  end

  for _, other_miniloader_inserter in pairs(other_miniloader_inserters) do
    M.sync_partner_connections(other_miniloader_inserter)
  end
end

local control_behavior_keys = {
  "circuit_condition", "logistic_condition", "connect_to_logistic_network",
  "circuit_read_hand_contents", "circuit_mode_of_operation", "circuit_hand_read_mode", "circuit_set_stack_size", "circuit_stack_control_signal",
}

local function on_wire_added(ev)
  for _, entity in ipairs{ev.entity, ev.target_entity} do
    if entity.valid and util.is_miniloader_inserter(entity) then
      M.sync_partner_connections(entity)
    end
  end
end

local function on_wire_removed(ev)
  for _, entity in ipairs{ev.entity, ev.target_entity} do
    if entity.valid and util.is_miniloader_inserter(entity) then
      M.sync_partner_connections(entity, ev)
    end
  end
end

function M.on_init()
  onwireplaced.on_init()
  M.on_load()
end

function M.on_load()
  onwireplaced.on_load()
  event.register(onwireplaced.on_wire_added, on_wire_added)
  event.register(onwireplaced.on_wire_removed, on_wire_removed)
end

function M.on_configuration_changed()
  onwireplaced.on_configuration_changed()
end

return M
