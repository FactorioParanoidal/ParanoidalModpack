-- Run with --test-scenario helmod/fluid-source-regression.
require("util")
require("mod-gui")
require("__helmod__/core/tableExtends")
require("__helmod__/core/global")
require("__helmod__/core/class")
require("__helmod__/core/defines")
require("__helmod__/core/logging")
Logging:new()
require("__helmod__/controller/DispatcherController")
Dispatcher = DispatcherController("HMDispatcherController")
Format = require("__helmod__/core/Format")
require("__helmod__/gui/Gui")
Player = require("__helmod__/model/Player")
Controller = require("__helmod__/controller/Controller")

local function machineNames(machines)
  local names = {}
  for _, machine in pairs(machines) do names[machine.name] = true end
  return names
end

local function logMachines(fluid_name)
  local names = {}
  for _, machine in pairs(RecipePrototype(fluid_name, "fluid"):getAllowedMachines()) do
    names[#names + 1] = machine.name
  end
  table.sort(names)
  log("PASS: " .. fluid_name .. " machines: " .. table.concat(names, ", "))
end

local function seedLegacyIndex(selector)
  Cache.reset(selector.classname)
  Cache.setData(selector.classname, "list_products", {water = {}})
  Cache.setData(selector.classname, "list_ingredients", {["iron-plate"] = {}})
end

script.on_event(defines.events.on_player_created, function(event)
  Player.set(game.get_player(event.player_index))
  local recipes = Player.getFluidRecipes()
  local mud_name = "angels-water-viscous-mud"
  if prototypes.fluid[mud_name] then
    assert(recipes[mud_name], "The seafloor pump fluid source must be available without a tile fluid")
    local selector = Controller:getView("HMRecipeSelector")
    seedLegacyIndex(selector)
    Cache.setData("fluid-source-regression", "preserved", true)
    Player.set(nil)
    selector:prepare()
    local indexed = Cache.getData(selector.classname, "list_products")
    assert(indexed[mud_name] and indexed[mud_name]["fluid-" .. mud_name],
      "Preparing a legacy persisted index must add the pumping source before a player is loaded")
    assert(Cache.getData("fluid-source-regression", "preserved"), "Only the recipe selector cache may be reset")
    selector:prepare()
    assert(Cache.getData(selector.classname, "list_products") == indexed,
      "A migrated source index must be reused on subsequent preparations")
    Player.set(game.get_player(event.player_index))
    seedLegacyIndex(selector)
    selector:onBeforeOpen({player_index = event.player_index, action = "OPEN"})
    indexed = Cache.getData(selector.classname, "list_products")
    assert(indexed[mud_name] and indexed[mud_name]["fluid-" .. mud_name],
      "Opening the selector after loading a save must migrate a legacy persisted index")
    log("PASS: legacy source index migration before player loading and on selector opening; migrated cache reused")
    local mud = RecipePrototype(mud_name, "fluid")
    local found = false
    for _, source in pairs(Player.searchRecipe(mud_name, false)) do
      if source.name == mud_name and source.type == "fluid" then found = true end
    end
    assert(found, "Searching fluid producers must include the seafloor pumping source")
    local machines = machineNames(mud:getAllowedMachines())
    for name, speed in pairs({["angels-seafloor-pump"] = 300,
      ["paranoidal-seafloor-pump-2"] = 600, ["paranoidal-seafloor-pump-3"] = 1200}) do
      if prototypes.entity[name] then
        assert(machines[name], "The mud source must allow " .. name)
        local factory = {name = name, quality = "normal"}
        assert(EntityPrototype(factory):getFluidProduction() == speed, name .. " output per second")
        assert(EntityPrototype(factory):speedFactory() == speed, name .. " calculation speed")
        local products = mud:getProducts(factory)
        assert(#products == 1 and products[1].name == mud_name and products[1].amount == 1,
          "The pump speed must be applied to a unit fluid recipe")
        assert(#mud:getIngredients(factory) == 0, "Seafloor pumping must not consume water or mud")
      end
    end
    assert(not machines["offshore-pump"], "A water pump must not produce viscous mud")
    assert(not machineNames(RecipePrototype("water", "fluid"):getAllowedMachines())["angels-seafloor-pump"],
      "A seafloor pump must not produce water")
    local tooltip = helpers.table_to_json(Controller:getView("HMRecipeSelector"):buildPrototypeTooltip({name = mud_name, type = "fluid"}))
    assert(tooltip:find("[entity=angels-seafloor-pump]", 1, true)
      and not tooltip:find("[entity=offshore-pump]", 1, true), "The pumping tooltip must list the matching machines")
    local legacy = Player.getProductionsCrafting("fluid", {name = mud_name})
    assert(legacy["angels-seafloor-pump"] and not legacy["offshore-pump"],
      "The legacy machine query must use the same fluid restrictions")
    log("PASS: seafloor pumping source, machines and output: 300/600/1200 per second")
    logMachines(mud_name)
  end

  local checked, unfiltered = 0, 0
  for _, pump in pairs(Player.getOffshorePumps()) do
    local filter = EntityPrototype(pump):getFluidProductionFilter()
    if filter then
      assert(recipes[filter.name], "Missing pumped fluid source: " .. pump.name .. "/" .. filter.name)
      local machines = machineNames(RecipePrototype(filter.name, "fluid"):getAllowedMachines())
      assert(machines[pump.name], "A pump must be allowed for its output filter: " .. pump.name)
      checked = checked + 1
    else
      assert(machineNames(RecipePrototype("water", "fluid"):getAllowedMachines())[pump.name],
        "An unfiltered offshore pump must produce tile water")
      assert(not Player.getOffshorePumps("steam")[pump.name],
        "An unfiltered offshore pump must not produce a non-tile fluid")
      unfiltered = unfiltered + 1
    end
  end
  local water = assert(Player.getFluidRecipe("water"), "Keep the tile water source")
  assert(#water.ingredients == 0 and #water.products == 1 and water.products[1].name == "water")
  water.products[1].amount = 999
  recipes.water = nil
  assert(Player.getFluidRecipe("water").products[1].amount == 1 and Player.getFluidRecipes().water,
    "Callers must not change the cached fluid source")
  assert(next(Player.getOffshorePumps("missing-fluid")) == nil, "Unknown fluids must not allow pumps")
  local pumps = Player.getOffshorePumps()
  pumps[next(pumps)] = nil
  assert(table.size(Player.getOffshorePumps()) == checked + unfiltered, "Keep the unfiltered query and cache isolation")
  logMachines("water")
  log("PASS: offshore pump filters: " .. checked .. "; unfiltered pumps: " .. unfiltered .. "; tile water source and cache isolation")
  script.finish_test()
end)
