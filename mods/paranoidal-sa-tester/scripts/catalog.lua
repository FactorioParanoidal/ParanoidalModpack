-- What the panel knows about the build: everything comes from the loaded prototypes (no hand-written planet
-- lists), so the panel follows any change of the tech tree. Results are cached for the session: they depend on
-- prototypes only, which are the same for every player, so the cache is deterministic.
local M = {}
local cache = {}

function M.reset()
  cache = {}
end

local function by_order(a, b)
  if a.order ~= b.order then return a.order < b.order end
  return a.name < b.name
end

-- Qualities the player can pick: not hidden, in the game's order (defects first, then normal and up).
function M.qualities()
  if not cache.qualities then
    local list = {}
    for _, q in pairs(prototypes.quality) do
      if not q.hidden and not q.parameter then list[#list + 1] = q end
    end
    table.sort(list, by_order)
    cache.qualities = list
  end
  return cache.qualities
end

function M.lab_inputs()
  if not cache.lab_inputs then
    local set = {}
    for _, lab in pairs(prototypes.get_entity_filtered({{filter = "type", type = "lab"}})) do
      for _, name in pairs(lab.lab_inputs or {}) do set[name] = true end
    end
    cache.lab_inputs = set
  end
  return cache.lab_inputs
end

-- All technologies, prerequisites first (iterative depth-first walk: no deep Lua recursion).
local function topo()
  if cache.topo then return cache.topo end
  local order, state = {}, {}
  for name, tech in pairs(prototypes.technology) do
    if not state[name] then
      state[name] = true
      local stack = {{tech = tech, pre = tech.prerequisites, key = nil}}
      while #stack > 0 do
        local top = stack[#stack]
        local key, pre = next(top.pre, top.key)
        if key then
          top.key = key
          if not state[key] then
            state[key] = true
            stack[#stack + 1] = {tech = pre, pre = pre.prerequisites, key = nil}
          end
        else
          stack[#stack] = nil
          order[#order + 1] = top.tech
        end
      end
    end
  end
  cache.topo = order
  return order
end

-- Effects of every technology: unlocked recipes and space locations.
local function index_effects()
  if cache.unlockers then return end
  local unlockers, discovery_of, discoveries = {}, {}, {}
  for _, tech in ipairs(topo()) do
    for _, effect in pairs(tech.effects or {}) do
      if effect.type == "unlock-recipe" then
        local list = unlockers[effect.recipe]
        if not list then list = {}; unlockers[effect.recipe] = list end
        list[#list + 1] = tech.name
      elseif effect.type == "unlock-space-location" then
        discovery_of[effect.space_location] = discovery_of[effect.space_location] or tech.name
        local list = discoveries[tech.name]
        if not list then list = {}; discoveries[tech.name] = list end
        list[#list + 1] = effect.space_location
      end
    end
  end
  cache.unlockers, cache.discovery_of, cache.discoveries = unlockers, discovery_of, discoveries
end

-- Longest prerequisite chain of every technology: sorts milestones and locations in playthrough order.
local function depth()
  if cache.depth then return cache.depth end
  local d = {}
  for _, tech in ipairs(topo()) do
    local best = 0
    for name in pairs(tech.prerequisites) do
      if (d[name] or 0) > best then best = d[name] end
    end
    d[tech.name] = best + 1
  end
  cache.depth = d
  return d
end

function M.unlockers(recipe_name)
  index_effects()
  return cache.unlockers[recipe_name] or {}
end

function M.discovery_of(location_name)
  index_effects()
  return cache.discovery_of[location_name]
end

-- Discovery technologies (unlock at least one space location the player can see), in playthrough order.
function M.discoveries()
  if cache.discovery_list then return cache.discovery_list end
  index_effects()
  local d = depth()
  local list = {}
  for tech_name, locations in pairs(cache.discoveries) do
    local shown
    for _, loc in ipairs(locations) do
      local proto = prototypes.space_location[loc]
      if proto and not proto.hidden then shown = shown or loc end
    end
    if shown and prototypes.technology[tech_name] and not prototypes.technology[tech_name].hidden then
      list[#list + 1] = {tech = tech_name, location = shown, locations = locations, depth = d[tech_name] or 0}
    end
  end
  table.sort(list, function(a, b)
    if a.depth ~= b.depth then return a.depth < b.depth end
    return a.tech < b.tech
  end)
  cache.discovery_list = list
  return list
end

-- Space locations for the planets list. Hidden ones (trench, factory floors) only on request.
function M.locations(show_hidden)
  local key = show_hidden and "locations_all" or "locations"
  if cache[key] then return cache[key] end
  index_effects()
  local d = depth()
  local list = {}
  for name, loc in pairs(prototypes.space_location) do
    if (show_hidden or not loc.hidden) and not loc.parameter then
      local tech = cache.discovery_of[name]
      list[#list + 1] = {name = name, proto = loc, discovery = tech, depth = tech and d[tech] or 0, order = loc.order}
    end
  end
  table.sort(list, function(a, b)
    if a.depth ~= b.depth then return a.depth < b.depth end
    if a.order ~= b.order then return a.order < b.order end
    return a.name < b.name
  end)
  cache[key] = list
  return list
end

-- Milestones of the playthrough after the rocket: the rocket silo technology, then in playthrough order every
-- technology after it that discovers a place or is the first to unlock a science pack (a lab input); later
-- recipes of an already unlocked pack (quality variants, alternatives) are not milestones.
function M.milestones()
  if cache.milestones then return cache.milestones end
  index_effects()
  local d = depth()
  local labs = M.lab_inputs()
  local root = prototypes.technology["rocket-silo"]
  local list = {}
  if root then
    local candidates = {}
    local seen, queue, head = {[root.name] = true}, {root}, 1
    while queue[head] do
      local tech = queue[head]
      head = head + 1
      for name, next_tech in pairs(tech.successors) do
        if not seen[name] then
          seen[name] = true
          queue[#queue + 1] = next_tech
          if not next_tech.hidden then
            local entry = {name = name, discovers = false, packs = {}}
            for _, effect in pairs(next_tech.effects or {}) do
              if effect.type == "unlock-space-location" then
                local loc = prototypes.space_location[effect.space_location]
                if loc and not loc.hidden then entry.discovers = true end
              elseif effect.type == "unlock-recipe" then
                local recipe = prototypes.recipe[effect.recipe]
                for _, product in pairs(recipe and recipe.products or {}) do
                  if product.type == "item" and labs[product.name] then entry.packs[#entry.packs + 1] = product.name end
                end
              end
            end
            if entry.discovers or #entry.packs > 0 then candidates[#candidates + 1] = entry end
          end
        end
      end
    end
    table.sort(candidates, function(a, b)
      if (d[a.name] or 0) ~= (d[b.name] or 0) then return (d[a.name] or 0) < (d[b.name] or 0) end
      return a.name < b.name
    end)
    list[1] = root.name
    -- Packs of the home game (start recipes, technologies before the rocket) are not new after it. Hidden recipes
    -- (recycling of every pack is enabled from the start) do not count.
    local packs_seen = {}
    local function mark(recipe)
      if not recipe or recipe.hidden then return end
      for _, product in pairs(recipe.products or {}) do
        if product.type == "item" and labs[product.name] then packs_seen[product.name] = true end
      end
    end
    for _, recipe in pairs(prototypes.recipe) do
      if recipe.enabled then mark(recipe) end
    end
    for name, tech in pairs(prototypes.technology) do
      if not seen[name] then
        for _, effect in pairs(tech.effects or {}) do
          if effect.type == "unlock-recipe" then mark(prototypes.recipe[effect.recipe]) end
        end
      end
    end
    for _, entry in ipairs(candidates) do
      local new_pack = false
      for _, pack in ipairs(entry.packs) do
        if not packs_seen[pack] then new_pack = true end
      end
      if entry.discovers or new_pack then
        list[#list + 1] = entry.name
        for _, pack in ipairs(entry.packs) do packs_seen[pack] = true end
      end
    end
  end
  cache.milestones = list
  return list
end

-- Every technology needed before `name` (not researched for `force`), prerequisites first.
function M.missing(force, name)
  local tech = force.technologies[name]
  if not tech then return {} end
  local out, seen = {}, {[name] = true}
  local stack = {{tech = tech, pre = tech.prerequisites, key = nil}}
  while #stack > 0 do
    local top = stack[#stack]
    local key, pre = next(top.pre, top.key)
    if key then
      top.key = key
      if not seen[key] and not pre.researched then
        seen[key] = true
        stack[#stack + 1] = {tech = pre, pre = pre.prerequisites, key = nil}
      end
    else
      stack[#stack] = nil
      if top.tech.name ~= name then out[#out + 1] = top.tech end
    end
  end
  return out
end

-- Researched technologies that need `name` (directly or through others), the farthest first.
function M.researched_dependents(force, name)
  local tech = force.technologies[name]
  if not tech then return {} end
  local found, queue, head = {}, {tech}, 1
  local seen = {[name] = true}
  while queue[head] do
    local t = queue[head]
    head = head + 1
    for key, next_tech in pairs(t.successors) do
      if not seen[key] and next_tech.researched then
        seen[key] = true
        found[#found + 1] = next_tech
        queue[#queue + 1] = next_tech
      end
    end
  end
  local d = depth()
  table.sort(found, function(a, b)
    if (d[a.name] or 0) ~= (d[b.name] or 0) then return (d[a.name] or 0) > (d[b.name] or 0) end
    return a.name < b.name
  end)
  return found
end

-- Technologies that belong to one discovery: they need it, and every other discovery they need is needed by it
-- too (Muluna before Vulcanus is fine, Vulcanus + Fulgora together belongs to neither).
local function signatures()
  if cache.sig then return cache.sig end
  local list = M.discoveries()
  local bit_of = {}
  for i, entry in ipairs(list) do
    if i <= 31 then bit_of[entry.tech] = bit32.lshift(1, i - 1) end
  end
  local sig = {}
  for _, tech in ipairs(topo()) do
    local s = bit_of[tech.name] or 0
    for name in pairs(tech.prerequisites) do s = bit32.bor(s, sig[name] or 0) end
    sig[tech.name] = s
  end
  cache.sig, cache.bit_of = sig, bit_of
  return sig
end

local function add_item(kit, seen, name)
  if seen[name] then return end
  local item = prototypes.item[name]
  if not item or item.hidden or item.parameter then return end
  seen[name] = true
  if M.lab_inputs()[name] then
    kit.packs[#kit.packs + 1] = name
  elseif item.place_result or item.place_as_tile_result then
    kit.buildings[#kit.buildings + 1] = name
  else
    kit.materials[#kit.materials + 1] = name
  end
end

local function add_fluid(kit, seen, name)
  if seen["fluid/" .. name] then return end
  local fluid = prototypes.fluid[name]
  if not fluid or fluid.hidden or fluid.parameter then return end
  seen["fluid/" .. name] = true
  kit.fluids[#kit.fluids + 1] = name
end

-- What a planet needs: buildings, packs, materials and fluids of its technologies, plus what its surface gives
-- (ores, plants, rocks and the fluids of its tiles).
function M.kit(discovery)
  cache.kits = cache.kits or {}
  if cache.kits[discovery] then return cache.kits[discovery] end
  local sig = signatures()
  local bit = cache.bit_of[discovery]
  local kit = {buildings = {}, materials = {}, packs = {}, fluids = {}, techs = 0}
  local seen = {}
  if bit then
    local own = sig[discovery]
    for _, tech in ipairs(topo()) do
      local s = sig[tech.name]
      if bit32.band(s, bit) ~= 0 and bit32.band(s, bit32.bnot(own)) == 0 and not tech.hidden then
        kit.techs = kit.techs + 1
        for _, effect in pairs(tech.effects or {}) do
          if effect.type == "unlock-recipe" then
            local recipe = prototypes.recipe[effect.recipe]
            for _, product in pairs(recipe and recipe.products or {}) do
              if product.type == "item" then add_item(kit, seen, product.name)
              elseif product.type == "fluid" then add_fluid(kit, seen, product.name) end
            end
          end
        end
      end
    end
  end
  index_effects()
  for _, loc_name in ipairs(cache.discoveries[discovery] or {}) do
    local loc = prototypes.space_location[loc_name]
    local mgs
    if loc then
      local ok, value = pcall(function() return loc.map_gen_settings end)
      if ok then mgs = value end
    end
    local settings = mgs and mgs.autoplace_settings
    for name in pairs(settings and settings.entity and settings.entity.settings or {}) do
      local entity = prototypes.entity[name]
      local mineable = entity and entity.mineable_properties
      for _, product in pairs(mineable and mineable.products or {}) do
        if product.type == "item" then add_item(kit, seen, product.name)
        elseif product.type == "fluid" then add_fluid(kit, seen, product.name) end
      end
    end
    for name in pairs(settings and settings.tile and settings.tile.settings or {}) do
      local tile = prototypes.tile[name]
      if tile and tile.fluid then add_fluid(kit, seen, tile.fluid.name) end
    end
  end
  cache.kits[discovery] = kit
  return kit
end

-- Platform kit: what a first test platform needs (names missing in the build are skipped).
local PLATFORM_KIT = {
  {"space-platform-starter-pack", 1}, {"space-platform-foundation", 500}, {"asteroid-collector", 10},
  {"crusher", 10}, {"thruster", 4}, {"cargo-bay", 10}, {"solar-panel", 50}, {"accumulator", 20},
  {"electric-energy-interface", 2}, {"medium-electric-pole", 50}, {"substation", 10}, {"fast-inserter", 50},
  {"transport-belt", 100}, {"pipe", 100}, {"assembling-machine-3", 10}, {"chemical-plant", 5},
  {"gun-turret", 10}, {"steel-chest", 10},
}

function M.platform_kit()
  if not cache.platform_kit then
    local list = {}
    for _, entry in ipairs(PLATFORM_KIT) do
      local item = prototypes.item[entry[1]]
      if item then list[#list + 1] = {name = entry[1], count = math.min(entry[2], item.stack_size * 10)} end
    end
    cache.platform_kit = list
  end
  return cache.platform_kit
end

-- The engine's test devices (hidden from normal play, present in every build).
local TEST_TOOLS = {{"infinity-chest", 5}, {"infinity-pipe", 10}, {"electric-energy-interface", 5}, {"heat-interface", 5}}

function M.test_tools()
  local list = {}
  for _, entry in ipairs(TEST_TOOLS) do
    if prototypes.item[entry[1]] then list[#list + 1] = {name = entry[1], count = entry[2]} end
  end
  return list
end

-- Machines that can make a recipe category, visible ones first.
function M.machines(category)
  cache.machines = cache.machines or {}
  if not cache.machines[category] then
    local list = {}
    for _, entity in pairs(prototypes.get_entity_filtered({{filter = "crafting-category", crafting_category = category}})) do
      list[#list + 1] = entity
    end
    table.sort(list, function(a, b)
      if (a.hidden or false) ~= (b.hidden or false) then return not a.hidden end
      return by_order(a, b)
    end)
    cache.machines[category] = list
  end
  return cache.machines[category]
end

-- Asteroid chunks a platform collector can catch (no placeholders).
function M.asteroid_chunks()
  if not cache.chunks then
    local list = {}
    for name, chunk in pairs(prototypes.asteroid_chunk) do
      if not chunk.hidden and not chunk.parameter and name ~= "asteroid-chunk-unknown" then list[#list + 1] = name end
    end
    table.sort(list)
    cache.chunks = list
  end
  return cache.chunks
end

function M.asteroids()
  if not cache.asteroids then
    local list = {}
    for name in pairs(prototypes.get_entity_filtered({{filter = "type", type = "asteroid"}})) do
      if name:find("^medium%-") then list[#list + 1] = name end
    end
    table.sort(list)
    cache.asteroids = list
  end
  return cache.asteroids
end

-- Surface properties with a name the player can read (not the hidden helpers of planet mods).
function M.surface_properties()
  if not cache.props then
    local list = {}
    for name, prop in pairs(prototypes.surface_property) do
      if not prop.hidden then list[#list + 1] = prop end
    end
    table.sort(list, by_order)
    cache.props = list
  end
  return cache.props
end

-- Surface conditions checked against a surface: list of {property, min, max, value, ok} and the overall result.
function M.check_conditions(conditions, surface)
  local out, all_ok = {}, true
  for _, c in pairs(conditions or {}) do
    local ok_read, value = pcall(surface.get_property, c.property)
    if not ok_read then value = nil end
    local ok = value ~= nil and value >= c.min and value <= c.max
    if not ok then all_ok = false end
    out[#out + 1] = {property = c.property, min = c.min, max = c.max, value = value, ok = ok}
  end
  return out, all_ok
end

return M
