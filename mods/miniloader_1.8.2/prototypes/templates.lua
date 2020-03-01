local templates = {
  [""] = {
    next_prefix = "fast-",
    prerequisite_techs = {"logistics-2"},
    tint = {r=0.8,  g=0.6,  b=0.05},
  },
  ["fast-"] = {
    next_prefix = "express-",
    prerequisite_techs = {"miniloader"},
    tint = {r=0.75, g=0.07, b=0.07},
  },
  ["express-"] = {
    prerequisite_techs = {"logistics-3", "fast-miniloader"},
    tint = {r=0.25, g=0.65, b=0.82},
  }
}

-- Bob's support
if data.raw.item["turbo-transport-belt"] then
  templates["express-"].next_prefix = "turbo-"
  templates["turbo-"] = {
    next_prefix = "ultimate-",
    prerequisite_techs = {"logistics-4", "express-miniloader"},
    tint = {r=0.68, g=0.25, b=0.84},
  }
  templates["ultimate-"] = {
    prerequisite_techs = {"logistics-5", "turbo-miniloader"},
    tint = {r=0.24, g=0.78, b=0.05},
  }
end

-- FactorioExtended-Plus-Transport support
if data.raw.item["rapid-transport-belt-mk2"] then
  templates["express-"].next_prefix = "rapid-mk1-"
  templates["rapid-mk1-"] = {
    next_prefix = "rapid-mk2-",
    prerequisite_techs = {"logistics-4", "express-miniloader"},
    tint = {r=0.07, g=0.97, b=0.04},
    base_underground_name = "rapid-transport-belt-to-ground-mk1",
  }
  templates["rapid-mk2-"] = {
    prerequisite_techs = {"logistics-5", "rapid-mk1-miniloader"},
    tint = {r=0.62, g=0.03, b=0.97},
    base_underground_name = "rapid-transport-belt-to-ground-mk2",
  }
end

if data.raw.item["k-transport-belt"] then
  templates["express-"].next_prefix = "k-"
  templates["k-"] = {
    prerequisite_techs = {"k-advanced-logistics", "express-miniloader"},
    tint = {r=0.60, g=0.00, b=0.70},
    base_underground_name = "k-underground-belt",
  }
end

-- UltimateBelts support
if data.raw.technology["ultimate-logistics"] then
  templates["ub-ultra-fast-"] = {
    next_prefix = "ub-extreme-fast-",
    prerequisite_techs = {"ultra-fast-logistics",      "express-miniloader"},
    tint = {r=0.15, g=0.59, b=0.07},
    base_underground_name = "ultra-fast-underground-belt",
  }
  templates["ub-extreme-fast-"] = {
    next_prefix = "ub-ultra-express-",
    prerequisite_techs = {"extreme-fast-logistics",    "ub-ultra-fast-miniloader"},
    tint = {r=0.7,  g=0,    b=0.06},
    base_underground_name = "extreme-fast-underground-belt",
  }
  templates["ub-ultra-express-"] = {
    next_prefix = "ub-extreme-express-",
    prerequisite_techs = {"ultra-express-logistics",   "ub-extreme-fast-miniloader"},
    tint = {r=0.29, g=0,    b=0.7},
    base_underground_name = "ultra-express-underground-belt",
  }
  templates["ub-extreme-express-"] = {
    next_prefix = "ub-ultimate-",
    prerequisite_techs = {"extreme-express-logistics", "ub-ultra-express-miniloader"},
    tint = {r=0,    g=0.06, b=0.7},
    base_underground_name = "extreme-express-underground-belt",
  }
  templates["ub-ultimate-"] = {
    prerequisite_techs = {"ultimate-logistics",        "ub-extreme-express-miniloader"},
    tint = {r=0.08, g=0.72, b=0.61},
    base_underground_name = "original-ultimate-underground-belt",
  }
end

-- xander-mod support
if data.raw.item["expedited-transport-belt"] then
  templates["fast-"].next_prefix = "expedited-"
  templates["expedited-"] = {
    next_prefix = "express-",
    prerequisite_techs = {"logistics-3", "fast-miniloader"},
    tint = {r=0.40, g=0.70, b=0.40},
  }
  templates["express-"].prerequisite_techs = {"logistics-4", "expedited-miniloader"}
end

-- space-exploration support
if data.raw.item["se-space-transport-belt"] then
  templates["space-"] = {
    prerequisite_techs = {"se-space-platform-scaffold"},
    base_underground_name = "se-space-underground-belt",
  }
end

return templates
