local Repair = {}

Repair.metatable = {__index = Repair}

function Repair.new(Character, target, distance)
  local state =
  {
    type = "repair",
    character = Character,
    target = target or error("No target?"),
  }
  return setmetatable(state, Repair.metatable)
end

function Repair:finish()
  self.character:clear_cursor()
  self.character:pop_state()
end

local repair_tools

local get_repair_tools = function()
  if repair_tools then return repair_tools end
  repair_tools = {}
  for name, item in pairs (game.item_prototypes) do
    if item.speed then
      repair_tools[name] = true
    end
  end
  return repair_tools
end

function Repair:prepare_tool()
  --if self.cursor_prepared then return true end
  local cursor = self.character.entity.cursor_stack
  if cursor.valid_for_read and get_repair_tools()[cursor.name] then
    self.cursor_prepared = true
    return true
  end
  local main_inventory = self.character.entity.get_main_inventory()
  for name, bool in pairs (get_repair_tools()) do
    local stack = main_inventory.find_item_stack(name)
    if stack then
      stack.swap_stack(cursor)
      self.cursor_prepared = true
      return true
    end
  end
  return false
end

function Repair:update()

  if not self.target.valid then
    --He died lol
    self:finish()
    return
  end

  if not self:prepare_tool() then
    self.search_tool = next(get_repair_tools(), self.search_tool)

    if not self.search_tool then
      self:finish()
      return
    end

    self.character:find_item(self.search_tool, 1)
    return

  end

  if not self.character:can_reach_entity(self.target) then
    --We are out of range, move to range
    self.character:move_to(self.target, self.character:get_repair_distance())
    return
  end

  if self.target.get_health_ratio() >= 1 then
    --He is healthy!
    self:finish()
    return
  end

  self.character.entity.update_selected_entity(self.target.position)
  self.character.entity.repair_state = {repairing = true, position = self.target.position}

end

return setmetatable(Repair, {__call = function(this, ...) return Repair.new(...) end})