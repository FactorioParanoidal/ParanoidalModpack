-- Enemies (Rampant, Big Monsters), turrets, vehicles and weapons. Kill entries have no generated
-- description: "mxlr-description.<name_key or id>" gets the amount (__1__) and the target (__2__).
local lib = require("prototypes.content.lib")

local ENEMY_TYPES = {"unit", "unit-spawner", "turret"}
local FACTIONS = {"acid", "arachnids", "electric", "energy", "fast", "fire", "inferno", "juggernaut", "laser",
  "neutral", "nuclear", "physical", "poison", "spawner", "suicide", "troll", "wasp"}
local PLANES = {names = {"gunship", "jet", "cargo-plane", "flying-fortress"}}

local function rampant(faction)
  return {patterns = {"^" .. faction .. "%-.*%-rampant$"}, types = ENEMY_TYPES, exclude = "proxy"}
end

return lib.list(
  lib.each(FACTIONS, function(faction)
    return {id = "entomologist-" .. faction, kind = "kill", to_kill = rampant(faction), amounts = {100, 1000},
      label = "rampant-" .. faction, name_key = "entomologist"}
  end),
  {id = "evolution-peak", kind = "kill", to_kill = {patterns = {"%-t10%-rampant$"}, types = {"unit"}}, label = "rampant-t10"},
  {id = "hive-raider", kind = "kill", to_kill = {patterns = {"%-hive%-v%d+%-t%d+%-rampant$"}, types = ENEMY_TYPES},
    amount = 100, label = "rampant-hive"},
  {id = "fight-fire", kind = "kill", to_kill = {patterns = {"^fire%-.*%-rampant$", "^inferno%-.*%-rampant$"},
    types = ENEMY_TYPES}, damage_type = "fire", amount = 1000, label = "rampant-fire"},
  {id = "short-circuit", kind = "kill", to_kill = {patterns = {"^electric%-.*%-rampant$"}, types = ENEMY_TYPES},
    damage_type = "electric", amount = 1000, label = "rampant-electric"},
  {id = "face-to-face", kind = "kill", to_kill = {patterns = {"^troll%-.*%-t10%-rampant$"}, types = ENEMY_TYPES},
    personally = true, label = "rampant-troll-t10"},
  {id = "godzilla", kind = "kill", to_kill = {"biterzilla15", "biterzilla25", "biterzilla35"}},
  {id = "dragon-mother", kind = "kill", to_kill = "bm-motherbiterzilla5"},
  {id = "volcanologist", kind = "kill", to_kill = "bm-volcano"},
  {id = "overgrown-worm", kind = "kill", to_kill = "bm-worm-boss-acid-shooter"},
  {id = "evil-twin", kind = "kill", to_kill = {patterns = {"^bm_fake_human_boss_"}, types = {"unit"}}, label = "fake-human"},
  {id = "popular-place", kind = "group-attack", amount = 1000, icon = {entity = "big-biter"}},

  {id = "veteran", kind = "kill", type_to_kill = "unit", amounts = {100, 1000, 1e4}, label = "enemies",
    damage_dealer = {patterns = {"^hero%-turret%-11%-for%-"}, types = lib.TURRET_TYPES}},
  {id = "modular-defense", kind = "kill", type_to_kill = "unit", amount = 1e4, label = "enemies",
    damage_dealer = lib.turrets({"w93%-.*turret2?"})},
  {id = "scattershot", kind = "kill", type_to_kill = "unit", amount = 1000, label = "enemies",
    damage_dealer = lib.turrets({"w93%-scattergun%-turret"})},
  {id = "sniper", kind = "kill", type_to_kill = "unit", amount = 1000, label = "enemies",
    damage_dealer = lib.turrets({"bob%-sniper%-turret%-%d"})},
  {id = "plasma-shower", kind = "kill", type_to_kill = "unit", amount = 1e4, label = "enemies",
    damage_dealer = lib.turrets({"bob%-plasma%-turret%-5"})},
  {id = "darts", kind = "kill", type_to_kill = "unit", amount = 1e4, label = "enemies",
    damage_dealer = lib.turrets({"bi%-dart%-turret"})},
  {id = "bio-artillery", kind = "kill", type_to_kill = "unit", amount = 1000, label = "enemies",
    damage_dealer = lib.turrets({"bi%-bio%-cannon"})},
  lib.each({"L", "M", "H", "SH", "F"}, function(class)
    return {id = "tank-platoon-" .. class:lower(), kind = "kill", type_to_kill = "unit", amount = 1000,
      damage_dealer = {patterns = {"^Schall%-tank%-" .. class .. "$", "^Schall%-tank%-" .. class .. "%-mk%d$"}},
      name_key = "tank-platoon"}
  end),
  {id = "ace", kind = "kill", to_kill = {patterns = {"%-flyer%-v%d+%-t%d+%-rampant$"}, types = {"unit"}},
    damage_dealer = PLANES, amount = 100, label = "rampant-flyer", icon = {entity = "jet"}},
  {id = "flying-fortress", kind = "kill", type_to_kill = "unit", damage_dealer = "flying-fortress", amount = 1e4,
    label = "enemies"},
  {id = "steamroller", kind = "kill", type_to_kill = "unit", damage_type = "impact", in_vehicle = true,
    amount = 1000, label = "enemies", icon = {entity = "tank"}},
  {id = "sapper", kind = "kill", type_to_kill = "unit", amount = 1000, label = "enemies",
    damage_dealer = {names = {"land-mine", "bob-poison-mine", "bob-slowdown-mine", "bob-distractor-mine"}}},

  {id = "atomic-artillery", kind = "produce", item = {"atomic-artillery-shell", "bob-atomic-artillery-shell"}, amount = 10},
  {id = "tsar-bomba", kind = "produce", item = "thermonuclear-bomb", amount = 1},
  {id = "mirv", kind = "use-item", item = "mirv-targeting-remote"},
  {id = "nerve-agent", kind = "use-item", item = "clowns-neurotoxin-capsule", amount = 100},
  {id = "poisoner", kind = "shoot", item = "bob-poison-bullet-magazine", amount = 1e4},
  {id = "firestorm", kind = "use-item", item = "bob-fire-capsule", amount = 100},
  {id = "laser-show", kind = "use-item", item = "bob-laser-robot-capsule", amount = 100},
  {id = "terminator", kind = "damaged", amounts = {2000, 5000}, survive = true, icon = {entity = "big-biter"}},
  {id = "splattered", kind = "damaged", amount = 10000, survive = false, icon = {entity = "behemoth-biter"}},
  {id = "train-survivor", kind = "damaged", amount = 50, survive = true, dealer_type = "locomotive",
    icon = {entity = "locomotive"}}
)
