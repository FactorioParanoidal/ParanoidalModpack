local function item(name, amount) return {type = "item", name = name, amount = amount} end
local function recipe(name, ingredients, time, categories)
  return {
    type = "recipe", name = name, enabled = false, energy_required = time,
    ingredients = ingredients, results = {item(name, 1)}, categories = categories
  }
end

data:extend({
  recipe("gunship", {item("electric-engine-unit", 64), item("steel-plate", 200), item("iron-plate", 400), item("electronic-circuit", 40), item("submachine-gun", 5), item("rocket-launcher", 5)}, 10),
  recipe("cargo-plane", {item("electric-engine-unit", 128), item("steel-plate", 400), item("iron-plate", 500), item("advanced-circuit", 20), item("submachine-gun", 1)}, 5),
  recipe("jet", {item("electric-engine-unit", 256), item("electronic-circuit", 120), item("advanced-circuit", 50), item("low-density-structure", 200), item("submachine-gun", 3), item("rocket-launcher", 3)}, 10),
  recipe("flying-fortress", {item("electric-engine-unit", 100), item("steel-plate", 2000), item("advanced-circuit", 80), item("processing-unit", 40), item("submachine-gun", 15), item("rocket-launcher", 15)}, 20),
  recipe("high-explosive-cannon-shell", {item("explosive-cannon-shell", 3), item("explosives", 1)}, 10),
  recipe("napalm", {item("flamethrower-ammo", 4), item("iron-plate", 10)}, 1),
  recipe("aircraft-afterburner", {item("electric-engine-unit", 10), {type = "fluid", name = "lubricant", amount = 5}, item("solid-fuel", 5)}, 3, {"crafting-with-fluid"}),
  recipe("aircraft-energy-shield", {item("energy-shield-mk2-equipment", 2), item("battery", 20)}, 5)
})
