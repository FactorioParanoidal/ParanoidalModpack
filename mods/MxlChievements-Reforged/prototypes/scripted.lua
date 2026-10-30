-- Achievements unlocked by control.lua (kind "script"). Read by the data stage and by control.lua,
-- so this file holds plain data only.
--   theme     content theme the achievement is shown with
--   tracker   handler in scripts/trackers.lua; amounts are its thresholds
--   params    tracker settings
--   mods      the achievement exists only when these mods are active
--   needs     prototypes that must exist: entities, items, technologies, any_entity, any_item
--   fight     not available on peaceful maps
-- Thresholds that a tracker cannot know from the save (deaths before the mod, for example)
-- start counting when the mod is added.

local PLANES = {"gunship", "jet", "cargo-plane", "flying-fortress"}
local TANKS = {"tank", "bob-tank-2", "bob-tank-3", "Schall-tank-L", "Schall-tank-L-mk1", "Schall-tank-L-mk2",
  "Schall-tank-M", "Schall-tank-M-mk1", "Schall-tank-M-mk2", "Schall-tank-H", "Schall-tank-H-mk1",
  "Schall-tank-H-mk2", "Schall-tank-SH", "Schall-tank-SH-mk1", "Schall-tank-SH-mk2", "Schall-tank-F",
  "Schall-tank-F-mk1", "Schall-tank-F-mk2"}

local function count(id, theme, amounts, spec, icon, mods)
  local entry = {id = id, kind = "script", theme = theme, tracker = "count", params = spec,
    needs = {any_entity = spec}, icon = icon, mods = mods}
  if #amounts > 1 then entry.amounts = amounts else entry.amount = amounts[1] end
  return entry
end

local function cargo(id, items, icon)
  return {id = id, kind = "script", theme = "space", tracker = "cargo", params = {items = items},
    needs = {any_item = items, entities = {"rocket-silo"}}, icon = icon}
end

local list = {
  -- resources
  {id = "robinson", kind = "script", theme = "resources", tracker = "wreck",
    needs = {any_entity = {patterns = {"^crash%-site%-spaceship", "ship%-wreck"}}}, icon = {entity = "crash-site-spaceship"}},
  {id = "handcraft", kind = "script", theme = "resources", tracker = "handcraft", amounts = {1e4, 1e5},
    icon = {item = "iron-gear-wheel"}},
  {id = "jack-of-all-trades", kind = "script", theme = "resources", tracker = "handcraft-variety", amount = 200,
    icon = {item = "repair-pack"}},
  {id = "chemist", kind = "script", theme = "resources", tracker = "gases", mods = {"angelspetrochem"},
    icon = {fluid = "angels-gas-hydrogen"}},
  {id = "prospector", kind = "script", theme = "resources", tracker = "rso", params = {stat = "veins"},
    amounts = {1, 10}, mods = {"RSO-reforged"}, icon = {entity = "coal"}},

  -- quality
  {id = "restorer", kind = "script", theme = "quality", tracker = "workshop", amounts = {1e4, 1e6},
    mods = {"ic-more-qualities"}, needs = {entities = {"ic-refine-workshop"}}, icon = {entity = "ic-refine-workshop"}},

  -- energy
  count("don-quixote", "energy", {10, 100, 1000},
    {names = {"texugo-wind-turbine", "texugo-wind-turbine2", "texugo-wind-turbine3"}}, {entity = "texugo-wind-turbine2"}),
  {id = "dead-calm", kind = "script", theme = "energy", tracker = "wind-calm", amount = 50,
    params = {names = {"texugo-wind-turbine", "texugo-wind-turbine2", "texugo-wind-turbine3"}},
    mods = {"Wind-Turbines-Reforged"}, needs = {entities = {"texugo-wind-turbine"}}, icon = {entity = "texugo-wind-turbine"}},
  {id = "hurricane", kind = "script", theme = "energy", tracker = "wind-storm", amount = 300,
    params = {names = {"texugo-wind-turbine", "texugo-wind-turbine2", "texugo-wind-turbine3"}},
    mods = {"Wind-Turbines-Reforged"}, needs = {entities = {"texugo-wind-turbine"}}, icon = {entity = "texugo-wind-turbine3"}},
  count("resistance", "energy", {1e4}, {patterns = {"."}, types = {"electric-pole"}}, {entity = "medium-electric-pole"},
    {"ElectricResistance2"}),
  count("christmas-tree", "energy", {1000}, {patterns = {"^lighted%-"}, types = {"electric-pole"}},
    {entity = "lighted-medium-electric-pole"}),

  -- logistics
  {id = "push-pull", kind = "script", theme = "logistics", tracker = "mu-train", mods = {"MultipleUnitTrainControl-reforged"},
    icon = {entity = "locomotive"}},
  {id = "overload", kind = "script", theme = "logistics", tracker = "overload", amount = 20, icon = {entity = "cargo-wagon"}},
  {id = "tardis", kind = "script", theme = "logistics", tracker = "factory-floor", mods = {"factorissimo-2-notnotmelon"},
    icon = {entity = "factory-1"}},
  {id = "factory-in-factory", kind = "script", theme = "logistics", tracker = "factory-nest",
    mods = {"factorissimo-2-notnotmelon"}, needs = {any_entity = {patterns = {"^factory%-%d$"}}}, icon = {entity = "factory-2"}},
  -- Streaks measured by Factorissimo (remote get_force_records), in hours of work.
  {id = "no-emissions", kind = "script", theme = "logistics", tracker = "factory-clean", amount = 10,
    mods = {"factorissimo-2-notnotmelon"}, needs = {entities = {"factory-1"}}, icon = {entity = "factory-2"}},
  {id = "factory-24-7", kind = "script", theme = "logistics", tracker = "factory-uptime", amount = 10,
    mods = {"factorissimo-2-notnotmelon"}, needs = {entities = {"factory-1"}}, icon = {entity = "factory-3"}},
  {id = "jumper", kind = "script", theme = "logistics", tracker = "teleport", amounts = {100, 1000},
    mods = {"Teleporters"}, needs = {entities = {"teleporter"}}, icon = {entity = "teleporter"}},
  count("hoarder", "logistics", {100}, {patterns = {"^warehouse%-", "^storehouse%-"}, types = {"container", "logistic-container"}},
    {entity = "warehouse-basic"}),
  count("crane-operator", "logistics", {100}, {patterns = {"^nco%-.*crane$"}, types = {"inserter"}}, {entity = "nco-crane"}),
  count("modesty", "logistics", {100}, {patterns = {"^mini%-"}, types = {"container", "logistic-container"}},
    {entity = "mini-steel-chest"}, {"osha_mini_containers"}),
  count("vacuum", "logistics", {10}, {patterns = {"^pickup%-tower%-%d+$"}}, {entity = "pickup-tower-1"}),
  count("centipede", "logistics", {1}, {patterns = {"^WideChests_"}, min_area = 20}, {entity = "steel-chest"}),
  {id = "plane-crash", kind = "script", theme = "logistics", tracker = "robot-crash", amount = 100,
    mods = {"robot_attrition"}, icon = {entity = "logistic-robot"}},

  -- combat
  {id = "bounty-hunter", kind = "script", theme = "combat", tracker = "bosses", fight = true, mods = {"Big-Monsters"},
    needs = {entities = {"bm-volcano"}}, icon = {entity = "biterzilla35"}},
  {id = "evolution", kind = "script", theme = "combat", tracker = "evolution", amounts = {50, 90, 99}, fight = true,
    icon = {entity = "behemoth-biter"}},
  {id = "guard-breaker", kind = "script", theme = "combat", tracker = "rso", params = {stat = "guards"},
    amounts = {1, 10}, fight = true, mods = {"RSO-reforged"}, icon = {entity = "biter-spawner"}},

  -- nature
  {id = "first-winter", kind = "script", theme = "nature", tracker = "season", params = {season = "winter"},
    mods = {"NightBrightness"}, icon = {item = "solar-panel"}},
  {id = "all-seasons", kind = "script", theme = "nature", tracker = "season", params = {all = true},
    mods = {"NightBrightness"}, icon = {item = "solar-panel"}},
  {id = "owl", kind = "script", theme = "nature", tracker = "nights", amount = 100, icon = {item = "small-lamp"}},
  -- Years since the landing (NightBrightness calendar): 1, 5, every 10 up to 100, every 100 up to 1000.
  {id = "years", kind = "script", theme = "nature", tracker = "years",
    amounts = {1, 5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000},
    frames = {1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3},
    mods = {"NightBrightness"}, icon = {item = "solar-panel"}},

  -- challenges
  {id = "archaeologist", kind = "script", theme = "challenges", tracker = "ruins", amounts = {10, 50},
    mods = {"AbandonedRuins-paranoidal"}, icon = {item = "stone-brick"}},
  {id = "archaeologist-all", kind = "script", theme = "challenges", tracker = "ruins", params = {all = true},
    mods = {"AbandonedRuins-paranoidal"}, icon = {item = "stone-brick"}, frame = 3},

  -- space
  {id = "houston", kind = "script", theme = "space", tracker = "silo-lost", needs = {entities = {"rocket-silo"}},
    icon = {entity = "rocket-silo"}},
  cargo("liftoff", {"car"}, {item = "car"}),
  cargo("orbital-tank", TANKS, {item = "tank"}),
  cargo("porthole", {"observation-satellite"}, {item = "observation-satellite"}),
  cargo("space-miner", {"autonomous-space-mining-drone"}, {item = "autonomous-space-mining-drone"}),
  cargo("eye-in-the-sky", {"space-telescope"}, {item = "space-telescope"}),
  cargo("rocket-in-rocket", {"rocket-silo"}, {item = "rocket-silo"}),
  {id = "spaceport", kind = "script", theme = "space", tracker = "launches", amounts = {10, 100, 1000},
    needs = {entities = {"rocket-silo"}}, icon = {entity = "rocket-silo"}},
  {id = "rocket-conveyor", kind = "script", theme = "space", tracker = "launch-rate", amount = 10,
    needs = {entities = {"rocket-silo"}}, icon = {item = "rocket-part"}},
  {id = "immortal", kind = "script", theme = "space", tracker = "immortal", needs = {entities = {"rocket-silo"}},
    icon = {item = "heavy-armor"}},

  -- character
  {id = "phoenix", kind = "script", theme = "character", tracker = "deaths", amounts = {10, 100},
    icon = {entity = "character-corpse"}},
  {id = "deja-vu", kind = "script", theme = "character", tracker = "deja-vu", icon = {entity = "character-corpse"}},
  {id = "own-goal", kind = "script", theme = "character", tracker = "own-goal", icon = {item = "grenade"}},
  {id = "road-accident", kind = "script", theme = "character", tracker = "car-death", icon = {entity = "car"}},
  {id = "marathon", kind = "script", theme = "character", tracker = "walk", amounts = {1e5, 1e6},
    icon = {item = "exoskeleton-equipment"}},
  {id = "pilot", kind = "script", theme = "character", tracker = "fly", amounts = {1e5, 1e6},
    params = {names = PLANES}, mods = {"Aircraft-space-age"}, needs = {any_entity = {names = PLANES}},
    icon = {entity = "gunship"}},
  {id = "schumacher", kind = "script", theme = "character", tracker = "speed", amount = 200, icon = {entity = "car"}},
  {id = "infinity", kind = "script", theme = "character", tracker = "infinite-research", amount = 100,
    icon = {item = "automation-science-pack"}},
  {id = "rpg-level", kind = "script", theme = "character", tracker = "rpg-level", amounts = {10, 50, 100, 200},
    mods = {"paranoidal-CodexRPG"}, icon = {item = "modular-armor"}},
  {id = "specialist", kind = "script", theme = "character", tracker = "rpg-attribute", amount = 50,
    mods = {"paranoidal-CodexRPG"}, icon = {item = "power-armor"}},
  {id = "godfather", kind = "script", theme = "character", tracker = "rename", amount = 100, icon = {item = "train-stop"}},
  {id = "malevich", kind = "script", theme = "character", tracker = "paint", amount = 50, icon = {entity = "locomotive"}},
  {id = "reverse-gear", kind = "script", theme = "character", tracker = "belt-reverse", amount = 100,
    mods = {"belt-reverser-space-age"}, icon = {item = "transport-belt"}},
  {id = "world-eraser", kind = "script", theme = "character", tracker = "chunks", amount = 100,
    mods = {"Delete-Chunk-Tool"}, icon = {item = "landfill"}},
  {id = "oops", kind = "script", theme = "character", tracker = "auto-deconstruct", amount = 100,
    mods = {"AutoDeconstruct"}, icon = {item = "deconstruction-planner"}},
  {id = "night-shift", kind = "script", theme = "character", tracker = "night-build", amount = 1000,
    icon = {item = "small-lamp"}},
  {id = "stuck", kind = "script", theme = "character", tracker = "unstuck", mods = {"TimedSpawnControl"},
    icon = {item = "stone-wall"}},
}

-- legendary ruins of AbandonedRuins-paranoidal (tracker "legendary", prototypes/legendary-ruins.lua)
for _, entry in ipairs(require("prototypes.legendary-ruins")) do table.insert(list, entry) end

return list
