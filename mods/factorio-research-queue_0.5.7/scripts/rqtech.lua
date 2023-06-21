local util = require('.util')

local rqtech = {}

function rqtech.init()
  global.rqtechs = {}
end

function rqtech.init_force(force)
  global.rqtechs[force.index] = {}
end

function rqtech.deinit_force(force)
  global.rqtechs[force.index] = nil
end


-- create rqtech struct: id, tech, level, upgradegroup, infinite, unitcount, prerequisites
function rqtech.new(tech, level, offset)
  if offset == nil then offset = 0 end
  local infinite = tech.research_unit_count_formula ~= nil

  local level_from_name = string.match(tech.name, '-(%d+)$')
  if level_from_name ~= nil then
    level_from_name = tonumber(level_from_name)
  elseif infinite then
    level_from_name = 1
  end
  if level == nil then
    level = level_from_name
  elseif level == 'current' or level == 'previous' or level == 'max' then
    if infinite then
      if level == 'current' then
        level = tech.level + offset
      elseif level == 'previous' then
        if tech.researched then
          level = tech.level + offset
        else
          level = tech.level - 1 + offset
        end
      elseif level == 'max' then
        level = tech.prototype.max_level
      else
        error(string.format('unknown infinite level spec %s', level))
      end
    else
      level = level_from_name
    end
  end
  if level ~= nil then
    if level_from_name == nil then
      error(string.format('%s: level (%d) given with no level in name', tech.name, level))
    end
    assert(level >= level_from_name, string.format('%s: level (%d) < level from name (%d)', tech.name, level, level_from_name))
    assert(level <= tech.prototype.max_level, string.format('%s: level (%d) > ,max level (%d)', tech.name, level, tech.prototype.max_level))
  else
    if level_from_name ~= nil then
      error(string.format('%s: no level given with level in name (%d)', tech.name, level_from_name))
    end
  end

  local id
  if level == nil then
    id = tech.name
  else
    id = string.format('%s:%s', tech.name, level)
  end

  local cached_rqtech = global.rqtechs[tech.force.index][id]
  if cached_rqtech ~= nil then
    return cached_rqtech
  end

  local upgrade_group
  do
    local level_tail = string.find(tech.name, '-%d+$')
    if level_tail ~= nil then
      upgrade_group = string.sub(tech.name, 1, level_tail - 1)
    else
      upgrade_group = tech.name
    end
  end

  local research_unit_count
  if infinite then
    research_unit_count = game.evaluate_expression(tech.research_unit_count_formula, { L = level, l = level })
  else
    research_unit_count = tech.research_unit_count
  end

  local prerequisites
  if level ~= level_from_name then
    prerequisites = { [tech.name] = rqtech.new(tech, level - 1) }
  else
    prerequisites = {}
    for name, prerequisite in pairs(tech.prerequisites) do
      if
        prerequisite.research_unit_count_formula ~= nil and
        prerequisite.prototype.max_level == 4294967295
      then
        -- prerequisite is an infinite tech with "infinite" max level
        -- this tech is unresearchable
        -- but just ignore the prerequisite for IRQ
        log(string.format('WARNING: %s is unresearchable! It has %s as a prerequisite, which is infinite with no max level. The prerequisite will be ignored in Improved Research Queue.', tech.name, prerequisite.name))
      else
        prerequisites[name] = rqtech.new(prerequisite, 'max')
      end
    end
  end

  local t = {
    id = id,
    tech = tech,
    level = level,
    upgrade_group = upgrade_group,
    infinite = infinite,
    research_unit_count = research_unit_count,
    prerequisites = prerequisites,
  }
  global.rqtechs[tech.force.index][id] = t
  return t
end

-- rqtech struct from tech id
function rqtech.from_id(force, id)
  local cached_rqtech = global.rqtechs[force.index][id]
  if cached_rqtech ~= nil then
    return cached_rqtech
  end
  local tech, level = string.match(id, '^(.+):(%d+)$')
  if tech ~= nil then
    tech = force.technologies[tech]
    level = tonumber(level)
  else
    tech = force.technologies[id]
    level = nil
  end
  if tech == nil then return nil end
  return rqtech.new(tech, level)
end

-- iterate over all rqtechs
function rqtech.iter(force)
  return util.iter_map(
    util.iter_values(force.technologies),
    rqtech.new)
end

-- progress from rqtech
function rqtech.progress(tech)
  local force = tech.tech.force
  if
    force.current_research ~= nil and
    force.current_research.name == tech.tech.name and
    (tech.level == nil or force.current_research.level == tech.level)
  then
    return force.research_progress
  elseif not tech.infinite or tech.tech.level == tech.level then
    return force.get_saved_technology_progress(tech.tech) or 0
  else
    return 0
  end
end

-- status from rqtech
function rqtech.is_researched(tech)
  if tech.tech.researched then
    return true
  end
  if tech.infinite then
    if tech.tech.level > tech.level then
      return true
    end
  end
  return false
end

return rqtech
