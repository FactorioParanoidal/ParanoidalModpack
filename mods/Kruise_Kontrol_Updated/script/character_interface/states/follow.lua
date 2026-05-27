local Follow = {}

Follow.metatable = {__index = Follow}

function Follow.new(Character, target, distance)
  local state =
  {
    type = "follow",
    character = Character,
    target = target or error("No target?"),
    distance = distance or 3
  }
  return setmetatable(state, Follow.metatable)
end

function Follow:finish()
  self.character:pop_state()
end

function Follow:update()

  if not (self.target.valid) then
    self:finish()
    return
  end

  if util.distance(self.character:get_position(), self.target.position) > self.distance then
    --We are out of range, move to range
    self.character:move_to(self.target, self.distance - 1)
    return
  end

  if self.target.type == "character" then
    self.character.entity.walking_state = self.target.walking_state
  end

end

return setmetatable(Follow, {__call = function(this, ...) return Follow.new(...) end})