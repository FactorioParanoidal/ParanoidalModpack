function get_item_fuel (item_name)
  local fuel = nil
  for i, p_t in pairs (data.raw) do
    for j, p in pairs (p_t) do
      if p.name == item_name and p.fuel_value then
        -- log ('p.fuel_value: '..p.fuel_value)
        local str = p.fuel_value
        local value = tonumber(string.match(str, "%d+"))
        -- if value then log (value) end
        local unit = string.match(str, "%a+")
        -- if unit then log (unit) end
        if value and unit then
          -- fuel = {value = value, unit = unit, category = "chemical", acceleration_multiplier = 1.2, top_speed_multiplier = 1.05}
          fuel = {value = value, unit = unit, category = p.fuel_category, acceleration_multiplier = p.fuel_acceleration_multiplier, top_speed_multiplier = p.fuel_fuel_acceleration_multiplier}
          -- log ('item '..item_name..' fuel: '..serpent.line(fuel))
          return fuel
        end
      end
    end
  end
end


local fuel_values = {}

for i, recipe in pairs (data.raw.recipe) do
  local fluid = nil
  if recipe.ingredients then
    for j, ingredient in pairs (recipe.ingredients) do
      if ingredient.type and ingredient.type == "fluid" then
        fluid = {name = ingredient.name, amount = ingredient.amount}
      end
    end
  end
  local item = nil
  if recipe.results then
    for j, result in pairs (recipe.results) do
      if (result.type and result.type == "item") or result[1] then
        local item_name = result.name or result[1]
        local amount = result.amount or result[2] or 1
        local fuel = get_item_fuel (item_name)
        if fuel then
          item = {name = item_name, amount = amount, fuel = fuel}
        end
      end
    end
  end
  if fluid and item and data.raw.fluid[fluid.name] then
    local amount = item.amount * item.fuel.value / fluid.amount
    
    -- log ('fluid '..serpent.line(fluid))
    -- log ('item '..serpent.line(item))
    -- log ('amount '..amount)
    data.raw.fluid[fluid.name].fuel = {amount = amount, unit = item.fuel.unit, value = (amount..item.fuel.unit)}
    -- log (fluid.name..' '..serpent.block(data.raw.fluid[fluid.name].fuel))
    log (fluid.name..'.fuel_value = '..serpent.block(data.raw.fluid[fluid.name].fuel.value))
  end
end


-- local fuel_values = {
    -- ['crude-oil'] = 44, -- MJ/kg
    -- ['diesel'] = 45,
    -- ['heavy-oil'] = 45,
    -- ['biodiesel'] = 38,
    -- ['light-oil'] = 38,
    -- ['natural-gas'] = 55,
    -- ['petroleum-gas'] = 55,
  -- }

for i, recipe in pairs (data.raw.recipe) do
  local has_barrel = false
  local has_fluid = nil
  local fluids = 0
  local energy = nil
  if recipe.ingredients and recipe.results then 
    for j, ingredient in pairs (recipe.ingredients) do
      local type = ingredient.type or 'item'
      local name = ingredient.name or ingredient[1]
      local amount = ingredient.amount or ingredient[2]
      if name == 'empty-barrel' then
        has_barrel = true
      end
      if type == 'fluid' then
        fluids = fluids + 1
        -- if data.raw.fluid[name] and fuel_values[name] then
        if data.raw.fluid[name] and data.raw.fluid[name].fuel and data.raw.fluid[name].fuel.amount and data.raw.fluid[name].fuel.unit then
          has_fluid = name
          energy = (amount * data.raw.fluid[name].fuel.amount )..data.raw.fluid[name].fuel.unit
          -- log (i..' recipe energy: "'..energy..'"')
        end
      end
    end
  end
  local result_barrel = nil
  if recipe.results then
    for i, result in pairs (recipe.results) do
      local type = result.type or "item"
      local name = result.name or result[1]
      if type == 'item' and data.raw.item[name] then
        result_barrel = name
      end
    end
  else
    -- log ('no results by '..i)
  end
  
  if has_barrel and has_fluid and (fluids == 1) and result_barrel then
    log (result_barrel..'.fuel_value = "'..energy..'"')
    data.raw.item[result_barrel].fuel_value = energy
    data.raw.item[result_barrel].fuel_category = "chemical"
    data.raw.item[result_barrel].burnt_result = 'empty-barrel'
  end
end

for i, v in pairs (data.raw) do
  for j, w in pairs (v) do
    if w.burner and w.burner.fuel_category and w.burner.fuel_category == "chemical" then
      if not w.burner.burnt_inventory_size or w.burner.burnt_inventory_size == 0 then
        w.burner.burnt_inventory_size = 1
      else
        w.burner.burnt_inventory_size = w.burner.burnt_inventory_size + 1
      end
    end
    if w.energy_source and w.energy_source.type and w.energy_source.type == "burner" then
      if w.energy_source.fuel_category and w.energy_source.fuel_category == "chemical" then
        if not w.energy_source.burnt_inventory_size or w.energy_source.burnt_inventory_size == 0 then
          w.energy_source.burnt_inventory_size = 1
        else
          w.energy_source.burnt_inventory_size = w.energy_source.burnt_inventory_size + 1
        end
      end
    end
  end
end