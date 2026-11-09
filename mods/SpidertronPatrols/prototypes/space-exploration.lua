if not mods["space-exploration"] then return end

if settings.startup["sp-enable-spiderling"].value then
  table.insert(data.raw.recipe["sp-spiderling"].ingredients, {type="item", name="rocket-control-unit", amount=4})
  table.insert(data.raw.technology["sp-spiderling"].prerequisites, "rocket-control-unit")
end
