local table = require("__flib__.table")

local constants = require("constants")

return function(database)
  -- Compatible fuels / burned in
  for _, class in pairs(constants.burner_classes) do
    for name, data in pairs(database[class]) do
      local can_burn = data.can_burn
      if can_burn then
        -- Generators might have a fluid defined here already
        for _, fuel_ident in pairs(can_burn) do
          local fuel_data = database[fuel_ident.class][fuel_ident.name]
          fuel_data.burned_in[#fuel_data.burned_in + 1] = { class = class, name = name }
        end
        local fuel_filter = data.fuel_filter
        if fuel_filter then
          data.can_burn = { fuel_filter }
          data.fuel_filter = nil
          local fuel_data = database[fuel_filter.class][fuel_filter.name]
          fuel_data.burned_in[#fuel_data.burned_in + 1] = { class = class, name = name }
        end
        for i, category_ident in pairs(data.fuel_categories or {}) do
          local category_data = database.fuel_category[category_ident.name]
          if category_data then
            -- Add fluids and items to the compatible fuels, and add the object to the material's burned in table
            for _, objects in pairs({ category_data.fluids, category_data.items }) do
              for _, obj_ident in pairs(objects) do
                local obj_data = database[obj_ident.class][obj_ident.name]
                obj_data.burned_in[#obj_data.burned_in + 1] = { class = class, name = name }
                can_burn[#can_burn + 1] = table.shallow_copy(obj_ident)
              end
            end
          else
            -- Remove this category from the entity
            table.remove(data.fuel_categories, i)
          end
        end
      end
    end
  end

  -- Burnt results
  for item_name, item_data in pairs(database.item) do
    local burnt_result = item_data.burnt_result
    if burnt_result then
      local result_data = database.item[burnt_result.name]
      result_data.burnt_result_of[#result_data.burnt_result_of + 1] = { class = "item", name = item_name }
    end
  end
end
