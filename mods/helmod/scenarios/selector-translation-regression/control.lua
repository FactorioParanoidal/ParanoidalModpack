-- Run with --test-scenario helmod/selector-translation-regression and locale=ru.
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

local selector, player, target, stage, started, original_name, manual_request

local function listed(name)
  for _, group in pairs(selector:getListGroupElements()) do
    for _, subgroup in pairs(group) do
      if subgroup["fluid-" .. (name or target)] then return true end
    end
  end
  return false
end

local function filterField()
  local panel = selector:getFilterPanel()["filter-box-panel"]
  local field = panel[selector.classname .. "=recipe-filter=filter-text"]
    or panel[selector.classname .. "=recipe-filter=filter-value=onchange"]
  return field
end

local function open()
  local event = {player_index = player.index, action = "OPEN", item4 = target}
  selector:open(event)
  selector:update(event)
end

script.on_event(defines.events.on_player_created, function(event)
  player = game.get_player(event.player_index)
  Player.set(player)
  selector = Controller:getView("HMRecipeSelector")
  target = prototypes.fluid["angels-water-viscous-mud"] and "angels-water-viscous-mud" or "water"
  User.setParameter("filter-language", "left")
  User.setParameter("auto-pause", false)
  User.setSetting("filter_show_disable", true)
  User.setSetting("filter_show_lock_recipes", true)
  User.resetTranslate()
  stage, started = "cold", game.tick
  open()
  game.tick_paused = false
end)

script.on_event(defines.events.on_player_joined_game, function()
  game.tick_paused = false
end)

script.on_event(defines.events.on_string_translated, function(event)
  Player.set(game.get_player(event.player_index))
  User.addTranslate(event)
end)

script.on_event(defines.events.on_tick, function()
  if not player then return end
  Player.set(player)
  assert(game.tick - started < 1800, "Selector translation did not finish")
  local queued = User.getParameter("next_event")
  if queued then
    User.setParameter("next_event", nil)
    selector:open(queued.event)
    selector:update(queued.event)
    return
  end

  if stage == "manual" and User.get("translated_ids")[manual_request] ~= nil then return end
  local expected = User.getTranslate(target)
  if stage == "system" or stage == "failed" then
    expected = target
  elseif stage == "manual" then
    expected = "несуществующий-рецепт"
  else
    assert(expected ~= target, "The test requires a real translated fluid name")
  end
  assert(selector:getFilter() == expected,
    stage .. ": the first opening must resolve the shortcut filter after translation")
  assert(filterField().text == expected, stage .. ": the search field must display the selected name")
  if stage == "manual" then
    assert(next(selector:getListGroupElements()) == nil, "A late translation must not replace the manual search results")
    log("PASS: manual search text and empty results survive the late shortcut translation")
  else
    assert(listed(), stage .. ": the pumping source must be listed on the first opening")
    log("PASS: " .. stage .. " translation cache; filter=" .. expected .. "; pumping source listed")
  end

  if stage == "cold" then
    stage = "warm"
    selector:close()
    open()
  elseif stage == "warm" then
    stage = "partial"
    selector:close()
    User.resetTranslate()
    User.get("translated")["unrelated-item"] = "Другой предмет"
    open()
  elseif stage == "partial" then
    stage = "system"
    selector:close()
    User.resetTranslate()
    User.setParameter("filter-language", "right")
    open()
  elseif stage == "system" then
    stage = "composite"
    selector:close()
    User.resetTranslate()
    User.setParameter("filter-language", "left")
    User.get("translated")["unrelated-item"] = "Другой предмет"
    local translations = Cache.getData(selector.classname, "list_translate")
    original_name = translations[target]
    translations[target] = {"", original_name}
    open()
  elseif stage == "composite" then
    stage = "failed"
    selector:close()
    User.resetTranslate()
    User.get("translated")["unrelated-item"] = "Другой предмет"
    Cache.getData(selector.classname, "list_translate")[target] = {"fluid-name.missing-translation-regression"}
    open()
  elseif stage == "failed" then
    stage = "manual"
    selector:close()
    Cache.getData(selector.classname, "list_translate")[target] = original_name
    open()
    local queued = assert(User.getParameter("next_event"), "The target translation must still be pending")
    manual_request = assert(queued.event.filter_translation_id)
    player.admin = true
    filterField().text = "несуществующий-рецепт"
    selector:onEvent({player_index = player.index, action = "recipe-filter", element = filterField()})
    assert(User.getParameter("next_event").event.item4 == nil,
      "Typing a new search must replace the queued shortcut search")
  else
    script.finish_test()
  end
end)
