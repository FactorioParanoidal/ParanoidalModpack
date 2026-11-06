local constants = require "scripts.constants"
local config = require "scripts.config"
local log = require("scripts.logger").control
local cc_util = require "scripts.cc_util"
local cc_gui = require "scripts.gui"
local cc_remote = require "scripts.remote"
local CybersynCombinator = require "scripts.combinator"

local function init_cs_default(name)
  if not settings.global[name] then return end
  local num = tonumber(settings.global[name].value)
  if not num then return end
  config.cs_signals[name].default = num
  log:debug("default value for ", name, " initialized to ", num)
end

init_cs_default(constants.SETTINGS.CS_REQUEST_THRESHOLD)
init_cs_default(constants.SETTINGS.CS_FLUID_REQUEST_THRESHOLD)
init_cs_default(constants.SETTINGS.CS_PRIORITY)
init_cs_default(constants.SETTINGS.CS_LOCKED_SLOTS)
init_cs_default(constants.SETTINGS.CS_RESERVED_FLUID_CAPACITY)

local function sort_all_combinators()
  log:info("Sorting all Cybersyn Constant Combinators")
  ---@type EntitySearchFilters
  local filter = {
    name = constants.ENTITY_NAME
  }
  for surface_name, surface in pairs(game.surfaces) do
    log:info("Processing surface ", surface_name)
    local entities = surface.find_entities_filtered(filter)
    for _, entity in pairs(entities) do
      if entity.valid then
        log:debug("Sorting combinator ", entity.unit_number)
        local combinator = CybersynCombinator:new(entity, false)
        combinator:sort_signals()
      end
    end
    log:info("Done with surface ", surface_name)
  end
  log:info("Done sorting combinators")
end

script.on_configuration_changed(function(data)
  -- local previous_is_old_map = data.old_version and data.old_version:match("^1%.")
  -- local current_is_new_map = data.new_version and data.new_version:match("^[^01]%.")
  local cc_changes = data.mod_changes[constants.MOD_NAME]
  -- local cc_old_ver_pre2 = cc_changes and cc_changes.old_version and (cc_changes.old_version:match("^[01]%.") or cc_changes.old_version == "2.0.0")
  -- local cc_new_ver_post2 = cc_changes and cc_changes.new_version and cc_changes.new_version:match("^[^01]%.")
  -- if (previous_is_old_map and current_is_new_map) or (cc_old_ver_pre2 and cc_new_ver_post2) then
  --   log:info("Map or mod version upgraded from old v0 or v1 (or v2.0.0), sorting combinators")
  --   sort_all_combinators()
  -- end
  if not cc_changes then return end
  for player_index, player in pairs(game.players) do
    player.request_translation({ "gui-train.empty-train-group" })
    if player.gui.screen[cc_gui.WINDOW_ID] then
      cc_gui:close(player_index, true)
    end
  end
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  local name = event.setting
  local tbl = config.cs_signals[name]
  if not tbl then return end
  local num = tonumber(settings.global[name].value)
  if not num then return end
  tbl.default = num
  log:debug("default value for ", name, " changed to ", num)
end)

local entity_event_filters = {
  { filter = "type", type = "constant-combinator" },
  { filter = "name", name = constants.ENTITY_NAME, mode = "and" },
  { filter = "ghost_type", type = "constant-combinator", mode = "or" },
  { filter = "ghost_name", name = constants.ENTITY_NAME, mode = "and" }
}

script.on_event(defines.events.on_player_mined_entity, function(event)
  local player = game.get_player(event.player_index)
  local entity = event.entity
  if not player or not entity then return end
  local pname = player.name
  log:debug(entity.name, "[", entity.unit_number, "] destroyed by ", pname)
  cc_gui:on_entity_destroyed(entity.unit_number)
  if storage.combinator_sections[entity.unit_number] then
    storage.combinator_sections[entity.unit_number] = nil
  end
end, entity_event_filters)

script.on_event(defines.events.on_robot_mined_entity, function(event)
  local entity = event.entity
  if not entity then return end
  log:debug(entity.name, "[", entity.unit_number, "] destroyed by bot")
  cc_gui:on_entity_destroyed(entity.unit_number)
  if storage.combinator_sections[entity.unit_number] then
    storage.combinator_sections[entity.unit_number] = nil
  end
end, entity_event_filters)

script.on_event(defines.events.script_raised_destroy, function(event)
  local entity = event.entity
  if not entity then return end
  log:debug(entity.name, "[", entity.unit_number, "] destroyed by script")
  cc_gui:on_entity_destroyed(entity.unit_number)
  if storage.combinator_sections[entity.unit_number] then
    storage.combinator_sections[entity.unit_number] = nil
  end
end, entity_event_filters)

script.on_event(defines.events.on_built_entity, function(event)
  local player = game.get_player(event.player_index)
  local entity = event.entity
  cc_gui:on_entity_built(entity)
  if not player or not entity then return end
  local pname = player.name
  log:debug(entity.name, "[", entity.unit_number, "] built by ", pname)
  local disable = settings.get_player_settings(player)[constants.SETTINGS.DISABLE_BUILT].value
  local combinator = CybersynCombinator:new(entity, true)
  if combinator:get_item_section_count() == 0 then
    combinator:add_item_section()
  end
  if not disable then return end
  combinator:disable()
  log:debug(entity.name, "[", entity.unit_number, "] disabled due to per-player setting")
end, entity_event_filters)

--- @param event EventData.script_raised_built|EventData.script_raised_revive
local function on_script_raised_built_or_revive(event)
  local entity = event.entity
  if not entity then return end
  cc_gui:on_entity_built(entity)
  local player = entity.last_user
  local disable = false
  if player then
    log:debug("found relevant player in script_raised_built_or_revive")
    disable = settings.get_player_settings(player)[constants.SETTINGS.DISABLE_BUILT].value == true
  else
    disable = settings.global[constants.SETTINGS.DISABLE_NONPLAYER_BUILT].value == true
  end
  local combinator = CybersynCombinator:new(entity, true)
  if combinator:get_item_section_count() == 0 then
    combinator:add_item_section()
  end
  if not disable then return end
  combinator:disable()
  log:debug(entity.name, "[", entity.unit_number, "] disabled due to per-player or global setting")
end

script.on_event(defines.events.script_raised_built, on_script_raised_built_or_revive, entity_event_filters)
script.on_event(defines.events.script_raised_revive, on_script_raised_built_or_revive, entity_event_filters)

script.on_event(defines.events.on_robot_built_entity, function(event)
  local entity = event.entity
  if not entity then return end
  cc_gui:on_entity_built(entity)
  local robot = event.robot
  local player = entity.last_user or robot.last_user
  local disable = false
  if player then
    log:debug("found relevant player in robot_built_entity")
    disable = settings.get_player_settings(player)[constants.SETTINGS.DISABLE_BUILT].value == true
  else
    disable = settings.global[constants.SETTINGS.DISABLE_NONPLAYER_BUILT].value == true
  end
  local combinator = CybersynCombinator:new(entity, true)
  if combinator:get_item_section_count() == 0 then
    combinator:add_item_section()
  end
  if not disable then return end
  combinator:disable()
  log:debug(entity.name, "[", entity.unit_number, "] disabled due to per-player or global setting")
end, entity_event_filters)

---@param source LuaEntity
---@param dest LuaEntity
local function on_cc_pasted(source, dest)
  local source_name = source.name == "entity-ghost" and source.ghost_name or source.name
  local dest_name = dest.name == "entity-ghost" and dest.ghost_name or dest.name
  local needs_sort = source_name ~= dest_name
  local dest_combinator = CybersynCombinator:new(dest, needs_sort)
  if needs_sort then return end
  local src_combinator = CybersynCombinator:new(source, false)
  dest_combinator:set_section_index(CybersynCombinator.CYBERSYN_SECTION_ID,
    src_combinator:get_or_create_section(CybersynCombinator.CYBERSYN_SECTION_ID).index)
  dest_combinator:set_section_index(CybersynCombinator.NETWORK_SECTION_ID,
    src_combinator:get_or_create_section(CybersynCombinator.NETWORK_SECTION_ID).index)
end

---@param player_index integer
---@param source LuaEntity
---@param dest LuaEntity
local function on_am_pasted(player_index, source, dest)
  local speed = source.crafting_speed
  local recipe, quality = source.get_recipe()
  local combinator = CybersynCombinator:new(dest, false)
  combinator:remove_item_sections()
  if not recipe then return end
  local negative = settings.get_player_settings(player_index)[constants.SETTINGS.NEGATIVE_SIGNALS].value == true
  local quality_name = quality and quality.name or "normal"
  local crafting_time = recipe.energy
  local craft_count = 30 / (crafting_time / speed)
  local section = combinator:add_item_section()
  if not section then return end
  for i, ingredient in pairs(recipe.ingredients) do
    local count = math.ceil(ingredient.amount * craft_count)
    local ingredient_quality = ingredient.type == "fluid" and "normal" or quality_name
    if negative then count = count * -1 end
    ---@type Signal
    local signal = { count = count, signal = { type = ingredient.type, name = ingredient.name, quality = ingredient_quality } }
    combinator:set_item_slot(section.index, i, signal)
  end
end

script.on_event(defines.events.on_entity_settings_pasted, function(event)
  local src = event.source
  if not src or not src.valid then return end
  local dest = event.destination
  if not dest or not dest.valid then return end
  if src.unit_number == dest.unit_number then return end
  local dest_type = dest.name == "entity-ghost" and dest.ghost_type or dest.type
  if dest_type ~= "constant-combinator" then return end
  local dest_name = dest.name == "entity-ghost" and dest.ghost_name or dest.name
  if dest_name ~= constants.ENTITY_NAME then return end
  if not src or not src.valid then return end
  local src_type = src.name == "entity-ghost" and src.ghost_type or src.type
  local src_name = src.name == "entity-ghost" and src.ghost_name or src.name
  log:debug("Paste from ", src_name, " (", src_type, ") [", src.unit_number, "] to ", dest.unit_number)
  if src_type == "constant-combinator" then
    on_cc_pasted(src, dest)
  elseif src_type == "assembling-machine" then
    on_am_pasted(event.player_index, src, dest)
  end
end)

script.on_event(defines.events.on_string_translated, function(event)
  log:debug("on_string_translated: ", serpent.line(event))
  if not event.translated then return end
  if not type(event.localised_string) == "table" then return end
  local key = event.localised_string[1]
  if key ~= "gui-train.empty-train-group" then return end
  local player_data = cc_util.get_player_data(event.player_index)
  if not player_data then return end
  if not player_data.translations then player_data.translations = {} end
  player_data.translations[key] = event.result
  log:debug("on_string_translated: ", key, " = ", event.result)
end)

script.on_event(defines.events.on_player_joined_game, function(event)
  local player = game.get_player(event.player_index)
  if not player then return end
  log:debug("Player ", event.player_index, " joined, requesting translation")
  player.request_translation({ "gui-train.empty-train-group" })
end)

script.on_event(defines.events.on_player_locale_changed, function(event)
  local player = game.get_player(event.player_index)
  if not player then return end
  log:debug("Locale changed for player ", event.player_index, ", requesting translation")
  player.request_translation({ "gui-train.empty-train-group" })
end)

local function sort_combinator(command)
  local player = game.get_player(command.player_index)
  if not player then return end
  local entity = player.selected
  if not entity or not entity.valid then return end
  if entity.name ~= constants.ENTITY_NAME then return end
  local combinator = CybersynCombinator:new(entity, false)
  combinator:sort_signals()
end

commands.add_command("cc_sort", { "cybersyn-combinator-commands.sort" }, sort_combinator)
commands.add_command("cc_sort_all", { "cybersyn-combinator-commands.sort-all" }, sort_all_combinators)

cc_gui:register()
cc_remote:register()
