local OV = angelsmods.functions.OV
if not (mods["angelsaddons-storage"] and angelsmods.addons.storage.warehouses) then
  return
end

local logistic_warehouses = {
  "angels-warehouse-passive-provider",
  "angels-warehouse-active-provider",
  "angels-warehouse-buffer",
  "angels-warehouse-storage",
  "angels-warehouse-requester",
}

local prerequisite_map = {
  ["angels-warehouse-passive-provider"] = "angels-warehouse",
  ["angels-warehouse-active-provider"] = "angels-warehouse",
  ["angels-warehouse-buffer"] = "angels-warehouse",
  ["angels-warehouse-storage"] = "angels-warehouse",
  ["angels-warehouse-requester"] = "angels-warehouse",
  ["angels-warehouse-mk2"] = "angels-warehouse",
  ["angels-warehouse-passive-provider-mk2"] = "angels-warehouse-passive-provider",
  ["angels-warehouse-active-provider-mk2"] = "angels-warehouse-active-provider",
  ["angels-warehouse-buffer-mk2"] = "angels-warehouse-buffer",
  ["angels-warehouse-storage-mk2"] = "angels-warehouse-storage",
  ["angels-warehouse-requester-mk2"] = "angels-warehouse-requester",
  ["angels-warehouse-mk3"] = "angels-warehouse-mk2",
  ["angels-warehouse-passive-provider-mk3"] = "angels-warehouse-passive-provider-mk2",
  ["angels-warehouse-active-provider-mk3"] = "angels-warehouse-active-provider-mk2",
  ["angels-warehouse-buffer-mk3"] = "angels-warehouse-buffer-mk2",
  ["angels-warehouse-storage-mk3"] = "angels-warehouse-storage-mk2",
  ["angels-warehouse-requester-mk3"] = "angels-warehouse-requester-mk2",
  ["angels-warehouse-mk4"] = "angels-warehouse-mk3",
  ["angels-warehouse-passive-provider-mk4"] = "angels-warehouse-passive-provider-mk3",
  ["angels-warehouse-active-provider-mk4"] = "angels-warehouse-active-provider-mk3",
  ["angels-warehouse-buffer-mk4"] = "angels-warehouse-buffer-mk3",
  ["angels-warehouse-storage-mk4"] = "angels-warehouse-storage-mk3",
  ["angels-warehouse-requester-mk4"] = "angels-warehouse-requester-mk3",
}

if mods["bobplates"] then
local bob_standard_ingredients = {
  [1] = {
    { type = "item", name = "iron-plate", amount = 500 },
    { type = "item", name = "stone-brick", amount = 100 },
  },
  [2] = {
    { type = "item", name = "bob-invar-alloy", amount = 400 },
    { type = "item", name = "bob-brass-gear-wheel", amount = 150 },
    { type = "item", name = "bob-steel-bearing", amount = 100 },
  },
  [3] = {
    { type = "item", name = "bob-titanium-plate", amount = 800 },
    { type = "item", name = "bob-ceramic-bearing", amount = 200 },
  },
  [4] = {
    { type = "item", name = "bob-tungsten-plate", amount = 1000 },
    { type = "item", name = "bob-nitinol-bearing", amount = 250 },
  },
}

local bob_logistic_ingredients = {
  [1] = {
    { type = "item", name = "steel-plate", amount = 250 },
    { type = "item", name = "electronic-circuit", amount = 100 },
    { type = "item", name = "advanced-circuit", amount = 40 },
  },
  [2] = {
    { type = "item", name = "bob-invar-alloy", amount = 400 },
    { type = "item", name = "bob-brass-gear-wheel", amount = 150 },
    { type = "item", name = "bob-steel-bearing", amount = 100 },
  },
  [3] = {
    { type = "item", name = "bob-titanium-plate", amount = 800 },
    { type = "item", name = "bob-ceramic-bearing", amount = 200 },
    { type = "item", name = "processing-unit", amount = 200 },
  },
  [4] = {
    { type = "item", name = "bob-tungsten-plate", amount = 1000 },
    { type = "item", name = "bob-nitinol-bearing", amount = 250 },
    { type = "item", name = "bob-advanced-processing-unit", amount = 200 },
  },
}

-- Revise Angel's warehouses
data.raw.recipe["angels-warehouse"].energy_required = 20
data.raw.recipe["angels-warehouse"].ingredients = util.copy(bob_standard_ingredients[1])

for _, warehouse in pairs(logistic_warehouses) do
  data.raw.recipe["" .. warehouse].energy_required = 20
  data.raw.recipe["" .. warehouse].ingredients = util.copy(bob_logistic_ingredients[1])
end

-- Iterate through warehouse types and make all the requisite recipes
for n = 2, 4 do
  -- Setup standard warehouse subtype
  data:extend({
    util.merge({
      data.raw.recipe["angels-warehouse"],
      {
        name = "angels-warehouse-mk" .. n,
        results = { { type = "item", name = "angels-warehouse-mk" .. n } },
        subgroup = "angels-warehouses-" .. n,
      },
    }),
  })

  data.raw.recipe["angels-warehouse-mk" .. n].ingredients = util.copy(bob_standard_ingredients[n])

  -- Setup logistics warehouse subtypes
  for _, prefix in pairs(logistic_warehouses) do
    data:extend({
      util.merge({
        data.raw.recipe["" .. prefix],
        {
          name = prefix .. "-mk" .. n,
          results = { { type = "item", name = prefix .. "-mk" .. n } },
          subgroup = "angels-warehouses-" .. n,
        },
      }),
    })

    data.raw.recipe[prefix .. "-mk" .. n].ingredients = util.copy(bob_logistic_ingredients[n])
  end
end

else

local standard_ingredients = {
  [1] = {
    { type = "item", name = "iron-plate", amount = 500 },
    { type = "item", name = "stone-brick", amount = 100 },
  },
  [2] = {
    { type = "item", name = "angels-plate-aluminium", amount = 400 },
  },
  [3] = {
    { type = "item", name = "angels-plate-titanium", amount = 800 },
  },
  [4] = {
    { type = "item", name = "angels-plate-tungsten", amount = 1000 },
  },
}

local logistic_ingredients = {
  [1] = {
    { type = "item", name = "steel-plate", amount = 250 },
    { type = "item", name = "electronic-circuit", amount = 100 },
    { type = "item", name = "advanced-circuit", amount = 40 },
  },
  [2] = {
    { type = "item", name = "angels-plate-aluminium", amount = 400 },
  },
  [3] = {
    { type = "item", name = "angels-plate-titanium", amount = 800 },
    { type = "item", name = "processing-unit", amount = 200 },
  },
  [4] = {
    { type = "item", name = "angels-plate-tungsten", amount = 1000 },
    { type = "item", name = "processing-unit", amount = 200 },
  },
}

-- Revise Angel's warehouses
data.raw.recipe["angels-warehouse"].energy_required = 20
data.raw.recipe["angels-warehouse"].ingredients = util.copy(standard_ingredients[1])

for _, warehouse in pairs(logistic_warehouses) do
  data.raw.recipe["" .. warehouse].energy_required = 20
  data.raw.recipe["" .. warehouse].ingredients = util.copy(logistic_ingredients[1])
end

-- Iterate through warehouse types and make all the requisite recipes
for n = 2, 4 do
  -- Setup standard warehouse subtype
  data:extend({
    util.merge({
      data.raw.recipe["angels-warehouse"],
      {
        name = "angels-warehouse-mk" .. n,
        results = { { type = "item", name = "angels-warehouse-mk" .. n } },
        subgroup = "angels-warehouses-" .. n,
      },
    }),
  })

  data.raw.recipe["angels-warehouse-mk" .. n].ingredients = util.copy(standard_ingredients[n])

  -- Setup logistics warehouse subtypes
  for _, prefix in pairs(logistic_warehouses) do
    data:extend({
      util.merge({
        data.raw.recipe["" .. prefix],
        {
          name = prefix .. "-mk" .. n,
          results = { { type = "item", name = prefix .. "-mk" .. n } },
          subgroup = "angels-warehouses-" .. n,
        },
      }),
    })

    data.raw.recipe[prefix .. "-mk" .. n].ingredients = util.copy(logistic_ingredients[n])
  end
end

end
-- Add all the prerequisites
if settings.startup["extangels-warehouses-require-previous"].value then
  for name, prerequisite in pairs(prerequisite_map) do
    local item_in = { type = "item", name = prerequisite, amount = 1 }
    OV.patch_recipes({{name = name, ingredients = {item_in},}})
  end
end

