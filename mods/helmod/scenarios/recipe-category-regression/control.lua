-- Run with --test-scenario helmod/recipe-category-regression.
local Player = require("__helmod__/model/Player")

local function rule(value)
  return { recipe = { ["entity-category"] = { [value] = true } } }
end

script.on_event(defines.events.on_tick, function()
  local recipe = assert(prototypes.recipe["bob-wooden-board"] or prototypes.recipe["iron-gear-wheel"])
  assert(Player.checkRules(true, rule("recycling"), "recipe", recipe, false),
    "The selector must keep an ordinary recipe when recycling is excluded")

  local checked, secondary = 0, 0
  for _, prototype in pairs(prototypes.recipe) do
    for i, category in ipairs(prototype.categories) do
      assert(not Player.checkRules(true, rule(category), "recipe", prototype, false), prototype.name)
      assert(Player.checkRules(false, rule(category), "recipe", prototype, true), prototype.name)
      checked = checked + 1
      if i > 1 then secondary = secondary + 1 end
    end
  end
  assert(checked > 0, "Exercise real LuaRecipePrototype categories")
  assert(not Player.checkRules(true, rule("all"), "recipe", recipe, false))
  assert(Player.checkRules(true, {}, "recipe", recipe, false))
  local force_recipe = assert(game.forces.player.recipes[recipe.name])
  assert(not Player.checkRules(true, rule(recipe.categories[1]), "recipe", force_recipe, false),
    "Force recipes must also use their categories")
  assert(not Player.checkRules(true, rule("custom"), "recipe", { category = "custom" }, false),
    "Helmod's table-based recipes must keep their category rules")
  log("PASS: Recipe selector category rules: " .. checked .. " categories, " .. secondary .. " secondary")
  script.finish_test()
end)
