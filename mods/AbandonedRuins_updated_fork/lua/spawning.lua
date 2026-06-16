-- Load other libraries
local constants = require("constants")
local expressions = require("expression_parsing")
local planets = require("planets")
local queue = require("queue")
local surfaces = require("surfaces")
local utils = require("utilities")

---@type boolean
local debug_log = settings.global[constants.ENABLE_DEBUG_LOG_KEY].value
---@type boolean
local sanity = settings.startup[constants.ENABLE_EXPENSIVE_SANITY_CHECKS_KEY].value

local spawning = {}

-- Initial ruin sizes: small, medium, large
---@type table<string>
spawning.ruin_sizes = {"small", "medium", "large"}

-- Spawn chances per table
---@type tabe<string, double>
spawning.spawn_chances = {}

-- Table of exclusive ruinsets per surface
---@type table<string, string> surface name, ruin-set name
spawning.exclusive_ruinset = {}

-- Table of "no-spawning" per surface (see same `no_spawning` in mod AbandondedRuins-base for a per-ruin setting)
---@type table<string, string> surface name, ruin-set name
spawning.no_spawning = {}

-- Ruin's half sizes
---@type table<string, number>
spawning.ruin_half_sizes = {
  small  = 8  / 2,
  medium = 16 / 2,
  large  = 32 / 2
}

--- Multiplier for minimum distance calculation
---@type table<string, number>
spawning.ruin_min_distance_multiplier = {
  small  = 1,
  medium = 2.5,
  large  = 5
}

function spawning.init()
  if debug_log then log("[init]: CALLED!") end

  for _, size in pairs(spawning.ruin_sizes) do
    if debug_log then log(string.format("[init]: Setting chance=0.0 for size='%s' ...", size)) end
    spawning.spawn_chances[size] = 0.0
  end

  ---@type boolean
  storage.spawn_ruins = storage.spawn_ruins or true

  -- Init local tables, variables
  ---@type table<string, number>
  local chances = {}
  ---@type table<string, number>
  local thresholds = {}
  local sumChance = 0.0

  for _, size in pairs(spawning.ruin_sizes) do
    local setting = settings.global["ruins-" .. size .. "-ruin-chance"]
    if debug_log then log(string.format("[init]: setting[]='%s'", type(setting))) end
    if setting == nil then
      error(string.format("Ruin size='%s' has no configuration key set. Please add a global runtime setting name='ruin-%s-ruin-chance' to your settings.lua file!", size, size))
    end

    chances[size] = setting.value
    sumChance = sumChance + setting.value
    if debug_log then log(string.format("[init]: chances[%s]=%.2f", size, chances[size])) end
  end

  local totalChance = math.min(sumChance, 1)
  if debug_log then log(string.format("[init]: sumChance=%.2f,totalChance=%.2f", sumChance, totalChance)) end

  -- now compute cumulative distribution of conditional probabilities for
  -- spawn_type given a spawn occurs.
  for i, size in pairs(spawning.ruin_sizes) do
    if debug_log then log(string.format("[init]: i=%d,size='%s'", i, size)) end
    thresholds[size] = chances[size]  / sumChance * totalChance
    if i > 1 then
      -- Add threshold of previous ruin size
      thresholds[size] = thresholds[size] + thresholds[spawning.ruin_sizes[i - 1]]
    end
    if debug_log then log(string.format("[init]: thresholds[%s]=%.2f", size, thresholds[size])) end
  end

  if debug_log then log(string.format("[init]: Adding %d thresholds ...", table_size(thresholds))) end
  for size, threshold in pairs(thresholds) do
    if debug_log then log(string.format("[init]: Adding/updating size='%s',threshold=%.2f ...", size, threshold)) end
    spawning.spawn_chances[size] = threshold
  end

  if debug_log then log("[init]: EXIT!") end
end

-- Enables whether ruins should be spawned at all
---@param spawn_ruins boolean
function spawning.enable_spawning_ruins(spawn_ruins)
  if debug_log then log(string.format("[enable_spawning_ruins]: spawn_ruins[]='%s' - CALLED!", type(spawn_ruins))) end
  if type(spawn_ruins) ~= "boolean" then
    error(string.format("spawn_ruins[]='%s' is not expected type 'boolean'", type(spawn_ruins)))
  end

  if debug_log then log(string.format("[enable_spawning_ruins]: Setting spawn_ruins='%s'", spawn_ruins)) end
  storage.spawn_ruins = spawn_ruins

  if debug_log then log("[enable_spawning_ruins]: EXIT!") end
end

-- Gets whether ruins should be spawned at all
---@return boolean
function spawning.is_spawning_ruins_enabled()
  if debug_log then log(string.format("[is_spawning_ruins_enabled]: storage.spawn_ruins='%s' - EXIT!", storage.spawn_ruins)) end
  return storage.spawn_ruins
end

---@param half_size number
---@param center MapPosition
---@param surface LuaSurface
local function no_corpse_fade(half_size, center, surface)
  if debug_log then log(string.format("[no_corpse_fade]: half_size=%d,center[]='%s',surface[]='%s' - CALLED!", half_size, type(center), type(surface))) end

  if type(half_size) ~= "number" then
    error(string.format("Parameter half_size[]='%s' is of unexpected type 'number'", type(half_size)))
  elseif half_size <= 0 then
    error(string.format("Unexpected value half_size=%d, must be positive", half_size))
  elseif type(surface) ~= "userdata" then
    error(string.format("surface[]='%s' is not expected type 'userdata'", type(surface)))
  elseif not surface.valid then
    error("Invalid surface provided")
  end

  ---@type BoundingBox
  local area = utils.area_from_center_and_half_size(half_size, center)
  if debug_log then log(string.format("[no_corpse_fade]: area[]='%s',surface.name='%s'", type(area), surface.name)) end

  for _, entity in pairs(surface.find_entities_filtered({area = area, type={"corpse", "rail-remnants"}})) do
    if debug_log then log(string.format("[no_corpse_fade]: entity.type='%s',entity.name='%s',entity.valid='%s' - Setting corpse_expires=false ...", entity.type, entity.name, entity.valid)) end
    entity.corpse_expires = false
  end

  if debug_log then log("[no_corpse_fade]: EXIT!") end
end

---@param expression EntityExpression|string
---@param relative_position MapPosition
---@param center MapPosition
---@param surface LuaSurface
---@param extra_options EntityOptions
---@param vars VariableValues
local function spawn_entity(expression, relative_position, center, surface, extra_options, vars)
  if debug_log then
    log(string.format(
      "[spawn_entity]: expression[]='%s',relative_position[]='%s',center[]='%s',surface[]='%s',extra_options[]='%s',vars[]='%s' - CALLED!",
      type(expression),
      type(relative_position),
      type(center),
      type(surface),
      type(extra_options),
      type(vars)
    ))
  end
  if type(surface) ~= "userdata" then
    error(string.format("surface[]='%s' is not expected type 'userdata'", type(surface)))
  elseif not surface.valid then
    error("Invalid surface provided")
  end

  local entity_name = expressions.entity(expression, vars)
  if debug_log then log(string.format("[spawn_entity]: entity_name='%s'", entity_name)) end

  if _G["prototypes"].entity[entity_name] == nil then
    log(string.format("[spawn_entity]: entity_name='%s' does not exist - EXIT!", entity_name))
    return
  end

  local force = extra_options.force or "neutral"
  if debug_log then log(string.format("[spawn_entity]: force='%s' - BEFORE!", force)) end
  if settings.global[constants.ENABLE_ENEMY_NOT_CEASE_FIRE_KEY].value == true and force ~= "neutral" then
    force = utils.get_enemy_force()
  end
  if debug_log then log(string.format("[spawn_entity]: force='%s' - AFTER!", force)) end

  --- @type string Recipe name
  local recipe_name = nil
  if debug_log then log(string.format("[spawn_entity]: extra_options.recipe[%s]='%s'", type(extra_options.recipe), extra_options.recipe)) end
  if type(extra_options.recipe) == "string" then
    if not _G["prototypes"].recipe[extra_options.recipe] then
      log(string.format("[spawn_entity]: extra_options.recipe='%s'' does not exist!", extra_options.recipe))
    else
      recipe_name = extra_options.recipe
    end
  end
  if debug_log then log(string.format("[spawn_entity]: recipe_name[]='%s'", type(recipe_name))) end

  local e = surface.create_entity
  {
    name        = entity_name,
    position    = {center.x + relative_position.x, center.y + relative_position.y},
    direction   = defines.direction[extra_options.dir] or defines.direction.north,
    force       = force,
    raise_built = true,
    create_build_effect_smoke = false,
    recipe      = recipe_name
  }

  if debug_log then log(string.format("[spawn_entity]: e[]='%s',extra_options.dmg[]='%s'", type(e), type(extra_options.dmg))) end
  if extra_options.dmg then
    local amount = expressions.number(extra_options.dmg.dmg, vars)
    if debug_log then log(string.format("[spawn_entity]: amount=%d", amount)) end

    if amount > 0 then
      if debug_log then log(string.format("[spawn_entity]: Invoking utils.safe_damage(%s,%s,%d) ...", type(e), type(extra_options.dmg), amount)) end
      utils.safe_damage(e, extra_options.dmg, amount)
    end
  end

  if debug_log then log(string.format("[spawn_entity]: extra_options.dead[]='%s'", type(extra_options.dead))) end
  if extra_options.dead then
    utils.safe_die(e, extra_options.dead)
  end

  if debug_log then log(string.format("[spawn_entity]: extra_options.fluids[]='%s'", type(extra_options.fluids))) end
  if extra_options.fluids then
    local fluids = {}
    if debug_log then log(string.format("[spawn_entity]: Parsing %d fluids ...", #extra_options.fluids)) end
    for name, amount_expression in pairs(extra_options.fluids) do
      if debug_log then log(string.format("[spawn_entity]: name='%s',amount_expression='%s',vars[]='%s'", name, amount_expression, type(vars))) end
      local amount = expressions.number(amount_expression, vars)

      if debug_log then log(string.format("[spawn_entity]: amount=%d", amount)) end
      if amount > 0 then
        if debug_log then log(string.format("[spawn_entity]: Adding fluid name='%s',amount=%d ...", name, amount)) end
        fluids[name] = amount
      end
    end

    if debug_log then log(string.format("[spawn_entity]: fluids()=%d", table_size(fluids))) end
    if table_size(fluids) > 0 then
      if debug_log then log(string.format("[spawn_entity]: Safely inserting %d fluids ...", table_size(fluids))) end
      utils.safe_insert_fluid(e, fluids)
    end
  end

  if debug_log then log(string.format("[spawn_entity]: extra_optios.items[]='%s'", type(extra_options.items))) end
  if extra_options.items then
    local items = {}

    for name, count_expression in pairs(extra_options.items) do
      if debug_log then log(string.format("[spawn_entity]: name='%s',count_expression='%s'", name, count_expression)) end
      if not _G["prototypes"].item[name] then
        log(string.format("[spawn_entity]: item '%s' does not exist - SKIPPED!", name))
      else
        local count = expressions.number(count_expression, vars)
        if debug_log then log(string.format("[spawn_entity]: count=%d", count)) end
        if count > 0 then
          if debug_log then log(string.format("[spawn_entity]: Adding item name='%s',count=%d ...", name, count)) end
          items[name] = count
        end
      end
    end

    if debug_log then log(string.format("[spawn_entity]: Found %d items.", #items)) end
    if table_size(items) > 0 then
      if debug_log then log(string.format("[spawn_entity]: Safely inserting %d items ...", table_size(items))) end
      utils.safe_insert(e, items)
    end
  end

  if debug_log then log("[spawn_entity]: EXIT!") end
end

---@param entities RuinEntity[]
---@param center MapPosition
---@param surface LuaSurface
---@param vars VariableValues
local function spawn_entities(entities, center, surface, vars)
  if debug_log then log(string.format("[spawn_entities]: entities[]='%s',center[]='%s',surface[]='%s',vars[]='%s' - CALLED!", type(entities), type(center), type(surface), type(vars))) end
  if (sanity or debug_log) and table_size(entities) == 0 then
    error(string.format("No entities to spawn on surface.name='%s' - EXIT!", surface.name))
  elseif type(surface) ~= "userdata" then
    error(string.format("surface[]='%s' is not expected type 'userdata'", type(surface)))
  elseif not surface.valid then
    error("Invalid surface provided")
  end

  if debug_log then log(string.format("[spawn_entities]: Spawning %d entities on surface.name='%s' ...", #entities, surface.name)) end
  for _, entity_info in pairs(entities) do
    spawn_entity(entity_info[1], entity_info[2], center, surface, entity_info[3] or {}, vars)
  end

  if debug_log then log("[spawn_entities]: EXIT!") end
end

---@param ruin_tiles RuinTile[]
---@param center MapPosition
---@param surface LuaSurface
local function spawn_tiles(ruin_tiles, center, surface)
  if debug_log then log(string.format("[spawn_tiles]: ruin_tiles[]='%s',center[]='%s',surface[]='%s' - CALLED!", type(ruin_tiles), type(center), type(surface))) end
  if (sanity or debug_log) and table_size(ruin_tiles) == 0 then
    error("[spawn_tiles]: Cannot spawn empty run_tiles!")
  elseif type(surface) ~= "userdata" then
    error(string.format("surface[]='%s' is not expected type 'userdata'", type(surface)))
  elseif not surface.valid then
    error("Invalid surface provided")
  end

  local tiles = {}
  local count = 0

  if debug_log then log(string.format("[spawn_tiles]: Spawning %d tiles on surface.name='%s' ...", #ruin_tiles, surface.name)) end
  for _, tile_spec in pairs(ruin_tiles) do
    if prototypes.tile[tile_spec[1]] then
      if debug_log then log(string.format("[spawn_tiles]: tile_spec[1]='%s',center.x=%d,center.y=%d,tile_spec[2].x=%d,tile_spec[2].y=%d", tile_spec[1], center.x, center.y, tile_spec[2].x, tile_spec[2].y)) end
      count = count + 1
      tiles[count] = {
        name     = tile_spec[1],
        position = {center.x + tile_spec[2].x, center.y + tile_spec[2].y}
      }
    else
      log(string.format("[spawn_tiles]: Tile '%s' does not exist!", tile_spec[1]))
    end
  end

  if debug_log then log(string.format("[spawn_tiles]: Setting %d tiles for surface.name='%s' ...", #tiles, surface.name)) end
  surface.set_tiles(
    tiles,
    true, -- correct_tiles,                Default: true
    true, -- remove_colliding_entities,    Default: true
    true, -- remove_colliding_decoratives, Default: true
    true) -- raise_event,                  Default: false

  if debug_log then log("[spawn_tiles]: EXIT!") end
end

-- Evaluates the values of the variables.
---@param variables Variable[]
---@return VariableValues
local function parse_variables(variables)
  if debug_log then log(string.format("[parse_variables]: variables[]='%s' - CALLED!", type(variables))) end
  if (sanity or debug_log) and table_size(variables) == 0 then
    error("[parse_variables]: Not parsing an empty variables list!")
  end

  local parsed = {}

  if debug_log then log(string.format("[parse_variables]: Parsing %d variables ...", #variables)) end
  for _, var in pairs(variables) do
    if debug_log then log(string.format("[parse_variables]: var.type='%s',var.name='%s',var.value[]='%s'", var.type, var.name, type(var.value))) end
    if var.type == "entity-expression" then
      if debug_log then log(string.format("[parse_variables]: Parsing entity expression for var.name='%s',var.value[]='%s' ...", var.name, type(var.value))) end
      parsed[var.name] = expressions.entity(var.value)
    elseif var.type == "number-expression" then
      if debug_log then log(string.format("[parse_variables]: Parsing number expression for var.name='%s',var.value[]='%s' ...", var.name, type(var.value))) end
      parsed[var.name] = expressions.number(var.value)
    else
      error(string.format("Unrecognized variable type: var.type='%s'. Valid are: 'entity-expression' and 'number-expression'", var.type))
    end
  end

  if debug_log then log(string.format("[parse_variables]: parsed()=%d - EXIT!", table_size(parsed))) end
  return parsed
end

---@param half_size number
---@param center MapPosition
---@param surface LuaSurface
---@return boolean @Whether the area is clear and ruins can be spawned
local function clear_area(half_size, center, surface)
  if debug_log then log(string.format("[clear_area]: half_size[]='%s',center[]='%s',surface[]='%s' - CALLED!", type(half_size), type(center), type(surface))) end
  if type(half_size) ~= "number" then
    error(string.format("Parameter half_size[]='%s' is not expected type 'number'", type(half_size)))
  elseif half_size <= 0 then
    error(string.format("Unexpected value half_size=%d, must be positive", half_size))
  elseif type(surface) ~= "userdata" then
    error(string.format("Parameter surface[]='%s' is not expected type 'userdata'", type(surface)))
  elseif not surface.valid then
    error("Invalid surface provided")
  elseif surface.name == constants.DEBUG_SURFACE_NAME then
    error(string.format("surface.name='%s' is a debug surface, no clearing needed.", surface.name))
  end

  ---@type BoundingBox
  local area = utils.area_from_center_and_half_size(half_size, center)
  if debug_log then log(string.format("[clear_area]: area[]='%s',surface.name='%s'", type(area), surface.name)) end

  -- exclude tiles that we shouldn't spawn on
  if surface.count_tiles_filtered({area = area, limit = 1, collision_mask = {item = true, object = true, water_tile = true}}) == 1 then
    if debug_log then log(string.format("[clear_area]: surface.name='%s' has excluded tile - EXIT!", surface.name)) end
    return false
  end

  for _, entity in pairs(surface.find_entities_filtered({area = area, type = {"resource"}, invert = true})) do
    if debug_log and not entity.valid then
      log("[clear_area]: Found an invalid entity ...")
    elseif debug_log and entity.valid then
      log(string.format("[clear_area]: Found entity.type='%s',entity.name='%s' ...", entity.type, entity.name))
    end

    if (entity.valid and entity.type ~= "tree") or math.random() < (half_size / 14) then
      if debug_log and not entity.valid then
        log("[clear_area]: Destroying invalid entity ...")
      elseif debug_log and entity.valid then
        log(string.format("[clear_area]: Destroying entity.name='%s' ...", entity.name))
      end

      entity.destroy({do_cliff_correction = true, raise_destroy = true})
    end
  end

  if debug_log then log("[clear_area]: Area is clear for ruin! - EXIT!") end
  return true
end

---@param ruin Ruin
---@param half_size number
---@param center MapPosition
---@param surface LuaSurface
spawning.spawn_ruin = function(ruin, half_size, center, surface)
  if debug_log then log(string.format("[spawn_ruin]: ruin[]='%s',half_size[]='%s',center[]='%s',surface[]='%s' - CALLED!", type(ruin), type(half_size), type(center), type(surface))) end
  if type(half_size) ~= "number" then
    error(string.format("Parameter half_size[]='%s' is not expected type 'number'", type(half_size)))
  elseif half_size <= 0 then
    error(string.format("Unexpected value half_size=%d, must be positive", half_size))
  elseif type(surface) ~= "userdata" then
    error(string.format("surface[]='%s' is not expected type 'userdata'", type(surface)))
  elseif not surface.valid then
    error("Invalid surface provided")
  elseif surface.name ~= constants.DEBUG_SURFACE_NAME and ruin.spawn_on_surfaces ~= nil and ruin.spawn_on_surfaces[surface.name] == nil then
    error(string.format("surface.name='%s' is not allowed to spawn this ruin", surface.name))
  end

  if clear_area(half_size, center, surface) then
    local variables = {}
    if debug_log then log(string.format("[spawn_ruin]: ruin.variables[]='%s'", type(ruin.variables))) end
    if ruin.variables ~= nil and table_size(ruin.variables) > 0 then
      if debug_log then log(string.format("[spawn_ruin]: Ruin '%s' has %d variables to parse.", utils.get_ruin_name(ruin), table_size(ruin.variables))) end
      variables = parse_variables(ruin.variables)
    end
    if debug_log then log(string.format("[spawn_ruin]: variables()=%d,ruin.entities[]='%s'", table_size(variables), type(ruin.entities))) end

    if ruin.entities ~= nil and table_size(ruin.entities) > 0 then
      if debug_log then log(string.format("[spawn_ruin]: Ruin '%s' has %d entities to spawn.", utils.get_ruin_name(ruin), table_size(ruin.entities))) end
      spawn_entities(ruin.entities, center, surface, variables)
    end

    if debug_log then log(string.format("[spawn_ruin]: ruin.tiles[]='%s'", type(ruin.tiles))) end
    if ruin.tiles ~= nil and table_size(ruin.tiles) > 0 then
      if debug_log then log(string.format("[spawn_ruin]: Ruin '%s' has %d tiles to spawn.", utils.get_ruin_name(ruin), table_size(ruin.tiles))) end
      spawn_tiles(ruin.tiles, center, surface)
    end

    no_corpse_fade(half_size, center, surface)
  end

  if debug_log then log("[spawn_ruin]: EXIT!") end
end

---@param ruins Ruin[]
---@param half_size number
---@param center MapPosition
---@param surface LuaSurface
spawning.spawn_random_ruin = function(ruins, half_size, center, surface)
  if debug_log then log(string.format("[spawn_random_ruin]: ruins[]='%s',half_size[]='%s',center[]='%s',surface[]='%s' - CALLED!", type(ruins), type(half_size), type(center), type(surface))) end
  if type(ruins) ~= "table" then
    error(string.format("Parameter ruins[]='%s' is not of expected type 'table'", type(ruins)))
  elseif type(half_size) ~= "number" then
    error(string.format("Parameter half_size[]='%s' is not of expected type 'number'", type(half_size)))
  elseif half_size <= 0 then
    error(string.format("Unexpected value half_size=%d, must be positive", half_size))
  elseif (sanity or debug_log) and table_size(ruins) == 0 then
    error("Array 'ruins' is empty")
  elseif type(surface) ~= "userdata" then
    error(string.format("surface[]='%s' is not expected type 'userdata'", type(surface)))
  elseif not surface.valid then
    error("Invalid surface provided")
  elseif surface.name == constants.DEBUG_SURFACE_NAME then
    error(string.format("Debug surface '%s' has no random ruin spawning.", surface.name))
  elseif surface.planet ~= nil and not planets.is_planet_allowed(surface.planet) then
    error(string.format("surface.name='%s' is associated with a planet not allowing spawning", surface.name))
  end

  ---@type Ruin
  local ruin = nil
  ---@type uint
  local size = table_size(ruins)
  if debug_log then log(string.format("[spawn_random_ruin]: size=%d", size)) end

  -- Spawn a random ruin from the list
  while ruin == nil do
    if debug_log then log(string.format("[spawn_random_ruin]: ruin[]='%s' - BEFORE!", type(ruin))) end
    ruin = ruins[math.random(size)]
    if debug_log then log(string.format("[spawn_random_ruin]: ruin[]='%s' - AFTER!", type(ruin))) end

    ---@type string
    local name = utils.get_ruin_name(ruin)

    if debug_log then log(string.format("[spawn_random_ruin]: name='%s',ruin.spawn_on_surfaces[]='%s'", name, type(ruin.spawn_on_surfaces))) end
    if ruin.spawn_on_surfaces ~= nil and (ruin.spawn_on_surfaces[surface.name] == nil or not ruin.spawn_on_surfaces[surface.name]) then
      -- Ruin is not allowed on this surface
      if debug_log then log(string.format("[spawn_random_ruin]: Ruin '%s' is not allowed to spawn on surface '%s' - SKIPPED!", name, surface.name)) end
      ruin = nil
    elseif ruin.no_spawning ~= nil and ruin.no_spawning[surface.name] then
      if debug_log then log(string.format("[spawn_random_ruin]: Surface '%s' is banned from spawning ruin '%s' - SKIPPED!", surface.name, name)) end
      ruin = nil
    else
      -- Spawn ruin
      if debug_log then log(string.format("[spawn_random_ruin]: Spawning ruin '%s' at surface '%s' ...", name, surface.name)) end
      spawning.spawn_ruin(ruin, half_size, center, surface)
    end
  end

  if debug_log then log("[spawn_random_ruin]: EXIT!") end
end

-- Returns spawning chance for given size
---@param size string
---@return float Spawning chance
spawning.get_spawn_chance = function(size)
  if debug_log then log(string.format("[get_spawn_chance]: size[]='%s' - CALLED!", type(size))) end
  if type(size) ~= "string" then
    error(string.format("size[]='%s' is not expected type 'string'", type(size)))
  elseif #size == 0 then
    error("Parameter 'size' cannot be an empty string")
  elseif spawning.spawn_chances[size] == nil then
    error(string.format("size='%s' is not found in spawn_chances table", size))
  end

  if debug_log then log(string.format("[get_spawn_chance]: spawning.spawn_chances[%s]=%.2f - EXIT!", size, spawning.spawn_chances[size])) end
  return spawning.spawn_chances[size]
end

-- Checks if spawning is allowed on given surface for ruinset name
---@param surface LuaSurface
---@param ruinset_name string
---@return boolean Whether spawning of given ruin-set is allowed on surface
spawning.allow_spawning_on = function (surface, ruinset_name)
  if debug_log then log(string.format("[allow_spawning_on]: surface[]='%s',ruinset_name[]='%s' - CALLED!", type(surface), type(ruinset_name))) end
  if type(surface) ~= "userdata" then
    error(string.format("surface[]='%s' is not expected type 'userdata'", type(surface)))
  elseif not surface.valid then
    error("Invalid surface provided")
  elseif type(ruinset_name) ~= "string" then
    error(string.format("ruinset_name[]='%s' is not expected type 'string'", type(ruinset_name)))
  elseif #ruinset_name == 0 then
    error("Parameter 'ruinset_name' cannot be an empty string")
  end

  if debug_log then log(string.format("[allow_spawning_on]: Checking surface.name='%s',ruinset_name='%s' ...", surface.name, ruinset_name)) end
  local allow = not (spawning.no_spawning[surface.name] ~= nil and ruinset_name == spawning.no_spawning[surface.name])

  if debug_log then log(string.format("[allow_spawning_on]: allow='%s' - EXIT!", allow)) end
  return allow
end

---@param size string
---@param min_distance number
---@param center MapPosition
---@param surface LuaSurface
function spawning.try_ruin_spawn(size, min_distance, center, surface)
  if debug_log then log(string.format("[try_ruin_spawn]: size='%s',min_distance[%s]=%d,center[]='%s',surface[]='%s' - CALLED!", size, type(min_distance), min_distance, type(center), type(surface))) end
  if settings.global[constants.CURRENT_RUIN_SET_KEY].value == constants.NONE then
    error("No ruin-set selected by player but this function was invoked. This should not happen.")
  elseif type(size) ~= "string" then
    error(string.format("size[]='%s' is not expected type 'string'", type(size)))
  elseif #size == 0 then
    error("Parameter 'size' cannot be an empty string")
  elseif (sanity or debug_log) and not utils.list_contains(spawning.ruin_sizes, size) then
    error(string.format("size='%s' is not a valid ruin size", size))
  elseif spawning.ruin_min_distance_multiplier[size] == nil then
    error(string.format("size='%s' is not found in multiplier table", size))
  elseif type(min_distance) ~= "number" then
    error(string.format("min_distance[]='%s' is not expected type 'string'", type(min_distance)))
  elseif min_distance <= 0 then
    error(string.format("min_distance=%.2f cannot be zero or below", min_distance))
  elseif type(surface) ~= "userdata" then
    error(string.format("surface[]='%s' is not expected type 'userdata'", type(surface)))
  elseif not surface.valid then
    error("Invalid surface provided")
  elseif surface.name == constants.DEBUG_SURFACE_NAME then
    error(string.format("Debug surface '%s' has no random ruin spawning.", surface.name))
  elseif surface.generate_with_lab_tiles == true then
    error(string.format("surface.name='%s' is a lab, no spawning allowed", surface.name))
  elseif (sanity or debug_log) and surface.planet ~= nil and not planets.is_planet_allowed(surface.planet) then
    error(string.format("surface.name='%s' is associated with a planet not allowing spawning", surface.name))
  elseif (sanity or debug_log) and utils.str_contains_any_from_table(surface.name, surfaces.get_all_excluded()) then
    error(string.format("surface.name='%s' is excluded, cannot spawn ruins on", surface.name))
  end

  if debug_log then log(string.format("[try_ruin_spawn]: min_distance=%d - BEFORE!", min_distance)) end
  local distance = min_distance * spawning.ruin_min_distance_multiplier[size]
  if debug_log then log(string.format("[try_ruin_spawn]: distance=%d - AFTER!", distance)) end

  if math.abs(center.x) < distance and math.abs(center.y) < distance then
    if debug_log then log(string.format("[try_ruin_spawn]: distance=%d is to close to spawn area - EXIT!", distance)) end
    return
  end

  -- random variance so they aren't always chunk aligned
  local variance = -(spawning.ruin_half_sizes[size] * 0.75) + 12 -- 4 -> 9, 8 -> 6, 16 -> 0. Was previously 4 -> 10, 8 -> 5, 16 -> 0
  if debug_log then log(string.format("[try_ruin_spawn]: variance=%.2f,center.x=%d,center.y=%d - BEFORE!", variance, center.x, center.y)) end
  if variance > 0 then
    if debug_log then log(string.format("[try_ruin_spawn]: Applying random variance=%.2f ...", variance)) end
    center.x = center.x + math.random(-variance, variance)
    center.y = center.y + math.random(-variance, variance)
  end
  if debug_log then log(string.format("[try_ruin_spawn]: variance=%.2f,center.x=%d,center.y=%d - AFTER!", variance, center.x, center.y)) end

  queue.add_ruin({
    size    = size,
    center  = center,
    surface = surface
  })

  if debug_log then log("[try_ruin_spawn]: EXIT!") end
end

return spawning
