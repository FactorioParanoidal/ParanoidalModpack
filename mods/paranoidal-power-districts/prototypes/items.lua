local S = require("shared")

-- first existing item of the list (the build loads us after zzzparanoidal, so Bob's items exist here;
-- the fallbacks keep the mod loadable without them)
local function ing(names, amount)
  if type(names) == "string" then names = { names } end
  for _, n in ipairs(names) do
    if data.raw.item[n] then return { type = "item", name = n, amount = amount } end
  end
  return { type = "item", name = names[#names], amount = amount }
end

local INGREDIENTS = {
  ["40"] = { ing("iron-plate", 10), ing("copper-cable", 20), ing({ "bob-basic-circuit-board", "electronic-circuit" }, 4),
    ing({ "small-iron-electric-pole", "small-electric-pole" }, 2) },
  ["80"] = { ing("ppd-transformer-40", 1), ing("steel-plate", 10), ing("copper-cable", 30), ing("electronic-circuit", 6) },
  ["160"] = { ing("ppd-transformer-80", 1), ing("steel-plate", 20), ing("copper-cable", 50), ing("advanced-circuit", 10), ing("concrete", 10) },
  ["320"] = { ing("ppd-transformer-160", 1), ing("steel-plate", 40), ing("copper-cable", 100), ing("processing-unit", 10), ing("concrete", 20) },
}
local TIME = { ["40"] = 5, ["80"] = 10, ["160"] = 15, ["320"] = 20 }

local protos = {
  { type = "item-subgroup", name = "ppd-power", group = "logistics", order = "a-06z" },
}

-- no custom_tooltip_fields on the items: the item tooltip already shows the fields of its place_result entity
-- (0.1.0 had them on both and every number appeared twice)
for i, t in ipairs(S.TIERS) do
  protos[#protos + 1] = {
    type = "item",
    name = t.name,
    icons = { { icon = S.GFX .. "icons/transformer-" .. t.key .. ".png", icon_size = 64, mipmap_count = 4 } },
    subgroup = "ppd-power",
    order = "a[transformer]-" .. i,
    place_result = t.name,
    stack_size = 10,
  }
  protos[#protos + 1] = {
    type = "recipe",
    name = t.name,
    enabled = false,
    energy_required = TIME[t.key],
    ingredients = INGREDIENTS[t.key],
    results = { { type = "item", name = t.name, amount = 1 } },
  }
end

protos[#protos + 1] = {
  type = "item",
  name = S.LOAD_BANK,
  icons = { { icon = "__base__/graphics/icons/accumulator.png", icon_size = 64, tint = { r = 1, g = 0.55, b = 0.32, a = 1 } } },
  subgroup = "ppd-power",
  order = "b[load-bank]",
  place_result = S.LOAD_BANK,
  stack_size = 20,
}
protos[#protos + 1] = {
  type = "recipe",
  name = S.LOAD_BANK,
  enabled = false,
  energy_required = 5,
  ingredients = { ing("steel-plate", 10), ing("copper-cable", 40), ing("electronic-circuit", 5), ing("iron-plate", 10) },
  results = { { type = "item", name = S.LOAD_BANK, amount = 1 } },
}

-- power meter (0.2.0)
protos[#protos + 1] = {
  type = "item",
  name = S.METER,
  icons = {
    { icon = "__base__/graphics/icons/display-panel.png", icon_size = 64 },
    { icon = "__base__/graphics/icons/signal/signal-lightning.png", icon_size = 64, scale = 0.25, shift = { 8, 8 } },
  },
  subgroup = "ppd-power",
  order = "c[meter]",
  place_result = S.METER,
  stack_size = 50,
}
protos[#protos + 1] = {
  type = "recipe",
  name = S.METER,
  enabled = false,
  energy_required = 2,
  ingredients = { ing("electronic-circuit", 3), ing("copper-cable", 10), ing("iron-plate", 5) },
  results = { { type = "item", name = S.METER, amount = 1 } },
}

data:extend(protos)
