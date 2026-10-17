-- Ladders that continue the base game production achievements (from More Achievements).
-- Tiers 1..base_tiers are the base game achievements; their amounts are read at load time,
-- so changes by other mods (Bob's computer-age) are kept. `extra` lists the added tiers.
-- With the quality mod every tier counts only normal items and gets uncommon..legendary
-- variants named <name>-<tier>-<quality>.
--   icon          base achievement picture, "%d" cycles over the base tiers
--   marker_shift  shift of the II/III marker on extra tiers
--   badge_shift   shift of the quality badge
--   unsuffixed_first  tier 1 is named <name> instead of <name>-1

local function crafting_with(module, order)
  return {
    name = "crafting-with-" .. module,
    type = "produce-achievement",
    item = module .. "-module-3",
    base_tiers = 1,
    unsuffixed_first = true,
    extra = {50, 100},
    icon = "__base__/graphics/achievement/crafting-with-" .. module .. ".png",
    marker_shift = {16, -2},
    badge_shift = {-10, 10},
    order = "a[progress]-h[crafting-tier-3-module]-" .. order .. "[" .. module .. "]",
  }
end

return {
  crafting_with("speed", "a"),
  crafting_with("efficiency", "b"),
  crafting_with("productivity", "c"),
  {
    name = "mass-production",
    type = "produce-achievement",
    item = "electronic-circuit",
    base_tiers = 3,
    extra = {5e7, 1e8, 2.5e8, 5e8, 1e9, 2e10},
    icon = "__base__/graphics/achievement/mass-production-%d.png",
    order = "d[production]-b[electronic-circuit-production]",
  },
  {
    name = "circuit-veteran",
    type = "produce-per-hour-achievement",
    item = "advanced-circuit",
    base_tiers = 3,
    extra = {5e4, 1e5, 2.5e5, 5e5, 1e6, 5e6},
    icon = "__base__/graphics/achievement/circuit-veteran-%d.png",
    order = "d[production]-c[advanced-circuit-production]",
  },
  {
    name = "computer-age",
    type = "produce-per-hour-achievement",
    item = "processing-unit",
    base_tiers = 3,
    -- above Bob's tier 3 (15k per hour); the base game has 5k there
    extra = {2.5e4, 5e4, 1e5, 2.5e5, 5e5, 1e6},
    icon = "__base__/graphics/achievement/computer-age-%d.png",
    order = "d[production]-d[processing-unit-production]",
  },
  {
    name = "iron-throne",
    type = "produce-per-hour-achievement",
    item = "iron-plate",
    base_tiers = 3,
    extra = {1e6, 2.5e6, 5e6, 1e7, 2.5e7, 5e7},
    icon = "__base__/graphics/achievement/iron-throne-%d.png",
    order = "d[production]-e[iron-throne]",
  },
}
