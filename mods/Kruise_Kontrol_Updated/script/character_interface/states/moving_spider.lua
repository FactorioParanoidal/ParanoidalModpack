local util = require("script/character_script_util")
local Moving_spider = {}

Moving_spider.metatable = {__index = Moving_spider}

function Moving_spider.new(Character, destination, radius)
  if not destination.valid then
    --For position type hacks.
    destination.valid = true
  end

  local state =
  {
    type = "moving_spider",
    character = Character,
    spider = Character.entity.vehicle,
    destination = destination or error("No destination given for creating a moving state."),
    radius = radius or 0.5
  }
  return setmetatable(state, Moving_spider.metatable)
end

function Moving_spider:cleanup()
end

function Moving_spider:get_destination()
  --Since destination can be either an entity or a position directly...
  return (self.destination and self.destination.position) or {self.destination[1], self.destination[2]}
end

function Moving_spider:get_destination_radius()
  return (self.destination and self.destination.get_radius and self.destination.get_radius() + self.radius) or self.radius
end

local spider_mask = {"colliding-with-tiles-only", "water-tile"}
local flags = {cache = false, allow_destroy_friendly_entities = false, prefer_straight_paths = true, no_break = true}
function Moving_spider:request_path()
  if self.path_request_index then return end
  local entity = self.spider
  local destination = self:get_destination()
  local radius = self:get_destination_radius()
  --error(serpent.block(destination))

  self.path_request_index = entity.surface.request_path(
  {
    bounding_box = entity.prototype.collision_box,
    collision_mask = spider_mask,
    start = entity.position,
    goal = destination,
    force = entity.force,
    radius = radius,
    can_open_gates = true,
    path_resolution_modifier = -3,
    pathfind_flags = flags,
    entity_to_ignore = entity
  })

  self.requested_destination = destination
  self.character:print("Requested a path. ")
end

function Moving_spider:finish()
  self.character:pop_state()
  self:cleanup()
end

function Moving_spider:update()

  if not self.destination.valid then
    self:finish()
    return
  end

  if not (self.spider and self.spider.valid and self.spider.type == "spider-vehicle") then
    self:finish()
    return
  end

  self:request_path()

end

local remove = table.remove

function Moving_spider:on_path_recieved(event)

  if not self.destination.valid then
    self:finish()
    return
  end

  if not (self.spider and self.spider.valid and self.spider.type == "spider-vehicle") then
    self:finish()
    return
  end

  --self.path_request_index = nil
  --self.character:print("Path request finished")
  local path = event.path
  if not path then
    self:finish()
    return
  end

  for k, node in pairs (path) do
    local next = path[k + 1]
    if not next then break end
    node.orientation_to_next = util.get_orientation_to(node.position, next.position)
  end

  for k = (#path), 1, -1 do
    local node = path[k]
    local next = path[k - 1]
    if not (node and next) then break end

    if node.orientation_to_next == next.orientation_to_next then
      remove(path, k)
    end
  end

  self.spider.autopilot_destination = nil
  local add = self.spider.add_autopilot_destination
  for k, node in pairs (event.path) do
    add(node.position)
  end

  self:finish()
end

function Moving_spider:on_script_path_request_finished(event)
  if event.name == defines.events.on_script_path_request_finished then
    if event.id == self.path_request_index then
      self:on_path_recieved(event)
    end
  end
end

return setmetatable(Moving_spider, {__call = function(this, ...) return Moving_spider.new(...) end})
