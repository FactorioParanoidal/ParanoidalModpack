local Find_item = {}

Find_item.metatable = { __index = Find_item }

function Find_item.new(Character, name, count, radius)
  local state =
  {
    type = "find_item",
    character = Character,
    name = name or error("No name given"),
    count = count or 0,
    radius = radius or 64
  }

  if state.count == 0 then
    state.count = math.ceil(game.item_prototypes[state.name].stack_size * 0.25)
  end

  return setmetatable(state, Find_item.metatable)
end

function Find_item:finish(dont_update_state)
  self.character:pop_state(dont_update_state)
end

function Find_item:fail()
  --In this case, we try to craft the item we are looking for.
  self.character:print("Couldn't find " .. self.name)
  self:finish(true)
  self.character:craft_item(self.name, self.count)
end

local find_types =
{
  ["container"] = 0,
  ["furnace"] = 0,
  ["assembling-machine"] = 0,
  ["logistic-container"] = 0,
  ["mining-drill"] = 5
}

local find_params =
{
  type =
  {
    "container",
    "logistic-container",
    "furnace",
    "assembling-machine",
    "mining-drill",
  }
}

function Find_item:find_new_target()
  local entities = self.character:find_nearby_entities(self.radius, find_params)
  for k, entity in pairs(entities) do
    local inventory = entity.get_output_inventory()
    if not inventory then
      entities[k] = nil
    elseif inventory.get_item_count(self.name) <= find_types[entity.type] then
      entities[k] = nil
    end
  end

  if not next(entities) then return end
  return self.character:get_closest(entities)
end

local belt_params =
{
  type = { "transport-belt" }
}

function Find_item:find_belt_target()
  local entities = self.character:find_nearby_entities(self.radius, belt_params)
  for k, entity in pairs(entities) do
    local has = false
    for i = 1, entity.get_max_transport_line_index() do
      local line = entity.get_transport_line(i)
      if line.get_item_count(self.name) > 0 then
        has = true
        break
      end
    end
    if not has then
      entities[k] = nil
    end
  end

  if not next(entities) then
    return
  end

  return self.character:get_closest(entities)
end

local product_cache = {}
local get_products = function(entity)
  local name = entity.name
  local products = product_cache[name]
  if products then return products end
  products = {}

  if entity.prototype.mineable_properties.products == nil then
    return products
  end

  for k, product in pairs(entity.prototype.mineable_properties.products) do
    if product.type == "item" then
      products[product.name] = true
    end
  end
  product_cache[name] = products
  return products
end

local mine_params =
{
  type = { "tree", "resource", "simple-entity" }
}

function Find_item:find_mine_target()
  local entities = self.character:find_nearby_entities(self.radius, mine_params)
  for k, entity in pairs(entities) do
    if not get_products(entity)[self.name] then
      entities[k] = nil
    end
  end

  if not next(entities) then
    return
  end

  return self.character:get_closest(entities)
end

local stack_size_cache = {}
local get_stack_size = function(name)
  local size = stack_size_cache[name]
  if size then return size end
  size = game.item_prototypes[name].stack_size
  stack_size_cache[name] = size
  return size
end

function Find_item:update()
  self.character:print("Find item update " .. self.name)

  local needed = self.count - self.character.entity.get_item_count(self.name)
  if needed <= 0 then
    --We already have enough of this item anyway.
    self:finish()
    return
  end

  local target = self:find_new_target()
  if target then
    self.character:take_item(target, self.name, math.max(needed, get_stack_size(self.name)))
    return
  end

  local belt_target = self:find_belt_target()
  if belt_target then
    self.character:take_item_from_belt(belt_target, self.name, math.max(needed, get_stack_size(self.name)))
    return
  end

  local mine_target = self:find_mine_target()
  if mine_target then
    self.character:mine(mine_target, math.max(needed, get_stack_size(self.name)))
    return
  end

  self:fail()
end

return setmetatable(Find_item, { __call = function(this, ...) return Find_item.new(...) end })
