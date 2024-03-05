local Idle =
{
  type = "idle"
}

Idle.metatable = {__index = Idle}

function Idle.new(Character, ticks_to_wait)
  local idle_state =
  {
    type = Idle.type,
    character = Character,
    finish_tick = game.tick + ticks_to_wait
  }
  return setmetatable(idle_state, Idle.metatable)
end

function Idle:update()
  if game.tick > self.finish_tick then
    self:succeed()
  end
end

function Idle:succeed()
  self.character:pop_state()
end

return setmetatable(Idle, {__call = function(this, ...) return Idle.new(...) end})