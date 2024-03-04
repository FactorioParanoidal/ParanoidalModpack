local Combat = {}

Combat.metatable = {__index = Combat}

function Combat.new(Character, target_position, radius)
  local state =
  {
    type = "combat",
    character = Character,
    target_position = target_position,
    radius = radius or 64
  }
  return setmetatable(state, Combat.metatable)
end

function Combat:finish()
  self.character:pop_state()
end

function Combat:find_target()
  local nearby = self.character:nearest_enemy(self.radius)
  if nearby then
    return nearby
  end

  local target = self.character:nearest_enemy(self.radius, self.target_position)
  if target then return target end


end

function Combat:update()

  local target = self:find_target()
  if not target then
    self:finish()
    return
  end

  if self.character.entity.get_health_ratio() <= 0.5 then
    if self.character:distance(target) >= 100 then
      self.character.entity.walking_state = {walking = false}
      return
    end
    local direction = self.character:get_direction_to(target)
    direction = (direction + defines.direction.south) % (defines.direction.south * 2)
    self.character.entity.walking_state = {walking = true, direction = direction}
    return
  end

  self.character:attack(target, 100)

end

return setmetatable(Combat, {__call = function(this, ...) return Combat.new(...) end})