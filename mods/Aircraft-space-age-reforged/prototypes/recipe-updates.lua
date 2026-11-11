local aircraft = require("shared.aircraft")
local helper = require("lib.data-util")
for _, spec in ipairs(aircraft.aircraft) do
  for _, carbon in ipairs({false, true}) do
    local recipe = data.raw.recipe[aircraft.name(spec, carbon)]
    if recipe then
      if spec.name == "gunship" and data.raw.item["bob-cobalt-steel-alloy"] then
        helper.replace_ingredient(recipe, "iron-plate", "bob-cobalt-steel-alloy")
      elseif spec.name == "jet" and data.raw.item["bob-nitinol-alloy"] then
        -- Replace one quarter of the structural material, not an additional full aircraft frame.
        helper.split_ingredient(recipe, carbon and "carbon-fiber" or "low-density-structure", "bob-nitinol-alloy", 50)
      elseif spec.name == "flying-fortress" then
        local material = data.raw.item["bob-copper-tungsten-alloy"] and "bob-copper-tungsten-alloy"
          or (data.raw.item["tungsten-plate"] and "tungsten-plate")
        if material then helper.replace_ingredient(recipe, "steel-plate", material) end
      end
      if spec.name ~= "cargo-plane" and data.raw.recipe.rifle and data.raw.gun.rifle then
        helper.replace_ingredient(recipe, "submachine-gun", "rifle")
      end
    end
  end
end
