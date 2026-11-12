local S = require("shared")

local function packs(n)
  local list = { "automation-science-pack", "logistic-science-pack", "chemical-science-pack",
    "production-science-pack", "utility-science-pack" }
  local out = {}
  for i = 1, n do out[i] = { list[i], 1 } end
  return out
end

local function icon(key) return S.GFX .. "technology/transformer-" .. key .. ".png" end

local function overlay(kind, key)
  local f = util and util["technology_icon_constant_" .. kind]
  if f then return f(icon(key)) end
  return { { icon = icon(key), icon_size = 256 } }
end

local function tech(t)
  return {
    type = "technology",
    name = t.name,
    icons = t.icons or { { icon = icon(t.icon or "80"), icon_size = 256 } },
    prerequisites = t.prereq,
    effects = t.effects or { { type = "nothing", effect_description = t.note } },
    unit = { count = t.count, ingredients = packs(t.packs), time = t.time or 30 },
    upgrade = t.upgrade,
    order = "c-e-p-" .. t.name,
  }
end

local list = {
  tech { name = S.TECH.t40, icon = "40", prereq = { "electricity" }, count = 50, packs = 1, time = 15,
    effects = { { type = "unlock-recipe", recipe = "ppd-transformer-40" },
      { type = "nothing", effect_description = { "ppd-tech.dispatcher" } } } },
  tech { name = S.TECH.t80, icon = "80", prereq = { S.TECH.t40, "medium-electric-pole" }, count = 100, packs = 2,
    effects = { { type = "unlock-recipe", recipe = "ppd-transformer-80" } } },
  tech { name = S.TECH.t160, icon = "160", prereq = { S.TECH.t80, "electric-energy-distribution-2" }, count = 200, packs = 3,
    effects = { { type = "unlock-recipe", recipe = "ppd-transformer-160" } } },
  tech { name = S.TECH.t320, icon = "320", prereq = { S.TECH.t160, "production-science-pack" }, count = 300, packs = 4, time = 45,
    effects = { { type = "unlock-recipe", recipe = "ppd-transformer-320" } } },
  tech { name = S.TECH.load_bank, prereq = { S.TECH.t80, "electric-energy-accumulators" }, count = 100, packs = 2,
    icons = { { icon = "__base__/graphics/technology/electric-energy-acumulators.png", icon_size = 256, tint = { r = 1, g = 0.6, b = 0.4, a = 1 } } },
    effects = { { type = "unlock-recipe", recipe = S.LOAD_BANK } } },
  tech { name = S.TECH.automation, prereq = { S.TECH.t80, "circuit-network" }, count = 150, packs = 2,
    icons = overlay("equipment", "160"), note = { "ppd-tech.automation" } },
}

local eff_packs = { 2, 3, 3, 4, 5 }
local eff_count = { 100, 150, 250, 300, 400 }
local eff_prereq = { { S.TECH.t80 }, { "chemical-science-pack" }, { S.TECH.t160 }, { "production-science-pack" }, { "utility-science-pack" } }
for i = 1, S.EFFICIENCY_LEVELS do
  local pre = {}
  if i > 1 then pre[1] = S.TECH.efficiency .. (i - 1) end
  for _, p in ipairs(eff_prereq[i]) do pre[#pre + 1] = p end
  list[#list + 1] = tech { name = S.TECH.efficiency .. i, prereq = pre, count = eff_count[i], packs = eff_packs[i],
    icons = overlay("productivity", "320"), note = { "ppd-tech.efficiency" }, upgrade = true }
end
list[#list + 1] = tech { name = S.TECH.regulation .. 1, prereq = { S.TECH.efficiency .. 2 }, count = 200, packs = 3,
  icons = overlay("range", "160"), note = { "ppd-tech.regulation", "15" }, upgrade = true }
list[#list + 1] = tech { name = S.TECH.regulation .. 2, prereq = { S.TECH.regulation .. 1, "utility-science-pack" }, count = 400, packs = 5,
  icons = overlay("range", "320"), note = { "ppd-tech.regulation", "20" }, upgrade = true }

-- 0.2.0: taps and the automatic tap changer, amorphous cores, short overload, power metering
local function constant(file, key)
  return { { icon = icon(key), icon_size = 256 },
    { icon = "__core__/graphics/icons/technology/constants/" .. file, icon_size = 128, scale = 0.5, shift = { 50, 50 },
      floating = true } }
end
list[#list + 1] = tech { name = S.TECH.taps .. 1, prereq = { S.TECH.t80 }, count = 150, packs = 2,
  icons = constant("constant-capacity.png", "80"), note = { "ppd-tech.taps", "10" }, upgrade = true }
list[#list + 1] = tech { name = S.TECH.taps .. 2, prereq = { S.TECH.taps .. 1, S.TECH.t160 }, count = 250, packs = 3,
  icons = constant("constant-capacity.png", "160"), note = { "ppd-tech.taps", "20" }, upgrade = true }
list[#list + 1] = tech { name = S.TECH.auto_taps, prereq = { S.TECH.taps .. 2, S.TECH.automation }, count = 300, packs = 3,
  icons = constant("constant-speed.png", "160"), note = { "ppd-tech.auto-taps" } }
list[#list + 1] = tech { name = S.TECH.amorphous, prereq = { S.TECH.t160 }, count = 250, packs = 3,
  icons = constant("constant-battery.png", "160"), note = { "ppd-tech.amorphous" } }
list[#list + 1] = tech { name = S.TECH.boost, prereq = { S.TECH.t160, S.TECH.automation }, count = 300, packs = 3,
  icons = constant("constant-damage.png", "320"), note = { "ppd-tech.boost" } }
list[#list + 1] = tech { name = S.TECH.metering, prereq = { S.TECH.t40, "circuit-network" }, count = 75, packs = 2,
  icons = { { icon = "__base__/graphics/technology/circuit-network.png", icon_size = 256 },
    { icon = icon("40"), icon_size = 256, scale = 0.25, shift = { 40, 40 }, floating = true } },
  effects = { { type = "unlock-recipe", recipe = S.METER } } }

data:extend(list)
