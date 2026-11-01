-- Blueprint Sandboxes, shared by the milestones and the achievements: nothing done in a lab counts.
-- Its forces are "bpsb-sb-..." (the sandbox force of force F is "bpsb-sb-f-F"), its lab surfaces
-- "bpsb-lab-...". Without the mod nothing is a sandbox.

local sandbox = {}

local FORCE_PREFIX = "bpsb-sb-"
local SURFACE_PREFIX = "bpsb-lab-"
local PARENT_PATTERN = "^bpsb%-sb%-f%-(.+)$"

local active = script.active_mods["blueprint-sandboxes"] ~= nil
sandbox.active = active

function sandbox.is_force_name(name)
  return active and string.sub(name, 1, #FORCE_PREFIX) == FORCE_PREFIX
end

function sandbox.is_surface_name(name)
  return active and string.sub(name, 1, #SURFACE_PREFIX) == SURFACE_PREFIX
end

function sandbox.is_force(force)
  return active and force ~= nil and force.valid and sandbox.is_force_name(force.name)
end

function sandbox.is_surface(surface)
  return active and surface ~= nil and surface.valid and sandbox.is_surface_name(surface.name)
end

-- Name of the real force of a sandbox force name, or nil.
function sandbox.parent_name(name)
  if not active then return nil end
  return string.match(name, PARENT_PATTERN)
end

-- The sandbox force of a real force, or nil.
function sandbox.force_of(force)
  if not active then return nil end
  return game.forces[FORCE_PREFIX .. "f-" .. force.name]
end

return sandbox
