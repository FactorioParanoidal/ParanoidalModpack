-- Facts about the legendary ruins for other mods (MxlChievements-Reforged builds its achievements on
-- them). One custom event, id from remote get_on_legendary_event; raised only when something happens.
-- Data: fact, force_index, player_index (when a player did it), kind (ruin), tier ("trial"/"citadel"),
-- feat (special feat of a ruin), member (relic name), amount (how many), ferocity (map setting).
-- Facts:
--   found, solved (+ tier, ferocity), ruined, feat, summoned (/legendary-spawn), crypt-wrong, rewind,
--   relic-built, relic-died, anchor, bell, themis (+ amount), gate, refused-build, updraft, floor.
-- Sites laid out by /legendary-spawn or the remote interface (site.forced) report nothing but "summoned".
local C = require("legendary.config")
local K = require("legendary.kit")

local F = {}

F.event = script.generate_event_name()

local TIER = {}
for _, kind in ipairs(require("legendary.kinds").list) do TIER[kind.name] = kind.tier end

local SANDBOX = "^bpsb%-sb%-"
local function playable(force)
  return force ~= nil and force.valid and force.name ~= "enemy" and force.name ~= "neutral"
    and force.name ~= C.FORCE and force.name ~= C.RUINS_FORCE and not force.name:find(SANDBOX)
end

local function raise(data)
  script.raise_event(F.event, data)
end

---A fact of a player (the player's force is reported too).
function F.player(player, fact, data)
  if not (player and player.valid and playable(player.force)) then return end
  data = data or {}
  data.fact, data.player_index, data.force_index = fact, player.index, player.force.index
  raise(data)
end

---A fact of a force.
function F.force(force, fact, data)
  if not playable(force) then return end
  data = data or {}
  data.fact, data.force_index = fact, force.index
  raise(data)
end

-- Forces concerned by a site event: the acting player's force, else the forces of players near the
-- site, else the forces that found it.
local function site_forces(site, player)
  local out, seen = {}, {}
  local function add(force)
    if playable(force) and not seen[force.index] then
      seen[force.index] = true
      out[#out + 1] = force
    end
  end
  if player and player.valid then add(player.force) end
  if #out == 0 then
    for _, p in ipairs(K.players(site, C.AWAKE_MARGIN)) do add(p.player.force) end
  end
  if #out == 0 then
    for force_index in pairs(site.found or {}) do add(game.forces[force_index]) end
  end
  return out
end

local function site_fact(site, fact, player, data)
  if site.forced then return end
  for _, force in ipairs(site_forces(site, player)) do
    local copy = { kind = site.kind, tier = TIER[site.kind] }
    for k, v in pairs(data or {}) do copy[k] = v end
    if player and player.valid and player.force == force then copy.player_index = player.index end
    F.force(force, fact, copy)
  end
end

---A special feat of a ruin (kinds call it as K.feat).
function F.feat(site, feat, player) site_fact(site, "feat", player, { feat = feat }) end

---A counted event of a ruin (wrong crypt code, time rollback...).
function F.site(site, fact, player) site_fact(site, fact, player, nil) end

function F.found(site, player)
  if site.forced or not (player and player.valid) then return end
  F.player(player, "found", { kind = site.kind, tier = TIER[site.kind] })
end

function F.solved(site, player)
  site_fact(site, "solved", player, { ferocity = C.setting("pd-legendary-ferocity") or "legendary" })
end

function F.ruined(site) site_fact(site, "ruined", nil, nil) end

return F
