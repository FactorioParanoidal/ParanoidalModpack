local util = require("script/character_script_util")
local Follow = {}

Follow.metatable = {__index = Follow}

function Follow.new(Character, target, distance)
  local state =
  {
    type = "follow",
    character = Character,
    target = target or error("Нет цели?"),
    distance = distance or 3
  }
  return setmetatable(state, Follow.metatable)
end

function Follow:cleanup()
  self.character.entity.walking_state = {walking = false}
end

function Follow:finish()
  self:cleanup()
  self.character:pop_state()
end

function Follow:update()
  if not self.target.valid or self.target.surface ~= self.character.entity.surface then
    self:finish()
    return
  end

  if util.distance(self.character:get_position(), self.target.position) > self.distance then
    --We are out of range, move to range
    if not self.character:approach(self.target, self.distance - 1) then self:finish() end
    return
  end

  self.approach_result = nil
  if self.target.type == "character" then
    self.character.entity.walking_state = self.target.walking_state
  end

end

return setmetatable(Follow, {__call = function(this, ...) return Follow.new(...) end})