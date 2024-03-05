local util = require("script/character_script_util")
local Moving_vehicle = {}

Moving_vehicle.metatable = {__index = Moving_vehicle}

function Moving_vehicle.new(Character, destination, radius)
  if not destination.valid then
    --For position type hacks.
    destination.valid = true
  end
  local state =
  {
    type = "moving_vehicle",
    character = Character,
    destination = destination or error("No destination given for creating a moving state."),
    radius = radius or 0.5,
    fail_count = -1,
  }
  return setmetatable(state, Moving_vehicle.metatable)
end

function Moving_vehicle:cleanup()
  self:clear_path()
end

function Moving_vehicle:get_destination()
  --Since destination can be either an entity or a position directly...
  return (self.destination and self.destination.position) or {self.destination[1], self.destination[2]}
end

function Moving_vehicle:clear_path()
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

function Moving_vehicle:render_path()
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

function Moving_vehicle:get_destination_radius()
  return (self.destination and self.destination.get_radius and self.destination.get_radius() + self.radius) or self.radius
end

local flags = {cache = false, allow_destroy_friendly_entities = false, prefer_straight_paths = true, no_break = true}

function Moving_vehicle:request_path()
  if self.path_request_index then return end
  local entity = self.character.entity.vehicle
  local destination = self:get_destination()
  local radius = self:get_destination_radius()
  --error(serpent.block(destination))
  local r = entity.get_radius() * 1.2

  self.path_request_index = entity.surface.request_path(
  {
    bounding_box = {{-r, -r},{r, r}},
    collision_mask = entity.prototype.collision_mask,
    start = entity.position,
    goal = destination,
    --force = entity.force,
    force = "neutral",
    radius = radius,
    can_open_gates = true,
    path_resolution_modifier = -3,
    pathfind_flags = flags,
    entity_to_ignore = entity
  })

  self.requested_destination = destination
  self.character:print("Requested a path. ")
end

function Moving_vehicle:finish()
  if self.character.entity.vehicle then
    self.character.entity.vehicle.riding_state = {acceleration = defines.riding.acceleration.braking, direction = defines.riding.direction.straight}
  end
  self.character:pop_state()
  self:cleanup()
end

function Moving_vehicle:move_to_next_node()
  local node = self.path[1]
  --self.character:print("Reached a waypoint.")
  table.remove(self.path, 1)
  if node.rendering then
    rendering.destroy(node.rendering)
    node.rendering = nil
  end
  self.total_distance = self.total_distance - (node.distance_to_next or 0)
  self:render_path_to_node()
end

function Moving_vehicle:render_path_to_node()
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

local get_orientation_to = util.get_orientation_to

function Moving_vehicle:follow_path()

  local vehicle = self.character.entity.vehicle
  local position = vehicle.position
  local rotation_speed = vehicle.prototype.rotation_speed
  local speed = vehicle.speed
  if vehicle.prototype.tank_driving then
    --rotation_speed = rotation_speed ^ 0.5
    rotation_speed = rotation_speed * 1.75
  else
    --rotation_speed = rotation_speed * (speed ^ 0.5)
  end
  local vehicle_orientation = vehicle.orientation
  local distance_to_node
  local node
  local target_orientation
  local orientation_diff
  while true do
    node = self.path[1]
    if not node then
      self:finish()
      return
    end
    distance_to_node = util.distance(position, node.position)
    target_orientation = get_orientation_to(position, node.position)

    orientation_diff = (target_orientation - vehicle_orientation)
    local diff = math.abs(orientation_diff)
    if diff > 0.5 then diff = math.abs(diff - 1) end

    local turn = (node.orientation_to_next or vehicle_orientation) - vehicle_orientation
    turn = math.abs(turn)
    if turn > 0.5 then turn = -turn + 1 end

    local change = math.max(diff, turn)
    local bend_radius = ((change / rotation_speed) * speed)
    --local ticks = 1 + math.ceil(diff / rotation_speed)
    --local turn_distance = math.max(ticks * speed, --[[15 * speed]] 1)
    local turn_distance = math.max(bend_radius, 2)

    --[[

      rendering.draw_circle
      {
        color={r = 1, g = 1, b = 0},
        radius=bend_radius,
        width=3,
        filled=false,
        target=position,
        surface = vehicle.surface,
        time_to_live = 2
      }
      ]]

    if distance_to_node < turn_distance then
      self:move_to_next_node()
    else
      break
    end
  end

  local total_orientation_diff = math.abs(orientation_diff)

  local acceleration = defines.riding.acceleration.accelerating

  local direction = defines.riding.direction.straight
  if speed > 0.1 and (speed * 60) > (self.total_distance + distance_to_node) then
    acceleration = defines.riding.acceleration.braking
  end

  if math.abs(orientation_diff) < vehicle.prototype.rotation_speed then
    vehicle.orientation = target_orientation
  else
    orientation_diff = orientation_diff % 1
    if orientation_diff > 0.5 then orientation_diff = orientation_diff - 1 end
    if orientation_diff > 0 then
      direction = defines.riding.direction.right
    else
      direction = defines.riding.direction.left
    end
  end

  vehicle.riding_state = {acceleration = acceleration, direction = direction}

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

function Moving_vehicle:check_path()
  --This is for the case where we are moving to an entity that might have moved!
  if not self.destination.position then return end
  if not self.requested_destination then return end

  local destination = self:get_destination()
  if rect_dist(destination, self.requested_destination) < 4 then return end

  if util.distance(self.character:get_position(), destination) < self.radius then
    return true
  end

  --Request a new path, but keep walking along the old as its probably its in the right direction still.
  self.character:print("Target moved, recalculating path")
  self:request_path()

end

function Moving_vehicle:clear_obstacles(position)
end

function Moving_vehicle:check_stuck()
  if not (self.path and self.path[1]) then return end

  local node = self.path[1]

  if node == self.last_stuck_node then
    self.character.entity.vehicle.orientation = get_orientation_to(self.character.entity.vehicle.position, node.position)
  end

  self.last_stuck_node = node

end

function Moving_vehicle:update()

  if not self.destination.valid then
    self:finish()
    return
  end

  if not (self.character.entity.vehicle) then
    self:finish()
    return
  end

  if self.character:update_every_n_ticks(300) then
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

    if self.character:distance(self.destination) <= (self.radius + 7.5) then
      self:finish()
      return
    end

    self:request_path()
    return
  end

  self:follow_path()

end

local remove = table.remove

function Moving_vehicle:on_path_recieved(event)

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

  local self_position = self.character:get_position()
  local dist_to_dest = util.distance(self_position, destination)

  for k, node in pairs (path) do
    local next = path[k + 1]
    if not next then break end

    local distance = util.distance(node.position, destination)
    if distance > util.distance(next.position, destination) and distance > dist_to_dest then
      remove(path, k)
    else
      break
    end
  end

  local total = 0
  for k, node in pairs (path) do
    local next = path[k + 1]
    if not next then break end
    node.distance_to_next = util.distance(node.position, next.position)
    node.orientation_to_next = get_orientation_to(node.position, next.position)
    total = total + node.distance_to_next
  end

  for k = (#path), 1, -1 do
    local node = path[k]
    local next = path[k - 1]
    if not (node and next) then break end

    if node.orientation_to_next == next.orientation_to_next then
      next.distance_to_next = next.distance_to_next + node.distance_to_next
      remove(path, k)
    end
  end

  self.total_distance = total

  self:clear_path()
  self.path = event.path
  self:render_path()
end

function Moving_vehicle:on_script_path_request_finished(event)
  if event.name == defines.events.on_script_path_request_finished then
    if event.id == self.path_request_index then
      self:on_path_recieved(event)
    end
  end
end


return setmetatable(Moving_vehicle, {__call = function(this, ...) return Moving_vehicle.new(...) end})