-- Native, read-only Atlas. View state and translations never decide shared game outcomes.
local events = require("scripts.events")
local mod_gui = require("mod-gui")
local model = require("scripts.atlas_model")
local M = {}
local ROOT = "pd_atlas"
local PAGE = 12
local VIEWS = {"cards", "chronicle", "records", "archive"}
local translation_requests, pending, requested_keys = {}, {}, {}
local upper, lower = "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ", "абвгдеёжзийклмнопрстуфхцчшщъыьэюя"
local russian = {}
for i = 1, #upper, 2 do russian[upper:sub(i, i + 1)] = lower:sub(i, i + 1) end
local function fold(value) return value:lower():gsub("[\208\209][\128-\191]", russian) end
local function state(player)
  storage.atlas = storage.atlas or {players = {}}
  local all = storage.atlas.players
  local s = all[player.index]
  if not s then s = {view = 1, theme = 1, filter = 1, query = "", page = 1, translations = {}, epoch = 0};all[player.index] = s end
  return s
end
local function schedule(player)
  local s = state(player)
  if not s.due then s.due = game.tick + 15 end
end
local function frame_of(player) return player.gui.screen[ROOT] end
local function translate(player, rows)
  local s = state(player)
  for _, row in ipairs(rows) do
    local id = row.translation_id or row.id
    local token = player.index .. ":" .. s.epoch .. ":" .. id
    if (s.translations[id] == nil or s.translations[id] == true) and not requested_keys[token] then
      s.translations[id] = true -- unfinished requests are retried after load; failures remain false
      local request = player.request_translation(row.title)
      translation_requests[request] = {player = player.index, id = id, epoch = s.epoch, token = token}
      requested_keys[token] = true
      pending[player.index] = (pending[player.index] or 0) + 1
    end
  end
end
local function number(value)
  if value == nil then return "—" end
  return string.format("%.4g", value)
end
local function timestamp(tick)
  if type(tick) ~= "number" or tick < 0 then return {"atlas.time-unknown"} end
  local seconds = math.floor(tick / 60)
  return string.format("%d:%02d:%02d", math.floor(seconds / 3600), math.floor(seconds / 60) % 60, seconds % 60)
end
local function sprite(parent, path)
  path = path and helpers.is_valid_sprite_path(path) and path or "utility/questionmark"
  local image = parent.add{type = "sprite", name = "icon", sprite = path}
  image.style.width, image.style.height = 40, 40
  return image
end
local function label(parent, caption, width, bold, name)
  local spec = {type = "label", name = name, caption = caption or ""}
  if bold then spec.style = "bold_label" end
  local result = parent.add(spec)
  result.style.single_line = false
  result.style.maximal_width = width
  return result
end
local function rows_for(player, s)
  local view = VIEWS[s.view]
  if view == "cards" then return model.cards(player, false)
  elseif view == "chronicle" then return model.chronicle(player)
  elseif view == "records" then return model.records()
  else
    local rows = model.cards(player, true)
    for _, row in ipairs(model.native_archive()) do rows[#rows + 1] = row end
    return rows
  end
end
local function matches(s, row)
  if VIEWS[s.view] == "cards" and s.theme > 1 and row.theme ~= model.themes[s.theme - 1] then return false end
  if VIEWS[s.view] == "cards" or VIEWS[s.view] == "archive" then
    if s.filter == 2 and row.status == "unavailable" then return false end
    if s.filter == 3 and row.status ~= "complete" then return false end
    if s.filter == 4 and row.status ~= "unknown" and row.status ~= "native" then return false end
  end
  if s.query == "" then return true end
  local translated = s.translations[row.translation_id or row.id]
  local text = row.id .. " " .. (type(translated) == "string" and translated or "")
  return fold(text):find(fold(s.query), 1, true) ~= nil
end
local function layout(player, frame)
  local scale = player.display_scale
  local width = math.max(360, math.min(940, math.floor(player.display_resolution.width / scale) - 56))
  local height = math.max(300, math.min(750, math.floor(player.display_resolution.height / scale) - 72))
  frame.style.width, frame.style.height = width, height
  frame.body.style.maximal_height = math.max(100, height - 230)
  frame.body.style.width = width - 28
  frame.searchbar.pd_atlas_search.style.width = math.max(120, width - 220)
  frame.scope.style.maximal_width = width - 28
  frame.notice.style.maximal_width = width - 28
  frame.pager.page.style.maximal_width = width - 180
  return width
end
local function draw(player)
  local frame = frame_of(player)
  if not (frame and frame.valid) then model.clear_request(player.index);return end
  local s = state(player)
  local width = layout(player, frame)
  local view = VIEWS[s.view]
  local rows = rows_for(player, s)
  translate(player, rows)
  local filtered = {}
  for _, row in ipairs(rows) do if matches(s, row) then filtered[#filtered + 1] = row end end
  local pages = math.max(1, math.ceil(#filtered / PAGE))
  s.page = math.max(1, math.min(s.page, pages))
  local force = select(2, get_display_storage_force(player.force)) or player.force
  frame.scope.caption = {"atlas.scope", force.name}
  frame.toolbar.pd_atlas_theme.visible = view == "cards"
  frame.searchbar.pd_atlas_filter.visible = view == "cards" or view == "archive"
  frame.notice.caption = {"atlas.notice-" .. view}
  frame.pending.caption = (pending[player.index] or 0) > 0 and {"atlas.translating"} or ""
  frame.pager.page.caption = {"atlas.page", s.page, pages, #filtered}
  frame.pager.previous.enabled, frame.pager.next.enabled = s.page > 1, s.page < pages
  local scroll, visible, keys = frame.body, {}, {view}
  for i = (s.page - 1) * PAGE + 1, math.min(s.page * PAGE, #filtered) do
    local row = filtered[i];visible[#visible + 1] = row;keys[#keys + 1] = row.id
  end
  local signature = table.concat(keys, "|")
  local rebuild = s.signature ~= signature
  for i = 1, #visible do
    local card = scroll["row" .. i]
    if not (card and card.content and card.content.title) then rebuild = true;break end
  end
  if rebuild then
    scroll.clear();scroll.scroll_to_top();s.signature = signature
    for i, row in ipairs(visible) do
      local card = scroll.add{type = "frame", name = "row" .. i, direction = "horizontal", style = "inside_shallow_frame_with_padding"}
      card.style.horizontally_stretchable = true
      sprite(card, row.sprite)
      local text = card.add{type = "flow", name = "content", direction = "vertical"}
      text.style.horizontally_stretchable = true
      label(text, row.title, width - 112, true, "title")
      for line = 1, 4 do label(text, "", width - 112, false, "line" .. line) end
    end
    if #visible == 0 then
      label(scroll, view == "chronicle" and s.query == "" and {"atlas.empty-chronicle"} or {"atlas.empty"}, width - 60)
    end
  end
  for i, row in ipairs(visible) do
    local card = scroll["row" .. i]
    card.icon.sprite = row.sprite and helpers.is_valid_sprite_path(row.sprite) and row.sprite or "utility/questionmark"
    local text = card.content
    text.title.caption, text.title.tooltip = row.title, row.id
    text.title.style.maximal_width = width - 112
    local lines = {}
    if view == "records" then
      local value = model.record_value(player, row)
      lines[1] = value and {"atlas.record-values", number(value.produced), number(value.consumed)} or {"atlas.wait-statistics"}
      lines[2] = {"atlas.native-stages", row.native_stages}
      lines[3] = value and {"atlas.record-updated", timestamp(value.tick)} or nil
    elseif view == "chronicle" then
      local time = row.lower_bound_tick and {"atlas.time-estimated", timestamp(row.lower_bound_tick), timestamp(row.tick)} or timestamp(row.tick)
      lines[1] = {"atlas.chronicle-row", number(row.quantity), time}
    else
      lines[1] = {"atlas.status-" .. row.status}
      lines[2] = row.stages and {"", {"atlas.scope-" .. row.scope}, " · ", {"atlas.stages", row.completed, row.stages}}
      lines[3] = row.value ~= nil and row.target and {"atlas.progress", number(row.value), number(row.target)} or nil
      lines[4] = row.description
    end
    for line = 1, 4 do
      local element = text["line" .. line]
      element.caption, element.visible = lines[line] or "", lines[line] ~= nil
      element.style.maximal_width = width - 112
    end
  end
  if view == "records" then model.request_records(player, visible) else model.clear_request(player.index) end
  s.last_refresh, s.due = game.tick, nil
end
local function ensure_button(player)
  local flow = mod_gui.get_button_flow(player)
  if not flow.pd_atlas_toggle then
    flow.add{type = "sprite-button", name = "pd_atlas_toggle", sprite = "utility/bookmark",
      style = mod_gui.button_style, tooltip = {"atlas.title"}, tags = {pd_atlas = "toggle"}}
  end
end
function M.close(player)
  local frame = frame_of(player)
  local s = state(player)
  if frame and frame.valid then
    s.location = frame.location
    s.display = {width = player.display_resolution.width, height = player.display_resolution.height, scale = player.display_scale}
    if player.opened == frame then player.opened = nil end
    if frame.valid then frame.destroy() end
  end
  s.due = nil;model.clear_request(player.index)
end
function M.open(player)
  local old = frame_of(player)
  if old and old.valid then old.bring_to_front();player.opened = old;return end
  ensure_button(player)
  local s = state(player)
  s.signature = nil
  local frame = player.gui.screen.add{type = "frame", name = ROOT, direction = "vertical"}
  local title = frame.add{type = "flow", direction = "horizontal"}
  title.add{type = "label", caption = {"atlas.title"}, style = "frame_title", ignored_by_interaction = true}
  local drag = title.add{type = "empty-widget", style = "draggable_space_header"}
  drag.style.horizontally_stretchable = true;drag.style.height = 24;drag.drag_target = frame
  title.add{type = "sprite-button", sprite = "utility/close", style = "frame_action_button", tags = {pd_atlas = "close"}}
  local toolbar = frame.add{type = "flow", name = "toolbar", direction = "horizontal"}
  local modes = {};for _, view in ipairs(VIEWS) do modes[#modes + 1] = {"atlas.view-" .. view} end
  toolbar.add{type = "drop-down", name = "pd_atlas_view", items = modes, selected_index = s.view, tags = {pd_atlas = "view"}}
  local theme_items = {{"atlas.all-themes"}}
  for _, key in ipairs(model.themes) do theme_items[#theme_items + 1] = {"atlas.theme-" .. key} end
  toolbar.add{type = "drop-down", name = "pd_atlas_theme", items = theme_items, selected_index = s.theme, tags = {pd_atlas = "theme"}}
  local search = frame.add{type = "flow", name = "searchbar", direction = "horizontal"}
  search.add{type = "drop-down", name = "pd_atlas_filter", items = {{"atlas.filter-all"}, {"atlas.filter-available"},
    {"atlas.filter-complete"}, {"atlas.filter-unknown"}}, selected_index = s.filter, tags = {pd_atlas = "filter"}}
  search.add{type = "textfield", name = "pd_atlas_search", text = s.query, tooltip = {"atlas.search-help"}, tags = {pd_atlas = "search"}}
  search.add{type = "sprite-button", sprite = "utility/reset", style = "tool_button", tooltip = {"atlas.reset"}, tags = {pd_atlas = "reset"}}
  frame.add{type = "label", name = "scope", caption = "", tooltip = {"atlas.scope-help"}}
  label(frame, "", 800, false, "notice")
  frame.add{type = "label", name = "pending", caption = ""}
  local body = frame.add{type = "scroll-pane", name = "body", style = "naked_scroll_pane", direction = "vertical"}
  body.style.vertically_stretchable = true
  local pager = frame.add{type = "flow", name = "pager", direction = "horizontal"}
  pager.add{type = "button", name = "previous", caption = {"atlas.previous"}, tags = {pd_atlas = "previous"}}
  pager.add{type = "label", name = "page", caption = ""}
  pager.add{type = "button", name = "next", caption = {"atlas.next"}, tags = {pd_atlas = "next"}}
  toolbar.pd_atlas_view.style.width, toolbar.pd_atlas_theme.style.width = 160, 160
  search.pd_atlas_filter.style.width = 140
  pager.previous.style.width, pager.next.style.width = 70, 70
  pager.page.style.single_line = false
  draw(player)
  local display = s.display
  if s.location and display and display.width == player.display_resolution.width and display.height == player.display_resolution.height
    and display.scale == player.display_scale then frame.location = s.location else frame.force_auto_center() end
  player.opened = frame
  frame.searchbar.pd_atlas_search.focus()
end
function M.toggle(player) if frame_of(player) then M.close(player) else M.open(player) end end
function M.on_init()
  storage.atlas = storage.atlas or {players = {}}
  for _, player in pairs(game.players) do ensure_button(player) end
end
function M.on_configuration_changed()
  for _, player in pairs(game.players) do
    local s = state(player);s.translations = {};s.epoch = s.epoch + 1;pending[player.index] = 0
    ensure_button(player)
    if frame_of(player) then M.close(player);M.open(player) end
  end
end
function M.poll(tick)
  for index, s in pairs(storage.atlas and storage.atlas.players or {}) do
    local player = game.get_player(index)
    if player and player.valid and frame_of(player) then
      if (s.due and tick >= s.due) or tick >= (s.last_refresh or 0) + 180 then draw(player) end
    else model.clear_request(index) end
  end
end
local function action(event)
  local element = event.element
  if not (element and element.valid) then return end
  local tag = element.tags.pd_atlas
  if not tag then return end
  local player = game.get_player(event.player_index)
  local s = state(player)
  if tag == "toggle" then M.toggle(player);return
  elseif tag == "close" then M.close(player);return
  elseif tag == "previous" then s.page = math.max(1, s.page - 1)
  elseif tag == "next" then s.page = s.page + 1
  elseif tag == "reset" then s.query = "";s.page = 1;frame_of(player).searchbar.pd_atlas_search.text = ""
  elseif tag == "view" then s.view = element.selected_index;s.page = 1
  elseif tag == "theme" then s.theme = element.selected_index;s.page = 1
  elseif tag == "filter" then s.filter = element.selected_index;s.page = 1
  elseif tag == "search" then s.query = element.text;s.page = 1;schedule(player);return end
  draw(player)
end
events.on(defines.events.on_gui_click, action)
events.on(defines.events.on_gui_selection_state_changed, action)
events.on(defines.events.on_gui_text_changed, action)
events.on(defines.events.on_gui_confirmed, function(event)
  if event.element and event.element.valid and event.element.name == "pd_atlas_search" then draw(game.get_player(event.player_index)) end
end)
events.on(defines.events.on_gui_closed, function(event)
  local player = game.get_player(event.player_index)
  if event.element and event.element.valid and event.element == frame_of(player) then M.close(player) end
end)
events.on(defines.events.on_gui_location_changed, function(event)
  local player = game.get_player(event.player_index)
  if event.element == frame_of(player) then state(player).location = event.element.location end
end)
events.on(defines.events.on_player_created, function(event) ensure_button(game.get_player(event.player_index)) end)
events.on(defines.events.on_player_removed, function(event)
  if storage.atlas then storage.atlas.players[event.player_index] = nil end
  model.clear_request(event.player_index);pending[event.player_index] = nil
  for id, request in pairs(translation_requests) do
    if request.player == event.player_index then requested_keys[request.token] = nil;translation_requests[id] = nil end
  end
end)
events.on(defines.events.on_player_changed_force, function(event)
  local player = game.get_player(event.player_index)
  state(player).page = 1
  if frame_of(player) then draw(player) end
end)
local function display_changed(event)
  local player = game.get_player(event.player_index)
  state(player).location = nil
  local frame = frame_of(player)
  if frame then draw(player);frame.force_auto_center() end
end
events.on(defines.events.on_player_display_resolution_changed, display_changed)
events.on(defines.events.on_player_display_scale_changed, display_changed)
events.on(defines.events.on_player_locale_changed, function(event)
  local player = game.get_player(event.player_index);local s = state(player)
  s.translations = {};s.epoch = s.epoch + 1;pending[player.index] = 0
  if frame_of(player) then draw(player) end
end)
events.on(defines.events.on_string_translated, function(event)
  local request = translation_requests[event.id]
  if not request then return end
  translation_requests[event.id] = nil;requested_keys[request.token] = nil
  local player = game.get_player(request.player)
  if not player then return end
  local s = state(player)
  if request.epoch ~= s.epoch then return end
  pending[player.index] = math.max(0, (pending[player.index] or 1) - 1)
  s.translations[request.id] = event.translated and event.result or false
  if frame_of(player) then schedule(player) end
end)
commands.add_command("paranoidal-atlas", {"atlas.command-help"}, function(command)
  local player = command.player_index and game.get_player(command.player_index)
  if player then M.toggle(player) end
end)
return M
