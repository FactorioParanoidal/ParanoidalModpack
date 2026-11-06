-- Per-player preferences of the tree window. Kept apart from the window state (storage.native_players),
-- which is reset on every mod update, so the player's choices survive updates. Fields are created lazily.
local M = {}

M.DEFAULTS = {
  window = 85,        -- window size, percent of the screen
  size = 2,           -- card size index (SIZES in ui.lua)
  view = "grid",      -- "grid" or "list"
  open_with = "last", -- selected technology on open: "last", "goal", "current"
  show_done = false,  -- researched technologies shown inside eras without pressing "Researched"
  show_disabled = true,
  show_trigger = true,
  focus_search = false,
  mark_new = true,
  rich_tooltip = true,
  evolution = true,
  chat_goal = true,
}
M.WINDOW = {70, 85, 100}
M.OPEN_WITH = {"last", "goal", "current"}
M.VIEW = {"grid", "list"}
-- Order of the checkboxes in the settings window.
M.FLAGS = {"show_done", "show_disabled", "show_trigger", "focus_search", "mark_new", "rich_tooltip", "evolution",
  "chat_goal"}

local function prefs(index)
  storage.ptt_prefs = storage.ptt_prefs or {}
  local p = storage.ptt_prefs[index]
  if not p then p = {}; storage.ptt_prefs[index] = p end
  p.opts = p.opts or {}; p.filters = p.filters or {}
  return p
end
M.prefs = prefs

function M.get(index, key)
  local v = prefs(index).opts[key]
  if v == nil then return M.DEFAULTS[key] end
  return v
end

function M.set(index, key, value) prefs(index).opts[key] = value end

function M.reset(index) prefs(index).opts = {} end

-- Active filters of the tree: status ("all" when absent) and science-pack era key (nil = all).
function M.filters(index) return prefs(index).filters end

-- Read-only: does not create storage (usable from goal messages for players who never opened the tree).
function M.peek(index, key)
  local p = storage.ptt_prefs and storage.ptt_prefs[index]
  local v = p and p.opts and p.opts[key]
  if v == nil then return M.DEFAULTS[key] end
  return v
end

return M
