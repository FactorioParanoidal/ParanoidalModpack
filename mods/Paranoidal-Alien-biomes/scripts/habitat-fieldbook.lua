local journal = require("scripts/habitat-journal")
local catalog = require("prototypes/habitats/catalog")
local GUI, SHORTCUT, PAGE = "ab_habitat_fieldbook", "ab-habitat-fieldbook", 6
local anchors, names, seasons = {}, {}, {spring = true, summer = true, fall = true, winter = true}
for _, habitat in ipairs(catalog) do
  for _, component in ipairs(habitat.components) do
    if component.entity or component.rock then
      local name = "ab-habitat-" .. component.id
      anchors[name] = habitat.id
      names[#names + 1] = name
    end
  end
end
local industrial = {"assembling-machine", "furnace", "mining-drill", "boiler", "generator", "reactor"}

local function state()
  if not storage.ab_fieldbook then storage.ab_fieldbook = journal.new() end
  return storage.ab_fieldbook
end

local function season()
  local api = remote.interfaces.NightBrightness
  if not (api and api.get_season) then return nil end
  local ok, value = pcall(remote.call, "NightBrightness", "get_season")
  return ok and seasons[value] and value or nil
end

local function label(parent, caption, width)
  local result = parent.add{type = "label", caption = caption}
  result.style.single_line = false
  result.style.maximal_width = width
  return result
end

local function title(record)
  local prototype = prototypes.entity[record.anchor_name]
  return prototype and prototype.localised_name or {"ab-fieldbook.missing-anchor"}
end

local function close(player)
  local frame = player.gui.screen[GUI]
  if frame then
    if player.opened == frame then player.opened = nil end
    if frame.valid then frame.destroy() end
  end
end

local function render(player)
  local frame = player.gui.screen[GUI]
  if not frame then return end
  local book = journal.player(state(), player.index)
  local records = journal.sorted(book)
  local pages = math.max(1, math.ceil(#records / PAGE))
  book.page = math.max(1, math.min(book.page or 1, pages))
  local found = 0
  for _ in pairs(book.collection) do found = found + 1 end
  frame.summary.caption = {"ab-fieldbook.summary", found, book.count, journal.PER_PLAYER}
  frame.paging.counter.caption = {"ab-fieldbook.page", book.page, pages}
  frame.paging.previous.enabled = book.page > 1
  frame.paging.next.enabled = book.page < pages
  local content = frame.scroller.content
  content.list.clear()
  if #records == 0 then label(content.list, {"ab-fieldbook.empty"}, content.list.style.maximal_width) end
  for i = (book.page - 1) * PAGE + 1, math.min(book.page * PAGE, #records) do
    local r = records[i]
    local row = content.list.add{type = "button", caption = {"ab-fieldbook.row", title(r),
      r.surface_name, math.floor(r.position.x), math.floor(r.position.y)},
      tags = {ab_fieldbook = true, action = "select", key = r.key}}
    row.style.width = content.list.style.maximal_width
    row.style.height = 48
    row.toggled = book.selected == r.key
  end
  content.details.clear()
  local r = book.selected and book.records[book.selected] or records[1]
  local width = content.details.style.maximal_width
  if r then
    label(content.details, title(r), width).style.font = "default-bold"
    local prototype = prototypes.entity[r.anchor_name]
    if prototype and prototype.localised_description then
      label(content.details, prototype.localised_description, width)
    end
    label(content.details, {"ab-fieldbook.visits", r.visits, math.floor(r.first_tick / 3600),
      math.floor(r.last_tick / 3600)}, width)
    label(content.details, {"ab-fieldbook.season", {"ab-fieldbook.season-" .. (r.season or "none")}}, width)
    if r.clearing_tick then label(content.details, {"ab-fieldbook.clearing"}, width) end
    if r.removed_tick then label(content.details, {"ab-fieldbook.anchor-removed"}, width) end
    if r.industry_tick then label(content.details, {"ab-fieldbook.industry"}, width) end
    label(content.details, {"ab-fieldbook.sector-note"}, width)
  else
    label(content.details, {"ab-fieldbook.instructions"}, width)
  end
end

local function open(player)
  local width = math.max(300, math.min(860, math.floor(player.display_resolution.width / player.display_scale) - 48))
  local narrow = width < 640
  local frame = player.gui.screen.add{type = "frame", name = GUI, direction = "vertical"}
  frame.style.width = width
  frame.auto_center = true
  local header = frame.add{type = "flow", direction = "horizontal"}
  header.drag_target = frame
  header.add{type = "label", caption = {"ab-fieldbook.title"}, style = "frame_title", ignored_by_interaction = true}
  local drag = header.add{type = "empty-widget", style = "draggable_space_header"}
  drag.style.horizontally_stretchable = true
  drag.drag_target = frame
  header.add{type = "sprite-button", sprite = "utility/close", style = "frame_action_button",
    tooltip = {"ab-fieldbook.close"}, tags = {ab_fieldbook = true, action = "close"}}
  label(frame, {"ab-fieldbook.instructions"}, width - 32)
  frame.add{type = "label", name = "summary"}
  local actions = frame.add{type = "flow", direction = "horizontal"}
  actions.add{type = "button", caption = {"ab-fieldbook.observe"}, tooltip = {"ab-fieldbook.observe-tooltip"},
    tags = {ab_fieldbook = true, action = "observe"}}
  actions.add{type = "button", caption = {"ab-fieldbook.refresh"}, tags = {ab_fieldbook = true, action = "refresh"}}
  local scroller = frame.add{type = "scroll-pane", name = "scroller", horizontal_scroll_policy = "never"}
  scroller.style.maximal_height = math.max(100, math.min(420, math.floor(player.display_resolution.height / player.display_scale) - 245))
  scroller.style.horizontally_stretchable = true
  local content = scroller.add{type = "flow", name = "content", direction = narrow and "vertical" or "horizontal"}
  local list = content.add{type = "flow", name = "list", direction = "vertical"}
  list.style.maximal_width = narrow and width - 48 or 300
  local details = content.add{type = "flow", name = "details", direction = "vertical"}
  details.style.maximal_width = narrow and width - 48 or width - 354
  local paging = frame.add{type = "flow", name = "paging", direction = "horizontal"}
  paging.add{type = "button", name = "previous", caption = {"ab-fieldbook.previous"}, tags = {ab_fieldbook = true, action = "previous"}}
  paging.add{type = "label", name = "counter"}
  paging.add{type = "button", name = "next", caption = {"ab-fieldbook.next"}, tags = {ab_fieldbook = true, action = "next"}}
  player.opened = frame
  render(player)
end

local function nearest(player, radius)
  local position, surface = player.physical_position, player.physical_surface
  local selected = player.selected
  if selected and selected.valid and anchors[selected.name] and selected.surface.index == surface.index then
    local p = selected.position
    if (p.x - position.x)^2 + (p.y - position.y)^2 <= radius^2 then return selected end
  end
  local result, distance
  -- Deliberate examination only: take the full small-radius set so "nearest"
  -- remains true even when a fixture or another mod has crowded the anchors.
  for _, entity in ipairs(surface.find_entities_filtered{position = position, radius = radius, name = names}) do
    local p = entity.position
    local d = (p.x - position.x)^2 + (p.y - position.y)^2
    if not result or d < distance or d == distance and (p.x < result.position.x
      or p.x == result.position.x and (p.y < result.position.y
      or p.y == result.position.y and entity.name < result.name)) then result, distance = entity, d end
  end
  return result
end

local function accent(player, current_season, entity)
  local book = journal.player(state(), player.index)
  local option = settings.get_player_settings(player)["ab-habitat-seasonal-sounds"]
  if not current_season or not option.value or game.tick < book.next_sound
    or entity.name ~= "ab-habitat-root-colony" or entity.surface.name ~= "nauvis"
    or player.surface.index ~= player.physical_surface.index then return end
  -- Native clips keep their day/night thresholds. No surface/calendar mutations.
  player.play_sound{path = "ab-habitat-season-" .. current_season, position = entity.position,
    volume_modifier = current_season == "winter" and 0.10 or 0.25, override_sound_type = "environment"}
  book.next_sound = game.tick + 2700
end

local function observe(player)
  local entity = nearest(player, 12)
  if not entity then
    player.create_local_flying_text{text = {"ab-fieldbook.no-anchor"}, create_at_cursor = true}
    return
  end
  local current_season = season()
  local industry = #entity.surface.find_entities_filtered{position = entity.position, radius = 32,
    type = industrial, force = player.force, limit = 1} > 0
  local book = journal.player(state(), player.index)
  journal.observe(state(), player.index, {habitat = anchors[entity.name], anchor_name = entity.name,
    surface_index = entity.surface.index, surface_name = entity.surface.name, position = entity.position,
    season = current_season, industry = industry}, game.tick)
  book.page = 1
  accent(player, current_season, entity)
  render(player)
end

script.on_event(defines.events.on_lua_shortcut, function(event)
  if event.prototype_name ~= SHORTCUT then return end
  local player = game.get_player(event.player_index)
  if player.gui.screen[GUI] then close(player) else open(player) end
end)

script.on_event(defines.events.on_gui_click, function(event)
  local element = event.element
  if not (element and element.valid and element.tags.ab_fieldbook) then return end
  local player = game.get_player(event.player_index)
  local frame = player.gui.screen[GUI]
  if not frame then return end
  local parent = element
  while parent and parent ~= frame do parent = parent.parent end
  if parent ~= frame then return end
  local action = element.tags.action
  if action == "close" then close(player); return end
  local book = journal.player(state(), player.index)
  if action == "observe" then observe(player); return end
  if action == "select" and book.records[element.tags.key] then book.selected = element.tags.key end
  if action == "previous" then book.page = book.page - 1 end
  if action == "next" then book.page = book.page + 1 end
  render(player)
end)

script.on_event(defines.events.on_gui_closed, function(event)
  if event.element and event.element.valid and event.element.name == GUI then close(game.get_player(event.player_index)) end
end)

script.on_event(defines.events.on_player_changed_position, function(event)
  local player = game.get_player(event.player_index)
  if not settings.get_player_settings(player)["ab-habitat-seasonal-sounds"].value then return end
  local book = journal.player(state(), player.index)
  if game.tick < book.next_probe or game.tick < book.next_sound or player.physical_surface.name ~= "nauvis" then return end
  local p = player.physical_position
  local sector = player.physical_surface.index .. ":" .. math.floor(p.x / 32) .. ":" .. math.floor(p.y / 32)
  if sector == book.probe_cell then return end
  book.probe_cell, book.next_probe = sector, game.tick + 600
  local current_season = season()
  if not current_season then return end
  local entity = player.physical_surface.find_entities_filtered{position = p, radius = 16,
    name = "ab-habitat-root-colony", limit = 1}[1]
  if entity then accent(player, current_season, entity) end
end)

local removal_filters = {{filter = "type", type = "tree"}}
for _, name in ipairs(names) do removal_filters[#removal_filters + 1] = {filter = "name", name = name} end
local function removed(event)
  if not storage.ab_fieldbook or storage.ab_fieldbook.count == 0 then return end
  local entity = event.entity
  if not (entity and entity.valid) then return end
  journal.removed(state(), {surface_index = entity.surface.index, position = entity.position,
    name = entity.name, tree = entity.type == "tree",
    reason = event.name == defines.events.on_entity_died and "destroyed" or "removed"}, game.tick)
end
for _, event in ipairs({defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity,
  defines.events.on_entity_died, defines.events.script_raised_destroy}) do
  script.on_event(event, removed, removal_filters)
end

script.on_init(function() state() end)
script.on_configuration_changed(function()
  journal.reindex(state())
  local missing = {}
  for index, book in pairs(state().players) do
    if not game.get_player(index) then journal.drop_player(state(), index)
    else
      for _, record in pairs(book.records) do
        if not game.surfaces[record.surface_index] then missing[record.surface_index] = true end
      end
    end
  end
  for surface in pairs(missing) do journal.drop_surface(state(), surface) end
  for _, player in pairs(game.players) do close(player) end
end)
script.on_event(defines.events.on_player_removed, function(event) journal.drop_player(state(), event.player_index) end)
script.on_event({defines.events.on_pre_surface_deleted, defines.events.on_surface_cleared}, function(event)
  journal.drop_surface(state(), event.surface_index)
end)
script.on_event(defines.events.on_player_changed_force, function(event)
  -- The notebook is personal: changing/merging forces neither shares nor erases it.
  close(game.get_player(event.player_index))
end)
script.on_event({defines.events.on_player_display_resolution_changed, defines.events.on_player_display_scale_changed}, function(event)
  local player = game.get_player(event.player_index)
  if player.gui.screen[GUI] then close(player); open(player) end
end)
