-- Load other libraries
local constants = require("constants")

---@type boolean
local debug_log = settings.global[constants.ENABLE_DEBUG_LOG_KEY].value

-- All planets from official mod "Space Age"
---@typpe table<string, boolean>
local sa_planets = {
  ["nauvis"]   = true,
  ["gleba"]    = true,
  ["fulgora"]  = true,
  ["vulcanus"] = true,
  ["aquilo"]   = true
}

-- Init "class" / library
local planets = {}

-- Creates a key for given planet name plus a suffix depending on if the
-- planet is part of SA ("official") or not ("custom")
---@param name string
---@return string
function planets.create_key(name)
  if debug_log then log(string.format("[create_key]: name[]='%s' - CALLED!", type(name))) end
  if type(name) ~= "string" then
    error(string.format("Parameter name[]='%s' is not expected type 'string'", type(name)))
  elseif #name == 0 then
    error("Parameter 'name' cannot be an empty string!")
  end

  -- By default all planets are "official"
  local suffix = "official"

  if debug_log then log(string.format("[create_key]: sa_planets[%s][]='%s'", name, type(sa_planets[name]))) end
  if sa_planets[name] == nil then
    -- No SA (official mod) planet
    suffix = "custom"
  end
  if debug_log then log(string.format("[create_key]: suffix='%s'", suffix)) end

  local key = string.format("%s%s-%s", constants.ALLOWED_PLANET_KEY_PART, name,  suffix)

  if debug_log then log(string.format("[create_key]: key='%s' - EXIT!", key)) end
  return key
end

-- Initializes the planets library
---@return void
function planets.init()
  if debug_log then log("[init]: CALLED!") end
  if not game then
    log("[init]: runtime isn't reached at this point. Skipping!")
    return
  end

  if debug_log then log(string.format("[init]: Initializing for %d planet(s) ...", #game.planets)) end
  for name, planet in pairs(game.planets) do
    if debug_log then log(string.format("[init]: name='%s',planet[]='%s'", name, type(planet))) end
    -- Init storage?
    if storage.allowed_planets == nil then
      -- Planets to allow spawning on
      ---@type table<string, boolean>
      storage.allowed_planets = {}
    end

    -- Is "allow spawning on all planets" enabled or is the planet part of SA?
    storage.allowed_planets[name] = (planet and planet.valid and (settings.startup[constants.ENABLE_SPAWN_RUINS_ALL_PLANETS_KEY].value or sa_planets[name] ~= nil))
    if debug_log then log(string.format("[init]: storage.allowed_planets[%s]='%s'", name, storage.allowed_planets[name])) end
  end

  if debug_log then log("[init]: EXIT!") end
end

-- Checks wether the given planet is allowed to spawn ruins on
---@param planet LuaPlanet
---@return boolean
function planets.is_planet_allowed(planet)
  if debug_log then log(string.format("[is_planet_allowed]: planet[]='%s' - CALLED!", type(planet))) end
  if type(planet) ~= "userdata" then
    error(string.format("Parameter planet[]='%s' is not expected type 'userdata'", type(planet)))
  elseif not planet.valid then
    error("Provided LuaPlanet instance is marked as invalid!")
  end

  -- Check condition
  local allowed = (storage.allowed_planets[planet.name] ~= nil)

  if debug_log then log(string.format("[is_planet_allowed]: allowed='%s' - EXIT!", allowed)) end
  return allowed
end

return planets
