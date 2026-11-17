-- Run with --test-scenario helmod/selector-refresh-regression.
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

script.on_event(defines.events.on_player_created, function(event)
  local player = game.get_player(event.player_index)
  Player.set(player)
  local recipe = assert(player.force.recipes["angels-wire-coil-copper"]
    or player.force.recipes["iron-gear-wheel"])
  local selector = Controller:getView("HMRecipeSelector")
  User.setSetting("filter_show_disable", false)
  User.setSetting("filter_show_hidden", false)
  User.setSetting("filter_show_hidden_player_crafting", false)
  User.setSetting("filter_show_lock_recipes", false)
  User.setSetting("filter_show_excludes_by_rules", false)
  selector:prepare()

  local function listed()
    for _, group in pairs(selector:getListGroupElements()) do
      for _, subgroup in pairs(group) do
        if subgroup["recipe-" .. recipe.name] then return true end
      end
    end
    return false
  end

  local function open()
    local event = {player_index = player.index, action = "OPEN"}
    selector:onBeforeOpen(event)
    local step = selector:createElementLists(event)
    local iterations = 0
    while step.wait do
      iterations = iterations + 1
      assert(iterations < 1000, "Selector list did not finish")
      step = selector:createElementLists(event)
    end
    assert(User.getParameter("next_event") == nil, "List build left a queued event")
  end

  recipe.enabled = false
  open()
  assert(not listed(), "Unavailable recipes must remain excluded")
  assert(next(selector:getListGroup()) ~= nil, "The first opening must build a real list")

  recipe.enabled = true
  open()
  assert(listed(), "Reopening with an empty search must include newly enabled recipes")

  recipe.enabled = false
  open()
  assert(not listed(), "Reopening must also remove recipes that became unavailable")

  log("PASS: recipe selector refreshes availability on reopening with an empty search")
  script.finish_test()
end)
