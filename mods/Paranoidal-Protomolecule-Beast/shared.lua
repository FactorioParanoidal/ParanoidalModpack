-- What the Beast can turn into, used by both the data and control stages. Every inserter is one leg: its base is the
-- foot, its arm the leg and its hand holds the body. Alone, its hand is all the body it has.
local shared = {}

-- The colour of the infection on the ground, and of the blob it arrives in.
shared.creep_tint = {r = 0.6, g = 0.06, b = 0.2, a = 0.9}

-- The plain one first, as it's who gets to be drawn if it's a tie.
shared.inserters = {"inserter", "burner-inserter", "long-handed-inserter", "fast-inserter", "bulk-inserter"}

-- The one of these that an inserter counts as: itself, or for one from Space Age or a mod, whichever it's most like.
function shared.inserter_for(name)
  for _, inserter in pairs(shared.inserters) do
    if name == inserter then return inserter end
  end
  if name:find("long") then return "long-handed-inserter" end
  if name:find("bulk") or name:find("stack") then return "bulk-inserter" end
  if name:find("fast") then return "fast-inserter" end
  if name:find("burner") then return "burner-inserter" end
  return "inserter"
end

-- Corrupted ones that an infected roboport launches. They fly, so they're plain units going straight over everything.
shared.robots = {"construction-robot", "logistic-robot"}

function shared.robot_name(robot)
  return "beast-" .. robot
end

function shared.lone_name(inserter)
  return "beast-" .. inserter
end

-- Two inserters clamped hand to hand, walking on their bases.
function shared.pair_name(inserter)
  return "beast-pair-" .. inserter
end

-- There's one of each for every type of inserter that can carry it, which is left off the name for the usual one.
function shared.compound_name(group, source, inserter)
  local name = "beast-" .. group.name .. "-" .. source
  if inserter and inserter ~= (group.leg_inserter or "inserter") then name = name .. "-" .. inserter end
  return name
end

function shared.leg_inserters(group)
  return group.strict and {group.leg_inserter} or shared.inserters
end

-- legs: how many inserters it takes. leg_inserter: the only type that counts, if strict.
-- along_sides: they hold it down both long sides, rather than by the corners. stride: tiles per step, if not the leg's own.
-- swivels: the hands hold its base, which has just the one direction and so keeps them where they are, while its head turns.
-- turns: its legs swing round to where it's going, as its body's small and square enough not to show that it hasn't turned.
-- height, stance, knee_height: how tall it stands and how far its feet spread, if not the usual. attack "drill": it has
-- to get right on top of things, and grinds whatever's under it.
shared.compounds =
{
  {name = "strider", sources = {"burner-mining-drill", "electric-mining-drill", "big-mining-drill"}, legs = 6, along_sides = true, health = 700, attack = "drill"},
  {name = "harvester", sources = {"assembling-machine-1", "assembling-machine-2", "assembling-machine-3"}, legs = 4, health = 800, attack = "rock"},
  {name = "spewer", sources = {"stone-furnace", "steel-furnace", "electric-furnace"}, legs = 4, health = 900, attack = "fire"},
  {name = "tripod", sources = {"wooden-chest", "iron-chest", "steel-chest"}, legs = 3, turns = true, height = 3.4, stance = 2.6, knee_height = 3.6, stride = 3.5, health = 600, attack = "rock"},
  {name = "watcher", sources = {"radar"}, legs = 4, health = 600, attack = "strike"},
  {name = "glimmer", sources = {"small-lamp"}, legs = 2, health = 300, attack = "strike"},
  {name = "sentry", sources = {"gun-turret"}, legs = 4, health = 700, attack = "gun", swivels = true},
  {name = "corruptor", sources = {"laser-turret"}, legs = 4, health = 700, attack = "corruption", swivels = true},
  {name = "pylon", sources = {"small-electric-pole", "medium-electric-pole"}, legs = 2, leg_inserter = "long-handed-inserter", strict = true, health = 400, attack = "electric"},
  {name = "doom-locomotive", sources = {"locomotive"}, legs = 6, along_sides = true, stride = 3.5, health = 2000, attack = "fire", train = true},
  {name = "doom-wagon", sources = {"cargo-wagon", "fluid-wagon", "artillery-wagon"}, legs = 6, along_sides = true, stride = 3.5, health = 1200, attack = "fire", train = true},
  {name = "big-pylon", sources = {"big-electric-pole", "substation"}, legs = 4, leg_inserter = "long-handed-inserter", strict = true, health = 900, attack = "electric"},
  -- Power, which an outbreak carries home before anything else (energy). Working names (the user's decision Q5: creature
  -- names later). "vane" has no base game building: wind turbines and other mods' electric energy interfaces.
  {name = "dynamo", sources = {"steam-engine", "steam-turbine"}, legs = 6, along_sides = true, health = 900, attack = "electric", energy = true},
  {name = "stoker", sources = {"boiler", "heat-exchanger"}, legs = 4, health = 800, attack = "fire", energy = true},
  {name = "heart", sources = {"nuclear-reactor"}, legs = 6, health = 3000, attack = "corruption", energy = true},
  {name = "cell", sources = {"accumulator"}, legs = 2, health = 400, attack = "electric", energy = true},
  {name = "mirror", sources = {"solar-panel"}, legs = 4, health = 500, attack = "corruption", energy = true},
  {name = "vane", sources = {}, legs = 4, health = 600, attack = "electric", energy = true},
  -- What it carries home to attack with (assault). Working names too. vehicle: its body keeps every direction of the
  -- car's own sprite and turns to where it's going, like a train's.
  {name = "howitzer", sources = {"artillery-turret"}, legs = 4, health = 1500, attack = "rock"},
  {name = "crawler", sources = {"car", "tank"}, legs = 4, along_sides = true, health = 1000, attack = "gun", vehicle = true},
}

-- How fast each walker goes in tiles per second, as an engine leg speed only sets how quick its steps are.
shared.lone_pace = 3.5
shared.pair_pace = 4.5
shared.paces = {strider = 2.5, harvester = 2.5, watcher = 2.5, glimmer = 3.5, spewer = 1.5, sentry = 3, corruptor = 3, tripod = 3.5, pylon = 3, ["big-pylon"] = 2, ["doom-locomotive"] = 2.5, ["doom-wagon"] = 2.5, dynamo = 2, stoker = 1.5, heart = 1.2, cell = 3, mirror = 2.5, vane = 2.5, howitzer = 1.5, crawler = 3}

function shared.group_by_name(name)
  for _, group in pairs(shared.compounds) do
    if group.name == name then return group end
  end
end

-- Any other building of these types becomes the same kind of creature as the base game's, if it's no bigger than
-- max_lifted_size tiles across (rolling stock always is). Poles go by size: one tile is a pylon, more a big pylon.
shared.group_for_type =
{
  ["mining-drill"] = "strider",
  ["assembling-machine"] = "harvester",
  ["furnace"] = "spewer",
  ["container"] = "tripod",
  ["logistic-container"] = "tripod",
  ["radar"] = "watcher",
  ["lamp"] = "glimmer",
  ["ammo-turret"] = "sentry",
  ["electric-turret"] = "corruptor",
  ["electric-pole"] = "pylon",
  ["locomotive"] = "doom-locomotive",
  ["cargo-wagon"] = "doom-wagon",
  ["fluid-wagon"] = "doom-wagon",
  ["generator"] = "dynamo",
  ["boiler"] = "stoker",
  ["burner-generator"] = "stoker",
  ["reactor"] = "heart",
  ["accumulator"] = "cell",
  ["solar-panel"] = "mirror",
  ["electric-energy-interface"] = "vane",
  ["artillery-turret"] = "howitzer",
  ["artillery-wagon"] = "doom-wagon",
  ["car"] = "crawler"
}

-- What it wants most after power: artillery, vehicles and trains, to attack with. A spidertron isn't lifted, as it walks
-- already: it is driven (lair_arms.lua).
shared.assault_types = {"artillery-turret", "artillery-wagon", "car", "spider-vehicle", "locomotive"}
shared.is_assault_type = {}
for _, type in pairs(shared.assault_types) do shared.is_assault_type[type] = true end

-- What makes or stores power. The outbreak goes for these first and carries them home whole: they are its power.
shared.energy_types = {"generator", "boiler", "burner-generator", "reactor", "accumulator", "solar-panel", "electric-energy-interface"}
shared.is_energy_type = {}
for _, type in pairs(shared.energy_types) do shared.is_energy_type[type] = true end

-- The forces that buildings of paranoidal-ruins belong to: "neutral" for what nobody has claimed with the claim tool yet,
-- and its hostile defences. Legendary ruins are told apart by their own force nearby (see outbreak.lua).
shared.ruin_forces = {"neutral", "AbandonedRuins:enemy"}
shared.legendary_force = "pd-legend"

-- The Paranoidal defects of ic-more-qualities, worst first: ic-defect-5 is -5.
shared.defects = {"ic-defect-5", "ic-defect-4", "ic-defect-3", "ic-defect-2", "ic-defect-1"}

-- A random defect for a building, if its item can be brought back to normal in the refining workshop of the quality mod
-- by its own rule (it has a refining recipe: mod-data "ic-quality-expansion" costs), so the quality mod needs no change
-- (the user's decision of 2026-11-03). That's every finished product but those the workshop never takes: materials
-- (pipes, rails), and items that carry contents or a grid (vehicles, rolling stock). Nil for those, and without the mod.
function shared.random_defect(entity_name)
  local proto = prototypes.entity[entity_name]
  local items = proto and proto.items_to_place_this
  local item = items and items[1] and items[1].name
  local expansion = prototypes.mod_data["ic-quality-expansion"]
  local costs = expansion and expansion.data and expansion.data.costs
  if not (item and costs and costs[item]) then return nil end
  local name = shared.defects[math.random(#shared.defects)]
  return prototypes.quality[name] and name or nil
end
shared.source_types = {}
for type in pairs(shared.group_for_type) do shared.source_types[#shared.source_types + 1] = type end
table.sort(shared.source_types)
shared.max_lifted_size = 5
-- Bigger than the base game's takes two more legs to lift.
shared.big_size = 4
shared.big_extra_legs = 2

-- Never infected at all: other mods' buildings that their own scripts look after, and which they'd lose track of if one
-- changed hands or was carried off. Factorissimo's factories (what's inside isn't on this surface), legendary ruins'
-- relics, the BnL start's distress beacon, the quality control post, Nanobots' roboport interface, Bio Industries'
-- arboretum area, and Rampant's own buildings (which are the enemy's anyway).
local excluded_patterns = {"^factory%-", "^space%-factory%-", "^pd%-relic%-", "^roboport%-interface%-", "%-rampant$"}
local excluded_names = {["bnl-distress-beacon"] = true, ["ic-control-post"] = true, ["bi-arboretum-area"] = true}

function shared.is_excluded(name)
  if excluded_names[name] then return true end
  for _, pattern in pairs(excluded_patterns) do
    if name:find(pattern) then return true end
  end
  return false
end

-- Ones that look just like another building and are lifted as that one: HeroTurretRedux's ranks (which are lost on the
-- way, for the sake of not making a creature of each) and lit poles.
local alias_patterns = {"^hero%-turret%-%d+%-for%-(.+)$", "^lighted%-(.+)$"}

function shared.alias_of(name)
  for _, pattern in pairs(alias_patterns) do
    local base = name:match(pattern)
    if base then return base end
  end
end

-- What the data stage made, for the control stage: sources[building] = {group, legs, as = the building it's drawn as},
-- creatures[creature, not walled] = {group, source, legs}.
shared.mod_data_name = "the-beast-compounds"
local made
local function made_data()
  if not made then
    local mod_data = prototypes.mod_data[shared.mod_data_name]
    made = mod_data and mod_data.data or {sources = {}, creatures = {}}
  end
  return made
end

-- What this building becomes when it's lifted, or nil if it can't be.
function shared.source_info(name)
  return made_data().sources[name]
end

function shared.creature_info(name)
  if shared.is_walled(name) then name = name:sub(1, -8) end
  return made_data().creatures[name]
end

-- From 0.1 to 8 tiles a second (prototypes/beasts.lua makes one for each tenth).
shared.max_pace_sticker = 80

function shared.pace_sticker(pace)
  return "beast-pace-" .. math.max(1, math.min(shared.max_pace_sticker, math.floor(pace * 10)))
end

-- Standing on pieces of wall, which it picked up as it went: taller, tougher and slower.
function shared.walled_name(name)
  return name .. "-walled"
end

function shared.is_walled(name)
  return name:sub(-7) == "-walled"
end

-- How it fights: "rock" is thrown by script, "drill" grinds what it stands on, and the rest are its prototype's attack.
-- Lone inserters and pairs only have a "strike", for when they get right up against something that fights back.
function shared.attack_of(name)
  if shared.is_walled(name) then name = name:sub(1, -8) end
  for _, robot in pairs(shared.robots) do
    if name == shared.robot_name(robot) then return "robot" end
  end
  local compound = shared.creature_info(name)
  return compound and shared.group_by_name(compound.group).attack or "strike"
end

function shared.walled_pace(pace)
  return math.floor(pace * 7) / 10
end

function shared.pace_of(name)
  if shared.is_walled(name) then return shared.walled_pace(shared.pace_of(name:sub(1, -8))) end
  for _, inserter in pairs(shared.inserters) do
    if name == shared.lone_name(inserter) then return shared.lone_pace end
    if name == shared.pair_name(inserter) then return shared.pair_pace end
  end
  local compound = shared.creature_info(name)
  return compound and shared.paces[compound.group]
end

return shared
