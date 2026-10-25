-- Kill counter and ranks of droids (the principle of HeroTurrets: a rank is a prototype of its own,
-- the entity is replaced when it gets promoted).
--
-- storage.kills[unit_number]   enemies killed by the droid (kept through promotion and drop pods)
-- storage.hover[player_index]  text object over the droid the player points at
--
-- Kills: on_entity_died of an entity of an enemy force whose cause is a droid of the army
-- (tracked by the mod). At shared.rank_threshold(kind, rank + 1) kills the droid is replaced by
-- "<droid>-rank-<rank + 1>" in the same place and squad, with the same quality, health share,
-- kills and land mines. Rank droids show the insignia of their rank (HeroTurrets) over them, or a
-- star and the rank number without that mod.
local shared = require("lib.shared")
local state = require("script.state")
local Squad = require("script.squad")
local droids = require("script.droids")

local ranks = {}

local STAR = "[img=virtual-signal/signal-star]"
local MARK_COLOR = {r = 1, g = 0.85, b = 0.2}
local HOVER_COLOR = {r = 0.95, g = 0.95, b = 0.85}

local has_insignia = helpers.is_valid_sprite_path(shared.rank_sprite_prefix .. "1")

--- Insignia over a rank droid, centred (destroyed with the droid).
function ranks.mark(droid)
  local rank = droids.rank[droid.name] or 0
  if rank <= 0 then return end
  local sprite = shared.rank_sprite_prefix .. rank
  if has_insignia and helpers.is_valid_sprite_path(sprite) then
    rendering.draw_sprite({
      sprite = sprite,
      target = {entity = droid, offset = {0, -1.6}},
      surface = droid.surface,
      x_scale = 1,
      y_scale = 1,
    })
  else
    rendering.draw_text({
      text = STAR .. rank,
      target = {entity = droid, offset = {0, -1.6}},
      surface = droid.surface,
      color = MARK_COLOR,
      scale = 0.8,
      alignment = "center",
      vertical_alignment = "middle",
      use_rich_text = true,
    })
  end
end

--- Moves the per-droid data from one entity to another (promotion).
local function transfer(from, to)
  for _, key in pairs({"kills", "mines", "mine_tick"}) do
    local t = storage[key]
    t[to] = t[from]
    t[from] = nil
  end
end

--- Replaces a droid with the prototype of `rank`; returns the new entity (or the old one).
local function promote(old, rank)
  local name = droids.rank_name(droids.kind[old.name], rank)
  if not name then return old end
  local surface, force = old.surface, old.force
  local new = surface.create_entity({
    name = name,
    position = old.position,
    force = force,
    quality = old.quality,
    direction = old.direction,
  })
  if not new then return old end
  new.health = math.max(1, new.max_health * old.health / old.max_health)
  local old_number = old.unit_number
  transfer(old_number, new.unit_number)
  state.track_unit(new)
  local id = storage.unit_squad[old_number]
  local squad = id and storage.squads[id]
  if squad and not squad.deleted then
    Squad.add(squad, new) -- first: removing the last member would delete the squad
    Squad.remove(squad, old_number, true)
  end
  storage.units[old_number] = nil
  old.destroy({raise_destroy = true})
  ranks.mark(new)
  rendering.draw_text({
    text = {"robotarmy-message.promoted", {"robotarmy-rank.rank-" .. rank}},
    target = {entity = new, offset = {0, -2.5}},
    surface = surface,
    forces = {force},
    color = MARK_COLOR,
    scale = 1.1,
    alignment = "center",
    time_to_live = 180,
  })
  script.raise_script_built({entity = new})
  return new
end

--- A droid killed an enemy.
function ranks.on_kill(droid)
  local unit_number = droid.unit_number
  if not storage.units[unit_number] then return end -- not in the army (a Bob's drone placed before its research)
  local kills = (storage.kills[unit_number] or 0) + 1
  storage.kills[unit_number] = kills
  local rank = droids.rank[droid.name] or 0
  local need = shared.rank_threshold(droids.kind[droid.name], rank + 1)
  if need and kills >= need then promote(droid, rank + 1) end
end

------------------------------------------------------------------------------------------
-- Pointing at a droid shows its rank, kills, kills to the next rank and land mines.

function ranks.caption(entity)
  local unit_number = entity.unit_number
  local kills = storage.kills[unit_number] or 0
  local rank = droids.rank[entity.name] or 0
  local need = shared.rank_threshold(droids.kind[entity.name], rank + 1)
  local text = need and {"robotarmy-gui.hover-kills-next", kills, need} or {"robotarmy-gui.hover-kills", kills}
  local mines = storage.mines[unit_number]
  if mines then text = {"", text, "   ", {"robotarmy-gui.hover-mines", mines}} end
  if rank > 0 then text = {"", {"robotarmy-rank.rank-" .. rank}, "   ", text} end
  return text
end

local function clear_hover(player_index)
  local object = storage.hover[player_index]
  if object and object.valid then object.destroy() end
  storage.hover[player_index] = nil
end
ranks.clear_hover = clear_hover

function ranks.on_selected_entity_changed(event)
  clear_hover(event.player_index)
  local player = game.get_player(event.player_index)
  local entity = player and player.selected
  if not (entity and entity.valid and droids.is_droid[entity.name] and storage.units[entity.unit_number]) then return end
  storage.hover[event.player_index] = rendering.draw_text({
    text = ranks.caption(entity),
    target = {entity = entity, offset = {0, -2.2}},
    surface = entity.surface,
    players = {player},
    color = HOVER_COLOR,
    scale = 1,
    alignment = "center",
    use_rich_text = true,
  })
end

--- GUI period: the numbers of the shown texts.
function ranks.refresh_hover()
  for player_index, object in pairs(storage.hover) do
    local target = object.valid and object.target
    local entity = target and target.entity
    if entity and entity.valid then
      object.text = ranks.caption(entity)
    else
      clear_hover(player_index)
    end
  end
end

return ranks
