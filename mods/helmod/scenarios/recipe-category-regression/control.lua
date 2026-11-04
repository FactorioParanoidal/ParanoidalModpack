-- Run with --test-scenario helmod/recipe-category-regression.
require("util")
require("__helmod__/core/tableExtends")
require("__helmod__/core/global")
require("__helmod__/core/class")
require("__helmod__/core/defines")
require("__helmod__/core/logging")
Logging:new()
Player = require("__helmod__/model/Player")
Model = require("__helmod__/data/Model")
require("__helmod__/model/Prototype")
require("__helmod__/model/ElectricPrototype")
require("__helmod__/model/EnergySourcePrototype")
require("__helmod__/model/EntityPrototype")
require("__helmod__/model/FluidboxPrototype")
require("__helmod__/model/FluidPrototype")
require("__helmod__/model/ItemPrototype")
require("__helmod__/model/Product")
require("__helmod__/model/RecipePrototype")

local function rule(value)
  return { recipe = { ["entity-category"] = { [value] = true } } }
end

-- Runs in on_init: zzzparanoidal-start-bnl pauses the game (tick_paused) for the profession choice, so on_tick never comes.
script.on_init(function()
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

  -- RecipePrototype:getCategory: game recipes use categories[1], Helmod's own recipe tables keep their category field.
  assert(RecipePrototype(recipe.name):getCategory() == recipe.categories[1], "Game recipe main category")
  local machines = prototypes.get_entity_filtered({{filter = "type", type = "assembling-machine"}})
  local boilers = 0
  for name, boiler_recipe in pairs(Player.getBoilerRecipes()) do
    local boiler_prototype = RecipePrototype(name, "boiler")
    local category = boiler_prototype:getCategory()
    assert(category == boiler_recipe.category and category ~= "crafting", name .. " category " .. tostring(category))
    -- ModelBuilder keeps a saved default factory only when it shares a category with the recipe:
    -- an assembler saved for "crafting" must not be put on a boiler recipe.
    for _, recipe_category in pairs(boiler_prototype:getAllCategories()) do
      for machine_name, machine in pairs(machines) do
        assert(not (machine.crafting_categories or {})[recipe_category], name .. " matches " .. machine_name)
      end
    end
    boilers = boilers + 1
  end
  assert(boilers > 0, "Exercise Helmod boiler recipes")
  log("PASS: Helmod boiler recipe categories: " .. boilers .. " recipes")
  script.finish_test()
end)
