local constants = require("constants")
local expressions = require("lua/expression_parsing")
local queue = require("lua/queue")
local surfaces = require("lua/surfaces")
local utils = require("utilities")

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

function spawning.init()
  if debug_log then log("[init]: CALLED!") end

  for _, size in pairs(spawning.ruin_sizes) do
    if debug_log then log(string.format("[init]: Setting chance=0.0 for size='%s' ...", size)) end
    spawning.spawn_chances[size] = 0.0
  end

  -- Init local tables, variables
  local chances = {}
  local thresholds = {}
  local sumChance = 0.0

  for _, size in pairs(spawning.ruin_sizes) do
    chances[size] = settings.global["ruins-" .. size .. "-ruin-chance"].value
    sumChance = sumChance + chances[size]
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

---@param half_size number
---@param center MapPosition
---@param surface LuaSurface
local function no_corpse_fade(half_size, center, surface)
  if debug_log then log(string.format("[no_corpse_fade]: half_size=%d,center[]='%s',surface[]='%s' - CALLED!", half_size, type(center), type(surface))) end

  if half_size <= 0 then
    error(string.format("Unexpected value half_size=%d, must be positive", half_size))
  elseif not surface.valid then
    error(string.format("surface.name='%s' is not valid", surface.name))
  end

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
  if not surface.valid then
    error(string.format("surface.name='%s' is not valid", surface.name))
  end

  local entity_name = expressions.entity(expression, vars)
  if debug_log then log(string.format("[spawn_entity]: entity_name='%s'", entity_name)) end

  if _G["prototypes"].entity[entity_name] == nil then
    log(string.format("[spawn_entity]: entity_name='%s' does not exist - EXIT!", entity_name))
    return
  end

  local force = extra_options.force or "neutral"
  if debug_log then log(string.format("[spawn_entity]: force='%s' - BEFORE!", force)) end
  if settings.global["ruins-enemy-not-cease-fire"].value == true and force ~= "neutral" then
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
    utils.safe_damage(e, extra_options.dmg, expressions.number(extra_options.dmg.dmg, vars))
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
  if table_size(entities) == 0 then
    error(string.format("No entities to spawn on surface.name='%s' - EXIT!", surface.name))
  elseif not surface.valid then
    error(string.format("surface.name='%s' is not valid", surface.name))
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
  if table_size(ruin_tiles) == 0 then
    error("[spawn_tiles]: Cannot spawn empty run_tiles!")
  elseif not surface.valid then
    error(string.format("surface.name='%s' is not valid", surface.name))
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
  if table_size(variables) == 0 then
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
  if half_size <= 0 then
    error(string.format("Unexpected value half_size=%d, must be positive", half_size))
  elseif not surface.valid then
    error(string.format("surface.name='%s' is not valid", surface.name))
  end

  local area = utils.area_from_center_and_half_size(half_size, center)

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
  if half_size <= 0 then
    error(string.format("Unexpected value half_size=%d, must be positive", half_size))
  elseif not surface.valid then
    error(string.format("surface.name='%s' is not valid", surface.name))
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
  elseif table_size(ruins) == 0 then
    error("Array 'ruins' is empty")
  elseif not surface.valid then
    error(string.format("surface[]='%s' is not valid", type(surface)))
  elseif surface.name == constants.DEBUG_SURFACE_NAME then
    error(string.format("Debug surface '%s' has no random ruin spawning.", surface.name))
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
  elseif type(ruinset_name) ~= "string" then
    error(string.format("ruinset_name[]='%s' is not expected type 'string'", type(ruinset_name)))
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
  if debug_log then log(string.format("[try_ruin_spawn]: size='%s',min_distance=%d,center[]='%s',surface[]='%s' - CALLED!", size, min_distance, type(center), type(surface))) end
  if type(size) ~= "string" then
    error(string.format("size[]='%s' is not expected type 'string'", type(size)))
  elseif not utils.list_contains(spawning.ruin_sizes, size) then
    error(string.format("size='%s' is not a valid ruin size", size))
  elseif utils.ruin_min_distance_multiplier[size] == nil then
    error(string.format("size='%s' is not found in multiplier table", size))
  elseif type(min_distance) ~= "number" then
    error(string.format("min_distance[]='%s' is not expected type 'string'", type(min_distance)))
  elseif surface.name == constants.DEBUG_SURFACE_NAME then
    error(string.format("Debug surface '%s' has no random ruin spawning.", surface.name))
  elseif surface.generate_with_lab_tiles == true then
    error(string.format("surface.name='%s' is a lab, no spawning allowed", surface.name))
  elseif utils.str_contains_any_from_table(surface.name, surfaces.get_all_excluded()) then
    error(string.format("surface.name='%s' is excluded, cannot spawn ruins on", surface.name))
  elseif settings.global[constants.CURRENT_RUIN_SET_KEY].value == constants.NONE then
    error("No ruin-set selected by player but this function was invoked. This should not happen.")
  end

  if debug_log then log(string.format("[try_ruin_spawn]: min_distance=%d - BEFORE!", min_distance)) end
  min_distance = min_distance * utils.ruin_min_distance_multiplier[size]
  if debug_log then log(string.format("[try_ruin_spawn]: min_distance=%d - AFTER!", min_distance)) end

  if math.abs(center.x) < min_distance and math.abs(center.y) < min_distance then
    if debug_log then log(string.format("[try_ruin_spawn]: min_distance=%d is to close to spawn area - EXIT!", min_distance)) end
    return
  end

  -- random variance so they aren't always chunk aligned
  local variance = -(utils.ruin_half_sizes[size] * 0.75) + 12 -- 4 -> 9, 8 -> 6, 16 -> 0. Was previously 4 -> 10, 8 -> 5, 16 -> 0
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
