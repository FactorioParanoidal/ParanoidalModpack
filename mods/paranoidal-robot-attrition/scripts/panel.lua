-- Panel next to the roboport window: the numbers the scan uses for this network. Refreshed every check.
local shared = require("shared")
local model = require("scripts.model")
local stats = require("scripts.stats")

local M = {}

local TICKS_PER_HOUR = 216000

local ctx = model.new_context()

local function fixed(value, digits)
  return string.format("%." .. digits .. "f", value)
end

local function lines_for(entity)
  local cell = entity.logistic_cell
  local network = cell and cell.logistic_network
  if not network then return {{"pra.panel-no-network"}} end
  local force, surface = entity.force, entity.surface
  local busy = network.all_logistic_robots - network.available_logistic_robots
  ctx.force, ctx.surface, ctx.network, ctx.busy = force, surface, network, busy
  model.queues(ctx)
  local lines = {
    {"pra.panel-busy", tostring(busy), tostring(shared.min_busy + 1)},
    {"pra.panel-queue", tostring(ctx.waiting), tostring(shared.queue_weight / shared.busy_weight)},
  }
  local factor = settings.global[shared.setting].value
  local dispatch, wind = model.dispatch_multiplier(force), model.wind_multiplier()
  local surface_multiplier = model.surface_multiplier(surface.index)
  if factor <= 0 or surface_multiplier <= 0 then
    lines[#lines + 1] = {"pra.panel-off"}
  elseif busy <= shared.min_busy then
    lines[#lines + 1] = {"pra.panel-rate-none", tostring(shared.min_busy + 1)}
  else
    ctx.risk, ctx.multiplier = model.risk(force.index, surface.index), surface_multiplier * dispatch * wind
    lines[#lines + 1] = {"pra.panel-rate", fixed(model.per_tick(ctx, factor) * TICKS_PER_HOUR, 1)}
  end
  lines[#lines + 1] = {"pra.panel-factors", fixed(dispatch, 2), fixed(wind, 2)}
  local limit = model.safety_level(force) * shared.safety_per_level
  if limit == 0 then
    lines[#lines + 1] = {"pra.panel-safety-none"}
  elseif busy <= limit then
    lines[#lines + 1] = {"pra.panel-safe", tostring(limit)}
  else
    lines[#lines + 1] = {"pra.panel-unsafe", tostring(limit)}
  end
  lines[#lines + 1] = {"pra.panel-crashes", tostring(stats.last_hour(force.index)), tostring(stats.total(force.index))}
  ctx.force, ctx.surface, ctx.network = nil, nil, nil
  return lines
end

function M.close(player_index)
  local panel = storage.panels[player_index]
  if panel and panel.frame.valid then panel.frame.destroy() end
  storage.panels[player_index] = nil
  local player = game.get_player(player_index)
  local stray = player and player.gui.relative[shared.panel_name]
  if stray then stray.destroy() end
end

function M.refresh(player_index)
  local panel = storage.panels[player_index]
  if not panel then return end
  if not (panel.entity.valid and panel.frame.valid) then
    M.close(player_index)
    return
  end
  local body = panel.body
  body.clear()
  for _, line in ipairs(lines_for(panel.entity)) do
    local label = body.add{type = "label", caption = line}
    label.style.single_line = false
    label.style.maximal_width = 300
  end
  local footer = body.add{type = "label", caption = {"pra.panel-footer"}}
  footer.style.single_line = false
  footer.style.maximal_width = 300
  footer.style.font = "default-small"
  footer.style.font_color = {0.6, 0.6, 0.6}
end

function M.open(player, entity)
  M.close(player.index)
  if not (entity and entity.valid and entity.type == "roboport") then return end
  if not player.mod_settings[shared.setting_panel].value then return end
  local frame = player.gui.relative.add{
    type = "frame",
    name = shared.panel_name,
    caption = {"pra.panel-title"},
    direction = "vertical",
    anchor = {gui = defines.relative_gui_type.roboport_gui, position = defines.relative_gui_position.right},
  }
  local body = frame.add{type = "frame", style = "inside_shallow_frame_with_padding", direction = "vertical"}
  storage.panels[player.index] = {entity = entity, frame = frame, body = body}
  M.refresh(player.index)
end

function M.refresh_all()
  for player_index in pairs(storage.panels) do M.refresh(player_index) end
end

return M
