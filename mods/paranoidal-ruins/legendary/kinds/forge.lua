-- The Forge of Hephaestus: the floor of the great hall breathes fire in a rhythm - stripes and
-- checkers glow orange, then burn. Cross it to the anvil. The anvil flashes the order of the three
-- bellows; work them in that order and the forge awakens. A wrong bellows spits fire.
local C = require("legendary.config")

local KIND = { name = "forge", tier = "trial", size = 96, weight = 1, relic = "pd-relic-hephaestus-forge" }

local CELL, HX0, HY0, NI, NJ = 4, -36, -28, 18, 14      -- hall: x -36..35, y -28..27
local PERIOD, WARN = 120, 50
local BELLOWS = { { -14, -37, { 1, 0.3, 0.2 }, "red" }, { -1, -40, { 0.3, 1, 0.3 }, "green" }, { 12, -37, { 0.3, 0.5, 1 }, "blue" } }

-- step -> list of hot cells as rectangles in cell units {i1, j1, i2, j2}
local function pattern(step)
  local out = {}
  local s = step % 8
  if s < 3 then
    for i = s, NI - 1, 3 do out[#out + 1] = { i, 0, i, NJ - 1 } end
  elseif s < 6 then
    for j = s - 3, NJ - 1, 3 do out[#out + 1] = { 0, j, NI - 1, j } end
  else
    for i = 0, NI - 1 do
      for j = 0, NJ - 1 do
        if (i + j) % 2 == s - 6 then out[#out + 1] = { i, j, i, j } end
      end
    end
  end
  return out
end

function KIND.layout(plan, site)
  local rng, d = plan.rng, site.data
  plan:fill("red-desert-3", -48, -48, 47, 47)
  plan:fill(function(x, y) return ((math.floor((x - HX0) / CELL) + math.floor((y - HY0) / CELL)) % 2 == 0) and "black-refined-concrete" or "brown-refined-concrete" end,
    HX0, HY0, HX0 + NI * CELL - 1, HY0 + NJ * CELL - 1)
  plan:fill("refined-concrete", -40, -46, 39, -30)
  plan:wall_ring(-48, -48, 47, 47, { { -1, 47 }, { 0, 47 } })
  plan:wall_line(HX0 - 1, -47, HX0 - 1, 46)
  plan:wall_line(HX0 + NI * CELL, -47, HX0 + NI * CELL, 46)
  -- the anvil and the bellows
  plan:put("crash-site-spaceship-wreck-medium-1", -1, -36, { force = "neutral", invincible = true, locked = true, key = "anvil" })
  plan:vault(-6, -43)
  plan:vault(5, -43)
  d.order = rng.shuffle({ 1, 2, 3 })
  for i, b in ipairs(BELLOWS) do plan:lever("bellows-" .. i, b[1], b[2]) end
  -- sparks: scorch decorations on the hall floor
  plan:sprinkle({ "medium-scorchmark", "big-scorchmark" }, 24, nil, { HX0, HY0, HX0 + NI * CELL - 1, HY0 + NJ * CELL - 1 })
  d.input = {}
end

function KIND.built(site, K)
  for _, b in ipairs(BELLOWS) do
    K.circle(site, K.abs(site, b[1] + 0.5, b[2] + 0.5), 1.4, { b[3][1], b[3][2], b[3][3], 0.45 }, nil, true, true)
  end
  K.light(site, K.abs(site, 0, -36), 3, { 1, 0.5, 0.2 }, true)
  K.text(site, K.abs(site, 0.5, 33), { "pd-legendary-forge.sign" }, { 1, 0.6, 0.3 }, 1.4, nil, true)
end

function KIND.tick(site, ctx, K)
  local d = site.data
  local t = ctx.tick % PERIOD
  local step = math.floor(ctx.tick / PERIOD)
  local cells = pattern(step)
  if t < 6 then
    for _, r in ipairs(cells) do
      rendering.draw_rectangle({ surface = site.surface, filled = true, draw_on_ground = true, color = { 0.9, 0.5, 0.1, 0.35 },
        left_top = K.abs(site, HX0 + r[1] * CELL, HY0 + r[2] * CELL),
        right_bottom = K.abs(site, HX0 + (r[3] + 1) * CELL, HY0 + (r[4] + 1) * CELL), time_to_live = WARN })
    end
  elseif t >= WARN and t < WARN + 6 then
    for _, r in ipairs(cells) do
      rendering.draw_rectangle({ surface = site.surface, filled = true, draw_on_ground = true, color = { 1, 0.15, 0.05, 0.55 },
        left_top = K.abs(site, HX0 + r[1] * CELL, HY0 + r[2] * CELL),
        right_bottom = K.abs(site, HX0 + (r[3] + 1) * CELL, HY0 + (r[4] + 1) * CELL), time_to_live = PERIOD - WARN })
    end
  end
  if t >= WARN then
    for _, p in ipairs(ctx.players) do
      local i, j = math.floor((p.rx - HX0) / CELL), math.floor((p.ry - HY0) / CELL)
      if i >= 0 and j >= 0 and i < NI and j < NJ then
        for _, r in ipairs(cells) do
          if i >= r[1] and i <= r[3] and j >= r[2] and j <= r[4] then
            K.damage(p.char, 14, "fire")
            K.stick(site, p.char, "fire-sticker")
            break
          end
        end
      end
    end
  end
  -- the anvil shows the order of the bellows, one second per bellows, every eight seconds
  local s = ctx.tick % 480
  if s < 6 or (s >= 60 and s < 66) or (s >= 120 and s < 126) then
    local n = s < 6 and 1 or (s < 66 and 2 or 3)
    local b = BELLOWS[d.order[n]]
    K.circle(site, K.abs(site, 0, -35.5), 2.2, { b[3][1], b[3][2], b[3][3], 0.6 }, 50, true)
  end
end

function KIND.lever(site, key, player, entity, K)
  local i = tonumber(key:match("^bellows%-(%d)$"))
  local d = site.data
  if not i then return end
  local b = BELLOWS[i]
  K.relever(site, key, b[1] + 0.5, b[2] + 0.5)
  d.input[#d.input + 1] = i
  local n = #d.input
  if d.order[n] ~= i then
    d.input = {}
    K.say(site, { "pd-legendary-forge.wrong" })
    for _ = 1, 6 do K.flame(site, K.abs(site, b[1] + math.random(-3, 3), b[2] + math.random(1, 4))) end
    K.explode(site, K.abs(site, b[1] + 0.5, b[2] + 2), 3, 60, "big-explosion")
    return
  end
  K.float(site, entity.valid and entity.position or K.abs(site, b[1], b[2]), { "pd-legendary-forge.bellows", n, 3 }, { 1, 0.7, 0.3 })
  if n == 3 then
    K.say(site, { "pd-legendary-forge.awake" })
    K.solve(site, player)
  end
end

return KIND
