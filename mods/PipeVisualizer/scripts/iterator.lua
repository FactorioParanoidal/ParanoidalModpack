local flib_math = require("__flib__/math")
local flib_queue = require("__flib__/queue")

local entity_data = require("__PipeVisualizer__/scripts/entity-data")
local renderer = require("__PipeVisualizer__/scripts/renderer")

--- @alias FlowDirection "input"|"output"|"input-output"
--- @alias FluidSystemID uint
--- @alias PlayerIndex uint

--- @class Iterator
--- @field entities table<UnitNumber, EntityData>
--- @field in_overlay boolean
--- @field in_queue table<UnitNumber, boolean>
--- @field next_color_index integer
--- @field player_index PlayerIndex
--- @field queue Queue<ToIterateData>
--- @field systems table<FluidSystemID, FluidSystemData?>
--- @field to_ignore table<UnitNumber, boolean>

--- @class FluidSystemData
--- @field color Color
--- @field from_hover boolean
--- @field order uint

--- @class ToIterateData
--- @field entity LuaEntity
--- @field unit_number UnitNumber

--- @param iterator Iterator
--- @param entity LuaEntity
local function push(iterator, entity)
  if not entity.valid then
    return
  end
  local unit_number = entity.unit_number --[[@as UnitNumber]]
  iterator.in_queue[unit_number] = true
  flib_queue.push_back(iterator.queue, { entity = entity, unit_number = unit_number })
end

--- @param iterator Iterator
--- @return LuaEntity?
local function pop(iterator)
  while true do
    local to_iterate = flib_queue.pop_front(iterator.queue)
    if not to_iterate then
      return
    end
    local unit_number = to_iterate.unit_number
    iterator.in_queue[unit_number] = nil
    if iterator.to_ignore[unit_number] then
      iterator.to_ignore[unit_number] = nil
    elseif to_iterate.entity.valid then
      return to_iterate.entity
    end
  end
end

--- @param entity LuaEntity
--- @param player_index PlayerIndex
--- @param in_overlay boolean
--- @param from_hover boolean?
--- @return boolean accepted
local function request(entity, player_index, in_overlay, from_hover)
  if not global.iterator then
    return false
  end

  local self = global.iterator[player_index]
  if not self then
    --- @type Iterator
    self = {
      entities = {},
      in_overlay = in_overlay,
      in_queue = {},
      next_color_index = 0,
      player_index = player_index,
      queue = flib_queue.new(),
      scheduled = {},
      systems = {},
      to_ignore = {},
    }
  end

  local unit_number = entity.unit_number
  if not unit_number then
    return false
  end
  if self.to_ignore[unit_number] then
    self.to_ignore[unit_number] = nil
  end
  if self.entities[unit_number] or self.in_queue[unit_number] then
    return self.in_overlay -- To handle entities that cross chunk boundaries
  end

  from_hover = from_hover or false

  local fluidbox = entity.fluidbox
  local should_iterate = false
  for fluidbox_index = 1, #fluidbox do
    local fluid_system_id = fluidbox.get_fluid_system_id(fluidbox_index)
    if not fluid_system_id then
      goto continue
    end
    local system = self.systems[fluid_system_id]
    if system and not in_overlay then
      goto continue
    end

    if not system then
      local color = { r = 0.4, g = 0.4, b = 0.4 }
      local order = flib_math.max_uint
      if global.color_by_system[self.player_index] then
        self.next_color_index = self.next_color_index + 1
        local next_color = global.system_colors[self.next_color_index]
        if next_color then
          color = next_color
          order = self.next_color_index
        end
      else
        local contents = fluidbox.get_fluid_system_contents(fluidbox_index)
        if contents and next(contents) then
          color = global.fluid_colors[next(contents)]
          order = global.fluid_order[next(contents)]
        end
      end

      self.systems[fluid_system_id] = { color = color, from_hover = from_hover, order = order }
    end

    should_iterate = true

    ::continue::
  end

  if should_iterate then
    push(self, entity)
    global.iterator[player_index] = self
  end

  return should_iterate
end

--- @param iterator Iterator
--- @param entities_per_tick integer
local function iterate(iterator, entities_per_tick)
  for _ = 1, entities_per_tick do
    local entity = pop(iterator)
    if not entity then
      break
    end

    -- If the entity data already existed, this entity was requested to be redrawn
    local data = entity_data.create(iterator, entity)
    if not data then
      return
    end

    renderer.draw(iterator, data)

    if iterator.in_overlay or iterator.in_queue[entity.unit_number] then
      goto continue
    end

    -- Propagate to undrawn neighbours
    for fluid_system_id, connections in pairs(data.connections) do
      if iterator.systems[fluid_system_id] then
        for _, connection in pairs(connections) do
          local owner = connection.target_owner
          if owner then
            local data = entity_data.get(iterator, owner)
            if not data or data.connections[fluid_system_id] and not data.connection_objects[fluid_system_id] then
              local unit_number = owner.unit_number --[[@as UnitNumber]]
              if not iterator.in_queue[unit_number] then
                push(iterator, owner)
              end
            end
          end
        end
      end
    end

    ::continue::
  end
end

--- @param iterator Iterator
--- @param fluid_system_id FluidSystemID
local function clear_system(iterator, fluid_system_id)
  iterator.systems[fluid_system_id] = nil
  for _, data in pairs(iterator.entities) do
    if data.connections[fluid_system_id] then
      entity_data.remove_system(iterator, data, fluid_system_id)
    end
  end
  if not next(iterator.systems) then
    global.iterator[iterator.player_index] = nil
  end
end

--- @param player_index PlayerIndex
--- @param entity LuaEntity
local function clear(player_index, entity)
  if not global.iterator or not entity.valid then
    return
  end
  local self = global.iterator[player_index]
  if not self then
    return
  end
  local unit_number = entity.unit_number
  if not unit_number then
    return
  end
  if self.in_queue[unit_number] then
    self.to_ignore[unit_number] = true
  end
  local data = entity_data.get(self, entity)
  if not data then
    return
  end
  entity_data.remove(self, data)
end

--- @param player_index PlayerIndex
local function clear_all(player_index)
  if not global.iterator then
    return
  end
  local it = global.iterator[player_index]
  if not it then
    return
  end
  for _, entity_data in pairs(it.entities) do
    renderer.clear(entity_data)
  end
  global.iterator[player_index] = nil
  if not next(global.iterator) then
    renderer.reset()
  end
end

--- @param player_index PlayerIndex
local function clear_hovered(player_index)
  if not global.iterator then
    return
  end
  local it = global.iterator[player_index]
  if not it then
    return
  end
  for system_id, system_data in pairs(it.systems) do
    if system_data.from_hover then
      clear_system(it, system_id)
    end
  end
  if not next(it.systems) then
    global.iterator[player_index] = nil
    if not next(global.iterator) then
      renderer.reset()
    end
  end
end

--- @param player_index PlayerIndex
--- @return Iterator?
local function get(player_index)
  if not global.iterator then
    return
  end
  return global.iterator[player_index]
end

--- @param entity LuaEntity
--- @param player_index PlayerIndex
local function request_or_clear(entity, player_index)
  local it = get(player_index)
  if not it then
    request(entity, player_index, false)
    return
  end
  if it.in_overlay then
    return
  end
  -- If this entity was being hovered, change its systems to persistent instead of removing the visualization.
  local entity_data = entity_data.get(it, entity)
  if entity_data then
    local did_change
    for fluid_system_id in pairs(entity_data.connections) do
      local system_data = it.systems[fluid_system_id]
      if system_data and system_data.from_hover then
        system_data.from_hover = false
        did_change = true
      end
    end
    if did_change then
      return
    end
  end
  if request(entity, player_index, false) then
    return
  end
  local fluidbox = entity.fluidbox
  for fluidbox_index = 1, #fluidbox do
    --- @cast fluidbox_index uint
    local id = fluidbox.get_fluid_system_id(fluidbox_index)
    if id and it.systems[id] then
      clear_system(it, id)
    end
  end
end

local function on_tick()
  if not global.iterator then
    return
  end
  local entities_per_tick =
    math.ceil(settings.global["pv-entities-per-tick"].value --[[@as int]] / table_size(global.iterator))
  for _, iterator in pairs(global.iterator) do
    iterate(iterator, entities_per_tick)
  end
end

--- @param e EventData.CustomInputEvent
local function on_toggle_hover(e)
  local iterator = global.iterator[e.player_index]
  if iterator and iterator.in_overlay then
    return
  end
  local player = game.get_player(e.player_index)
  if not player then
    return
  end
  local entity = player.selected
  if not entity then
    clear_all(e.player_index)
    return
  end
  request_or_clear(entity, e.player_index)
end

local function reset()
  --- @type table<PlayerIndex, Iterator>
  global.iterator = {}
end

--- @class iterator
local iterator = {}

iterator.on_init = reset
iterator.on_configuration_changed = reset

iterator.events = {
  [defines.events.on_tick] = on_tick,
  ["pv-visualize-selected"] = on_toggle_hover,
}

iterator.clear = clear
iterator.clear_all = clear_all
iterator.clear_hovered = clear_hovered
iterator.get = get
iterator.request = request

return iterator
