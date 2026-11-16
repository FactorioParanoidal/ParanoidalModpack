-- Her memory and case №A113-6, per team (force): memory cards, their decoding, the case board and what she remembers
-- on the map as rewards; where the cards come from (the Axiom-6, ruins, wrecks, her searches); the colony's last camp.
local shared = require("shared")
local state = require("script.state")
local story = require("script.story")
local speech = require("script.speech")

local memory = {}

local minute = 3600
local wrong_lock = 5 * minute
local search_gap = 15 * minute       -- a team finds at most one card by her searches per this
local search_chance = 0.35
local mined_chance = 0.04            -- a wreck mined by hand
local mined_gap = 10 * minute
local ruin_chance = 0.3
local ruin_cards_max = 40
local axiom6_radius = 72

-- Called when the case or memory of a force changes (the window refreshes); set by script/gui.lua.
memory.on_changed = nil

local changed = function(force)
  if memory.on_changed then
    memory.on_changed(force)
  end
end

memory.force_data = function(force)
  local f = state.s.forces[force.index]
  if not f then
    f = {fragments = {}, count = 0, solved = {}, locked = {}, tales = 0, last_search_card = -search_gap,
         last_mined_card = -mined_gap}
    state.s.forces[force.index] = f
  end
  return f
end

-- Every nanny of the force (for lines meant for the whole team).
local nannies_of = function(force)
  local list = {}
  for player_index, data in pairs(state.s.players) do
    local player = game.get_player(player_index)
    if player and player.force == force and data.status == "active" then
      list[#list + 1] = data
    end
  end
  return list
end

-- A line from the player's own nanny, or from any of the team's when he has none up.
local tell = function(player, message, opts)
  local data = state.s.players[player.index]
  if data and data.status == "active" then
    speech.say(data, message, opts)
    return
  end
  local others = nannies_of(player.force)
  if others[1] then
    speech.say(others[1], message, opts)
  else
    player.print({"", "[item=" .. shared.item .. "] ", {"nan-e.name"}, ": ", message}, {color = {1, 0.82, 0.9}})
  end
end
memory.tell = tell

-- The first fragment comes with her: "Where are my children?"
memory.unlock_first = function(force)
  local f = memory.force_data(force)
  local first = story.chapters[1].fragments[1]
  if not f.fragments[first] then
    f.fragments[first] = game.tick
    f.count = f.count + 1
    changed(force)
  end
end

local chapter_open = function(force, chapter)
  if not chapter.tech then return true end
  local tech = force.technologies[chapter.tech]
  return tech and tech.researched or false
end

-- What the next card holds: a fragment id (and its chapter), or blocked by a technology, or a tale.
memory.next = function(force)
  local f = memory.force_data(force)
  for index, chapter in ipairs(story.chapters) do
    for _, id in ipairs(chapter.fragments) do
      if not f.fragments[id] then
        if not chapter_open(force, chapter) then
          return nil, index, chapter.tech
        end
        return id, index
      end
    end
  end
  return nil, nil
end

memory.chapter_done = function(force, index)
  local f = memory.force_data(force)
  for _, id in ipairs(story.chapters[index].fragments) do
    if not f.fragments[id] then return false end
  end
  return true
end

-- The price of decoding the next card: item name, count (the tales cost what the last chapter did).
memory.price = function(force)
  local _, index = memory.next(force)
  return story.cost(story.chapters[index or #story.chapters])
end

-- Items of any quality (defects included) in the engineer's main inventory: the price takes whatever he carries.
local count_any = function(player, name)
  local inventory = player.get_inventory(defines.inventory.character_main)
  return inventory and inventory.get_item_count{name = name} or 0
end
memory.count_any = count_any

local remove_any = function(player, name, count)
  local inventory = player.get_inventory(defines.inventory.character_main)
  if not inventory then return end
  for _, entry in pairs(inventory.get_contents()) do
    if count <= 0 then return end
    if entry.name == name then
      count = count - inventory.remove{name = name, count = math.min(count, entry.count), quality = entry.quality}
    end
  end
end

-- Decoding a card for the player. Returns true, or false with the reason already said.
memory.start_decrypt = function(player)
  local force = player.force
  local f = memory.force_data(force)
  if f.decrypting then
    tell(player, {"nan-e.decrypt-busy"}, {mood = "neutral"})
    return false
  end
  local id, index, blocked = memory.next(force)
  if blocked then
    tell(player, {"nan-e.decrypt-blocked", "[technology=" .. blocked .. "]"}, {mood = "worried"})
    return false
  end
  if count_any(player, shared.card) < 1 then
    tell(player, {"nan-e.decrypt-no-card"}, {mood = "worried"})
    return false
  end
  local item, count = story.cost(story.chapters[index or #story.chapters])
  if item and count_any(player, item) < count then
    tell(player, {"nan-e.decrypt-cost", "[item=" .. item .. "] × " .. count}, {mood = "worried"})
    return false
  end
  remove_any(player, shared.card, 1)
  if item then
    remove_any(player, item, count)
  end
  local ticks = settings.global[shared.settings.decode].value * 60
  f.decrypting = {done = game.tick + ticks, total = ticks, player = player.index, fragment = id}
  local data = state.s.players[player.index]
  if data and data.status == "active" then
    speech.sound(data, shared.sounds.lullaby)
  end
  tell(player, {"nan-e.decrypt-start"}, {mood = "glitch", silent = true})
  changed(force)
  return true
end

-- Every 60 ticks: decoding finished.
memory.poll = function(event)
  for force_index, f in pairs(state.s.forces) do
    local job = f.decrypting
    if job and event.tick >= job.done then
      f.decrypting = nil
      local force = game.forces[force_index]
      local player = game.get_player(job.player)
      if force then
        local id = job.fragment
        if id and not f.fragments[id] then
          f.fragments[id] = event.tick
          f.count = f.count + 1
          f.last_fragment = id
        elseif not id then
          f.tales = f.tales + 1
        end
        if player then
          local data = state.s.players[player.index]
          if data and data.status == "active" then
            speech.sound(data, shared.sounds.decrypted)
          end
          if not id then
            tell(player, {"", {"nan-e.decrypt-tale"}, " ", {"nan-e-tale." .. ((f.tales - 1) % story.tales + 1)}}, {mood = "happy", ticks = 720})
          elseif story.fragment[id].bnl then
            tell(player, {"nan-e.decrypt-fake"}, {mood = "glitch"})
          else
            tell(player, {"nan-e.decrypt-done"}, {mood = "happy"})
          end
          local index = id and story.fragment[id].chapter
          if index and memory.chapter_done(force, index) then
            tell(player, {"nan-e.decrypt-chapter", {"nan-e-memory." .. story.chapters[index].title}}, {mood = "surprised", ticks = 600})
          end
        end
        changed(force)
      end
    end
  end
end

-- ---------------------------------------------------------------- the case board

memory.question_open = function(force, q)
  return memory.chapter_done(force, story.questions[q].chapter)
end

local tag = function(force, surface, position, icon)
  force.chart(surface, {{position.x - 16, position.y - 16}, {position.x + 16, position.y + 16}})
  -- The chunk is charted on the next ticks: the tag is added then (memory.poll_tags).
  local f = memory.force_data(force)
  f.pending_tags = f.pending_tags or {}
  f.pending_tags[#f.pending_tags + 1] = {surface = surface.index, position = position, icon = icon, tries = 0}
end

-- Every 60 ticks: tags waiting for their chunk to be charted.
memory.poll_tags = function()
  for force_index, f in pairs(state.s.forces) do
    local pending = f.pending_tags
    if pending and #pending > 0 then
      local force = game.forces[force_index]
      for i = #pending, 1, -1 do
        local entry = pending[i]
        local surface = game.surfaces[entry.surface]
        entry.tries = entry.tries + 1
        if not (force and surface) or entry.tries > 30 then
          table.remove(pending, i)
        elseif force.is_chunk_charted(surface, {math.floor(entry.position.x / 32), math.floor(entry.position.y / 32)}) then
          force.add_chart_tag(surface, {position = entry.position, icon = entry.icon, text = "NAN-E"})
          table.remove(pending, i)
        end
      end
    end
  end
end

-- Q1: the richest uncharted resource chunk within 600 tiles.
local reward_ore = function(player)
  local char = player.character
  local surface = char and char.surface or player.surface
  local origin = char and char.position or player.position
  local force = player.force
  local best, best_count
  local radius = 600
  for chunk in surface.get_chunks() do
    local cx, cy = chunk.x * 32 + 16, chunk.y * 32 + 16
    if math.abs(cx - origin.x) < radius and math.abs(cy - origin.y) < radius and surface.is_chunk_generated(chunk)
      and not force.is_chunk_charted(surface, chunk) then
      local count = surface.count_entities_filtered{area = chunk.area, type = "resource"}
      if count > 0 and (not best_count or count > best_count) then
        best, best_count = chunk, count
      end
    end
  end
  if not best then return false end
  local resource = surface.find_entities_filtered{area = best.area, type = "resource", limit = 1}[1]
  local icon = {type = "virtual", name = "signal-dot"}
  if resource then
    local products = resource.prototype.mineable_properties.products
    local product = products and products[1]
    if product and product.type == "item" then
      icon = {type = "item", name = product.name}
    elseif product and product.type == "fluid" then
      icon = {type = "fluid", name = product.name}
    end
  end
  tag(force, surface, {x = best.x * 32 + 16, y = best.y * 32 + 16}, icon)
  return true
end

-- Q2: the nearest ruin of paranoidal-ruins not yet tagged.
local reward_ruin = function(player)
  local list = state.s.ruins.list
  local char = player.character
  if not char or #list == 0 then return false end
  local best, best_d
  for _, ruin in pairs(list) do
    if not ruin.tagged and ruin.surface == char.surface_index then
      local dx, dy = ruin.x - char.position.x, ruin.y - char.position.y
      local d = dx * dx + dy * dy
      if not best_d or d < best_d then
        best, best_d = ruin, d
      end
    end
  end
  if not best then return false end
  best.tagged = true
  tag(player.force, char.surface, {x = best.x, y = best.y}, {type = "item", name = shared.item})
  return true
end

-- Q3: Sprocket's toolbox.
local reward_toolbox = function(player)
  local gifts = {{"repair-pack", 25}, {"electronic-circuit", 20}, {"iron-gear-wheel", 40}}
  local char = player.character
  for _, gift in pairs(gifts) do
    if prototypes.item[gift[1]] then
      local inserted = player.insert{name = gift[1], count = gift[2]}
      if inserted < gift[2] and char then
        char.surface.spill_item_stack{position = char.position, stack = {name = gift[1], count = gift[2] - inserted}}
      end
    end
  end
  return true
end

-- The camp: 400-700 tiles from the Axiom-6 (or the team's spawn), in a direction of its own.
local camp_position = function(force, surface)
  local f = memory.force_data(force)
  if f.camp then return f.camp end
  local a6 = state.s.axiom6
  local origin = (a6.position and a6.surface == surface.index) and a6.position or force.get_spawn_position(surface)
  local angle = math.random() * 2 * math.pi
  local d = math.random(400, 700)
  f.camp = {surface = surface.index, x = math.floor(origin.x + math.cos(angle) * d), y = math.floor(origin.y + math.sin(angle) * d),
            origin = {x = origin.x, y = origin.y}}
  return f.camp
end

-- Q4: the direction: a line two thirds of the way on the map.
local reward_direction = function(player)
  local char = player.character
  local surface = char and char.surface or player.surface
  local camp = camp_position(player.force, surface)
  local o = camp.origin
  local to = {x = o.x + (camp.x - o.x) * 0.66, y = o.y + (camp.y - o.y) * 0.66}
  local f = memory.force_data(player.force)
  f.direction = rendering.draw_line{color = {0.95, 0.5, 0.75}, width = 4, from = o, to = to, surface = surface,
    forces = {player.force}, render_mode = "chart", dash_length = 6, gap_length = 4}
  return true
end

local spawn_capsule = function(force, surface, camp)
  if camp.capsule and camp.capsule.valid then return end
  if not prototypes.entity[shared.capsule] then return end
  local spot = surface.find_non_colliding_position(shared.capsule, {camp.x, camp.y}, 32, 1)
  if not spot then return end
  local capsule = surface.create_entity{name = shared.capsule, position = spot, force = "neutral", create_build_effect_smoke = false}
  if not capsule then return end
  capsule.destructible = false
  camp.capsule = capsule
  camp.x, camp.y = spot.x, spot.y
  local inventory = capsule.get_inventory(defines.inventory.chest)
  inventory.insert{name = shared.drawing, count = 1}
  local gifts = {{"modular-armor", 1}, {"exoskeleton-equipment", 1}, {"solar-panel-equipment", 4}, {"repair-pack", 50}}
  for _, gift in pairs(gifts) do
    if prototypes.item[gift[1]] then
      inventory.insert{name = gift[1], count = gift[2], quality = prototypes.quality.uncommon and "uncommon" or "normal"}
    end
  end
  tag(force, surface, spot, {type = "item", name = shared.drawing})
end

-- Q5: the camp itself. Its chunk is generated if it is not yet; the box appears then (memory.on_chunk_generated).
local reward_camp = function(player)
  local char = player.character
  local surface = char and char.surface or player.surface
  local camp = camp_position(player.force, surface)
  camp.revealed = true
  local chunk = {math.floor(camp.x / 32), math.floor(camp.y / 32)}
  if surface.is_chunk_generated(chunk) then
    spawn_capsule(player.force, surface, camp)
  else
    surface.request_to_generate_chunks({camp.x, camp.y}, 1)
  end
  player.force.chart(surface, {{camp.x - 48, camp.y - 48}, {camp.x + 48, camp.y + 48}})
  return true
end

local rewards = {ore = reward_ore, ruin = reward_ruin, toolbox = reward_toolbox, direction = reward_direction, camp = reward_camp}

-- The case board: a version presented. Returns "solved", "wrong", "locked" or "closed".
memory.answer = function(player, q, option)
  local question = story.questions[q]
  if not question then return "closed" end
  local force = player.force
  local f = memory.force_data(force)
  if f.solved[q] then return "solved" end
  if not memory.question_open(force, q) then return "closed" end
  if f.locked[q] and game.tick < f.locked[q] then
    tell(player, {"nan-e.case-locked", math.ceil((f.locked[q] - game.tick) / 60)}, {mood = "stern"})
    return "locked"
  end
  local data = state.s.players[player.index]
  if option ~= question.answer then
    f.locked[q] = game.tick + wrong_lock
    if data and data.status == "active" then
      speech.sound(data, shared.sounds.wrong)
    end
    tell(player, {"nan-e.case-wrong-" .. math.random(3)}, {mood = "worried"})
    changed(force)
    return "wrong"
  end
  f.solved[q] = game.tick
  f.locked[q] = nil
  if data and data.status == "active" then
    speech.sound(data, shared.sounds.solved)
  end
  tell(player, {"nan-e-case." .. q .. "-truth"}, {mood = "surprised", ticks = 1200})
  local ok = rewards[question.reward](player)
  tell(player, ok and {"nan-e-case." .. q .. "-reward"} or {"nan-e-case.reward-none"}, {mood = "happy", ticks = 600, silent = true})
  changed(force)
  return "solved"
end

memory.solved_count = function(force)
  local n = 0
  for _ in pairs(memory.force_data(force).solved) do
    n = n + 1
  end
  return n
end

-- ---------------------------------------------------------------- where the cards come from

-- Her search found a card? Not more often than once per search_gap a team, and only while the story lasts... and
-- then for tales, rarely.
memory.search_card = function(force)
  local f = memory.force_data(force)
  if game.tick - f.last_search_card < search_gap then return false end
  local id = memory.next(force)
  local chance = (id or f.count < story.total) and search_chance or search_chance / 3
  if math.random() >= chance then return false end
  f.last_search_card = game.tick
  return true
end

-- A wreck mined by hand may hold a card.
memory.on_player_mined = function(event)
  local entity = event.entity
  if not (entity and entity.valid and string.find(entity.name, "wreck", 1, true)) then return end
  local player = game.get_player(event.player_index)
  if not player then return end
  local f = memory.force_data(player.force)
  if game.tick - f.last_mined_card < mined_gap or math.random() >= mined_chance then return end
  f.last_mined_card = game.tick
  event.buffer.insert{name = shared.card, count = 1}
  local data = state.s.players[player.index]
  if data and data.status == "active" then
    speech.sound(data, shared.sounds.card)
    speech.say(data, {"nan-e.card-mined"}, {mood = "happy", silent = true})
  end
end

-- paranoidal-ruins spawned a ruin: remember it (rewards) and perhaps hide a card in one of its chests.
memory.on_ruin_spawned = function(event)
  local surface = event.surface
  if not (surface and surface.valid and event.center) then return end
  local ruins = state.s.ruins
  local list = ruins.list
  list[#list + 1] = {surface = surface.index, x = event.center.x, y = event.center.y, name = event.ruin_name}
  if #list > 300 then
    table.remove(list, 1)
  end
  if ruins.seeded >= ruin_cards_max or math.random() >= ruin_chance then return end
  local h = (event.half_size or 8) + 1
  local c = event.center
  local chests = {}
  for _, chest in pairs(surface.find_entities_filtered{area = {{c.x - h, c.y - h}, {c.x + h, c.y + h}}, type = "container", limit = 20}) do
    if chest.force.name ~= "player" then
      chests[#chests + 1] = chest
    end
  end
  if #chests == 0 then return end
  local chest = chests[math.random(#chests)]
  local inventory = chest.get_inventory(defines.inventory.chest)
  if inventory and inventory.insert{name = shared.card, count = 1} > 0 then
    ruins.seeded = ruins.seeded + 1
  end
end

-- Every 300 ticks until done: an engineer within reach of the Axiom-6 of the start (zzzparanoidal-start-bnl) — she
-- lies there switched off, her cards in the liner's hold.
memory.poll_axiom6 = function()
  local a6 = state.s.axiom6
  if a6.state ~= "searching" then return end
  if not prototypes.entity["bnl-old-expedition"] then
    a6.state = "none"
    return
  end
  for _, player in pairs(game.connected_players) do
    local char = player.character
    if char and char.valid then
      local ship = char.surface.find_entities_filtered{name = "bnl-old-expedition", position = char.position,
        radius = axiom6_radius, limit = 1}[1]
      if ship then
        a6.state = "placed"
        a6.surface = ship.surface.index
        a6.position = {x = ship.position.x, y = ship.position.y}
        local husk = memory.spawn_husk(ship.surface, {x = ship.position.x + 6, y = ship.position.y + 3}, player.force, "found", nil, 0.12)
        a6.husk = husk
        local inventory = ship.get_inventory(defines.inventory.chest)
        if inventory then
          inventory.insert{name = shared.card, count = 2}
        end
        return
      end
    end
  end
end

-- The camp's chunk got generated: the box appears.
memory.on_chunk_generated = function(event)
  for force_index, f in pairs(state.s.forces) do
    local camp = f.camp
    if camp and camp.revealed and not (camp.capsule and camp.capsule.valid) and camp.surface == event.surface.index then
      local area = event.area
      if camp.x >= area.left_top.x and camp.x < area.right_bottom.x and camp.y >= area.left_top.y and camp.y < area.right_bottom.y then
        local force = game.forces[force_index]
        if force then
          spawn_capsule(force, event.surface, camp)
        end
      end
    end
  end
end

-- The camp's box opened: the colony's letter.
memory.on_gui_opened = function(event)
  local entity = event.entity
  if not (entity and entity.valid and entity.name == shared.capsule) then return end
  local player = game.get_player(event.player_index)
  if not player then return end
  local f = memory.force_data(player.force)
  if f.epilogue then return end
  f.epilogue = game.tick
  local data = state.s.players[player.index]
  if data and data.status == "active" then
    speech.sound(data, shared.sounds.lullaby)
  end
  tell(player, {"nan-e-case.epilogue"}, {mood = "happy", ticks = 1800, chat = true})
  tell(player, {"nan-e.epilogue-after"}, {mood = "glitch", ticks = 600, silent = true})
  changed(player.force)
end

-- Every 60 ticks: near the camp she notices the box; a minute after a distress beacon, the BnL update knocks.
memory.poll_players = function()
  for _, data in pairs(state.s.players) do
    local player = game.get_player(data.player_index)
    if player and data.status == "active" and data.unit and data.unit.valid then
      if data.sos_line and game.tick >= data.sos_line then
        data.sos_line = nil
        speech.sound(data, shared.sounds.glitch)
        speech.say(data, {"nan-e.sos-blocked"}, {mood = "glitch", ticks = 600, silent = true})
      end
      local f = memory.force_data(player.force)
      local camp = f.camp
      if camp and camp.capsule and camp.capsule.valid and not f.epilogue and not data.camp_seen
        and data.unit.surface == camp.capsule.surface then
        local p = data.unit.position
        if (p.x - camp.x) ^ 2 + (p.y - camp.y) ^ 2 < 400 then
          data.camp_seen = true
          speech.say(data, {"nan-e.camp-found"}, {mood = "worried", ticks = 600})
        end
      end
    end
  end
end

-- start-bnl's distress beacon built: the BnL "update" knocks at her head again.
memory.on_beacon_built = function(event)
  local player = event.player_index and game.get_player(event.player_index)
  if not player then return end
  local data = state.s.players[player.index]
  if data and data.status == "active" then
    data.sos_line = game.tick + minute
  end
end

memory.spawn_husk = nil   -- set by control.lua (nanny.spawn_husk; memory loads before nanny)

return memory
