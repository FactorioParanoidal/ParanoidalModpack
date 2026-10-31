-- Grid maze shared by the labyrinth and the forest of Yggdrasil.
-- Cells (i, j), 0-based, n x n. Edge keys: "h:i:j" between (i, j) and (i + 1, j),
-- "v:i:j" between (i, j) and (i, j + 1). open[edge] = true is a passage.
local M = {}

function M.edge(i1, j1, i2, j2)
  if i2 < i1 or j2 < j1 then i1, j1, i2, j2 = i2, j2, i1, j1 end
  if i2 == i1 + 1 then return "h:" .. i1 .. ":" .. j1 end
  return "v:" .. i1 .. ":" .. j1
end

local DIRS = { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }

function M.neighbours(n, i, j)
  local out = {}
  for _, d in ipairs(DIRS) do
    local a, b = i + d[1], j + d[2]
    if a >= 0 and b >= 0 and a < n and b < n then out[#out + 1] = { a, b } end
  end
  return out
end

---Perfect maze by an iterative backtracker; `blocked(i, j)` cells are left out.
function M.generate(n, rng, start, blocked)
  local open, seen = {}, {}
  local function id(i, j) return i * n + j end
  local stack = { start }
  seen[id(start[1], start[2])] = true
  while #stack > 0 do
    local top = stack[#stack]
    local options = {}
    for _, nb in ipairs(M.neighbours(n, top[1], top[2])) do
      if not seen[id(nb[1], nb[2])] and not (blocked and blocked(nb[1], nb[2])) then options[#options + 1] = nb end
    end
    if #options == 0 then
      stack[#stack] = nil
    else
      local nb = options[rng.next(1, #options)]
      open[M.edge(top[1], top[2], nb[1], nb[2])] = true
      seen[id(nb[1], nb[2])] = true
      stack[#stack + 1] = nb
    end
  end
  return open
end

---Opens extra passages (loops) between cells that are both part of the maze.
function M.loops(n, open, rng, chance, blocked)
  for i = 0, n - 1 do
    for j = 0, n - 1 do
      if not (blocked and blocked(i, j)) then
        for _, nb in ipairs({ { i + 1, j }, { i, j + 1 } }) do
          if nb[1] < n and nb[2] < n and not (blocked and blocked(nb[1], nb[2])) and rng.next() < chance then
            open[M.edge(i, j, nb[1], nb[2])] = true
          end
        end
      end
    end
  end
end

---Breadth-first distances from a cell over open passages.
function M.distances(n, open, from)
  local dist = { [from[1] * n + from[2]] = 0 }
  local queue, head = { from }, 1
  while head <= #queue do
    local c = queue[head]
    head = head + 1
    local d = dist[c[1] * n + c[2]]
    for _, nb in ipairs(M.neighbours(n, c[1], c[2])) do
      local k = nb[1] * n + nb[2]
      if dist[k] == nil and open[M.edge(c[1], c[2], nb[1], nb[2])] then
        dist[k] = d + 1
        queue[#queue + 1] = nb
      end
    end
  end
  return dist
end

function M.degree(n, open, i, j)
  local d = 0
  for _, nb in ipairs(M.neighbours(n, i, j)) do
    if open[M.edge(i, j, nb[1], nb[2])] then d = d + 1 end
  end
  return d
end

---Number of reachable cells from `from`.
function M.reach(n, open, from)
  local count = 0
  for _ in pairs(M.distances(n, open, from)) do count = count + 1 end
  return count
end

return M
