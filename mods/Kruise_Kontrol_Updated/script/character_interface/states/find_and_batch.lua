local Find_and_batch = {}

Find_and_batch.metatable = {__index = Find_and_batch}

function Find_and_batch.new(Character, job_type, param)
  local state =
  {
    type = "find_and_batch",
    character = Character,
    job_type = job_type,
    param = param,
    fail_cache = {}
  }
  return setmetatable(state, Find_and_batch.metatable)
end

function Find_and_batch:finish()
  self.character:pop_state()
end

local index = function(entity)
  return entity.unit_number or script.register_on_entity_destroyed(entity)
end

function Find_and_batch:find()
  local entities = self.character:find_nearby_entities(self.param.radius or 64, self.param)

  if self.job_type == "repair" then
    for k, entity in pairs (entities) do
      if not (entity.get_health_ratio() and entity.get_health_ratio() < 1) then
        entities[k] = nil
      end
    end
  end

  if self.job_type == "fuel" then
    for k, entity in pairs (entities) do
      if not entity.burner then
        entities[k] = nil
      end
    end
  end

  if self.job_type == "mine" then
    for k, entity in pairs (entities) do
      if entity.type == "deconstructible-tile-proxy" then
        entities[k] = nil
      end
    end
  end

  local fail_cache = self.fail_cache
  for k, entity in pairs (entities) do
    local key = index(entity)
    if fail_cache[key] then
      entities[k] = nil
    else
      fail_cache[key] = true
    end
  end

  return entities
end

function Find_and_batch:update()

  local entities = self:find()
  if not next(entities) then
    self:finish()
    return
  end

  self.character:batch_job(self.job_type, entities)

end

return setmetatable(Find_and_batch, {__call = function(this, ...) return Find_and_batch.new(...) end})