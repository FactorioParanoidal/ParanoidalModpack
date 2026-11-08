local all_lab_types = data.raw['lab']

for k,v in pairs(all_lab_types) do
    table.insert(v.inputs,"golden-science-pack") --add my science pack to all labs
end

-- Paranoidal: the recycler is built at home before the rocket, its output inventory stays as in the build.
--data.raw['furnace']['recycler'].result_inventory_size = 40
--data.raw["utility-constants"]["default"].max_belt_stack_size = 5

--[[
              subgroup = "cubic",
              icons = 
              {
                {
                  icon = "__cubium__/graphics/icons/matter-cube-yellow.png",
                  scale = 0.9
                },
                {
                  icon = "__corrundum__/graphics/icons/electrochemical-science-pack.png",
                  scale = 0.6,
                }
              },
--]]



if(mods["cubium"]) then 
    data:extend(
      {        
        {
            type ="recipe",
            name ="golden-science-pack-cubic",
            categories ={"crafting-with-fluid","metallurgy"},
            icon ="__secretas__/graphics/icons/golden-science-pack.png",
            subgroup = "cubic",
            icons = 
            {
              {
                icon = "__cubium__/graphics/icons/matter-cube.png",
                scale = 0.9
              },
              {
                icon = "__secretas__/graphics/icons/golden-science-pack.png",
                scale = 0.6,
              }
            },
            enabled = false,
            ingredients =
            {
              {type ="item", name ="gold-plate", amount = 14},
              {type ="item", name ="steam-turbine", amount = 2},
              {type ="item", name ="solid-fuel", amount = 7},
              {type ="item", name ="arithmetic-combinator", amount = 14},
              {type ="fluid", name ="steam", amount = 250},
              {type ="fluid", name ="dream-concentrate", amount = 200},
              {type = "item", name = "energized-microcube", amount = 1},
            },
            surface_conditions =
            {
              {
                property = "pressure",
                min = 200,
                max = 280
              }
            },
            energy_required = 20,
            results =
            {
              {type ="item", name ="golden-science-pack", amount = 16},
              {type ="item", name ="golden-science-pack", amount = 2, independent_probability= 0.652},
              {type = "item", name = "dormant-microcube",                amount = 1,  percent_spoiled = 0, ignored_by_productivity = 9999, show_details_in_recipe_tooltip = false},
            },
            allow_productivity = true,
            allow_quality = true,
            main_product ="golden-science-pack",
            factoriopedia_description ="Refine gold into science.",
            auto_recycle = false,
        },
      }
    )
  
    table.insert(data.raw["technology"]["cube-mastery-4"].effects,
    {       
      type = "unlock-recipe",
      recipe = "golden-science-pack-cubic",
    }
    )

  end