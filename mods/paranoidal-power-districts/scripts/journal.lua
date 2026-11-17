-- Dispatcher journal (ring of 500 events per force), alerts and chat messages.
local state = require("scripts.state")

local M = {}
local MAX = 500
local ICON = { type = "virtual", name = "signal-lightning" }
local JOURNAL_ONLY = {
  ["ppd-journal.zone-in"] = true,
  ["ppd-journal.zone-out"] = true,
  ["ppd-journal.tap"] = true,
  ["ppd-journal.restored"] = true,
  ["ppd-journal.off-manual"] = true,
  ["ppd-journal.on-manual"] = true,
  ["ppd-journal.boost"] = true,
}

-- level: "alarm" (alerts for "all" and "alarms"), "info" (only for "all")
-- kind: "zone", "overload", "auto", "destroy", "wire"
function M.add(force_index, kind, level, msg, m, entity)
  local f = state.force(force_index)
  f.jn = f.jn + 1
  local ent = entity or (m and m.e)
  local pos = ent and ent.valid and ent.position or nil
  f.journal[(f.jn - 1) % MAX + 1] = { t = game.tick, k = kind, l = level, msg = msg, u = m and m.unit or nil,
    pos = pos, s = ent and ent.valid and ent.surface.index or nil }
  -- Routine switching stays in the journal, not in alerts or chat.
  if JOURNAL_ONLY[msg[1]] then return end
  local setting = m and m.msg or settings.global["ppd-default-messages"].value
  if setting == "none" or (setting == "alarms" and level ~= "alarm") then return end
  local force = game.forces[force_index]
  if not force then return end
  local already_shown = m and m.current_alert_message
    and serpent.line(m.current_alert_message) == serpent.line(msg)
  for _, player in pairs(force.connected_players) do
    if ent and ent.valid and not already_shown then player.add_custom_alert(ent, ICON, msg, true) end
    if setting == "all" then player.print({ "", "[img=virtual-signal/signal-lightning] ", msg }, { skip = defines.print_skip.if_visible }) end
  end
end

function M.clear_alerts(m, message)
  if not (m and m.e and m.e.valid) then return end
  local force = game.forces[m.force]
  if not force then return end
  for _, player in pairs(force.players) do
    player.remove_alert({ entity = m.e, type = defines.alert_type.custom, icon = ICON, message = message })
  end
  if not message or message == m.current_alert_message then
    m.current_alert_message, m.current_alert_key, m.current_alert_tick = nil, nil, nil
  end
end

-- Current electrical faults are refreshed by the existing district pass, without journal/chat repeats.
function M.current(m, message)
  local setting = m.msg or settings.global["ppd-default-messages"].value
  if not message or setting == "none" then
    if m.current_alert_message then M.clear_alerts(m, m.current_alert_message) end
    return
  end
  local key = message[1] -- state changes are immediate; percentages/names wait for the bounded refresh
  if key == m.current_alert_key and game.tick - (m.current_alert_tick or 0) < 300 then return end
  if m.current_alert_message then M.clear_alerts(m, m.current_alert_message) end
  local force = game.forces[m.force]
  if not (force and m.e and m.e.valid) then return end
  -- Also replaces an identical one-shot warning from the same pass.
  for _, player in pairs(force.connected_players) do
    player.remove_alert({ entity = m.e, type = defines.alert_type.custom, icon = ICON, message = message })
    player.add_custom_alert(m.e, ICON, message, true)
  end
  m.current_alert_message, m.current_alert_key, m.current_alert_tick = message, key, game.tick
end

-- newest first, optional kind filter
function M.list(force_index, kind, limit)
  local f = state.force(force_index)
  local out = {}
  local n = math.min(f.jn, MAX)
  for i = 0, n - 1 do
    local idx = (f.jn - 1 - i) % MAX + 1
    local e = f.journal[idx]
    if e and (kind == nil or kind == "all" or e.k == kind) then
      out[#out + 1] = e
      if #out >= limit then break end
    end
  end
  return out
end

return M
