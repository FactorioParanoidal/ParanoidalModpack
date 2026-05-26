local Batch_job = {}

Batch_job.metatable = {__index = Batch_job}

function Batch_job.new(Character, job_type, entities)
  local state =
  {
    type = "batch_job",
    character = Character,
    job_type = job_type,
    entities = entities
  }
  return setmetatable(state, Batch_job.metatable)
end

function Batch_job:finish()
  self.character:pop_state()
end


function Batch_job:get_next_target()

  for k, entity in pairs (self.entities) do
    if not (entity.valid) then
      self.entities[k] = nil
    elseif entity == self.target then
      self.entities[k] = nil
    end
  end

  if not next(self.entities) then
    return
  end

  return self.character.entity.surface.get_closest(self.character:get_position(), self.entities)
end

function Batch_job:update()

  self.target = self:get_next_target()
  if not self.target then
    self:finish()
    return
  end

  if self.job_type == "fuel" then
    self.character:fuel_entity(self.target)
  elseif self.job_type == "build" then
    self.character:build_ghost(self.target)
  elseif self.job_type == "mine" then
    self.character:mine(self.target, -1)
  elseif self.job_type == "attack" then
    self.character:attack(self.target)
  elseif self.job_type == "repair" then
    self.character:repair(self.target)
  elseif self.job_type == "upgrade" then
    self.character:upgrade(self.target)
  else
    error("Unknown batch job type "..self.job_type)
  end


end

return setmetatable(Batch_job, {__call = function(this, ...) return Batch_job.new(...) end})