-- The citadel force and its diplomacy: a truce with the biters (the "enemy" force and every other AI
-- controlled force), war with every player force. The player force list is cached (rebuilt when
-- forces or players change, and at most once per tick: game state only, so every peer gets the same).
local S = require("lib.shared")

local F = {}

local cache = nil  -- {players = array of LuaForce, names = array of names, truce = array of names}

function F.is_truce(force)
  return force.name ~= S.force and (force.name == "enemy" or force.ai_controllable)
end

function F.is_player(force)
  if force.name == S.force or force.name == "neutral" or F.is_truce(force) then return false end
  return force.name == "player" or #force.players > 0
end

function F.invalidate()
  cache = nil
end

local function build()
  cache = {tick = game.tick, players = {}, names = {}, truce = {}}
  for _, force in pairs(game.forces) do
    if F.is_player(force) then
      cache.players[#cache.players + 1] = force
      cache.names[#cache.names + 1] = force.name
    elseif F.is_truce(force) then
      cache.truce[#cache.truce + 1] = force.name
    end
  end
  if #cache.names == 0 then
    cache.players = {game.forces.player}
    cache.names = {"player"}
  end
end

--- Player forces (LuaForce array) the citadel fights.
function F.players()
  if not cache or cache.tick ~= game.tick then build() end
  return cache.players
end

--- Names of the player forces (for entity search filters).
function F.player_names()
  if not cache or cache.tick ~= game.tick then build() end
  return cache.names
end

--- Names of the forces in truce with the citadel (the biters).
function F.truce_names()
  if not cache or cache.tick ~= game.tick then build() end
  return cache.truce
end

function F.get()
  return game.forces[S.force]
end

--- Creates the citadel force and sets the diplomacy with every force.
function F.ensure()
  local force = game.forces[S.force] or game.create_force(S.force)
  -- needed to create unit groups by script; without unit spawners the force neither expands nor
  -- sends pollution attacks on its own
  force.ai_controllable = true
  force.share_chart = false
  for _, other in pairs(game.forces) do
    if other ~= force and other.name ~= "neutral" then
      local truce = F.is_truce(other)
      if force.get_friend(other) then force.set_friend(other, false) end
      if force.get_cease_fire(other) ~= truce then force.set_cease_fire(other, truce) end
      if other.get_cease_fire(force) ~= truce then other.set_cease_fire(force, truce) end
    end
  end
  F.invalidate()
  return force
end

--- Message to every player force (if messages are on).
function F.print(cfg, message, color)
  if not cfg.messages then return end
  for _, force in pairs(F.players()) do
    if force.valid then force.print(message, {color = color or {r = 1, g = 0.45, b = 0.35}}) end
  end
end

return F
