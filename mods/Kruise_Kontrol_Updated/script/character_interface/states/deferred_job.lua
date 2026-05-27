local Deferred_job = {}

Deferred_job.metatable = {__index = Deferred_job}

function Deferred_job.new(Character, position, entity)
  local state =
  {
    type = "Deferred_job",
    character = Character,
    position = position,
    entity = entity
  }
  return setmetatable(state, Deferred_job.metatable)
end

function Deferred_job:finish()

end

function Deferred_job:update()

  self.character:pop_state()
  self.character:determine_job(self.entity, self.position)
  
end

return setmetatable(Deferred_job, {__call = function(this, ...) return Deferred_job.new(...) end})