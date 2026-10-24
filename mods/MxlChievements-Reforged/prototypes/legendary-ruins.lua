-- Theme "legendary": achievements of the legendary ruins of AbandonedRuins-paranoidal. Plain data,
-- read by prototypes/scripted.lua (data stage and control.lua). Tracker "legendary" listens to the
-- ruins' custom event (remote get_on_legendary_event) and matches its fields with params:
--   fact      event fact; kind, feat, tier, ferocity  must match when given
--   set       count different members (event member or kind) in this set of the scope
--   sum       add event amount (default 1) to this counter of the scope
--   scope     "player": the acting player (default: the force)
-- Without set/sum the achievement unlocks on the first matching event.

local RUINS = {
  -- kind, relic
  {"labyrinth", "pd-relic-daedalus-workshop"}, {"minesweeper", "pd-relic-minelayer"},
  {"pyramid", "pd-relic-sun-obelisk"}, {"searchlight", "pd-relic-all-seeing-eye"},
  {"dune", "pd-relic-deep-drill"}, {"gates", "pd-relic-forerunner-gate"},
  {"crypt", "pd-relic-archive"}, {"mirrors", "pd-relic-prism-turret"},
  {"frozen", "pd-relic-time-anchor"}, {"bazaar", "pd-relic-themis-scales"},
  {"forge", "pd-relic-hephaestus-forge"}, {"colosseum", "pd-relic-champion-banner"},
  {"hive", "pd-relic-xeno-incubator"}, {"director", "pd-relic-director-hive"},
  {"reactor", "pd-relic-heart-of-reactor"}, {"oilfield", "pd-relic-eternal-spring"},
  {"quarantine", "pd-relic-healing-spring"}, {"hammer", "pd-relic-hammer"},
  {"mothership", "pd-relic-rescue-beacon"}, {"observatory", "pd-relic-star-telescope"},
  {"yggdrasil", "pd-relic-yggdrasil-sprout"}, {"cemetery", "pd-relic-funeral-bell"},
}
local TRIALS, CITADELS = 11, 11
local RELIC = {}
for _, r in ipairs(RUINS) do RELIC[r[1]] = r[2] end

-- Special feats of single ruins: feat id, kind (the feat is reported as is).
local FEATS = {
  labyrinth = {"labyrinth-theseus", "labyrinth-pacifist"},
  minesweeper = {"minesweeper-flawless"},
  pyramid = {"pyramid-last-second"},
  searchlight = {"searchlight-ghost"},
  dune = {"dune-dinner"},
  gates = {"gates-pit"},
  bazaar = {"bazaar-taxpayer", "bazaar-robbery"},
  colosseum = {"colosseum-bread", "colosseum-coward"},
  reactor = {"reactor-meltdown", "reactor-photo-finish"},
  oilfield = {"oilfield-dry"},
  yggdrasil = {"yggdrasil-arson"},
  cemetery = {"cemetery-gravedigger"},
}
-- Counted feats: id, kind, fact, amount.
local COUNTED = {
  crypt = {{"crypt-amnesia", "crypt-wrong", 3}},
  frozen = {{"frozen-groundhog", "rewind", 5}},
}

local list = {}
local function add(id, params, frame, relic, amount)
  list[#list + 1] = {
    id = "legend-" .. id, kind = "script", theme = "legendary", tracker = "legendary",
    params = params, amount = amount, frame = frame,
    mods = {"AbandonedRuins-paranoidal"}, needs = {items = {relic}}, icon = {item = relic},
  }
end

-- the collection
add("found-all", {fact = "found", set = "found"}, 3, "pd-relic-star-telescope", #RUINS)
add("solved-5", {fact = "solved", set = "solved"}, 2, "pd-relic-champion-banner", 5)
add("solved-all", {fact = "solved", set = "solved"}, 3, "pd-relic-champion-banner", #RUINS)
add("trials-all", {fact = "solved", tier = "trial", set = "solved-trial"}, 3, RELIC.labyrinth, TRIALS)
add("citadels-all", {fact = "solved", tier = "citadel", set = "solved-citadel"}, 3, RELIC.hammer, CITADELS)
add("no-mercy", {fact = "solved", ferocity = "legendary", set = "no-mercy"}, 3, RELIC.mirrors, 5)
add("ruined-first", {fact = "ruined"}, 1, RELIC.reactor)
add("lazy", {fact = "summoned", scope = "player"}, 1, RELIC.gates)

-- every ruin: found, beaten and its feats
for _, r in ipairs(RUINS) do
  local kind, relic = r[1], r[2]
  add("found-" .. kind, {fact = "found", kind = kind}, 1, relic)
  add("solved-" .. kind, {fact = "solved", kind = kind}, 2, relic)
  for _, feat in ipairs(FEATS[kind] or {}) do add(feat, {fact = "feat", kind = kind, feat = feat}, 3, relic) end
  for _, c in ipairs(COUNTED[kind] or {}) do add(c[1], {fact = c[2], kind = kind, sum = c[2]}, 3, relic, c[3]) end
end

-- relics and the sanctuary
add("relic-first", {fact = "relic-built"}, 1, RELIC.forge)
add("relic-collector", {fact = "relic-built", set = "relics"}, 3, RELIC.crypt, 10)
add("relic-broken", {fact = "relic-died"}, 1, RELIC.mirrors)
add("anchor-saved", {fact = "anchor", scope = "player"}, 2, RELIC.frozen)
add("bell-respawn", {fact = "bell", scope = "player"}, 2, RELIC.cemetery)
add("themis-justice", {fact = "themis", sum = "themis"}, 2, RELIC.bazaar, 1000)
add("gate-walker", {fact = "gate", sum = "gates"}, 2, RELIC.gates, 100)
add("no-build", {fact = "refused-build", sum = "refused-build", scope = "player"}, 1, RELIC.labyrinth, 10)
add("icarus", {fact = "updraft", scope = "player"}, 1, RELIC.observatory)
add("floor-thief", {fact = "floor", scope = "player"}, 1, RELIC.forge)

return list
