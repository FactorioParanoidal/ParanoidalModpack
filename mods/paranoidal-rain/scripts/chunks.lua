-- Generated chunk count per rain surface (thunder rate). Counted once, then kept by on_chunk_generated.
local R = require("scripts.registry")

local M = {}
R.chunks = M

local function count(index)
  local surface = game.surfaces[index]
  if not surface then return 0 end
  local n = 0
  for _ in surface.get_chunks() do n = n + 1 end
  storage.chunk_counts[index] = n
  return n
end

function M.reconcile()
  storage.chunk_counts = storage.chunk_counts or {}
  local keep = {}
  for _, index in ipairs(R.surfaces.rain_indices()) do
    keep[index] = true
    if not storage.chunk_counts[index] then count(index) end
  end
  for index in pairs(storage.chunk_counts) do
    if not keep[index] then storage.chunk_counts[index] = nil end
  end
end

function M.on_chunk_generated(index)
  local counts = storage.chunk_counts
  if counts and counts[index] then counts[index] = counts[index] + 1 end
end

function M.count(index)
  local counts = storage.chunk_counts
  return counts and counts[index] or 0
end

function M.forget(index)
  if storage.chunk_counts then storage.chunk_counts[index] = nil end
end

return M
