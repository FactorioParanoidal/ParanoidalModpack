local Take_item_from_belt = {}

Take_item_from_belt.metatable = {__index = Take_item_from_belt}

function Take_item_from_belt.new(Character, target, name, count)
  local state =
  {
    type = "take_item_from_belt",
    character = Character,
    target = target or error("Нет цели?"),
    name = name,
    count = count
  }
  return setmetatable(state, Take_item_from_belt.metatable)
end

function Take_item_from_belt:cleanup()
  self.character.entity.picking_state = false
end

function Take_item_from_belt:finish()
  self:cleanup()
  self.character:pop_state()
end

function Take_item_from_belt:update()

  if not self.target.valid then
    self:finish()
    return
  end

  local distance = self.character:get_slurp_distance()
  if not (self.character:distance(self.target) < distance) then
    --We are out of range, move to range
    self:cleanup()
    if not self.character:approach(self.target, distance / 2) then self:finish() end
    return
  end

  -- we are in range of the belt, start slurping.
  self.approach_result = nil
  self.character.entity.picking_state = true
  self.tick_of_last_diff = self.tick_of_last_diff or game.tick

  local item_count = self.character:get_item_count(self.name)
  if self.last_count then
    local diff = (item_count - self.last_count)
    if diff > 0 then
      self.count = self.count - diff
      self.tick_of_last_diff = game.tick
    end
  end
  self.last_count = item_count

  if self.count <= 0 or game.tick - self.tick_of_last_diff > 60 then
    self:finish()
  end

end

return setmetatable(Take_item_from_belt, {__call = function(this, ...) return Take_item_from_belt.new(...) end})