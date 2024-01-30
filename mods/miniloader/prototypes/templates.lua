local templates = {
  [""] = {
    next_prefix = "fast-",
    prerequisite_techs = {"logistics", "fast-inserter", "steel-processing"},
    tint = util.color("ffc340D1"),
  },
  ["fast-"] = {
    next_prefix = "express-",
    prerequisite_techs = {"logistics-2", "miniloader"},
    tint = util.color("e31717D1"),
  },
  ["express-"] = {
    prerequisite_techs = {"logistics-3", "fast-miniloader"},
    tint = util.color("43c0faD1"),
  }
}

-- Bob's support
if data.raw.item["basic-transport-belt"] then
  local hex, alpha
  if mods["boblogistics-belt-reskin"] then
    basic_hex = "00000000"
  else
    basic_hex = "7d7d7dD1"
  end
  templates["basic-"] = {
    next_prefix = "",
    prerequisite_techs = {"logistics-0"},
    tint = util.color(basic_hex), 
  }
  templates[""].prerequisite_techs = {"logistics", "basic-miniloader"}
end

if data.raw.item["turbo-transport-belt"] then
  local turbo_hex
  if mods["boblogistics-belt-reskin"] then
    turbo_hex = "df1ee5D1"
  else
    turbo_hex = "a510e5D1"
  end
  templates["express-"].next_prefix = "turbo-"
  templates["turbo-"] = {
    next_prefix = "ultimate-",
    prerequisite_techs = {"logistics-4", "express-miniloader"},
    tint = util.color(turbo_hex),
  }
  templates["ultimate-"] = {
    prerequisite_techs = {"logistics-5", "turbo-miniloader"},
    tint = util.color("16f263D1"),
  }
end

-- FactorioExtended-Plus-Transport support
if data.raw.item["rapid-transport-belt-mk2"] then
  templates["express-"].next_prefix = "rapid-mk1-"
  templates["rapid-mk1-"] = {
    next_prefix = "rapid-mk2-",
    prerequisite_techs = {"logistics-4", "express-miniloader"},
    tint = util.color("2cd529D1"),
    base_underground_name = "rapid-transport-belt-to-ground-mk1",
  }
  templates["rapid-mk2-"] = {
    prerequisite_techs = {"logistics-5", "rapid-mk1-miniloader"},
    tint = util.color("9a2cc9D1"),
    base_underground_name = "rapid-transport-belt-to-ground-mk2",
  }
end

-- Krastorio2 support
if data.raw.item["kr-superior-transport-belt"] then
  templates["express-"].next_prefix = "kr-advanced-"
  templates["kr-advanced-"] = {
    prerequisite_techs = {"kr-logistic-4", "express-miniloader"},
    tint = util.color("3ade21D1"),
  }
  templates["kr-superior-"] = {
    prerequisite_techs = {"kr-logistic-5", "kr-advanced-miniloader"},
    tint = util.color("a30bd6D1"),
  }
end

-- RandomFactorioThings and PlutoniumEnergy support
-- note: RFT doesn't add belts and other plutonium machinery without PE mod
if mods["RandomFactorioThings"] then
  templates["nuclear-"] = {
    prerequisite_techs = {"nuclear-logistics", "express-miniloader"},
    tint = util.color("00ff00")
  }
  if mods["PlutoniumEnergy"] then
    templates["plutonium-"] = {
      prerequisite_techs = {"plutonium-logistics", "nuclear-miniloader"},
      tint = util.color("00e1ffde")
    }
  end
end

-- UltimateBelts support
if data.raw.technology["ultimate-logistics"] then
  -- Support both sets of Ultimate Belt colors
  local ub_hexes = {}  
  if mods["UltimateBelts_Owoshima_And_Pankeko-Mod"] then
    -- Pankeko UB colors
    ub_hexes.ultra_fast      = "2bc24bDB"
    ub_hexes.extreme_fast    = "c4632fDB"
    ub_hexes.ultra_express   = "6f2de0D1"
    ub_hexes.extreme_express = "3d3af0DB"
    ub_hexes.ultimate        = "999999D1"
  else
    -- Standard UB colors
    ub_hexes.ultra_fast      = "00b30cFF"
    ub_hexes.extreme_fast    = "e00000FF"
    ub_hexes.ultra_express   = "3604b5E8"
    ub_hexes.extreme_express = "002bffFF"
    ub_hexes.ultimate        = "00ffddD1"
  end

  -- Setup miniloaders
  templates["ub-ultra-fast-"] = {
    next_prefix = "ub-extreme-fast-",
    prerequisite_techs = {"ultra-fast-logistics",      "express-miniloader"},
    tint = util.color(ub_hexes.ultra_fast),
    base_underground_name = "ultra-fast-underground-belt",
  }
  templates["ub-extreme-fast-"] = {
    next_prefix = "ub-ultra-express-",
    prerequisite_techs = {"extreme-fast-logistics",    "ub-ultra-fast-miniloader"},
    tint = util.color(ub_hexes.extreme_fast),
    base_underground_name = "extreme-fast-underground-belt",
  }
  templates["ub-ultra-express-"] = {
    next_prefix = "ub-extreme-express-",
    prerequisite_techs = {"ultra-express-logistics",   "ub-extreme-fast-miniloader"},
    tint = util.color(ub_hexes.ultra_express),
    base_underground_name = "ultra-express-underground-belt",
  }
  templates["ub-extreme-express-"] = {
    next_prefix = "ub-ultimate-",
    prerequisite_techs = {"extreme-express-logistics", "ub-ultra-express-miniloader"},
    tint = util.color(ub_hexes.extreme_express),
    base_underground_name = "extreme-express-underground-belt",
  }
  templates["ub-ultimate-"] = {
    prerequisite_techs = {"ultimate-logistics",        "ub-extreme-express-miniloader"},
    tint = util.color(ub_hexes.ultimate),
    base_underground_name = "original-ultimate-underground-belt",
  }
end

-- space-exploration support
if data.raw.item["se-space-transport-belt"] then
  templates["space-"] = {
    prerequisite_techs = {"se-space-platform-scaffold"},
    base_underground_name = "se-space-underground-belt",
  }
end

if data.raw.item["se-deep-space-transport-belt-black"] then
  templates["deep-space-"] = {
    prerequisite_techs = {"se-deep-space-transport-belt"},
    tint = {r=0,g=0,b=0},
    base_underground_name = "se-deep-space-underground-belt-black",
  }
  templates["space-"]["next_prefix"] = "deep-space-"
end

return templates
