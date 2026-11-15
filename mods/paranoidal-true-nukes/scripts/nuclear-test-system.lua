-- Nuclear tests (Paranoidal 9.0.0, variant A): a detonation in a test site counts for its force;
-- a technology with a "scripted" trigger listed in prototypes/nukes/nuclear-tests.lua is researched once
-- all its detonations are counted and its prerequisites are researched (checked again whenever a
-- research finishes). storage.nuclearTests[force index][detonation item name] = count.
local tests = require("__paranoidal-true-nukes__.prototypes.nukes.nuclear-tests")

local function counts(force)
  storage.nuclearTests = storage.nuclearTests or {}
  storage.nuclearTests[force.index] = storage.nuclearTests[force.index] or {}
  return storage.nuclearTests[force.index]
end

local function reevaluate(force)
  local done = counts(force)
  for tech_name, detonations in pairs(tests) do
    local tech = force.technologies[tech_name]
    local trigger = tech and tech.prototype.research_trigger
    if tech and not tech.researched and trigger and trigger.type == "scripted" then
      local ready = true
      for _, d in pairs(detonations) do
        if (done[d] or 0) < 1 then ready = false break end
      end
      if ready then
        for _, pre in pairs(tech.prerequisites) do
          if not pre.researched then ready = false break end
        end
      end
      if ready then force.script_trigger_research(tech_name) end
    end
  end
end

local function testDetonation(force, detonation_name)
  local done = counts(force)
  done[detonation_name] = (done[detonation_name] or 0) + 1
  reevaluate(force)
end

local function count(force_index, detonation_name)
  local f = storage.nuclearTests and storage.nuclearTests[force_index]
  return f and f[detonation_name] or 0
end

script.on_event(defines.events.on_research_finished, function(event)
  reevaluate(event.research.force)
end)

return {testDetonation = testDetonation, reevaluate = reevaluate, count = count}
