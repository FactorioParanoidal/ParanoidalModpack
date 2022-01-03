local util = require("__AbandonedRuins__/utilities")
local expressions = require("__AbandonedRuins__/expression_parsing")

local spawning = {}

---@param half_size number
---@param center MapPosition
---@param surface LuaSurface
local function no_corpse_fade(half_size, center, surface)
  local area = util.area_from_center_and_half_size(half_size, center)
  for _, entity in pairs(surface.find_entities_filtered({area = area, type={"corpse", "rail-remnants"}})) do
    entity.corpse_expires = false
  end
end

---@param entity EntityExpression|string
---@param relative_position MapPosition
---@param center MapPosition
---@param surface LuaSurface
---@param extra_options EntityOptions
---@param vars VariableValues
---@param prototypes LuaCustomTable<string,LuaEntityPrototype>
local function spawn_entity(entity, relative_position, center, surface, extra_options, vars, prototypes)
  local entity_name = expressions.entity(entity, vars)

  --drd begin (AbandonedRuins: теперь не будет падать при спауне руин с призраками. --by sbeljakov)
  if entity == 'entity-ghost' then
    util.debugprint("ghost entity could not be spawned")
    return
  end
  --drd end


  if not prototypes[entity_name] then
    util.debugprint("entity " .. entity_name .. " does not exist")
    return
  end

  local force = extra_options.force or "neutral"
  if force == "enemy" then
    force = util.get_enemy_force()
  end

  local recipe
  if extra_options.recipe then
    if not game.recipe_prototypes[extra_options.recipe] then
      util.debugprint("recipe " .. extra_options.recipe .. " does not exist")
    else
      recipe = extra_options.recipe
    end
  end

  local e = surface.create_entity
  {
    name = entity_name,
    position = {center.x + relative_position.x, center.y + relative_position.y},
    direction = defines.direction[extra_options.dir] or defines.direction.north,
    force = force,
    raise_built = true,
    create_build_effect_smoke = false,
    recipe = recipe
  }

  if extra_options.dmg then
    util.safe_damage(e, extra_options.dmg, expressions.number(extra_options.dmg.dmg, vars))
  end
  if extra_options.dead then
    util.safe_die(e, extra_options.dead)
  end
  if extra_options.fluids then
    local fluids = {}
    for name, amount_expression in pairs(extra_options.fluids) do
      local amount = expressions.number(amount_expression, vars)
      if amount > 0 then
        fluids[name] = amount
      end
    end
    util.safe_insert_fluid(e, fluids)
  end
  if extra_options.items then
    local items = {}
    for name, count_expression in pairs(extra_options.items) do
      local count = expressions.number(count_expression, vars)
      if count > 0 then
        items[name] = count
      end
    end
    util.safe_insert(e, items)
  end
end

---@param entities RuinEntity[]
---@param center MapPosition
---@param surface LuaSurface
---@param vars VariableValues
local function spawn_entities(entities, center, surface, vars)
  if not entities then return end

  local prototypes = game.entity_prototypes

  for _, entity_info in pairs(entities) do
    spawn_entity(entity_info[1], entity_info[2], center, surface, entity_info[3] or {}, vars, prototypes)
  end
end

---@param tiles RuinTile[]
---@param center MapPosition
---@param surface LuaSurface
local function spawn_tiles(tiles, center, surface)
  if not tiles then return end

  local prototypes = game.tile_prototypes
  ---@type Tile[]
  local valid = {}
  for _, tile_info in pairs(tiles) do
    local name = tile_info[1]
    local pos = tile_info[2]
    if prototypes[name] then
      valid[#valid+1] = {name = name, position = {center.x + pos.x, center.y + pos.y}}
    else
      util.debugprint("tile " .. name .. " does not exist")
    end
  end

  surface.set_tiles(
    valid,
    true, -- correct_tiles,                Default: true
    true, -- remove_colliding_entities,    Default: true
    true, -- remove_colliding_decoratives, Default: true
    true) -- raise_event,                  Default: false
end

-- Evaluates the values of the variables.
---@param vars Variable[]
---@return VariableValues
local function parse_variables(vars)
  if not vars then return end
  local parsed = {}

  for _, var in pairs(vars) do
    if var.type == "entity-expression" then
      parsed[var.name] = expressions.entity(var.value)
    elseif var.type == "number-expression" then
      parsed[var.name] = expressions.number(var.value)
    else
      error("Unrecognized variable type: " .. var.type)
    end
  end

  return parsed
end

---@param half_size number
---@param center MapPosition
---@param surface LuaSurface
---@return boolean @Whether the area is clear and ruins can be spawned
local function clear_area(half_size, center, surface)
  local area = util.area_from_center_and_half_size(half_size, center)
  -- exclude tiles that we shouldn't spawn on
  if surface.count_tiles_filtered{ area = area, limit = 1, collision_mask = {"item-layer", "object-layer"} } == 1 then
    return false
  end

  for _, entity in pairs(surface.find_entities_filtered({area = area, type = {"resource"}, invert = true})) do
    if (entity.valid and entity.type ~= "tree") or math.random() < (half_size / 14) then
      entity.destroy({do_cliff_correction = true, raise_destroy = true})
    end
  end

  return true
end

---@param ruin Ruin
---@param half_size number
---@param center MapPosition
---@param surface LuaSurface
spawning.spawn_ruin = function(ruin, half_size, center, surface)
  if surface.valid and clear_area(half_size, center, surface) then
    local vars = parse_variables(ruin.variables)
    spawn_entities(ruin.entities, center, surface, vars)
    spawn_tiles(ruin.tiles, center, surface)
    no_corpse_fade(half_size, center, surface)
  end
end

---@param ruins Ruin[]
---@param half_size number
---@param center MapPosition
---@param surface LuaSurface
spawning.spawn_random_ruin = function(ruins, half_size, center, surface)
  --spawn a random ruin from the list
  spawning.spawn_ruin(ruins[math.random(#ruins)], half_size, center, surface)
end

return spawning
