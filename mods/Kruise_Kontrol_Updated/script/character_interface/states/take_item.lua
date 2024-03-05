local Take_item = {}

Take_item.metatable = {__index = Take_item}

function Take_item.new(Character, target, name, count)
  local state =
  {
    type = "take_item",
    character = Character,
    target = target or error("No target?"),
    name = name,
    count = count
  }
  return setmetatable(state, Take_item.metatable)
end

function Take_item:fail()
  self.character:pop_state()
end

function Take_item:succeed()
  self.character:pop_state()
end

function Take_item:update()
  if not self.target.valid then
    self:fail()
    return
  end

  if not self.character:can_reach_entity(self.target) then
    --We are out of range, move to range
    self.character:move_to(self.target, self.character:get_reach_distance())
    return
  end

  -- we are in range of the pickup target
  self.character.direction = self.character:get_direction_to(self.target)

  local inventory = self.target.get_output_inventory()
  if not inventory then return end


  local stack = inventory.find_item_stack(self.name)
  if not stack then
    self:fail()
    return
  end

  local count = self.character:take_item_stack(stack, self.count, self.target)
  self.count = self.count - count

  if self.count <= 0 then
    self:succeed()
    self.character:print("We have enough of the item "..self.name)
  end


end

return setmetatable(Take_item, {__call = function(this, ...) return Take_item.new(...) end})