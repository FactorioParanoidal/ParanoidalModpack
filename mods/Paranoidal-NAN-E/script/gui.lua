-- Her window (Alt+N, the shortcut, the button at the top left), rebuilt from Informatron's: a menu on the left, a page
-- on the right, the planet's time in the title bar. Pages: her status and abilities, her memory, the case board, a
-- live summary, the journal of what she said, help on the build's mods.
local mod_gui = require("__core__/lualib/mod-gui")
local shared = require("shared")
local state = require("script.state")
local story = require("script.story")
local memory = require("script.memory")
local errands = require("script.errands")
local abilities = require("script.abilities")

local gui = {}

local ROOT = "nan-e-window"
local BUTTON = "nan-e-button"
local T = shared.tech
local content_width = 600

local pages = {"nanny", "memory", "case", "summary", "journal", "help"}

-- Help: own mods of the build she knows, in this order (shown only when active).
local help_mods =
{
  "zzzparanoidal-start-bnl", "Paranoidal-Droid-M-O", "ic-more-qualities", "paranoidal-robot-attrition", "paranoidal-rain",
  "paranoidal-ruins", "paranoidal-CodexRPG", "paranoidal-achievements", "paranoidal-tech-tree", "paranoidal-power-districts",
  "paranoidal-flammable-fluids", "paranoidal-true-nukes", "paranoidal-stack-sizes", "paranoidal-tank-platoon",
  "paranoidal-vehicle-physics", "paranoidal-lighting", "paranoidal-deep-storage", "paranoidal-autofill",
  "paranoidal-picker-tools", "paranoidal-upgrade-tech", "paranoidal-sound", "paranoidal-decoration-cleanup",
  "paranoidal-petrochem", "paranoidal-clowns"
}

local ability_list =
{
  {T.lamp}, {T.trail}, {T.vacuum}, {T.umbrella, rain = true}, {T.defib}
}

local view = function(player)
  local v = state.s.gui[player.index]
  if not v then
    v = {page = "nanny"}
    state.s.gui[player.index] = v
  end
  return v
end

gui.get = function(player)
  return player.gui.screen[ROOT]
end

local game_time = function(tick)
  local seconds = math.floor(tick / 60)
  local days = math.floor(seconds / 86400)
  local hours = math.floor(seconds / 3600) % 24
  local mins = math.floor(seconds / 60) % 60
  local secs = seconds % 60
  return {"nan-e-gui.game-time", days, string.format("%02d", hours), string.format("%02d", mins), string.format("%02d", secs)}
end

local text = function(parent, caption, style, colour)
  local label = parent.add{type = "label", caption = caption, style = style}
  label.style.single_line = false
  label.style.maximal_width = content_width - 24
  if colour then
    label.style.font_color = colour
  end
  return label
end

local heading = function(parent, caption)
  local label = parent.add{type = "label", caption = caption, style = "heading_2_label"}
  label.style.top_margin = 8
  return label
end

-- ---------------------------------------------------------------- pages

local builders = {}

builders.nanny = function(parent, player)
  local data = state.s.players[player.index]
  local row = parent.add{type = "flow", direction = "horizontal"}
  row.style.horizontal_spacing = 12
  local active = data and data.status == "active" and data.unit and data.unit.valid
  local mood = active and "neutral" or "sleepy"
  row.add{type = "sprite", sprite = shared.sprite.portrait .. mood}
  local info = row.add{type = "flow", direction = "vertical"}
  info.style.vertical_spacing = 6
  if not data or (data.status ~= "active" and not (data.husk and data.husk.valid)) then
    text(info, {"nan-e-gui.no-nanny"})
  else
    local status = data.status == "active" and "status-active" or (data.status == "boot" and "status-boot" or "status-offline")
    text(info, {"nan-e-gui.status", {"nan-e-gui." .. status}}, "bold_label")
    local entity = active and data.unit or data.husk
    if entity and entity.valid then
      local ratio = entity.health / entity.max_health
      text(info, {"nan-e-gui.health", math.floor(ratio * 100 + 0.5)})
      local bar = info.add{type = "progressbar", value = ratio}
      bar.style.horizontally_stretchable = true
    end
    if active then
      local task = data.task and ("task-" .. data.task.kind) or "task-follow"
      if data.away_since then
        task = "task-wait"
      end
      text(info, {"nan-e-gui.task", {"nan-e-gui." .. task}})
      local buttons = info.add{type = "flow", direction = "horizontal"}
      buttons.style.top_margin = 8
      buttons.add{type = "button", caption = {"nan-e-gui.call"}, tooltip = {"nan-e-gui.call-tooltip"}, tags = {nan_e = "call"}}
      local quiet = data.quiet_until and game.tick < data.quiet_until
      buttons.add{type = "button", caption = {quiet and "nan-e-gui.quiet-off" or "nan-e-gui.quiet"},
        tooltip = {"nan-e-gui.quiet-tooltip"}, tags = {nan_e = "quiet"}}
      buttons.add{type = "button", caption = {"nan-e-gui.talk"}, tags = {nan_e = "talk"}}
    end
  end
  heading(parent, {"nan-e-gui.abilities"})
  local table_ = parent.add{type = "table", column_count = 3}
  table_.style.horizontal_spacing = 12
  table_.style.vertical_spacing = 4
  for _, entry in ipairs(ability_list) do
    local name = entry[1]
    if prototypes.technology[name] then
      table_.add{type = "sprite", sprite = "technology/" .. name, resize_to_sprite = false}.style.size = 32
      table_.add{type = "label", caption = {"technology-name." .. name}, tooltip = {"technology-description." .. name}}
      local ready = abilities.researched(player.force, name)
      local label = table_.add{type = "label", caption = {ready and "nan-e-gui.ability-ready" or "nan-e-gui.ability-locked"}}
      label.style.font_color = ready and {0.55, 1, 0.55} or {0.7, 0.7, 0.7}
    end
  end
end

builders.memory = function(parent, player)
  local force = player.force
  local f = memory.force_data(force)
  text(parent, {"nan-e-gui.memory-intro"})
  local row = parent.add{type = "flow", direction = "horizontal"}
  row.style.vertical_align = "center"
  row.style.horizontal_spacing = 12
  local cards = memory.count_any(player, shared.card)
  row.add{type = "label", caption = {"nan-e-gui.cards", cards}}
  row.add{type = "label", caption = {"nan-e-gui.fragments", f.count, story.total}}
  local job = f.decrypting
  if job then
    local left = math.max(0, math.ceil((job.done - game.tick) / 60))
    text(parent, {"nan-e-gui.decrypting", left}).name = "nan-e-decrypt-text"
    local bar = parent.add{type = "progressbar", name = "nan-e-decrypt-bar", value = 1 - (job.done - game.tick) / job.total}
    bar.style.horizontally_stretchable = true
  else
    local item, count = memory.price(force)
    local price = item and ("[item=" .. item .. "] × " .. count) or ""
    local button = parent.add{type = "button", style = "confirm_button", caption = {"nan-e-gui.decrypt"},
      tooltip = {"nan-e-gui.decrypt-tooltip", price, settings.global[shared.settings.decode].value}, tags = {nan_e = "decrypt"}}
    button.enabled = cards > 0
    if not memory.next(force) and f.count >= story.total then
      text(parent, {"nan-e-gui.decrypt-done-all"}, nil, {0.8, 0.8, 0.8})
    end
  end
  for index, chapter in ipairs(story.chapters) do
    local done = 0
    for _, id in ipairs(chapter.fragments) do
      if f.fragments[id] then
        done = done + 1
      end
    end
    heading(parent, {"", index, ". ", {"nan-e-memory." .. chapter.title}, "  ", {"nan-e-gui.chapter-progress", done, #chapter.fragments}})
    local tech = chapter.tech and force.technologies[chapter.tech]
    if tech and not tech.researched then
      text(parent, {"nan-e-gui.chapter-locked", "[technology=" .. chapter.tech .. "]"}, nil, {0.8, 0.6, 0.5})
    end
    for _, id in ipairs(chapter.fragments) do
      if f.fragments[id] then
        local label
        if story.fragment[id].bnl then
          label = text(parent, {"", "[", {"nan-e-memory.bnl-restored"}, "] ", {"nan-e-memory." .. id}}, nil, {0.95, 0.85, 0.85})
        else
          label = text(parent, {"nan-e-memory." .. id})
        end
        label.name = "nan-e-fragment-" .. id
      else
        text(parent, {"nan-e-gui.fragment-unknown"}, nil, {0.45, 0.45, 0.45})
      end
    end
  end
end

builders.case = function(parent, player)
  local force = player.force
  local f = memory.force_data(force)
  text(parent, {"nan-e-case.intro"})
  for _, q in ipairs(story.question_order) do
    local question = story.questions[q]
    heading(parent, {"nan-e-case." .. q}).name = "nan-e-question-" .. q
    if f.solved[q] then
      text(parent, {"nan-e-gui.case-solved", {"nan-e-case." .. q .. "-o" .. question.answer}}, "bold_label", {0.55, 1, 0.55})
      text(parent, {"nan-e-case." .. q .. "-truth"})
    elseif not memory.question_open(force, q) then
      text(parent, {"nan-e-gui.case-closed-q", {"nan-e-memory." .. story.chapters[question.chapter].title}}, nil, {0.7, 0.7, 0.7})
    else
      local items = {}
      for i = 1, question.options do
        items[i] = {"nan-e-case." .. q .. "-o" .. i}
      end
      local row = parent.add{type = "flow", direction = "horizontal"}
      row.style.vertical_align = "center"
      local dropdown = row.add{type = "drop-down", name = "nan-e-case-" .. q, items = items}
      dropdown.style.width = 400
      local locked = f.locked[q] and game.tick < f.locked[q]
      local button = row.add{type = "button", caption = {"nan-e-gui.case-present"}, tags = {nan_e = "answer", q = q},
        tooltip = locked and {"nan-e-gui.case-wait", math.ceil((f.locked[q] - game.tick) / 60)} or {"nan-e-gui.case-choose"}}
      button.enabled = not locked
    end
  end
  if f.solved.q5 then
    heading(parent, {"nan-e-case.epilogue-title"})
    if f.epilogue then
      text(parent, {"nan-e-case.epilogue"})
    else
      text(parent, {"nan-e-gui.epilogue-locked"}, nil, {0.7, 0.7, 0.7})
    end
  end
end

local daytime = function(surface)
  local d = surface.darkness
  if d > 0.6 then return "daytime-night" end
  if d > 0.2 then return "daytime-dusk" end
  return "daytime-day"
end

builders.summary = function(parent, player)
  local surface = player.surface
  local position = player.character and player.character.position or player.position
  text(parent, {"nan-e-gui.summary-time", game_time(game.tick)})
  text(parent, {"nan-e-gui.summary-daytime", {"nan-e-gui." .. daytime(surface)}})
  local enemy = game.forces.enemy
  if enemy then
    text(parent, {"nan-e-gui.summary-evolution", string.format("%.1f", enemy.get_evolution_factor(surface) * 100)})
  end
  text(parent, {"nan-e-gui.summary-pollution", string.format("%.0f", surface.get_pollution(position))})
  local research = player.force.current_research
  if research then
    text(parent, {"nan-e-gui.summary-research", "[technology=" .. research.name .. "]", string.format("%.0f", player.force.research_progress * 100)})
  else
    text(parent, {"nan-e-gui.summary-noresearch"})
  end
  if remote.interfaces["paranoidal-rain"] then
    local stage = remote.call("paranoidal-rain", "stage", surface.index)
    local left = remote.call("paranoidal-rain", "time_left", surface.index)
    if stage then
      text(parent, {"nan-e-gui.summary-rain", {"nan-e-gui.rain-" .. stage}, left and math.ceil(left / 3600) or "?"})
    end
  end
  local data = state.s.players[player.index]
  local scan = data and data.scan
  if not scan then
    text(parent, {"nan-e-gui.summary-debt-never"}, nil, {0.7, 0.7, 0.7})
  else
    local lines = {}
    for _, key in ipairs(errands.debt_keys) do
      if scan.counts[key] then
        lines[#lines + 1] = key
      end
    end
    if #lines == 0 then
      text(parent, {"nan-e-gui.summary-debt-none"})
    else
      text(parent, {"nan-e-gui.summary-debt", math.floor((game.tick - scan.tick) / 3600)}, "bold_label")
      for _, key in ipairs(lines) do
        text(parent, {"", "• ", {"nan-e-gui.debt-" .. key}, ": ", scan.counts[key]})
      end
    end
  end
  text(parent, {"nan-e-gui.summary-story", memory.solved_count(player.force)})
end

builders.journal = function(parent, player)
  local data = state.s.players[player.index]
  local journal = data and data.journal
  if not journal or #journal == 0 then
    text(parent, {"nan-e-gui.journal-empty"}, nil, {0.7, 0.7, 0.7})
    return
  end
  for i = #journal, 1, -1 do
    local entry = journal[i]
    local seconds = math.floor(entry[1] / 60)
    local stamp = string.format("[%d:%02d:%02d] ", math.floor(seconds / 3600), math.floor(seconds / 60) % 60, seconds % 60)
    text(parent, {"", stamp, entry[2]})
  end
end

builders.help = function(parent, player)
  text(parent, {script.active_mods["paranoidal-CodexRPG"] and "nan-e-gui.help-intro" or "nan-e-gui.help-intro-nocodex"})
  for _, name in ipairs(help_mods) do
    if script.active_mods[name] then
      heading(parent, {"?", {"mod-name." .. name}, name})
      text(parent, {"?", {"mod-description." .. name}, ""})
      text(parent, {"nan-e-gui.help-nanny", {"nan-e-help." .. name}}, "semibold_label", {1, 0.82, 0.9})
    end
  end
end

-- ---------------------------------------------------------------- window

local show_page = function(player, root)
  local v = view(player)
  local menu = root.body.menu
  for _, child in pairs(menu.children) do
    child.toggled = child.tags.page == v.page
  end
  local page = root.body.page
  page.subheader.title.caption = {"nan-e-gui.page-" .. v.page}
  local pane = page.pane
  pane.clear()
  local content = pane.add{type = "flow", name = "content", direction = "vertical"}
  content.style.vertical_spacing = 6
  content.style.padding = 12
  builders[v.page](content, player)
end

-- Rebuilds the page; focus: the name of an element of the page to scroll to (a fragment, a question).
gui.refresh = function(player, focus)
  local root = gui.get(player)
  if not root then return end
  show_page(player, root)
  root.titlebar.time.caption = game_time(game.tick)
  local pane = root.body.page.pane
  local target = focus and pane.content[focus]
  if target then
    pane.scroll_to_element(target, "top-third")
  end
end

gui.open = function(player, page)
  local old = gui.get(player)
  if old then
    old.destroy()
  end
  if page then
    view(player).page = page
  end
  local root = player.gui.screen.add{type = "frame", name = ROOT, direction = "vertical"}
  local titlebar = root.add{type = "flow", name = "titlebar", direction = "horizontal"}
  titlebar.drag_target = root
  titlebar.style.horizontal_spacing = 8
  titlebar.add{type = "sprite", sprite = "item/" .. shared.item, ignored_by_interaction = true}.style.size = 24
  titlebar.add{type = "label", caption = {"nan-e-gui.title"}, style = "frame_title", ignored_by_interaction = true}
  local drag = titlebar.add{type = "empty-widget", style = "draggable_space_header", ignored_by_interaction = true}
  drag.style.horizontally_stretchable = true
  drag.style.height = 24
  titlebar.add{type = "label", name = "time", caption = game_time(game.tick), tooltip = {"nan-e-gui.game-time-tooltip"},
    style = "semibold_label"}
  titlebar.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close", tags = {nan_e = "close"}}
  local body = root.add{type = "flow", name = "body", direction = "horizontal"}
  body.style.horizontal_spacing = 12
  local menu = body.add{type = "frame", name = "menu", direction = "vertical", style = "inside_deep_frame"}
  menu.style.width = 190
  menu.style.vertically_stretchable = true
  for _, name in ipairs(pages) do
    local button = menu.add{type = "button", caption = {"nan-e-gui.page-" .. name}, style = "list_box_item",
      tags = {nan_e = "page", page = name}}
    button.style.horizontally_stretchable = true
  end
  local page_frame = body.add{type = "frame", name = "page", direction = "vertical", style = "inside_shallow_frame"}
  page_frame.style.width = content_width
  local subheader = page_frame.add{type = "frame", name = "subheader", style = "subheader_frame"}
  subheader.style.horizontally_stretchable = true
  subheader.add{type = "label", name = "title", style = "subheader_caption_label"}
  local pane = page_frame.add{type = "scroll-pane", name = "pane", style = "naked_scroll_pane", horizontal_scroll_policy = "never"}
  local height = math.min(560, math.floor(player.display_resolution.height / player.display_scale) - 160)
  pane.style.height = math.max(300, height)
  pane.style.horizontally_stretchable = true
  show_page(player, root)
  root.force_auto_center()
  player.opened = root
end

gui.close = function(player)
  local root = gui.get(player)
  if root then
    root.destroy()
  end
end

gui.toggle = function(player)
  if gui.get(player) then
    gui.close(player)
  else
    gui.open(player)
  end
end

-- The button at the top left, by the player's setting.
gui.update_button = function(player)
  local flow = mod_gui.get_button_flow(player)
  local button = flow[BUTTON]
  if player.mod_settings[shared.settings.button].value then
    if not button then
      flow.add{type = "sprite-button", name = BUTTON, sprite = "item/" .. shared.item, style = mod_gui.button_style,
        tooltip = {"controls." .. shared.input}}
    end
  elseif button then
    button.destroy()
  end
end

gui.on_click = function(event)
  local element = event.element
  if not (element and element.valid) then return end
  local player = game.get_player(event.player_index)
  if not player then return end
  if element.name == BUTTON then
    gui.toggle(player)
    return
  end
  local tags = element.tags
  local action = tags and tags.nan_e
  if not action then return end
  if action == "close" then
    gui.close(player)
  elseif action == "page" then
    view(player).page = tags.page
    gui.refresh(player)
  elseif action == "decrypt" then
    memory.start_decrypt(player)
    gui.refresh(player)
  elseif action == "answer" then
    local dropdown = element.parent["nan-e-case-" .. tags.q]
    local choice = dropdown and dropdown.selected_index or 0
    if choice > 0 then
      memory.answer(player, tags.q, choice)
      gui.refresh(player, "nan-e-question-" .. tags.q)
    end
  elseif gui.on_action then
    gui.on_action(player, action)
    gui.refresh(player)
  end
end

gui.on_closed = function(event)
  local element = event.element
  if element and element.valid and element.name == ROOT then
    element.destroy()
  end
end

-- Every 60 ticks: the clock, and the pages that change by themselves.
gui.on_second = function()
  for _, player in pairs(game.connected_players) do
    local root = gui.get(player)
    if root then
      root.titlebar.time.caption = game_time(game.tick)
      local page = view(player).page
      if page == "summary" or (page == "nanny" and game.tick % 180 < 60) then
        gui.refresh(player)
      elseif page == "memory" then
        -- The countdown in place: rebuilding would throw the reader back to the top.
        local job = memory.force_data(player.force).decrypting
        local content = root.body.page.pane.content
        if job and content and content["nan-e-decrypt-text"] then
          local left = math.max(0, math.ceil((job.done - game.tick) / 60))
          content["nan-e-decrypt-text"].caption = {"nan-e-gui.decrypting", left}
          content["nan-e-decrypt-bar"].value = math.max(0, math.min(1, 1 - (job.done - game.tick) / job.total))
        end
      end
    end
  end
end

-- Her journal and the team's memory changed: open windows on those pages follow.
gui.on_said = function(player)
  if gui.get(player) and view(player).page == "journal" then
    gui.refresh(player)
  end
end

gui.on_memory_changed = function(force)
  for _, player in pairs(force.connected_players) do
    local root = gui.get(player)
    local page = root and view(player).page
    if page == "memory" then
      local last = memory.force_data(force).last_fragment
      gui.refresh(player, last and ("nan-e-fragment-" .. last))
    elseif page == "case" or page == "summary" then
      gui.refresh(player)
    end
  end
end

return gui
