local State = {}

State.metatable = {__index = State}

local fuel_threshold = 5

local items = {}

local get_category_items = function(category)
  if items[category] then
    return items[category]
  end

  local unsorted = {}
  for item_name, item in pairs (game.item_prototypes) do
    if item.fuel_category and item.fuel_category == category then
      table.insert(unsorted, {name = item_name, value = item.fuel_value})
    end
  end

  table.sort(unsorted, function(a, b) return a.value > b.value end)
  local map = {}
  for k, v in pairs (unsorted) do
    map[v.name] = true
  end
  items[category] = map

  return map
end

local get_burner_items = function(burner)
  local items = {}
  for name, bool in pairs (burner.fuel_categories) do
    for item, bool in pairs (get_category_items(name)) do
      items[item] = true
    end
  end
  return items
end


function State.new(Character, target)
  local state =
  {
    type = "fuel_entity",
    character = Character,
    target = target or error("No target?"),
    items = get_burner_items(target.burner),
    current_item = nil
  }
  return setmetatable(state, State.metatable)
end

function State:finish()
  self.character:pop_state()
end

function State:update()

  if not (self.target.valid) then
    self:finish()
    return
  end

  local inventory = self.target.get_fuel_inventory()

  if not inventory then
    self:finish()
    return
  end

  if not inventory.is_empty() then
    self:finish()
    return
  end


  if self.current_item then

    if self.character:has_item(self.current_item, fuel_threshold) then
      self.character:put_item(self.target, self.current_item, fuel_threshold)
      return
    end

    if not self.find_attempted then
      self.find_attempted = true
      self.character:find_item(self.current_item, fuel_threshold)
      return
    end
  end

  self.current_item = next(self.items, self.current_item)
  self.find_attempted = false

  if not self.current_item then
    --We have gone through all items, none available.
    self:finish()
    return
  end

end

return setmetatable(State, {__call = function(this, ...) return State.new(...) end})