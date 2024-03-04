local Put_item = {}

Put_item.metatable = {__index = Put_item}

function Put_item.new(Character, target, name, count)
  assert(count > 0)
  local state =
  {
    type = "put_item",
    character = Character,
    target = target or error("No target?"),
    name = name,
    count = count
  }
  return setmetatable(state, Put_item.metatable)
end

function Put_item:fail()
  self.character:pop_state()
end

function Put_item:succeed()
  self.character:pop_state()
end

function Put_item:update()

  if not self.target.valid then
    self:fail()
    return
  end

  if not self.character:has_item(self.name, self.count) then
    --We don't even have the item, so fail.
    self:fail()
    return
  end

  if not self.character:can_reach_entity(self.target) then
    --We are out of range, move to range
    self.character:move_to(self.target, self.character:get_reach_distance())
    return
  end

  -- we are in range of the put target
  self.character:look_at(self.target)

  local given = self.character:give_item(self.name, self.count, self.target)
  if given == 0 then
    self:fail()
    return
  end

  self.count = self.count - given
  --If we can't put it all anyway, we would fail, idk.
  self:succeed()


end

return setmetatable(Put_item, {__call = function(this, ...) return Put_item.new(...) end})