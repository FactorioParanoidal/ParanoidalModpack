local util = require("script/character_script_util")
local Build_ghost = {}

Build_ghost.metatable = {__index = Build_ghost}

function Build_ghost.new(Character, target)
  local state =
  {
    type = "build_ghost",
    character = Character,
    target = target or error("No target?"),
    check_index = nil
  }
  return setmetatable(state, Build_ghost.metatable)
end

local items_to_place = {}

local function get_items_to_place(entity)
  local name = entity.ghost_name
  if items_to_place[name] then
    return items_to_place[name]
  end
  if entity.type == "entity-ghost" then
    items_to_place[name] = game.entity_prototypes[name].items_to_place_this
  elseif entity.type == "tile-ghost" then
    items_to_place[name] = game.tile_prototypes[name].items_to_place_this
  end
  return items_to_place[name]
end

function Build_ghost:fail()
  self.character:pop_state()
end

function Build_ghost:succeed()
  self.character:pop_state()
  self.character:wait(5)
end

function Build_ghost:clear_obstacles()
  local box = self.target.bounding_box
  local entities = self.target.surface.find_entities_filtered{area = box, collision_mask = self.target.ghost_prototype.collision_mask}
  if next(entities) == nil then
    local box2 = {left_top = {x = box.left_top.x - 1, y = box.left_top.y - 1}, right_bottom = {x = box.right_bottom.x + 1, y = box.right_bottom.y + 1}}
    entities = self.target.surface.find_entities_filtered{area = box2, collision_mask = self.target.ghost_prototype.collision_mask, to_be_deconstructed = true}
  end

  for k, entity in pairs (entities) do
    if entity.type == "cliff" then
      local i = -1
      for j, state in pairs (self.character.state_stack) do
        if state.type == "build_ghost" then
            i = j
            break
        end
      end

      if i ~= -1 then
        table.remove(self.character.state_stack, i)
      end

      for j = i - 2, 1, -1 do
        table.remove(self.character.state_stack, j)
      end

      self.character:update()
      return
    end

    if entity == self.character.entity then
      local surface = entity.surface
      for k, x in pairs({box.left_top.x - 1, box.right_bottom.x + 1}) do
        for y = box.left_top.y - 1, box.right_bottom.y + 1, 1 do
          if surface.can_place_entity{name = entity.name,position = {x, y}} then
            self.character:move_to({x, y}, 0.25)
            return
          end
        end
      end
      for k, y in pairs({box.left_top.y - 1, box.right_bottom.y + 1}) do
        for x = box.left_top.x - 1, box.right_bottom.x + 1, 1 do
          if surface.can_place_entity{name = entity.name,position = {x, y}} then
            self.character:move_to({x, y}, 0.25)
            return
          end
        end
      end
    elseif entity ~= self.target then
      self.character:mine(entity)
    end
  end
end

function Build_ghost:clear_trees(entities)
  local box = self.target.bounding_box
  for k, entity in pairs (entities) do
    self.character:mine(entity)
  end
end

local ghost_type =
{
  ["entity-ghost"] = true,
  ["tile-ghost"] = true
}

local revive_opts =
{
  raise_revive = true
}
function Build_ghost:update()
  if not self.target.valid then
    self:fail()
    return
  end

  if not ghost_type[self.target.type] then
    error("Non-ghost given to build ghost order?")
  end

  if not self.item or not self.character:has_item(self.item.name, self.item.count) then
    self.check_index, self.item = next(get_items_to_place(self.target), self.check_index)
  end

  if not self.item then
    self:fail()
    return
  end

  if not self.character:has_item(self.item.name, self.item.count) then
    self.character:find_item(self.item.name, self.item.count)
    return
  end

  if self.character:distance(self.target) > self.character:get_build_distance() then
    self.character:move_to(self.target, self.character:get_build_distance() - (self.target.get_radius() + 0.5))
    return
  end

  self.character.entity.direction = self.character:get_direction_to(self.target)

  local entities = self.target.surface.find_entities_filtered{type = "tree", position = self.target.position, radius = self.target.get_radius() + 3, to_be_deconstructed = false}
  if next(entities) ~= nil then
    self:clear_trees(entities)
	return
  end

  local success, revive_entity = self.target.revive(revive_opts)
  if not success then
    self:clear_obstacles()
    return
  end

  self.character:remove_item(self.item.name, self.item.count)
  self:succeed()
  --[[
    if revive_entity and revive_entity.burner then
      self.character:fuel_entity(revive_entity)
    end
    ]]
end

return setmetatable(Build_ghost, {__call = function(this, ...) return Build_ghost.new(...) end})