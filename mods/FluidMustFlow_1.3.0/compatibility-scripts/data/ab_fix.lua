if mods["bobelectronics"] and mods["bobplates"] then
  data.raw["recipe"]["duct-small"].ingredients = {
    { type = "item", name = "silicon-nitride", amount = 4 },
    { type = "item", name = "titanium-plate", amount = 1 },
  }
  data.raw["recipe"]["duct-t-junction"].ingredients = {
    { type = "item", name = "duct-small", amount = 3 },
    { type = "item", name = "silicon-nitride", amount = 3 },
    { type = "item", name = "titanium-plate", amount = 1 },
  }
  data.raw["recipe"]["duct-curve"].ingredients = {
    { type = "item", name = "duct-small", amount = 2 },
    { type = "item", name = "silicon-nitride", amount = 2 },
    { type = "item", name = "titanium-plate", amount = 1 },
  }
  data.raw["recipe"]["duct-cross"].ingredients = {
    { type = "item", name = "duct-small", amount = 4 },
    { type = "item", name = "silicon-nitride", amount = 4 },
    { type = "item", name = "titanium-plate", amount = 1 },
  }
  data.raw["recipe"]["duct-underground"].ingredients = {
    { type = "item", name = "duct-small", amount = 24 },
    { type = "item", name = "silicon-nitride", amount = 12 },
    { type = "item", name = "titanium-plate", amount = 3 },
  }
  data.raw["recipe"]["non-return-duct"].ingredients = {
    { type = "item", name = "silicon-nitride", amount = 24 },
    { type = "item", name = "titanium-plate", amount = 12 },
    { type = "item", name = "bob-pump-2", amount = 5 },
  }
  data.raw["recipe"]["duct-end-point-intake"].ingredients = {
    { type = "item", name = "silicon-nitride", amount = 24 },
    { type = "item", name = "titanium-plate", amount = 12 },
    { type = "item", name = "bob-pump-2", amount = 10 },
    { type = "item", name = "advanced-circuit", amount = 5 },
  }
  data.raw["recipe"]["duct-end-point-outtake"].ingredients = {
    { type = "item", name = "silicon-nitride", amount = 24 },
    { type = "item", name = "titanium-plate", amount = 12 },
    { type = "item", name = "bob-pump-2", amount = 10 },
    { type = "item", name = "advanced-circuit", amount = 5 },
  }

  if not settings.startup["fmf-enable-duct-auto-join"].value then
    data.raw["recipe"]["duct"].ingredients = {
      { type = "item", name = "duct-small", amount = 2 },
    }
    data.raw["recipe"]["duct-long"].ingredients = {
      { type = "item", name = "duct", amount = 2 },
    }
  end
end
