local State = {}

State.metatable = {__index = State}

function State.new(Character, target)
  local state =
  {
    type = "follow",
    character = Character,
    target = target or error("No target?")
  }
  return setmetatable(state, State.metatable)
end

function State:finish()
  self.character:pop_state()
end

function State:update()

  if not (self.target.valid) then
    self:finish()
    return
  end

end

return setmetatable(State, {__call = function(this, ...) return State.new(...) end})