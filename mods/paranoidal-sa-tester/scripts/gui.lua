-- The tester window: titlebar, five tabs, status line. Built once per opening; afterwards only the parts whose
-- content changes are updated (captions, styles, small lists).
local common = require("scripts.common")
local catalog = require("scripts.catalog")
local actions = require("scripts.actions")

local G = {}

local TABS = {"progress", "planets", "items", "modes", "inspect"}
local WIDTH = 800
local CONFIRM_TICKS = 300
local SPEEDS = {0, 1, 2, 5, 10, 30}

-------------------------------------------------------------------------------- helpers

local function sprite(kind, name)
  local path = kind .. "/" .. name
  if helpers.is_valid_sprite_path(path) then return path end
  return "utility/questionmark"
end

local function pane(parent, caption)
  local frame = parent.add({type = "frame", style = "inside_shallow_frame", direction = "vertical"})
  frame.style.horizontally_stretchable = true
  local sub = frame.add({type = "frame", style = "subheader_frame", direction = "horizontal"})
  sub.style.horizontally_stretchable = true
  local title = sub.add({type = "label", style = "subheader_caption_label", caption = caption})
  local filler = sub.add({type = "empty-widget"})
  filler.style.horizontally_stretchable = true
  local body = frame.add({type = "flow", direction = "vertical"})
  body.style.padding = 12
  body.style.vertical_spacing = 8
  return body, sub, title
end

local function hint(parent, caption)
  local label = parent.add({type = "label", caption = caption})
  label.style.single_line = false
  label.style.maximal_width = WIDTH - 40
  label.style.font_color = {0.75, 0.75, 0.75}
  return label
end

local function grid(parent, columns)
  local t = parent.add({type = "table", column_count = columns})
  t.style.horizontal_spacing = 8
  t.style.vertical_spacing = 4
  return t
end

-- Text button running an action; `confirm` buttons keep their caption key to restore it after arming.
local function button(parent, caption_key, tooltip_key, tags, style)
  if actions.confirm[tags.pst] then tags.cap = caption_key end
  local b = parent.add({type = "button", caption = {caption_key}, tooltip = tooltip_key and {tooltip_key} or nil,
    tags = tags, style = style or (actions.confirm[tags.pst] and "red_button" or "button")})
  b.style.horizontally_stretchable = true
  b.style.minimal_width = 0
  return b
end

local function row(parent)
  local f = parent.add({type = "flow", direction = "horizontal"})
  f.style.vertical_align = "center"
  f.style.horizontal_spacing = 8
  return f
end

local function location_name(name)
  local proto = prototypes.space_location[name]
  return proto and proto.localised_name or name
end

local function yes_no(value)
  return value and {"pst.yes"} or {"pst.no"}
end

-------------------------------------------------------------------------------- tab: progress

local function build_progress(player, content, refs, d)
  local body = pane(content, {"pst.pane-milestones"})
  hint(body, {"pst.milestones-hint"})
  local frame = body.add({type = "frame", style = "deep_frame_in_shallow_frame"})
  local t = frame.add({type = "table", style = "slot_table", column_count = 18})
  refs.milestones = {}
  for _, name in ipairs(catalog.milestones()) do
    refs.milestones[name] = t.add({type = "sprite-button", style = "slot_sized_button", sprite = sprite("technology", name),
      elem_tooltip = {type = "technology", name = name}, mouse_button_filter = {"left", "right"},
      tags = {pst = "milestone", tech = name}})
  end
  if #catalog.milestones() == 0 then hint(body, {"pst.no-milestones"}) end

  body = pane(content, {"pst.pane-tech"})
  local r = row(body)
  refs.tech_chooser = r.add({type = "choose-elem-button", elem_type = "technology", technology = d.tech,
    tags = {pst_ui = "pick-tech"}, tooltip = {"pst.pick-tech"}})
  refs.tech_status = r.add({type = "label", caption = ""})
  refs.tech_status.style.single_line = false
  refs.tech_status.style.maximal_width = WIDTH - 120
  local g = grid(body, 3)
  button(g, "pst.research-with", "pst.research-with-tooltip", {pst = "research", mode = "with"})
  button(g, "pst.research-before", "pst.research-before-tooltip", {pst = "research", mode = "prereq"})
  button(g, "pst.unresearch", "pst.unresearch-tooltip", {pst = "unresearch"})
  refs.tech_trigger = hint(body, "")
  refs.missing_caption = body.add({type = "label", style = "caption_label", caption = ""})
  local mframe = body.add({type = "frame", style = "deep_frame_in_shallow_frame"})
  refs.missing = mframe.add({type = "table", style = "slot_table", column_count = 18})

  body = pane(content, {"pst.pane-research"})
  refs.research_status = body.add({type = "label", caption = ""})
  g = grid(body, 3)
  button(g, "pst.finish-research", "pst.finish-research-tooltip", {pst = "finish-research"})
  refs.lab_speed = button(g, "pst.lab-speed-on-caption", "pst.lab-speed-tooltip", {pst = "lab-speed"})
  button(g, "pst.research-all", "pst.research-all-tooltip", {pst = "research-all"})
end

local function trigger_text(tech)
  local trigger = tech.prototype.research_trigger
  if not trigger then return "" end
  local t = trigger.type
  if t == "craft-item" then
    local item = type(trigger.item) == "table" and trigger.item.name or trigger.item
    return {"pst.trigger-craft-item", "[item=" .. tostring(item) .. "]", trigger.count or 1}
  elseif t == "craft-fluid" then
    return {"pst.trigger-craft-fluid", "[fluid=" .. trigger.fluid .. "]", common.fmt_number(trigger.amount)}
  elseif t == "mine-entity" then
    local names = {}
    for _, n in pairs(trigger.entities or {}) do names[#names + 1] = n end
    return {"pst.trigger-mine-entity", common.icons("entity", names, 6)}
  elseif t == "build-entity" then
    local entity = type(trigger.entity) == "table" and trigger.entity.name or trigger.entity
    return {"pst.trigger-build-entity", "[entity=" .. tostring(entity) .. "]"}
  elseif t == "send-item-to-orbit" then
    local item = type(trigger.item) == "table" and trigger.item.name or trigger.item
    return {"pst.trigger-send-item", "[item=" .. tostring(item) .. "]"}
  elseif t == "capture-spawner" then
    return {"pst.trigger-capture-spawner"}
  elseif t == "create-space-platform" then
    return {"pst.trigger-create-platform"}
  elseif t == "scripted" then
    return {"pst.trigger-scripted", trigger.trigger_description or ""}
  end
  return {"pst.trigger-other", t}
end

local function refresh_progress(player, refs, d)
  local force = player.force
  for name, b in pairs(refs.milestones or {}) do
    if b.valid then
      local tech = force.technologies[name]
      local style = "slot_sized_button"
      if tech and tech.researched then
        style = "slot_sized_button_green"
      elseif tech then
        local ready = true
        for _, pre in pairs(tech.prerequisites) do
          if not pre.researched then ready = false break end
        end
        if ready then style = "slot_sized_button_blue" end
      end
      if b.style.name ~= style then b.style = style end
    end
  end

  local tech = d.tech and force.technologies[d.tech]
  if refs.tech_chooser.valid and refs.tech_chooser.elem_value ~= d.tech then refs.tech_chooser.elem_value = d.tech end
  refs.missing.clear()
  if not tech then
    refs.tech_status.caption = {"pst.tech-none"}
    refs.tech_trigger.caption = ""
    refs.missing_caption.caption = ""
  else
    local missing = catalog.missing(force, tech.name)
    local state = tech.researched and {"pst.tech-researched"} or (#missing == 0 and {"pst.tech-ready"} or
      {"pst.tech-locked", #missing})
    refs.tech_status.caption = {"", "[technology=" .. tech.name .. "]  ", state}
    refs.tech_trigger.caption = trigger_text(tech)
    if #missing == 0 then
      refs.missing_caption.caption = {"pst.missing-none"}
    else
      refs.missing_caption.caption = {"pst.missing-caption", #missing}
      for i, t in ipairs(missing) do
        if i > 144 then break end
        refs.missing.add({type = "sprite-button", style = "slot_button", sprite = sprite("technology", t.name),
          elem_tooltip = {type = "technology", name = t.name}, tags = {pst_ui = "pick-tech-from", tech = t.name}})
      end
    end
  end
  refs.missing.parent.visible = #refs.missing.children > 0

  local current = force.current_research
  if current then
    refs.research_status.caption = {"pst.research-current", "[technology=" .. current.name .. "]",
      string.format("%d", math.floor(force.research_progress * 100))}
  else
    refs.research_status.caption = {"pst.research-none"}
  end
  local fd = common.fdata(force)
  refs.lab_speed.caption = fd.lab_bonus and {"pst.lab-speed-off-caption"} or {"pst.lab-speed-on-caption"}
end

-------------------------------------------------------------------------------- tab: planets

local function fill_places(player, refs, d)
  local t = refs.places
  t.clear()
  refs.place_rows = {}
  for _, loc in ipairs(catalog.locations(d.show_hidden)) do
    local name = loc.name
    t.add({type = "sprite-button", style = "slot_button", sprite = sprite("space-location", name),
      elem_tooltip = {type = "space-location", name = name}, tags = {pst_ui = "noop"}})
    local cell = t.add({type = "flow", direction = "vertical"})
    cell.style.vertical_spacing = 0
    cell.style.width = 230
    cell.add({type = "label", style = "bold_label", caption = loc.proto.localised_name})
    local status = cell.add({type = "label", caption = ""})
    status.style.font = "default-small"
    status.style.font_color = {0.75, 0.75, 0.75}
    local is_planet = game.planets[name] ~= nil
    local toggle = button(t, "pst.location-open", "pst.location-toggle-tooltip", {pst = "toggle-location", location = name})
    local go = button(t, "pst.go", "pst.go-tooltip", {pst = "go", location = name})
    go.enabled = is_planet
    local view = button(t, "pst.view", "pst.view-tooltip", {pst = "view", location = name})
    view.enabled = is_planet
    local move = button(t, "pst.platform-here", "pst.platform-here-tooltip", {pst = "platform-move", location = name})
    refs.place_rows[name] = {status = status, toggle = toggle, move = move, planet = is_planet}
  end
end

local function build_planets(player, content, refs, d)
  local body, sub = pane(content, {"pst.pane-places"})
  refs.show_hidden = sub.add({type = "checkbox", caption = {"pst.show-hidden"}, tooltip = {"pst.show-hidden-tooltip"},
    state = d.show_hidden == true, tags = {pst_ui = "show-hidden"}})
  local g = grid(body, 3)
  button(g, "pst.go-home", "pst.go-home-tooltip", {pst = "go-home"})
  refs.leave = button(g, "pst.platform-leave", "pst.platform-leave-tooltip", {pst = "platform-leave"})
  hint(body, {"pst.places-hint"})
  refs.places = body.add({type = "table", column_count = 6})
  refs.places.style.horizontal_spacing = 8
  refs.places.style.vertical_spacing = 4
  refs.places.style.vertical_align = "center"
  fill_places(player, refs, d)

  body = pane(content, {"pst.pane-platforms"})
  if not script.feature_flags.space_travel then
    hint(body, {"pst.no-space-travel"})
    return
  end
  local r = row(body)
  refs.platform_dd = r.add({type = "drop-down", tags = {pst_ui = "pick-platform"}, tooltip = {"pst.pick-platform"}})
  refs.platform_dd.style.width = 320
  refs.platform_info = r.add({type = "label", caption = ""})
  g = grid(body, 4)
  button(g, "pst.platform-create", "pst.platform-create-tooltip", {pst = "platform-create"})
  refs.platform_buttons = {
    button(g, "pst.platform-enter", "pst.platform-enter-tooltip", {pst = "platform-enter"}),
    button(g, "pst.platform-pause", "pst.platform-pause-tooltip", {pst = "platform-pause"}),
    button(g, "pst.platform-kit", "pst.platform-kit-tooltip", {pst = "platform-kit"}),
    button(g, "pst.platform-chunks", "pst.platform-chunks-tooltip", {pst = "platform-chunks"}),
    button(g, "pst.platform-asteroids", "pst.platform-asteroids-tooltip", {pst = "platform-asteroids"}),
    button(g, "pst.platform-delete", "pst.platform-delete-tooltip", {pst = "platform-delete"}),
  }
end

local function platform_list(player)
  local list = {}
  for index, platform in pairs(player.force.platforms) do
    if platform.valid and platform.scheduled_for_deletion == 0 then list[#list + 1] = index end
  end
  table.sort(list)
  return list
end

local function platform_state_text(platform)
  local loc = platform.space_location
  local where = loc and {"", "[space-location=" .. loc.name .. "] ", loc.localised_name} or {"pst.platform-in-flight"}
  return {"", where, platform.paused and {"", ", ", {"pst.platform-state-paused"}} or ""}
end

local function refresh_planets(player, refs, d)
  local force = player.force
  local selected = actions.selected_platform(player)
  local here = {}
  for _, platform in pairs(force.platforms) do
    if platform.valid and platform.space_location then
      here[platform.space_location.name] = (here[platform.space_location.name] or 0) + 1
    end
  end
  for name, entry in pairs(refs.place_rows or {}) do
    if entry.status.valid then
      local unlocked = force.is_space_location_unlocked(name)
      local planet = game.planets[name]
      local parts = {"", unlocked and {"pst.place-open"} or {"pst.place-closed"}}
      if entry.planet then
        parts[#parts + 1] = {"", " · ", (planet and planet.surface) and {"pst.place-surface"} or {"pst.place-no-surface"}}
      else
        parts[#parts + 1] = {"", " · ", {"pst.place-space-only"}}
      end
      if here[name] then parts[#parts + 1] = {"", " · ", {"pst.place-platforms", here[name]}} end
      entry.status.caption = parts
      entry.toggle.caption = unlocked and {"pst.location-close"} or {"pst.location-open"}
      entry.move.enabled = selected ~= nil
    end
  end
  if refs.leave and refs.leave.valid then refs.leave.enabled = player.surface.platform ~= nil end
  if refs.platform_dd and refs.platform_dd.valid then
    local list = platform_list(player)
    d.platform_list = list
    local items, selected_index = {}, 0
    for i, index in ipairs(list) do
      local platform = force.platforms[index]
      items[i] = {"", platform.name, " — ", platform_state_text(platform)}
      if selected and selected.index == index then selected_index = i end
    end
    refs.platform_dd.items = items
    refs.platform_dd.selected_index = selected_index
    if #list == 0 then
      refs.platform_info.caption = {"pst.no-platforms"}
    elseif selected then
      refs.platform_info.caption = {"pst.platform-info", selected.name, common.fmt_number(selected.speed or 0)}
    else
      refs.platform_info.caption = {"pst.pick-platform"}
    end
    for _, b in ipairs(refs.platform_buttons) do b.enabled = selected ~= nil end
  end
end

-------------------------------------------------------------------------------- tab: items

local function build_items(player, content, refs, d)
  local body = pane(content, {"pst.pane-give"})
  local g = grid(body, 4)
  g.add({type = "label", caption = {"pst.quality"}})
  local items, selected = {}, 1
  for i, q in ipairs(catalog.qualities()) do
    items[i] = {"", "[quality=" .. q.name .. "] ", q.localised_name}
    if q.name == d.quality then selected = i end
  end
  refs.quality = g.add({type = "drop-down", items = items, selected_index = selected, tags = {pst_ui = "pick-quality"},
    tooltip = {"pst.quality-tooltip"}})
  refs.quality.style.width = 240
  g.add({type = "label", caption = {"pst.count"}})
  local counts = {}
  for i, entry in ipairs(common.COUNTS) do
    counts[i] = entry.stacks and {"pst.count-stacks", entry.stacks} or {"pst.count-n", entry.n}
  end
  refs.count = g.add({type = "drop-down", items = counts, selected_index = d.count, tags = {pst_ui = "pick-count"},
    tooltip = {"pst.count-tooltip"}})

  body = pane(content, {"pst.pane-any-item"})
  local r = row(body)
  refs.item_chooser = r.add({type = "choose-elem-button", elem_type = "item", item = d.item,
    tags = {pst_ui = "pick-item"}, tooltip = {"pst.pick-item"}})
  local f = r.add({type = "flow", direction = "horizontal"})
  f.style.horizontal_spacing = 8
  button(f, "pst.give", "pst.give-tooltip", {pst = "give"})
  button(f, "pst.infinite", "pst.infinite-tooltip", {pst = "infinite"})
  r = row(body)
  refs.fluid_chooser = r.add({type = "choose-elem-button", elem_type = "fluid", fluid = d.fluid,
    tags = {pst_ui = "pick-fluid"}, tooltip = {"pst.pick-fluid"}})
  r.add({type = "label", caption = {"pst.temperature"}})
  refs.temperature = r.add({type = "textfield", style = "short_number_textfield", numeric = true, allow_decimal = true,
    allow_negative = true, text = d.fluid_temperature and tostring(d.fluid_temperature) or "",
    tags = {pst_ui = "temperature"}, tooltip = {"pst.temperature-tooltip"}})
  button(r, "pst.fluid-pipe", "pst.fluid-pipe-tooltip", {pst = "fluid-pipe"})
  local g2 = grid(body, 3)
  button(g2, "pst.duplicate-cursor", "pst.duplicate-cursor-tooltip", {pst = "duplicate-cursor"})
  button(g2, "pst.test-tools", "pst.test-tools-tooltip", {pst = "test-tools"})
  button(g2, "pst.clear-inventory", "pst.clear-inventory-tooltip", {pst = "clear-inventory"})

  body = pane(content, {"pst.pane-kits"})
  hint(body, {"pst.kits-hint"})
  local t = body.add({type = "table", column_count = 6})
  t.style.horizontal_spacing = 8
  t.style.vertical_spacing = 4
  for _, entry in ipairs(catalog.discoveries()) do
    local kit = catalog.kit(entry.tech)
    t.add({type = "sprite-button", style = "slot_button", sprite = sprite("space-location", entry.location),
      elem_tooltip = {type = "technology", name = entry.tech}, tags = {pst_ui = "noop"}})
    local name = t.add({type = "label", style = "bold_label", caption = location_name(entry.location)})
    name.style.width = 170
    local b = button(t, "pst.kit-buildings-button", nil, {pst = "kit-buildings", discovery = entry.tech})
    b.tooltip = {"pst.kit-buildings-tooltip", #kit.buildings, common.icons("item", kit.buildings, 60)}
    b.enabled = #kit.buildings > 0
    local mats = #kit.materials + #kit.packs
    b = button(t, "pst.kit-materials-button", nil, {pst = "kit-materials", discovery = entry.tech})
    b.tooltip = {"pst.kit-materials-tooltip", mats, common.icons("item", kit.materials, 60) .. common.icons("item", kit.packs)}
    b.enabled = mats > 0
    b = button(t, "pst.kit-fluids-button", nil, {pst = "kit-fluids", discovery = entry.tech})
    b.tooltip = {"pst.kit-fluids-tooltip", #kit.fluids, common.icons("fluid", kit.fluids, 40)}
    b.enabled = #kit.fluids > 0
    b = button(t, "pst.kit-packs-button", nil, {pst = "kit-packs", discovery = entry.tech})
    b.tooltip = {"pst.kit-packs-tooltip", #kit.packs, common.icons("item", kit.packs)}
    b.enabled = #kit.packs > 0
  end
  local names = {}
  for _, entry in ipairs(catalog.platform_kit()) do names[#names + 1] = entry.name end
  r = row(body)
  local b = button(r, "pst.kit-platform", nil, {pst = "kit-platform"})
  b.tooltip = {"pst.kit-platform-tooltip", common.icons("item", names)}
  b.enabled = #names > 0
end

-------------------------------------------------------------------------------- tab: modes

local function checkbox(parent, caption_key, tooltip_key, tags)
  return parent.add({type = "checkbox", caption = {caption_key}, tooltip = tooltip_key and {tooltip_key} or nil,
    state = false, tags = tags})
end

local function build_modes(player, content, refs, d)
  local body = pane(content, {"pst.pane-character"})
  local g = grid(body, 3)
  refs.mode_boxes = {
    cheat = checkbox(g, "pst.mode-cheat", "pst.mode-cheat-tooltip", {pst = "mode", mode = "cheat"}),
    immortal = checkbox(g, "pst.mode-immortal", "pst.mode-immortal-tooltip", {pst = "mode", mode = "immortal"}),
    run = checkbox(g, "pst.mode-run", "pst.mode-run-tooltip", {pst = "mode", mode = "run"}),
    reach = checkbox(g, "pst.mode-reach", "pst.mode-reach-tooltip", {pst = "mode", mode = "reach"}),
    mine = checkbox(g, "pst.mode-mine", "pst.mode-mine-tooltip", {pst = "mode", mode = "mine"}),
  }
  g = grid(body, 3)
  button(g, "pst.heal", "pst.heal-tooltip", {pst = "heal"})
  refs.editor = button(g, "pst.editor", "pst.editor-tooltip", {pst = "editor"})

  local surface_body, _, title = pane(content, "")
  body = surface_body
  refs.surface_title = title
  g = grid(body, 3)
  refs.always_day = checkbox(g, "pst.always-day", "pst.always-day-tooltip", {pst = "always-day"})
  refs.peaceful = checkbox(g, "pst.peaceful", "pst.peaceful-tooltip", {pst = "peaceful"})
  refs.free_power = checkbox(g, "pst.free-power", "pst.free-power-tooltip", {pst = "free-power"})
  refs.evolution_label = body.add({type = "label", caption = ""})
  g = grid(body, 3)
  button(g, "pst.kill-enemies", "pst.kill-enemies-tooltip", {pst = "kill-enemies", radius = 200})
  button(g, "pst.evolution-reset", "pst.evolution-reset-tooltip", {pst = "evolution-reset"})
  button(g, "pst.clear-area", "pst.clear-area-tooltip", {pst = "clear-area"})
  button(g, "pst.chart", "pst.chart-tooltip", {pst = "chart", radius = 512})
  button(g, "pst.chart-all", "pst.chart-all-tooltip", {pst = "chart-all"})
  button(g, "pst.generate", "pst.generate-tooltip", {pst = "generate", radius = 8})
  local r = row(body)
  refs.tile_chooser = r.add({type = "choose-elem-button", elem_type = "tile", tile = d.tile,
    tags = {pst_ui = "pick-tile"}, tooltip = {"pst.pick-tile"}})
  button(r, "pst.pave", "pst.pave-tooltip", {pst = "pave"})

  body = pane(content, {"pst.pane-game"})
  r = row(body)
  r.add({type = "label", caption = {"pst.speed"}})
  refs.speed_buttons = {}
  for _, value in ipairs(SPEEDS) do
    local key = value == 0 and "pst.speed-pause" or "pst.speed-x"
    local b = r.add({type = "button", caption = value == 0 and {key} or {key, value},
      tooltip = value == 0 and {"pst.speed-pause-tooltip"} or {"pst.speed-tooltip", value},
      tags = {pst = "speed", value = value}})
    b.style.minimal_width = 56
    refs.speed_buttons[#refs.speed_buttons + 1] = b
  end
  refs.evolution = checkbox(body, "pst.evolution", "pst.evolution-tooltip", {pst = "evolution"})
end

local function refresh_modes(player, refs, d)
  local character = player.character
  for mode, box in pairs(refs.mode_boxes) do
    if mode == "cheat" then
      box.state = player.cheat_mode
    else
      box.state = d.modes[mode] == true
      box.enabled = character ~= nil
    end
  end
  refs.editor.enabled = player.admin
  local surface = player.surface
  local where = surface.platform and {"", "[img=utility/starmap_platform_stopped] ", surface.platform.name}
    or (surface.planet and {"", "[space-location=" .. surface.planet.name .. "] ", surface.planet.prototype.localised_name})
    or surface.name
  refs.surface_title.caption = {"pst.pane-surface", where}
  refs.always_day.state = surface.always_day
  refs.peaceful.state = surface.peaceful_mode
  refs.free_power.state = storage.power[surface.index] ~= nil
  local enemy = game.forces["enemy"]
  local evo = enemy and enemy.get_evolution_factor(surface) or 0
  refs.evolution_label.caption = {"pst.evolution-here", string.format("%.1f", evo * 100)}
  refs.evolution.state = game.map_settings.enemy_evolution.enabled
  if refs.tile_chooser.elem_value ~= d.tile then refs.tile_chooser.elem_value = d.tile end
  for i, b in ipairs(refs.speed_buttons) do
    local value = SPEEDS[i]
    local active = (value == 0 and game.tick_paused) or (value ~= 0 and not game.tick_paused and game.speed == value)
    b.toggled = active
  end
end

-------------------------------------------------------------------------------- tab: inspect

local status_names
local function status_key(status)
  if not status_names then
    status_names = {}
    for name, value in pairs(defines.entity_status) do status_names[value] = name:gsub("_", "-") end
  end
  return status_names[status]
end

local function line(parent, caption)
  local label = parent.add({type = "label", caption = caption})
  label.style.single_line = false
  label.style.maximal_width = WIDTH - 60
  return label
end

local function condition_lines(parent, conditions, surface)
  local checked = catalog.check_conditions(conditions, surface)
  for _, c in ipairs(checked) do
    local prop = prototypes.surface_property[c.property]
    line(parent, {"pst.condition", prop and prop.localised_name or c.property, common.fmt_number(c.value),
      common.fmt_number(c.min), common.fmt_number(c.max), c.ok and {"pst.condition-ok"} or {"pst.condition-fail"}})
  end
  return #checked
end

local function fill_selected(player, refs)
  local box = refs.selected
  if not (box and box.valid) then return end
  box.clear()
  local e = player.selected
  if not (e and e.valid) then
    hint(box, {"pst.selected-none"})
    return
  end
  local r = row(box)
  r.add({type = "sprite-button", style = "slot_button", sprite = sprite("entity", e.name),
    elem_tooltip = {type = "entity-with-quality", name = e.name, quality = e.quality.name}, tags = {pst_ui = "noop"}})
  local head = r.add({type = "flow", direction = "vertical"})
  head.style.vertical_spacing = 0
  head.add({type = "label", style = "bold_label", caption = {"", e.localised_name, "  [quality=" .. e.quality.name .. "]"}})
  local id = head.add({type = "label", caption = {"pst.selected-id", e.name, e.type}})
  id.style.font = "default-small"
  id.style.font_color = {0.75, 0.75, 0.75}
  local ok, history = pcall(prototypes.get_history, e.type, e.name)
  if ok and history then
    local changed = {}
    for i, mod in ipairs(history.changed) do
      if i > 8 then changed[#changed + 1] = "…" break end
      changed[#changed + 1] = mod
    end
    line(box, {"pst.selected-mods", history.created, #history.changed > 0 and table.concat(changed, ", ") or {"pst.nobody"}})
  end
  if e.max_health and e.max_health > 0 then
    line(box, {"pst.selected-health", common.fmt_number(e.health), common.fmt_number(e.max_health)})
  end
  local key = e.status and status_key(e.status)
  if key then line(box, {"pst.selected-status", {"entity-status." .. key}}) end
  if e.type == "assembling-machine" or e.type == "furnace" or e.type == "rocket-silo" then
    local ok_recipe, recipe = pcall(e.get_recipe)
    if ok_recipe and recipe then
      line(box, {"pst.selected-recipe", "[recipe=" .. recipe.name .. "]", recipe.localised_name})
    end
  end
  if e.type == "rocket-silo" then
    line(box, {"pst.selected-rocket-parts", e.rocket_parts, e.prototype.rocket_parts_required})
  end
  if e.type == "resource" then line(box, {"pst.selected-amount", common.fmt_number(e.amount)}) end
  if e.frozen then line(box, {"pst.selected-frozen"}) end
  local temperature = e.temperature
  if temperature then line(box, {"pst.selected-temperature", string.format("%.1f", temperature)}) end
  local fluids = {}
  for i = 1, e.fluids_count do
    local fluid = e.get_fluid(i)
    if fluid then
      fluids[#fluids + 1] = "[fluid=" .. fluid.name .. "] " .. common.fmt_number(fluid.amount) ..
        string.format(" (%.0f°)", fluid.temperature or 0)
    end
  end
  if #fluids > 0 then line(box, {"pst.selected-fluids", table.concat(fluids, "   ")}) end
  local conditions = e.prototype.surface_conditions
  if conditions and #conditions > 0 then
    box.add({type = "label", style = "caption_label", caption = {"pst.selected-conditions"}})
    condition_lines(box, conditions, e.surface)
  end
end

local function slot_with_number(parent, kind, name, number, tags)
  return parent.add({type = "sprite-button", style = "slot_button", sprite = sprite(kind, name), number = number,
    elem_tooltip = {type = kind, name = name}, tags = tags or {pst_ui = "noop"}})
end

local function fill_recipe(player, refs, d)
  local box = refs.recipe_info
  if not (box and box.valid) then return end
  box.clear()
  local name = d.recipe
  local proto = name and prototypes.recipe[name]
  if not proto then
    hint(box, {"pst.recipe-none"})
    return
  end
  local force_recipe = player.force.recipes[name]
  local r = row(box)
  r.add({type = "label", caption = force_recipe and force_recipe.enabled and {"pst.recipe-open"} or {"pst.recipe-closed"}})
  if force_recipe and not force_recipe.enabled then
    button(r, "pst.unlock-recipe", "pst.unlock-recipe-tooltip", {pst = "unlock-recipe", recipe = name})
  end

  local unlockers = catalog.unlockers(name)
  if #unlockers > 0 then
    box.add({type = "label", style = "caption_label", caption = {"pst.recipe-unlocked-by"}})
    local f = box.add({type = "flow", direction = "horizontal"})
    for _, tech in ipairs(unlockers) do
      local t = player.force.technologies[tech]
      f.add({type = "sprite-button", style = (t and t.researched) and "slot_sized_button_green" or "slot_sized_button",
        sprite = sprite("technology", tech), elem_tooltip = {type = "technology", name = tech},
        tags = {pst_ui = "pick-tech-from", tech = tech}})
    end
  else
    line(box, {"pst.recipe-no-unlock"})
  end

  box.add({type = "label", style = "caption_label", caption = {"pst.recipe-parts"}})
  local f = box.add({type = "flow", direction = "horizontal"})
  f.style.vertical_align = "center"
  for _, ing in pairs(proto.ingredients) do slot_with_number(f, ing.type, ing.name, ing.amount) end
  f.add({type = "label", caption = "→"})
  for _, prod in pairs(proto.products) do
    slot_with_number(f, prod.type, prod.name, prod.amount or prod.amount_max)
  end

  local surface = player.surface
  local recipe_checks, recipe_ok = catalog.check_conditions(proto.surface_conditions, surface)
  if #recipe_checks > 0 then
    box.add({type = "label", style = "caption_label", caption = {"pst.recipe-conditions"}})
    condition_lines(box, proto.surface_conditions, surface)
  end

  box.add({type = "label", style = "caption_label", caption = {"pst.recipe-machines"}})
  local any = false
  for _, category in ipairs(proto.categories) do
    local machines = catalog.machines(category)
    local cat = prototypes.recipe_category[category]
    local mr = row(box)
    mr.add({type = "label", caption = {"", cat and cat.localised_name or category, ":"}})
    for _, machine in ipairs(machines) do
      local _, machine_ok = catalog.check_conditions(machine.surface_conditions, surface)
      local fits = machine_ok and recipe_ok
      any = true
      mr.add({type = "sprite-button", style = fits and "slot_sized_button_green" or "slot_sized_button_red",
        sprite = sprite("entity", machine.name), elem_tooltip = {type = "entity", name = machine.name},
        tooltip = fits and {"pst.machine-fits"} or {"pst.machine-not-here"}, tags = {pst_ui = "noop"}})
    end
    if #machines == 0 then mr.add({type = "label", caption = {"pst.no-machines"}}) end
  end
  if any then hint(box, {"pst.machines-legend"}) end
end

local function fill_surface(player, refs)
  local t = refs.surface_info
  if not (t and t.valid) then return end
  t.clear()
  local surface = player.surface
  local nauvis = prototypes.space_location["nauvis"]
  local nauvis_props = nauvis and nauvis.surface_properties or {}
  for _, h in ipairs({{"pst.prop"}, {"pst.prop-here"}, {"pst.prop-nauvis"}}) do
    t.add({type = "label", style = "caption_label", caption = h})
  end
  for _, prop in ipairs(catalog.surface_properties()) do
    local ok, value = pcall(surface.get_property, prop.name)
    if not ok then value = nil end
    local home = nauvis_props[prop.name] or prop.default_value
    local unit = prop.localised_unit_key or ("surface-property-unit." .. prop.name)
    t.add({type = "label", caption = prop.localised_name})
    t.add({type = "label", caption = {"?", {unit, common.fmt_number(value)}, common.fmt_number(value)}})
    t.add({type = "label", caption = {"?", {unit, common.fmt_number(home)}, common.fmt_number(home)}})
  end
  local box = refs.surface_extra
  box.clear()
  line(box, {"pst.surface-day", common.fmt_number(surface.ticks_per_day / 60), string.format("%.0f",
    surface.darkness * 100)})
  line(box, {"pst.surface-solar", string.format("%.2f", surface.solar_power_multiplier)})
  local pollutant = surface.pollutant_type
  line(box, {"pst.surface-pollution", pollutant and pollutant.localised_name or {"pst.nothing"}})
  local platform = surface.platform
  if platform then
    line(box, {"pst.surface-platform", platform.name, platform_state_text(platform),
      common.fmt_number(math.floor(platform.weight / 1000000 + 0.5))})
  end
end

local function fill_resources(player, refs)
  local t = refs.resources
  if not (t and t.valid) then return end
  t.clear()
  local totals, order = {}, {}
  local found = player.surface.find_entities_filtered({position = player.position, radius = 256, type = "resource"})
  for _, e in pairs(found) do
    if not totals[e.name] then
      totals[e.name] = 0
      order[#order + 1] = e.name
    end
    totals[e.name] = totals[e.name] + e.amount
  end
  table.sort(order)
  for _, name in ipairs(order) do
    t.add({type = "sprite-button", style = "slot_button", sprite = sprite("entity", name), number = totals[name],
      elem_tooltip = {type = "entity", name = name}, tags = {pst_ui = "noop"}})
  end
  refs.resources_caption.caption = #order > 0 and {"pst.resources-found", #found} or {"pst.resources-none"}
  t.parent.visible = #order > 0
end

local function build_inspect(player, content, refs, d)
  local body = pane(content, {"pst.pane-selected"})
  refs.selected = body.add({type = "flow", direction = "vertical"})
  refs.selected.style.vertical_spacing = 4
  local g = grid(body, 3)
  button(g, "pst.repair-selected", "pst.repair-selected-tooltip", {pst = "repair-selected"})
  button(g, "pst.silo-ready", "pst.silo-ready-tooltip", {pst = "silo-ready"})
  button(g, "pst.remove-selected", "pst.remove-selected-tooltip", {pst = "remove-selected"})

  body = pane(content, {"pst.pane-recipe"})
  local r = row(body)
  refs.recipe_chooser = r.add({type = "choose-elem-button", elem_type = "recipe", recipe = d.recipe,
    tags = {pst_ui = "pick-recipe"}, tooltip = {"pst.pick-recipe"}})
  hint(r, {"pst.recipe-hint"})
  refs.recipe_info = body.add({type = "flow", direction = "vertical"})
  refs.recipe_info.style.vertical_spacing = 4

  body = pane(content, {"pst.pane-surface-info"})
  refs.surface_info = body.add({type = "table", column_count = 3})
  refs.surface_info.style.horizontal_spacing = 24
  refs.surface_extra = body.add({type = "flow", direction = "vertical"})
  r = row(body)
  local b = r.add({type = "button", caption = {"pst.count-resources"}, tooltip = {"pst.count-resources-tooltip"},
    tags = {pst_ui = "count-resources"}})
  b.style.minimal_width = 0
  refs.resources_caption = r.add({type = "label", caption = ""})
  local frame = body.add({type = "frame", style = "deep_frame_in_shallow_frame"})
  refs.resources = frame.add({type = "table", style = "slot_table", column_count = 18})
  frame.visible = false

  body = pane(content, {"pst.pane-report"})
  hint(body, {"pst.report-hint"})
  r = row(body)
  local rb = button(r, "pst.report", "pst.report-tooltip", {pst = "report"})
  rb.style.horizontally_stretchable = false
end

local function refresh_inspect(player, refs, d)
  fill_selected(player, refs)
  fill_recipe(player, refs, d)
  fill_surface(player, refs)
end

-------------------------------------------------------------------------------- window

local BUILDERS = {progress = build_progress, planets = build_planets, items = build_items, modes = build_modes,
  inspect = build_inspect}
local REFRESH = {progress = refresh_progress, planets = refresh_planets, modes = refresh_modes, inspect = refresh_inspect}

local function window(player)
  local frame = player.gui.screen[common.WINDOW]
  if frame and frame.valid then return frame end
  return nil
end

function G.is_open(player)
  return window(player) ~= nil
end

local function refresh_status(player, refs, d)
  if not (refs.status and refs.status.valid) then return end
  local surface = player.surface
  local where
  if surface.platform then
    where = {"", "[img=utility/starmap_platform_stopped] ", surface.platform.name}
  elseif surface.planet then
    where = {"", "[space-location=" .. surface.planet.name .. "] ", surface.planet.prototype.localised_name}
  else
    where = surface.name
  end
  local active = {}
  if player.cheat_mode then active[#active + 1] = "cheat" end
  for _, mode in ipairs({"immortal", "run", "reach", "mine"}) do
    if d.modes[mode] then active[#active + 1] = mode end
  end
  local modes = {""}
  for i, mode in ipairs(active) do
    if i > 1 then modes[#modes + 1] = ", " end
    modes[#modes + 1] = {"pst.mode-" .. mode}
  end
  local speed = game.tick_paused and {"pst.status-paused"} or {"pst.status-speed", common.fmt_number(game.speed)}
  refs.status.caption = {"pst.status", where, speed, #modes > 1 and modes or {"pst.status-no-modes"}}
end

-- Update what the current tab shows, the status line and the armed (red) buttons.
function G.refresh(player)
  if not (player and player.valid) then return end
  local frame = window(player)
  if not frame then return end
  local d = common.pdata(player)
  local refs = d.refs
  if not (refs.tabs and refs.tabs.valid) then return end
  local tab = TABS[refs.tabs.selected_tab_index or 1]
  local fn = REFRESH[tab]
  if fn then fn(player, refs, d) end
  refresh_status(player, refs, d)
  if d.armed and game.tick - d.armed.tick > CONFIRM_TICKS then d.armed = nil end
  for _, b in ipairs(refs.confirm_buttons or {}) do
    if b.valid and not (d.armed and d.armed.index == b.index) then b.caption = {b.tags.cap} end
  end
end

function G.refresh_all()
  for _, player in pairs(game.connected_players) do
    if G.is_open(player) then G.refresh(player) end
  end
end

-- Light periodic update while a window is open (status line and the current research).
function G.tick()
  for _, player in pairs(game.connected_players) do
    if G.is_open(player) then
      local d = common.pdata(player)
      local refs = d.refs
      refresh_status(player, refs, d)
      if refs.tabs and refs.tabs.valid and refs.tabs.selected_tab_index == 1 and refs.research_status.valid then
        local current = player.force.current_research
        refs.research_status.caption = current and {"pst.research-current", "[technology=" .. current.name .. "]",
          string.format("%d", math.floor(player.force.research_progress * 100))} or {"pst.research-none"}
      end
    end
  end
end

local function collect_confirm_buttons(element, out)
  for _, child in pairs(element.children) do
    local tags = child.tags
    if child.type == "button" and tags and tags.pst and actions.confirm[tags.pst] then out[#out + 1] = child end
    collect_confirm_buttons(child, out)
  end
  return out
end

function G.close(player)
  local frame = window(player)
  local d = common.pdata(player)
  if frame then
    d.location = frame.location
    frame.destroy()
  end
  d.refs = {}
  d.armed = nil
  if player.valid then player.set_shortcut_toggled(common.SHORTCUT, false) end
end

function G.open(player, tab_name)
  if not common.enabled() then
    common.say(player, {"pst.disabled"})
    return
  end
  local d = common.pdata(player)
  local old = window(player)
  if old then
    d.location = old.location
    old.destroy()
  end
  local refs = {}
  d.refs = refs
  local frame = player.gui.screen.add({type = "frame", name = common.WINDOW, direction = "vertical"})
  refs.frame = frame
  local scale = player.display_scale > 0 and player.display_scale or 1
  local max_height = math.max(400, math.floor(player.display_resolution.height / scale) - 160)

  local bar = frame.add({type = "flow", direction = "horizontal"})
  bar.drag_target = frame
  bar.style.horizontal_spacing = 8
  bar.add({type = "label", style = "frame_title", caption = {"pst.title"}, ignored_by_interaction = true})
  local drag = bar.add({type = "empty-widget", style = "draggable_space_header", ignored_by_interaction = true})
  drag.style.height = 24
  drag.style.horizontally_stretchable = true
  drag.style.right_margin = 4
  bar.add({type = "sprite-button", style = "frame_action_button", sprite = "utility/close", tooltip = {"pst.close"},
    tags = {pst_ui = "close"}})

  local deep = frame.add({type = "frame", style = "inside_deep_frame", direction = "vertical"})
  local tabs = deep.add({type = "tabbed-pane", tags = {pst_ui = "tabs"}})
  refs.tabs = tabs
  for _, key in ipairs(TABS) do
    local tab = tabs.add({type = "tab", caption = {"pst.tab-" .. key}})
    local scroll = tabs.add({type = "scroll-pane", style = "naked_scroll_pane", horizontal_scroll_policy = "never",
      vertical_scroll_policy = "auto-and-reserve-space"})
    scroll.style.maximal_height = max_height - 110
    local content = scroll.add({type = "flow", direction = "vertical"})
    content.style.padding = 12
    content.style.vertical_spacing = 12
    content.style.width = WIDTH
    tabs.add_tab(tab, scroll)
    BUILDERS[key](player, content, refs, d)
  end

  local foot = frame.add({type = "flow", direction = "horizontal"})
  foot.style.top_padding = 8
  foot.style.vertical_align = "center"
  foot.style.horizontal_spacing = 8
  refs.status = foot.add({type = "label", caption = ""})
  local filler = foot.add({type = "empty-widget"})
  filler.style.horizontally_stretchable = true
  refs.pin = foot.add({type = "checkbox", caption = {"pst.pin"}, tooltip = {"pst.pin-tooltip"}, state = d.pinned == true,
    tags = {pst_ui = "pin"}})

  refs.confirm_buttons = collect_confirm_buttons(frame, {})
  local index = 1
  for i, key in ipairs(TABS) do
    if key == tab_name then index = i end
  end
  if not tab_name then index = d.tab or 1 end
  tabs.selected_tab_index = index

  if d.location then frame.location = d.location else frame.force_auto_center() end
  if not d.pinned then player.opened = frame end
  player.set_shortcut_toggled(common.SHORTCUT, true)
  G.refresh(player)
end

function G.toggle(player, tab_name)
  if window(player) then G.close(player) else G.open(player, tab_name) end
end

-------------------------------------------------------------------------------- events

local function key_of_tab(index)
  return TABS[index]
end

-- An action from a GUI element (or from the remote interface with the same tags).
function G.act(player, tags, mods, element)
  local name = tags.pst
  local args = {}
  for k, v in pairs(tags) do
    if k ~= "pst" and k ~= "cap" then args[k] = v end
  end
  local d = common.pdata(player)
  mods = mods or {}
  if name == "milestone" then
    if mods.right then
      d.tech = tags.tech
      G.refresh(player)
      return true
    end
    name = "research"
    args = {tech = tags.tech, mode = mods.shift and "prereq" or "with"}
  end
  if actions.confirm[name] and not mods.confirmed then
    local armed = d.armed
    if not (element and armed and armed.index == element.index and game.tick - armed.tick <= CONFIRM_TICKS) then
      d.armed = {index = element and element.index or 0, tick = game.tick}
      if element and element.valid then element.caption = {"pst.confirm-again"} end
      return false, "armed"
    end
    d.armed = nil
  end
  local was_open = window(player) ~= nil
  local tab = d.tab
  local ok, message = actions.run(player, name, args)
  if message then
    if ok and actions.global[name] then common.announce(player, message) else common.say(player, message) end
  end
  -- A change of controller (map view, teleport, platform) closes the open window: bring it back on the same tab.
  if was_open and not window(player) and common.enabled() then G.open(player, TABS[tab or 1]) end
  if actions.global[name] then G.refresh_all() else G.refresh(player) end
  return ok, message
end

function G.on_click(e)
  local element = e.element
  if not (element and element.valid) then return end
  local tags = element.tags
  if not tags then return end
  local player = game.get_player(e.player_index)
  if not player then return end
  if tags.pst_ui then
    local ui = tags.pst_ui
    if ui == "close" then
      G.close(player)
    elseif ui == "pick-tech-from" then
      local d = common.pdata(player)
      d.tech = tags.tech
      local refs = d.refs
      if refs.tabs and refs.tabs.valid then
        refs.tabs.selected_tab_index = 1
        d.tab = 1
      end
      G.refresh(player)
    elseif ui == "count-resources" then
      fill_resources(player, common.pdata(player).refs)
    end
    return
  end
  if tags.pst and element.type ~= "checkbox" then
    G.act(player, tags, {right = e.button == defines.mouse_button_type.right, shift = e.shift, control = e.control},
      element)
  end
end

function G.on_checked(e)
  local element = e.element
  if not (element and element.valid) then return end
  local tags = element.tags
  local player = game.get_player(e.player_index)
  if not (player and tags) then return end
  local d = common.pdata(player)
  if tags.pst_ui == "show-hidden" then
    d.show_hidden = element.state
    fill_places(player, d.refs, d)
    G.refresh(player)
  elseif tags.pst_ui == "pin" then
    d.pinned = element.state
    local frame = window(player)
    if frame and not d.pinned then player.opened = frame end
  elseif tags.pst then
    G.act(player, tags, {}, element)
  end
end

function G.on_elem_changed(e)
  local element = e.element
  if not (element and element.valid and element.tags) then return end
  local player = game.get_player(e.player_index)
  if not player then return end
  local d = common.pdata(player)
  local ui = element.tags.pst_ui
  local value = element.elem_value
  if ui == "pick-tech" then
    d.tech = value
  elseif ui == "pick-recipe" then
    d.recipe = value
  elseif ui == "pick-item" then
    d.item = value
  elseif ui == "pick-fluid" then
    d.fluid = value
  elseif ui == "pick-tile" then
    d.tile = value
  else
    return
  end
  G.refresh(player)
end

function G.on_selection(e)
  local element = e.element
  if not (element and element.valid and element.tags) then return end
  local player = game.get_player(e.player_index)
  if not player then return end
  local d = common.pdata(player)
  local ui = element.tags.pst_ui
  if ui == "pick-quality" then
    local q = catalog.qualities()[element.selected_index]
    d.quality = q and q.name or "normal"
  elseif ui == "pick-count" then
    d.count = element.selected_index > 0 and element.selected_index or 2
  elseif ui == "pick-platform" then
    d.platform = d.platform_list and d.platform_list[element.selected_index] or nil
    G.refresh(player)
  end
end

function G.on_text(e)
  local element = e.element
  if not (element and element.valid and element.tags and element.tags.pst_ui == "temperature") then return end
  local player = game.get_player(e.player_index)
  if not player then return end
  common.pdata(player).fluid_temperature = tonumber(element.text)
end

function G.on_tab(e)
  local element = e.element
  if not (element and element.valid and element.tags and element.tags.pst_ui == "tabs") then return end
  local player = game.get_player(e.player_index)
  if not player then return end
  common.pdata(player).tab = element.selected_tab_index
  G.refresh(player)
end

function G.on_closed(e)
  local element = e.element
  if not (element and element.valid and element.name == common.WINDOW) then return end
  local player = game.get_player(e.player_index)
  if not player then return end
  if common.pdata(player).pinned then return end
  G.close(player)
end

function G.on_location(e)
  local element = e.element
  if not (element and element.valid and element.name == common.WINDOW) then return end
  local player = game.get_player(e.player_index)
  if player then common.pdata(player).location = element.location end
end

function G.on_selected_entity(player)
  local d = common.pdata(player)
  local refs = d.refs
  if not (refs.tabs and refs.tabs.valid and refs.tabs.selected_tab_index == 5) then return end
  fill_selected(player, refs)
end

-- Tags of every element that runs an action (the test suite clicks them one by one).
function G.action_elements(player)
  local frame = window(player)
  local out = {}
  local function walk(element)
    for _, child in pairs(element.children) do
      local tags = child.tags
      if tags and (tags.pst or tags.pst_ui) then
        out[#out + 1] = {type = child.type, tags = tags, enabled = child.enabled}
      end
      walk(child)
    end
  end
  if frame then walk(frame) end
  return out
end

-- Test hook: act as the player using a window control. `name` is a pst_ui tag ("pick-tech", "tabs", ...) or
-- "pst:<action>" for an action button; `nth` picks among equal ones. The value is set on the real element and the
-- same handler as the GUI event runs. Returns false when no such element is open.
function G.simulate(player, name, value, nth, mods)
  local frame = window(player)
  if not frame then return false end
  local want_action = name:match("^pst:(.+)$")
  local found, count = nil, 0
  local function walk(element)
    for _, child in pairs(element.children) do
      if found then return end
      local tags = child.tags
      if tags and ((want_action and tags.pst == want_action) or (not want_action and tags.pst_ui == name)) then
        count = count + 1
        if count == (nth or 1) then found = child return end
      end
      walk(child)
    end
  end
  if not want_action and name == "window" then found = frame else walk(frame) end
  if not found then return false end
  mods = mods or {}
  local e = {element = found, player_index = player.index, button = mods.right and defines.mouse_button_type.right or
    defines.mouse_button_type.left, shift = mods.shift == true, control = mods.control == true}
  local t = found.type
  if name == "window" then
    G.on_closed(e)
  elseif t == "choose-elem-button" then
    found.elem_value = value
    G.on_elem_changed(e)
  elseif t == "checkbox" then
    found.state = value == true
    G.on_checked(e)
  elseif t == "drop-down" then
    found.selected_index = value
    G.on_selection(e)
  elseif t == "textfield" then
    found.text = tostring(value or "")
    G.on_text(e)
  elseif t == "tabbed-pane" then
    found.selected_tab_index = value
    G.on_tab(e)
  else
    G.on_click(e)
  end
  return true
end

G.key_of_tab = key_of_tab
G.TABS = TABS

return G
