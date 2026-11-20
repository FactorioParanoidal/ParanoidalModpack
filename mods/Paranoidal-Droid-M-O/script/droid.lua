-- Д-ОК and his station: the directive, as a cycle. Find a foreign contaminant -> claim it -> drive there -> scrub it
-- -> weigh the battery -> come home, empty the bin, charge. Built on Klaudia's Sweepbot (MIT).
local shared = require("shared")
local state = require("script.state")
local paving = require("script.paving")
local contaminants = require("script.contaminants")
local reactions = require("script.reactions")
local tracks = require("script.tracks")

local droid = {}
local achievement_facts = require("script.achievement-facts")

local drain_per_tick = 10000 / 60
local update_interval = 30
local respawn_ticks = 60 * 60
local skip_ticks = 60 * 60 * 5
droid.forget_interval = 60 * 60
local stuck_ticks = 60 * 60 * 2
-- Stuck is getting no further than this in stuck_ticks: a long way round is fine as long as it keeps going.
local stuck_distance = 1
local docked_distance = 0.3
-- Failing to find a way home this many times running, he's fetched back onto the dock.
local stranded_fails = 3
-- go_to_location counts the bot as there once its centre is within the radius plus half its collision box's diagonal,
-- so that is taken back off: he stops within arrive_distance of the point.
local arrive_distance = 0.08
local bot_radius = shared.bot_size * 2 ^ 0.5

-- The dock scans outward in a square spiral of cells, a few at a time while it knows of little dirt.
local max_range = 500
local cell_size = 8
local cells_per_update = 8
local dirt_wanted = 32
local rescan_ticks = 60 * 60 * 5
local idle_recheck_ticks = 60
-- Paths wind, so a straight line home is padded, and some battery is kept back for the scrubbing itself.
local path_factor = 1.3
local scrub_reserve = drain_per_tick * 60 * 10
-- Bin chests: any of these touching the dock takes what he brings home; checked every few seconds while docked.
local chest_types = {"container", "logistic-container", "linked-container"}
local unload_interval = 120

-- A dirty engineer: dirt (script/tracks.lua) at which he goes for him, how far from his port, and for how long.
local chase_dirt = 40
local chase_radius = 16
local chase_give_up = 60 * 45
local chase_stroke = 25
-- The film's tread-on-the-face moment: a filthy engineer may smear him once; he screams and scrubs himself.
local smear_dirt = 60
local smear_chance = 0.35
local smear_ticks = 90
-- He says his name to a clean engineer who comes up to his dock, now and then.
local greet_distance = 3.5
local greet_cooldown = 60 * 60 * 10

local states =
{
  charging = "charging",
  sweeping = "sweeping",
  chasing = "chasing",
  returning = "returning"
}

-- Shown on the bot and its dock when hovered over, as neither has a window to show it in: the game's own words where it
-- has them.
local green, yellow, red = defines.entity_status_diode.green, defines.entity_status_diode.yellow, defines.entity_status_diode.red
local statuses =
{
  sweeping = {diode = green, label = {"droid-m-o-status.sweeping"}},
  chasing = {diode = green, label = {"droid-m-o-status.chasing"}},
  returning = {diode = green, label = {"droid-m-o-status.returning"}},
  nothing_to_sweep = {diode = green, label = {"droid-m-o-status.all-clean"}},
  charging = {diode = green, label = {"entity-status.charging"}},
  low_power = {diode = yellow, label = {"entity-status.low-power"}},
  no_power = {diode = red, label = {"entity-status.no-power"}},
  unplugged = {diode = red, label = {"entity-status.not-plugged-in-electric-network"}},
  no_path = {diode = red, label = {"entity-status.no-path"}},
  replacing_bot = {diode = yellow, label = {"droid-m-o-status.replacing-bot"}},
  bin_full = {diode = yellow, label = {"droid-m-o-status.bin-full"}}
}

droid.new_storage = function()
  return
  {
    docks = {},
    bots = {},
    registrations = {},
    claimed = {},
    skipped = {},
    forces = {},
    buckets = {},
    players = {}
  }
end

local port_offsets =
{
  [defines.direction.north] = {0.5, 0},
  [defines.direction.east] = {0, 0.5},
  [defines.direction.south] = {-0.5, 0},
  [defines.direction.west] = {0, -0.5}
}

local get_port = function(dock)
  local offset = port_offsets[dock.direction] or port_offsets[defines.direction.north]
  local position = dock.position
  return {x = position.x + offset[1], y = position.y + offset[2]}
end

local distance = function(a, b)
  local dx, dy = a.x - b.x, a.y - b.y
  return (dx * dx + dy * dy) ^ 0.5
end

local travel_energy = function(tiles)
  return tiles * path_factor / shared.movement_speed * drain_per_tick
end

local researched_levels = function(force, name, levels)
  local count = 0
  for level = 1, levels do
    local technology = force.technologies[name .. "-" .. level]
    if technology and technology.researched then
      count = count + 1
    end
  end
  return count
end

-- What a force's research has made of its bots' batteries and docks.
local update_force = function(force)
  local battery_levels = researched_levels(force, shared.battery_technology, shared.battery_levels)
  local charging_levels = researched_levels(force, shared.charging_technology, shared.charging_levels)
  local upgrades =
  {
    capacity = shared.battery_capacity * (1 + shared.battery_bonus * battery_levels),
    charge_per_tick = shared.charging_power / 60 * (1 + shared.charging_bonus * charging_levels)
  }
  state.s.forces[force.index] = upgrades
  return upgrades
end

local get_upgrades = function(force)
  return state.s.forces[force.index] or update_force(force)
end

-- The station's quality scales his battery: a defective one (ic-more-qualities' ic-defect-5..1, told by name, as
-- their level is 0) by its useful share, a better one by 30 % a level, at most tenfold.
local quality_factor = function(quality)
  local grade = quality.name:match("^ic%-defect%-(%d)$")
  if grade then
    return 1 / 3 + (5 - tonumber(grade)) * 2 / 15
  end
  return math.min(10, 1 + 0.3 * quality.level)
end

local get_capacity = function(data)
  return get_upgrades(data.dock.force).capacity * (data.quality_factor or 1)
end

local reach = function(capacity)
  return math.max(0, math.min(max_range, (capacity - scrub_reserve) / travel_energy(1) / 2))
end

local get_surface_table = function(tables, surface_index)
  local result = tables[surface_index]
  if not result then
    result = {}
    tables[surface_index] = result
  end
  return result
end

-- Not once its dock is gone: the bot goes too, when on_object_destroyed comes round.
local get_data_by_bot = function(unit_number)
  local s = state.s
  local dock_number = unit_number and s.bots[unit_number]
  local data = dock_number and s.docks[dock_number]
  return data and data.dock.valid and data or nil
end

-- Sparks round the contacts while the dock charges him: the roboport's, drawn on the bot so they go with it.
local show_charging = function(data, charging)
  if not charging then
    if data.sparks and data.sparks.valid then
      data.sparks.destroy()
    end
    data.sparks = nil
    return
  end
  if data.sparks and data.sparks.valid then return end
  local port, centre = data.port, data.dock.position
  local length = distance(port, centre)
  data.sparks = rendering.draw_animation
  {
    animation = shared.charging,
    target =
    {
      entity = data.bot,
      offset = {(centre.x - port.x) / length * 0.47, (centre.y - port.y) / length * 0.47 - 0.3}
    },
    surface = data.bot.surface,
    render_layer = "higher-object-under",
    animation_speed = 0.5
  }
end

-- Machine noises at his contacts, for everyone near.
local play_sound = function(data, path)
  data.bot.surface.play_sound{path = path, position = data.bot.position}
end

local set_status = function(data, status)
  if data.status == status then return end
  data.status = status
  data.dock.custom_status = statuses[status]
  if data.bot and data.bot.valid then
    data.bot.custom_status = statuses[status]
  end
end

local set_state = function(data, new_state)
  if new_state ~= states.charging then
    show_charging(data, false)
    -- While charging, it depends on the power: update_dock works it out.
    set_status(data, new_state)
  end
  data.state = new_state
  data.moved_from = nil
end

local release_target = function(data)
  if data.proxy and data.proxy.valid then
    data.proxy.destroy()
  end
  data.proxy = nil
  if data.target then
    get_surface_table(state.s.claimed, data.surface_index)[data.target.key] = nil
  end
  data.target = nil
  data.missed = nil
end

local skip_target = function(data)
  if not data.target or data.target.kind == "player" then return end
  get_surface_table(state.s.skipped, data.surface_index)[data.target.key] = game.tick + skip_ticks
end

local is_skipped = function(skipped, key)
  local until_tick = skipped[key]
  if not until_tick then return false end
  if until_tick <= game.tick then
    skipped[key] = nil
    return false
  end
  return true
end

-- Square spiral: index 1 is the centre, ring k holds indices (2k - 1)^2 + 1 to (2k + 1)^2.
local spiral = function(n)
  local k = math.ceil(((n ^ 0.5) - 1) / 2)
  local t = 2 * k + 1
  local m = t * t
  t = t - 1
  if n >= m - t then return k - (m - n), -k end
  m = m - t
  if n >= m - t then return -k, -k + (m - n) end
  m = m - t
  if n >= m - t then return -k + (m - n), k end
  return k, k - (m - n - t)
end

local scan = function(data, tick)
  if #data.queue >= dirt_wanted or tick < (data.scan_paused_until or 0) then return end
  local dock = data.dock
  local surface = dock.surface
  local origin = dock.position
  local rings = math.ceil(reach(get_capacity(data)) / cell_size)
  local last_index = (2 * rings + 1) ^ 2
  local skipped = get_surface_table(state.s.skipped, surface.index)
  local check_skipped = function(key) return is_skipped(skipped, key) end
  for _ = 1, cells_per_update do
    local index = data.scan_index or 1
    if index > last_index then
      data.scan_index = 1
      data.scan_paused_until = tick + rescan_ticks
      return
    end
    local cx, cy = spiral(index)
    local x1 = math.floor(origin.x) + cx * cell_size - cell_size / 2
    local y1 = math.floor(origin.y) + cy * cell_size - cell_size / 2
    contaminants.scan_cell(data, surface, x1, y1, cell_size, check_skipped, dock.force)
    data.scan_index = index + 1
    if #data.queue >= dirt_wanted then return end
  end
end

local remove_queued = function(data, index)
  local queue = data.queue
  data.queue_keys[queue[index].key] = nil
  queue[index] = queue[#queue]
  queue[#queue] = nil
end

-- Back on the queue for when he's charged, or for the next bot: what he was on his way to (or partway through).
local requeue_target = function(data)
  local target = data.target
  if not target or target.kind == "player" then return end
  if not data.queue_keys[target.key] then
    data.queue_keys[target.key] = true
    data.queue[#data.queue + 1] = target
  end
end

local wants_bin = {item = true, wreck = true}

-- The nearest contaminant he can reach, clean and still get home from. Dropped from the queue on the way: what's gone
-- out of reach or been skipped. With his bin full, what would go in it waits.
local nearest_target = function(data)
  local surface_index = data.surface_index
  local home = data.port
  local from = data.bot.position
  local claimed = get_surface_table(state.s.claimed, surface_index)
  local skipped = get_surface_table(state.s.skipped, surface_index)
  local capacity = get_capacity(data)
  local best, best_distance
  local index = 1
  local queue = data.queue
  while index <= #queue do
    local target = queue[index]
    local anchor = contaminants.anchor(target)
    local home_distance = distance(anchor, home)
    if is_skipped(skipped, target.key) or 2 * travel_energy(home_distance) + scrub_reserve > capacity then
      remove_queued(data, index)
    else
      if not claimed[target.key] and not (data.bin_full and wants_bin[target.kind]) then
        local away = distance(anchor, from)
        local needed = travel_energy(away + home_distance) + scrub_reserve
        if needed <= data.battery and (not best_distance or away < best_distance) then
          best, best_distance = index, away
        end
      end
      index = index + 1
    end
  end
  if not best then return end
  local target = queue[best]
  remove_queued(data, best)
  return target
end

-- The nearest contaminant still there, and where to scrub it from. What he can't pull up to is skipped for a while.
local pick_target = function(data)
  local surface = data.dock.surface
  while true do
    local target = nearest_target(data)
    if not target then return end
    if contaminants.still_there(surface, target) then
      local point = contaminants.approach(surface, target, data.bot.position)
      if point then
        return target, point
      end
      get_surface_table(state.s.skipped, surface.index)[target.key] = game.tick + skip_ticks
    end
  end
end

local go_to = function(destination)
  return
  {
    type = defines.command.go_to_location,
    destination = destination,
    radius = arrive_distance - bot_radius,
    distraction = defines.distraction.none
  }
end

-- Parked, he backs onto the charging block: his bin's contacts meet the block's.
local back_onto_charger = function(data)
  local port, centre = data.port, data.dock.position
  data.bot.orientation = (math.atan2(port.x - centre.x, centre.y - port.y) / (2 * math.pi)) % 1
end

-- His bin into any chest touching the dock. Shows what went where.
local unload = function(data)
  local backpack = data.backpack
  if not (backpack and backpack.valid) or backpack.is_empty() then
    data.bin_full = nil
    return
  end
  local dock = data.dock
  local box = dock.bounding_box
  local area = {{box.left_top.x - 1, box.left_top.y - 1}, {box.right_bottom.x + 1, box.right_bottom.y + 1}}
  local moved
  for _, chest in pairs(dock.surface.find_entities_filtered{area = area, type = chest_types, force = dock.force}) do
    local inventory = chest.get_inventory(defines.inventory.chest)
    if inventory then
      local shown = {}
      for i = 1, #backpack do
        local stack = backpack[i]
        if stack.valid_for_read then
          local name, count = stack.name, stack.count
          local inserted = inventory.insert(stack)
          if inserted > 0 then
            if inserted >= count then
              stack.clear()
            else
              stack.count = count - inserted
            end
            moved = true
            if #shown < 6 then
              shown[#shown + 1] = "[item=" .. name .. "]"
            end
          end
        end
      end
      if shown[1] then
        reactions.label(dock.surface, chest, table.concat(shown), reactions.colours.note, 90, {0, -0.7})
      end
      if backpack.is_empty() then break end
    end
  end
  if moved then
    reactions.say(data, shared.sounds.unload, dock.position)
  end
  data.bin_full = backpack.count_empty_stacks() == 0 or nil
end

local dock_bot = function(data, completed_return)
  achievement_facts.returned(data, completed_return == true)
  -- Rather than idling there and looking for dirt again.
  local arriving = data.state ~= states.charging or distance(data.port, data.bot.position) > 0.01
  release_target(data)
  reactions.siren_down(data)
  set_state(data, states.charging)
  data.fails = nil
  data.hesitated = nil
  data.gotcha = nil
  data.next_think = game.tick + idle_recheck_ticks
  data.bot.commandable.set_command{type = defines.command.stop, distraction = defines.distraction.none}
  -- The last hair onto the port, and squared up to it.
  data.bot.teleport(data.port)
  back_onto_charger(data)
  if arriving then
    play_sound(data, shared.sounds.connect)
    -- Home in his hold: a contented warble.
    reactions.say(data, shared.sounds.warble)
    unload(data)
    data.next_unload = game.tick + unload_interval
  end
end

-- "All clean": said once a sortie has cleaned something and nothing is left that he can reach now.
local all_clean = function(data, over)
  if not data.cleaned or data.cleaned <= 0 then return end
  data.cleaned = 0
  reactions.say(data, shared.sounds.all_clean)
  if over and over.valid then
    reactions.label(over.surface, over, {"droid-m-o-text.all-clean"}, reactions.colours.clean, 120, {0, -2.4})
  else
    reactions.label_bot(data, {"droid-m-o-text.all-clean"}, reactions.colours.clean, 120)
  end
end

local go_home = function(data, finished)
  release_target(data)
  if finished then
    all_clean(data)
    reactions.siren_down(data)
  end
  if distance(data.port, data.bot.position) < docked_distance then
    dock_bot(data, true)
    return
  end
  set_state(data, states.returning)
  data.bot.commandable.set_command(go_to(data.port))
end

local claim = function(data, target)
  get_surface_table(state.s.claimed, data.surface_index)[target.key] = data.bot.unit_number
end

-- The scanner finds something: siren up, the reading over it. Only when he sets out (and for each wreck), so a floor
-- full of grass doesn't make him shout every few seconds.
local announce = function(data, target, departing)
  if not departing and target.kind ~= "wreck" then return end
  local surface = data.dock.surface
  local reading = contaminants.reading(target)
  local anchor = contaminants.anchor(target)
  reactions.label(surface, anchor, {"droid-m-o-text.foreign-contaminant", reading}, reactions.colours.alarm, 120, {0, -0.6})
  if departing then
    reactions.say(data, shared.sounds.scan)
    reactions.siren_up(data, reading >= 60 and 60 * 4 or 60 * 2)
  end
  if target.kind == "wreck" or reading >= 80 then
    reactions.say(data, shared.sounds.gasp)
  end
end

local start_sweeping = function(data, target, point)
  local surface = data.dock.surface
  local proxy = surface.create_entity{name = shared.proxy, position = point.brush, force = "neutral"}
  if not proxy then return false end
  local departing = data.state == states.charging
  if departing then
    achievement_facts.begin(data)
    play_sound(data, shared.sounds.disconnect)
  end
  announce(data, target, departing)
  proxy.disabled_by_script = true
  data.proxy = proxy
  data.target = target
  claim(data, target)
  set_state(data, states.sweeping)
  local commands = {}
  -- Muddy prints off his line: the film's moment where he hesitates, then leaves his line to clean them.
  if target.prints then
    if not data.hesitated then
      data.hesitated = true
      commands[1] = {type = defines.command.stop, ticks_to_wait = 50, distraction = defines.distraction.none}
      reactions.say(data, shared.sounds.hm)
    elseif not data.gotcha then
      -- Fresh tracks once he is on the trail: "Ah-hah! Gotcha!"
      data.gotcha = true
      reactions.say(data, shared.sounds.gotcha)
    end
  end
  commands[#commands + 1] = go_to(point.stand)
  commands[#commands + 1] = {type = defines.command.attack, target = proxy, distraction = defines.distraction.none}
  data.bot.commandable.set_command
  {
    type = defines.command.compound,
    structure_type = defines.compound_command.return_last,
    distraction = defines.distraction.none,
    commands = commands
  }
  return true
end

-- After pick_target finds none: whatever's left on the queue that isn't claimed needs more battery than he has.
local wants_charge = function(data)
  local claimed = get_surface_table(state.s.claimed, data.surface_index)
  for _, target in pairs(data.queue) do
    if not claimed[target.key] and not (data.bin_full and wants_bin[target.kind]) then
      return true
    end
  end
  return false
end

-- Out of known dirt while the scan is still going: wait where he is for the scan to find more nearby.
local wait_for_scan = function(data)
  if data.state ~= states.sweeping then
    set_state(data, states.sweeping)
  end
  data.bot.commandable.set_command{type = defines.command.stop, ticks_to_wait = update_interval, distraction = defines.distraction.none}
end

local think = function(data)
  local bot = data.bot
  if not (bot and bot.valid) then return end
  local target, point = pick_target(data)
  if target and start_sweeping(data, target, point) then
    return
  end
  -- Waiting in the field pays only with an empty bin and battery to spare; otherwise home first.
  local scanning = game.tick >= (data.scan_paused_until or 0)
  if scanning and not wants_charge(data) and data.backpack.is_empty() and data.battery >= get_capacity(data) / 2 and
    distance(data.port, bot.position) >= docked_distance then
    wait_for_scan(data)
    return
  end
  go_home(data, true)
end

-- ------------------------------------------------------------------ the dirty engineer

local chase_enabled = function()
  return settings.global[shared.settings.chase].value
end

local start_chase = function(data, player, character, dirt)
  requeue_target(data)
  release_target(data)
  local surface = data.dock.surface
  local proxy = surface.create_entity{name = shared.proxy, position = character.position, force = "neutral"}
  if not proxy then return end
  proxy.disabled_by_script = true
  if data.state == states.charging then
    play_sound(data, shared.sounds.disconnect)
  end
  data.proxy = proxy
  local position = character.position
  data.target =
  {
    kind = "player",
    key = "player:" .. player.index,
    player_index = player.index,
    x = position.x,
    y = position.y,
    since = game.tick,
    start_dirt = dirt
  }
  claim(data, data.target)
  set_state(data, states.chasing)
  data.bot.commandable.set_command{type = defines.command.attack, target = proxy, distraction = defines.distraction.none}
  -- As at the Axiom's dock: the reading, horror, the siren.
  reactions.say(data, shared.sounds.gasp)
  reactions.say(data, shared.sounds.siren)
  reactions.siren_up(data, 60 * 10)
  reactions.label(surface, character, {"droid-m-o-text.foreign-contaminant", dirt}, reactions.colours.alarm, 150, {0, -2.4})
end

-- The engineer got away (or wore his dirt off on the floor, leaving prints): grumble, and clean what's left.
local give_up_chase = function(data)
  reactions.say(data, shared.sounds.grumble)
  reactions.siren_down(data)
  release_target(data)
  data.scan_index = 1
  data.scan_paused_until = nil
  think(data)
end

local greet = function(data, player, character, tick)
  data.greeted = data.greeted or {}
  local last = data.greeted[player.index]
  if last and tick - last < greet_cooldown then return end
  data.greeted[player.index] = tick
  local from, to = data.bot.position, character.position
  data.bot.orientation = (math.atan2(to.x - from.x, from.y - to.y) / (2 * math.pi)) % 1
  reactions.say(data, shared.sounds.name)
  reactions.label_bot(data, {"droid-m-o-text.name"}, reactions.colours.note, 120)
end

-- Engineers near the station: a dirty one is chased (if the map allows it and he has the battery), a clean one greeted.
local look_around = function(data, tick)
  local current = data.state
  if current == states.returning or current == states.chasing then return end
  local port = data.port
  local claimed
  for _, player in pairs(game.connected_players) do
    if player.surface_index == data.surface_index and not player.vehicle then
      local character = player.character
      if character and character.valid and character.surface_index == data.surface_index then
        local position = character.position
        local away = distance(position, port)
        if away <= chase_radius then
          local dirt = tracks.dirt(player.index)
          if dirt >= chase_dirt then
            claimed = claimed or get_surface_table(state.s.claimed, data.surface_index)
            if chase_enabled() and not claimed["player:" .. player.index] and
              paving.is_paved(character.surface.get_tile(position.x, position.y).name) and
              data.battery >= 2 * travel_energy(away) + scrub_reserve then
              start_chase(data, player, character, dirt)
              return
            end
          elseif current == states.charging and away <= greet_distance and
            distance(port, data.bot.position) < docked_distance then
            greet(data, player, character, tick)
          end
        end
      end
    end
  end
end

-- One stroke on the engineer: a quarter of his dirt, or a smear in the face.
local scrub_player = function(data, target)
  local bot = data.bot
  if not target.smeared and (target.start_dirt or 0) >= smear_dirt and math.random() < smear_chance then
    target.smeared = true
    reactions.say(data, shared.sounds.scream)
    reactions.label_bot(data, {"droid-m-o-text.smeared"}, reactions.colours.alarm, 120)
    bot.surface.create_entity{name = shared.dust, position = bot.position}
    bot.commandable.set_command
    {
      type = defines.command.compound,
      structure_type = defines.compound_command.return_last,
      distraction = defines.distraction.none,
      commands =
      {
        {type = defines.command.stop, ticks_to_wait = smear_ticks, distraction = defines.distraction.none},
        {type = defines.command.attack, target = data.proxy, distraction = defines.distraction.none}
      }
    }
    return
  end
  if tracks.clean(target.player_index, chase_stroke) > 0 then return end
  local player = game.get_player(target.player_index)
  data.cleaned = (data.cleaned or 0) + 1
  all_clean(data, player and player.character)
  reactions.siren_down(data)
  release_target(data)
  think(data)
end

-- ------------------------------------------------------------------ the station and its bot

local spawn_bot = function(data)
  local dock = data.dock
  local bot = dock.surface.create_entity{name = shared.bot, position = data.port, force = dock.force, quality = dock.quality}
  if not bot then return end
  data.bot = bot
  data.respawn_tick = nil
  -- A new bot has no status yet, whatever its dock shows.
  data.status = nil
  state.s.bots[bot.unit_number] = dock.unit_number
  state.s.registrations[script.register_on_object_destroyed(bot)] = {bot = dock.unit_number}
  -- Parked from the start: a unit given no command wanders off.
  dock_bot(data)
  -- "M-O."
  reactions.say(data, shared.sounds.name)
  reactions.label_bot(data, {"droid-m-o-text.name"}, reactions.colours.note, 120)
end

local direction_names =
{
  [defines.direction.north] = "north",
  [defines.direction.east] = "east",
  [defines.direction.south] = "south",
  [defines.direction.west] = "west"
}

-- The port's floor plate, under entities so the parked bot is drawn over it. It goes with the dock.
local draw_port = function(data)
  if data.port_sprite and data.port_sprite.valid then
    data.port_sprite.destroy()
  end
  local dock = data.dock
  data.port_sprite = rendering.draw_sprite
  {
    sprite = shared.dock .. "-port-" .. (direction_names[dock.direction] or "north"),
    target = dock,
    surface = dock.surface,
    render_layer = "floor"
  }
end

local function add_to_dock_index(index, number, data)
  local by_force = get_surface_table(index, data.surface_index)
  get_surface_table(by_force, data.force_index)[number] = true
end

local function rebuild_dock_index()
  local s = state.s
  local index = {}
  for number, data in pairs(s.docks) do
    if data.dock.valid then
      data.force_index = data.dock.force.index
      add_to_dock_index(index, number, data)
    end
  end
  s.dock_index = index
  s.dock_counts = nil -- superseded; older saves rebuild from the dock records
  return index
end

local function dock_index()
  return state.s.dock_index or rebuild_dock_index()
end

local function remove_from_dock_index(index, number, data)
  local by_force = index[data.surface_index]
  local docks = by_force and by_force[data.force_index]
  if not docks then return end
  docks[number] = nil
  if not next(docks) then
    by_force[data.force_index] = nil
    if not next(by_force) then index[data.surface_index] = nil end
  end
end

local function docks_on(surface_index, force_index)
  local by_force = dock_index()[surface_index]
  return by_force and by_force[force_index]
end

tracks.has_docks = function(surface_index, force_index)
  return docks_on(surface_index, force_index) ~= nil
end

local bucket_of = function(dock_number)
  return dock_number % update_interval
end

local on_dock_built = function(dock)
  local s = state.s
  -- Some mods raise a built event again for a dock that's already set up.
  if s.docks[dock.unit_number] then return end
  local quality = quality_factor(dock.quality)
  local data =
  {
    dock = dock,
    surface_index = dock.surface.index,
    force_index = dock.force.index,
    position = dock.position,
    direction = dock.direction,
    port = get_port(dock),
    quality_factor = quality,
    battery = get_upgrades(dock.force).capacity * quality / 2,
    queue = {},
    queue_keys = {},
    scan_index = 1,
    backpack = game.create_inventory(shared.backpack_slots)
  }
  local index = dock_index()
  s.docks[dock.unit_number] = data
  get_surface_table(s.buckets, bucket_of(dock.unit_number))[dock.unit_number] = true
  add_to_dock_index(index, dock.unit_number, data)
  s.registrations[script.register_on_object_destroyed(dock)] = {dock = dock.unit_number}
  draw_port(data)
  spawn_bot(data)
end

droid.on_built = function(event)
  local entity = event.entity
  if entity and entity.valid and entity.name == shared.dock then
    on_dock_built(entity)
  end
end

-- A cloned dock gets a bot of its own, so a clone of its bot (or of what he was scrubbing at) is left with nothing.
droid.on_entity_cloned = function(event)
  local entity = event.destination
  if not (entity and entity.valid) then return end
  if entity.name == shared.dock then
    on_dock_built(entity)
  elseif entity.name == shared.bot or entity.name == shared.proxy then
    entity.destroy()
  end
end

-- Rotated or flipped, a placed dock turns end for end, and the game checks neither tile: it's turned back if that would
-- put its port off the paved floor.
droid.on_dock_turned = function(event)
  local dock = event.entity
  if not (dock and dock.valid and dock.name == shared.dock) then return end
  local data = state.s.docks[dock.unit_number]
  if not data or dock.direction == data.direction then return end
  local port = get_port(dock)
  if not paving.is_paved(dock.surface.get_tile(port.x, port.y).name) then
    dock.direction = data.direction
    local player = game.get_player(event.player_index)
    if player then
      player.create_local_flying_text{text = {"droid-m-o-message.port-unpaved"}, position = dock.position}
      player.play_sound{path = "utility/cannot_build"}
    end
    return
  end
  data.direction = dock.direction
  data.port = port
  draw_port(data)
  if data.bot and data.bot.valid and data.state ~= states.sweeping and data.state ~= states.chasing then
    go_home(data)
  end
end

local spill = function(surface, position, inventory, player)
  for i = 1, #inventory do
    local stack = inventory[i]
    if stack.valid_for_read then
      local inserted = player and player.insert(stack) or 0
      if inserted < stack.count then
        if inserted > 0 then
          stack.count = stack.count - inserted
        end
        surface.spill_item_stack{position = position, stack = stack, enable_looted = true, allow_belts = false}
      end
      stack.clear()
    end
  end
end

-- Mined, the station hands over his bin: to the player who mined it, otherwise onto the floor by it.
droid.on_dock_mined = function(event)
  local dock = event.entity
  if not (dock and dock.valid and dock.name == shared.dock) then return end
  local data = state.s.docks[dock.unit_number]
  if not (data and data.backpack and data.backpack.valid) then return end
  local player = event.player_index and game.get_player(event.player_index)
  spill(dock.surface, dock.position, data.backpack, player)
end

-- Destroyed, his bin bursts where he was.
droid.on_bot_died = function(event)
  local bot = event.entity
  if not (bot and bot.valid) then return end
  local data = get_data_by_bot(bot.unit_number)
  if data and data.backpack and data.backpack.valid then
    spill(bot.surface, bot.position, data.backpack)
    data.bin_full = nil
  end
end

droid.on_bot_damaged = function(event)
  local bot = event.entity
  if not (bot and bot.valid) then return end
  local data = get_data_by_bot(bot.unit_number)
  if data then
    reactions.say(data, shared.sounds.yelp)
  end
end

droid.on_object_destroyed = function(event)
  local s = state.s
  local registration = s.registrations[event.registration_number]
  if not registration then return end
  s.registrations[event.registration_number] = nil

  if registration.dock then
    local data = s.docks[registration.dock]
    if not data then return end
    s.docks[registration.dock] = nil
    local bucket = s.buckets[bucket_of(registration.dock)]
    if bucket then
      bucket[registration.dock] = nil
    end
    remove_from_dock_index(dock_index(), registration.dock, data)
    release_target(data)
    reactions.siren_down(data)
    if data.backpack and data.backpack.valid then
      local surface = game.get_surface(data.surface_index)
      if surface then
        spill(surface, data.position, data.backpack)
      end
      data.backpack.destroy()
    end
    if data.bot and data.bot.valid then
      s.bots[data.bot.unit_number] = nil
      data.bot.destroy()
    end
    return
  end

  local data = s.docks[registration.bot]
  if not data then return end
  if event.useful_id then
    s.bots[event.useful_id] = nil
  end
  if data.bot and data.bot.valid then return end
  requeue_target(data)
  release_target(data)
  reactions.siren_down(data)
  data.bot = nil
  data.respawn_tick = game.tick + respawn_ticks
end

droid.on_ai_command_completed = function(event)
  if event.result == defines.behavior_result.deleted then return end
  local data = get_data_by_bot(event.unit_number)
  if not (data and data.bot and data.bot.valid) then return end

  if data.state == states.returning then
    data.fails = event.result ~= defines.behavior_result.success and (data.fails or 0) + 1 or nil
    -- Home, or stranded (walled in, or his floor dug up from under him) and fetched.
    if not data.fails or data.fails >= stranded_fails then
      if data.fails then
        reactions.say(data, shared.sounds.whoa)
      end
      dock_bot(data, not data.fails)
      return
    end
    set_state(data, states.charging)
    data.next_think = game.tick + 60 * data.fails
    return
  end

  if data.state == states.chasing then
    give_up_chase(data)
    return
  end

  if data.state == states.sweeping then
    -- Short of his target: he couldn't get there, or he's dying, which can't be told yet. A tick's wait tells them apart
    -- (a dying bot's is cut short), so a bot that's killed leaves his target to the next one.
    if data.proxy and data.proxy.valid then
      if not data.missed then
        data.missed = true
        data.bot.commandable.set_command{type = defines.command.stop, ticks_to_wait = 1, distraction = defines.distraction.none}
        return
      end
      if event.result ~= defines.behavior_result.success then return end
      -- Couldn't get to it: a puzzled "Huh?", and it's left for a while.
      reactions.say(data, shared.sounds.huh)
      skip_target(data)
    end
    release_target(data)
    data.fails = nil
    think(data)
  end
end

droid.on_script_trigger_effect = function(event)
  if event.effect_id ~= shared.scrub_effect then return end
  local source = event.source_entity
  if not (source and source.valid) then return end
  local data = get_data_by_bot(source.unit_number)
  if not (data and data.target) then return end
  local target = data.target

  if data.state == states.chasing and target.kind == "player" then
    scrub_player(data, target)
    return
  end
  if data.state ~= states.sweeping then return end

  local result, cleaned = contaminants.stroke(data, target)
  data.turned_back = nil
  if result == "more" then return end
  if result == "full" then
    -- Back for it once the bin is emptied.
    data.bin_full = true
    requeue_target(data)
    reactions.label_bot(data, {"droid-m-o-text.bin-full"}, reactions.colours.warn, 120)
    go_home(data)
    return
  end
  data.cleaned = (data.cleaned or 0) + 1
  if cleaned then achievement_facts.cleaned(data) end
  release_target(data)
end

-- How the charging is going on the port, from what he wanted from the dock this update and what he got. Some slack: at
-- the fastest research a whole update's charge is all the dock's buffer holds.
local charging_status = function(dock, wanted, taken)
  if wanted <= 0 then
    return "nothing_to_sweep"
  end
  if taken <= 0 then
    return dock.is_connected_to_electric_network() and "no_power" or "unplugged"
  end
  return taken < wanted * 0.9 and "low_power" or "charging"
end

local must_go_home = function(data)
  local home_distance = distance(data.bot.position, data.port)
  return data.battery <= travel_energy(home_distance) + drain_per_tick * update_interval * 2
end

-- His target waits for him to charge, unless he ran low on his way there last time too, with no stroke since: the way
-- round is longer than his battery lasts, so it's left for a while.
local turn_back = function(data)
  local key = data.target and data.target.key
  if key and key == data.turned_back then
    skip_target(data)
  else
    requeue_target(data)
  end
  data.turned_back = key
  reactions.say(data, shared.sounds.low_battery)
  go_home(data)
end

local update_dock = function(data, tick)
  local dock = data.dock
  if not dock.valid then return end

  local force = dock.force
  local force_index = force.index
  if data.force_index ~= force_index then
    local index = state.s.dock_index
    if index then
      remove_from_dock_index(index, dock.unit_number, data)
      data.force_index = force_index
      add_to_dock_index(index, dock.unit_number, data)
    else
      rebuild_dock_index()
    end
  end
  scan(data, tick)

  local bot = data.bot
  if not (bot and bot.valid) then
    if data.respawn_tick and tick >= data.respawn_tick then
      spawn_bot(data)
    else
      set_status(data, "replacing_bot")
    end
    return
  end

  -- A script can change the dock's force, with no event for it.
  if bot.force ~= force then bot.force = force end

  look_around(data, tick)

  if data.state == states.charging then
    if distance(data.port, bot.position) < docked_distance then
      local upgrades = get_upgrades(dock.force)
      local capacity = get_capacity(data)
      local wanted = math.min(capacity - data.battery, upgrades.charge_per_tick * update_interval)
      local taken = math.min(math.max(wanted, 0), dock.energy)
      if taken > 0 then
        dock.energy = dock.energy - taken
        data.battery = data.battery + taken
        play_sound(data, shared.sounds.charge)
      end
      show_charging(data, taken > 0)
      if data.backpack and not data.backpack.is_empty() and tick >= (data.next_unload or 0) then
        data.next_unload = tick + unload_interval
        unload(data)
      end
      local status = charging_status(dock, wanted, taken)
      if data.bin_full and (status == "charging" or status == "nothing_to_sweep") then
        status = "bin_full"
      end
      set_status(data, status)
      achievement_facts.service(data, capacity, states.charging, docked_distance)
      if data.battery >= capacity and tick >= (data.next_think or 0) then
        think(data)
      end
    else
      -- His way home failed: he tries again in a moment.
      set_status(data, "no_path")
      if tick >= (data.next_think or 0) then
        go_home(data)
      end
    end
    return
  end

  data.battery = math.max(0, data.battery - drain_per_tick * update_interval)

  if data.state == states.chasing then
    local target = data.target
    local player = target and game.get_player(target.player_index)
    local character = player and player.character
    if not (character and character.valid and data.proxy and data.proxy.valid) or player.vehicle or
      character.surface_index ~= data.surface_index or distance(character.position, data.port) > chase_radius + 8 or
      tracks.dirt(target.player_index) <= 0 or tick - target.since > chase_give_up or must_go_home(data) then
      give_up_chase(data)
      return
    end
    data.proxy.teleport(character.position)
    return
  end

  local position = bot.position
  if not data.moved_from or distance(position, data.moved_from) > stuck_distance then
    data.moved_from, data.moved_tick = position, tick
  elseif tick - data.moved_tick > stuck_ticks then
    reactions.say(data, shared.sounds.whoa)
    go_home(data)
    return
  end

  if data.state == states.sweeping and must_go_home(data) then
    turn_back(data)
  end
end

-- Each dock is looked at every update_interval ticks, on its own tick of the cycle, so many docks spread out.
droid.on_tick = function(event)
  local s = state.s
  local bucket = s.buckets[event.tick % update_interval]
  if not bucket then return end
  local docks = s.docks
  for dock_number in pairs(bucket) do
    local data = docks[dock_number]
    if data then
      update_dock(data, event.tick)
    end
  end
end

-- Skipped dirt is only let go of when it's looked at again, which it may never be (its dock gone, or the dirt cleaned up
-- some other way), so now and then it's all gone through. Tables left empty go too.
droid.forget = function(event)
  local s = state.s
  for index, skipped in pairs(s.skipped) do
    for key, until_tick in pairs(skipped) do
      if until_tick <= event.tick then
        skipped[key] = nil
      end
    end
    if not next(skipped) then
      s.skipped[index] = nil
    end
  end
  for index, claimed in pairs(s.claimed) do
    if not next(claimed) then
      s.claimed[index] = nil
    end
  end
end

-- A new surface can be given a deleted one's index: it starts with nothing skipped.
droid.on_surface_gone = function(event)
  state.s.skipped[event.surface_index] = nil
  state.s.claimed[event.surface_index] = nil
  if state.s.dock_index then state.s.dock_index[event.surface_index] = nil end
end

droid.on_research_changed = function(event)
  update_force(event.research.force)
end

-- Also when a force is created: it may have the index of one merged away, and with it that force's upgrades.
droid.on_force_changed = function(event)
  update_force(event.force)
end

droid.on_forces_merged = function(event)
  state.s.forces[event.source_index] = nil
  update_force(event.destination)
  rebuild_dock_index()
end

-- Rebuilt from the docks: which tick each is updated on and which can see new prints.
droid.rebuild_indexes = function()
  local s = state.s
  s.buckets = {}
  for dock_number, data in pairs(s.docks) do
    if data.dock.valid then
      get_surface_table(s.buckets, bucket_of(dock_number))[dock_number] = true
    end
  end
  rebuild_dock_index()
end

-- Fresh muddy prints (script/tracks.lua): straight onto the queue of every station of that force in reach of them.
tracks.notice = function(surface_index, force_index, x, y)
  local docks = docks_on(surface_index, force_index)
  if not docks then return end
  local key = contaminants.tile_key(x, y)
  local centre = {x = x + 0.5, y = y + 0.5}
  for number in pairs(docks) do
    local data = state.s.docks[number]
    if data and not data.queue_keys[key] and data.dock.valid and data.dock.force.index == force_index and
      distance(centre, data.port) <= reach(get_capacity(data)) then
      data.queue_keys[key] = true
      data.queue[#data.queue + 1] = {kind = "decor", key = key, x = x, y = y, prints = true}
    end
  end
end

local get_dock_data = function(dock)
  return dock and dock.valid and state.s.docks[dock.unit_number]
end

droid.remote =
{
  get_service_cycle_event = achievement_facts.get_event,
  get_bot = function(dock)
    local data = get_dock_data(dock)
    return data and data.bot and data.bot.valid and data.bot or nil
  end,
  get_state = function(dock)
    local data = get_dock_data(dock)
    return data and data.state
  end,
  get_status = function(dock)
    local data = get_dock_data(dock)
    return data and data.status
  end,
  get_battery = function(dock)
    local data = get_dock_data(dock)
    return data and data.battery / get_capacity(data)
  end,
  set_battery = function(dock, fraction)
    local data = get_dock_data(dock)
    if data then data.battery = get_capacity(data) * fraction end
  end,
  get_capacity = function(force)
    return get_upgrades(game.forces[force or "player"]).capacity
  end,
  get_reach = function(force)
    return reach(get_upgrades(game.forces[force or "player"]).capacity)
  end,
  get_queue_size = function(dock)
    local data = get_dock_data(dock)
    return data and #data.queue
  end,
  get_bin = function(dock)
    local data = get_dock_data(dock)
    return data and data.backpack and data.backpack.valid and data.backpack.get_contents() or nil
  end,
  get_target_kind = function(dock)
    local data = get_dock_data(dock)
    return data and data.target and data.target.kind
  end,
  get_dirt = function(player_index)
    return tracks.dirt(player_index)
  end,
  set_dirt = function(player_index, dirt)
    tracks.get(player_index).dirt = dirt
  end,
  rescan = function(dock)
    local data = get_dock_data(dock)
    if data then
      data.scan_index = 1
      data.scan_paused_until = nil
    end
  end,
  count_skipped = function(surface_index)
    return table_size(state.s.skipped[surface_index] or {})
  end
}

return droid
