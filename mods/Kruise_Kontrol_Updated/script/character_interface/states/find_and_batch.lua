local Find_and_batch = {}

Find_and_batch.metatable = { __index = Find_and_batch }

function Find_and_batch.new(Character, job_type, param)
    local state =
    {
        type = "find_and_batch",
        character = Character,
        job_type = job_type,
        param = param,
        max_radius = param.radius or 64,
        fail_cache = {}
    }
    return setmetatable(state, Find_and_batch.metatable)
end

function Find_and_batch:finish()
    self.character:pop_state()
end

-- Key for the "already tried" cache. Entities without a unit number (trees, rocks, resources)
-- do not move, so name + position identifies them without registering every one of them
-- with script.register_on_object_destroyed.
local entity_key = function(entity)
    local unit_number = entity.unit_number
    if unit_number then return unit_number end
    local position = entity.position
    return entity.name .. "@" .. position.x .. "," .. position.y
end

local job_filters =
{
    repair = function(entity)
        local ratio = entity.get_health_ratio()
        return ratio and ratio < 1
    end,
    fuel = function(entity)
        return entity.burner ~= nil
    end,
    mine = function(entity)
        return entity.type ~= "deconstructible-tile-proxy"
    end,
}

-- Search near the character first and widen only when nothing new is found nearby.
-- Jobs are processed nearest-first anyway, so this keeps batches small instead of
-- collecting thousands of entities in a radius of 64 at once.
local search_radii = { 8, 16, 32 }

function Find_and_batch:find_in_radius(radius)
    local entities = self.character:find_nearby_entities(radius, self.param)
    local filter = job_filters[self.job_type]
    local fail_cache = self.fail_cache
    local result = {}
    local count = 0
    for _, entity in pairs(entities) do
        if (not filter or filter(entity)) and not fail_cache[entity_key(entity)] then
            count = count + 1
            result[count] = entity
        end
    end
    return result, count
end

function Find_and_batch:find()
    if not self.max_radius then
        -- States from older saves.
        self.max_radius = self.param.radius or 64
    end
    local max_radius = self.max_radius

    local result, count
    for _, radius in ipairs(search_radii) do
        if radius >= max_radius then break end
        result, count = self:find_in_radius(radius)
        if count > 0 then break end
    end
    if not count or count == 0 then
        result, count = self:find_in_radius(max_radius)
    end

    local fail_cache = self.fail_cache
    for k = 1, count do
        fail_cache[entity_key(result[k])] = true
    end

    return result
end

function Find_and_batch:update()
    local entities = self:find()
    if not next(entities) then
        self:finish()
        return
    end

    self.character:batch_job(self.job_type, entities)
end

return setmetatable(Find_and_batch, { __call = function(this, ...) return Find_and_batch.new(...) end })
