
function BI_Functions.lib.allow_productivity(recipe_name)
  if data.raw.recipe[recipe_name] then
    for i, module in pairs(data.raw.module) do
      if module.limitation and module.effect.productivity then
        table.insert(module.limitation, recipe_name)
      end
    end
  end
end


function BI_Functions.lib.remove_from_blueprint(check_tile)
  if data.raw.tile[check_tile] then
    data.raw.tile[check_tile].can_be_part_of_blueprint = false
  end
end


function BI_Functions.lib.fuel_emissions_multiplier_update(item2update, value)
  local target = data.raw.item[item2update]
  if target and target.fuel_value then
    target.fuel_emissions_multiplier = value
  end
end
