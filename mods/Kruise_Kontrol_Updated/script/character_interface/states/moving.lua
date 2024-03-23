local Moving = {}

Moving.metatable = {__index = Moving}

function Moving.new(Character, destination, radius, timeout)
  if not destination.valid then
    --For position type hacks.
    destination.valid = true
  end
  local state =
  {
    type = "moving",
    character = Character,
    destination = destination or error("No destination given for creating a moving state."),
    radius = radius or 0.5,
    fail_count = -1,
    tick_to_timeout = (timeout and game.tick + timeout) or nil
  }
  return setmetatable(state, Moving.metatable)
end

function Moving:cleanup()
  self:clear_path()
end

function Moving:get_destination()
  --Since destination can be either an entity or a position directly...
  return (self.destination and self.destination.position) or {self.destination[1], self.destination[2]}
end

function Moving:clear_path()
  if not self.path then return end
  for k, node in pairs (self.path) do
    if node.rendering then
      rendering.destroy(node.rendering)
      node.rendering = nil
    end
  end
  if self.next_node_render then
    rendering.destroy(self.next_node_render)
  end
end

function Moving:render_path()
  local path = self.path
  if not path then return end
  for k, node in pairs (path) do
    local next_index, next_node = next(path, k)
    if next_node then
      node.rendering = rendering.draw_line
      {
        color = {0, 1, 0, 0.5},
        width = 3,
        dash_length = 0.5,
        gap_length = 0.5,
        from = node.position,
        to = next_node.position,
        surface = self.character.entity.surface,
        players = {self.character.player},
        visible = true,
        draw_on_ground = true,
        only_in_alt_mode = false
      }
    end
  end
  self:render_path_to_node()
end

function Moving:render_path_to_node()
  if self.next_node_render then
    rendering.destroy(self.next_node_render)
  end
  local node = self.path[1]
  if not node then return end
  self.next_node_render = rendering.draw_line
  {
    color = {0, 1, 0, 0.5},
    width = 3,
    dash_length = 0.5,
    gap_length = 0.5,
    to = self.character.entity,
    from = node.position,
    surface = self.character.entity.surface,
    players = {self.character.player},
    visible = true,
    draw_on_ground = true,
    only_in_alt_mode = false
  }
end

function Moving:get_destination_radius()
  return (self.destination and self.destination.get_radius and self.destination.get_radius() + self.radius) or self.radius
end

local flags = {cache = false, allow_destroy_friendly_entities = false, prefer_straight_paths = true, no_break = true}
function Moving:request_path()
  if self.path_request_index then return end
  local entity = self.character.entity
  local destination = self:get_destination()
  local radius = self:get_destination_radius()
  --error(serpent.block(destination))

  self.path_request_index = entity.surface.request_path(
  {
    bounding_box = entity.prototype.collision_box,
    collision_mask = entity.prototype.collision_mask,
    start = entity.position,
    goal = destination,
    force = entity.force,
    radius = radius,
    can_open_gates = true,
    path_resolution_modifier = self.fail_count,
    pathfind_flags = flags,
    entity_to_ignore = entity
  })

  self.requested_destination = destination
  self.character:print("Requested a path. ")
end

function Moving:finish()
  self.character:print("No more nodes, we must be at the destination?")
  self.character.entity.walking_state = {walking = false}
  self.character:pop_state()
  self:cleanup()
end

function Moving:move_to_next_node()
  local node = self.path[1]
  --self.character:print("Reached a waypoint.")
  --self.character.entity.teleport(node.position)
  table.remove(self.path, 1)
  if node.rendering then
    rendering.destroy(node.rendering)
    node.rendering = nil
  end
  self:render_path_to_node()
end

function Moving:follow_path()

  local node = self.path[1]
  if not node then
    self:finish()
    return
  end

  if util.distance(node.position, self.character:get_position()) < (self.character:get_speed()) then
    self:move_to_next_node()
  end

  local node = self.path[1]
  if not node then
    self:finish()
    return
  end

  if node.needs_destroy_to_reach then
    if self:clear_obstacles(node.position) then
      return
    end
  end

  self.character.entity.walking_state = {walking = true, direction = self.character:get_direction_to(node.position)}

end

local is_near = function(a, b)
  return math.abs(a - b) < 1
end

local rect_dist = function(position_1, position_2)
  local x1 = position_1.x or position_1[1]
  local x2 = position_2.x or position_2[1]

  local y1 = position_1.y or position_1[2]
  local y2 = position_2.y or position_2[2]

  return math.abs(x1 - x2) + math.abs(y1 - y2)
end

function Moving:check_path()
  --This is for the case where we are moving to an entity that might have moved!
  if not self.destination.position then return end
  if not self.requested_destination then return end

  local destination = self:get_destination()
  if rect_dist(destination, self.requested_destination) < 1 then return end

  if util.distance(self.character:get_position(), destination) < self.radius then
    return true
  end

  --Request a new path, but keep walking along the old as its probably its in the right direction still.
  self.character:print("Target moved, recalculating path")
  self:request_path()

end

function Moving:clear_obstacles(position)
  local force = self.character.entity.force
  local entities = self.character.entity.surface.find_entities_filtered
  {
    position = self.character:get_position(),
    radius = self.character.entity.get_radius() + 0.5,
    collision_mask = self.character.entity.prototype.collision_mask
  }

  local stand = false
  for k, entity in pairs (entities) do
    if entity ~= self.character.entity and entity.type ~= "cliff" then
      stand = true
      if not force.get_cease_fire(entity.force) then
        self.character:attack(entity)
      end
      self.character:mine(entity)
    end
  end

  if stand then
    self.character.entity.walking_state = {walking = false, direction = self.character:get_direction_to(position)}
    return true
  end

  return false

end

function Moving:check_stuck()
  if not (self.path and self.path[1]) then return end

  local node = self.path[1]

  if node == self.last_stuck_node then
    self:request_path()
  end

  self.last_stuck_node = node

end

function Moving:update()

  if self.tick_to_timeout and game.tick > self.tick_to_timeout then
    self:finish()
    return
  end


  self.character.entity.walking_state = {walking = false}

  if not self.destination.valid then
    self:finish()
    return
  end

  if self.character:update_every_n_ticks(60) then
    self:check_stuck()
  end

  if self.character:update_every_n_ticks(100) then
    if self:check_path() then
      --Will return true if it checks and we are actually already in range.
      self:finish()
      return
    end
  end

  if not self.path then

    if self.character:distance(self.destination) <= (self.radius + 0.1) then
      self:finish()
      return
    end

    self:request_path()
    return
  end

  self:follow_path()

end

local remove = table.remove

function Moving:on_path_recieved(event)

  if not self.destination.valid then
    self:finish()
    return
  end

  self.path_request_index = nil
  self.character:print("Path request finished")
  local path = event.path
  if not path then
    self.path = nil
    self.fail_count = self.fail_count + 1
    if self.fail_count > 3 then
      self:finish()
    end
    return
  end

  local destination = self:get_destination()

  local dist_to_dest = rect_dist(self.character:get_position(), destination)

  for k, node in pairs (path) do
    local next = path[k + 1]
    if not next then break end

    local distance = rect_dist(node.position, destination)
    if distance > rect_dist(next.position, destination) and distance > dist_to_dest then
      remove(path, k)
    else
      break
    end
  end

  self:clear_path()
  self.path = event.path
  self:render_path()
end

function Moving:on_script_path_request_finished(event)
  if event.name == defines.events.on_script_path_request_finished then
    if event.id == self.path_request_index then
      self:on_path_recieved(event)
    end
  end
end


return setmetatable(Moving, {__call = function(this, ...) return Moving.new(...) end})