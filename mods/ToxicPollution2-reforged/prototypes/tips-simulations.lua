-- Paranoidal: animations of the "Toxic smog" tips (prototypes/tips.lua). The mod's own script is not loaded in the
-- tips window (it works only for connected players), so every scene runs the intoxication model of
-- scripts/model.lua itself, with the numbers of shared/config.lua and the startup tolerance put into the scene
-- text below (K). Characters, armor-slot items, furnaces, the air filter, the combinator and its wire are real
-- entities; the smog cloud, the bars and the alert panel are drawn. An error is shown as text (tpr-tips-sim.error).
local C = require("shared.config")

local function armor(name)
	local spec = C.ARMORS[name]
	return {
		name = name,
		share = spec.filtration / 100,
		max = spec.durability,
		endurance = C.POISON_FILTERS[name] and 1 or C.ARMOR_ENDURANCE,
	}
end

local K = {
	tolerance = settings.startup["tpr-tolerance"].value,
	model = C.MODEL,
	tiers = C.TIERS,
	last_share = C.LAST_SHARE,
	last_seconds = C.LAST_SECONDS,
	endurance = C.ARMOR_ENDURANCE,
	alert = C.ALERT,
	signal = C.SIGNAL,
	damage_type = C.DAMAGE_TYPE,
	respirator = armor(C.RESPIRATOR),
	gas_mask = armor(C.GAS_MASK),
	heavy = armor("heavy-armor"),
	filter_item = C.REFILL_ITEM,
}

local PRELUDE = "local K = " .. serpent.line(K, { comment = false }) .. "\n" .. [=[
local surface = game.surfaces[1]
local force = game.forces.player
local sim = game.simulation
local P = K.model
S = {t = 0, stats = {}}
sim.hide_cursor = true

function S.fail(message)
  if S.err then return end
  S.err = tostring(message)
  pcall(log, "tpr tips simulation: " .. S.err)
  pcall(rendering.draw_text, {text = {"tpr-tips-sim.error", S.err}, surface = surface, target = {0, -6},
    color = {1, 0.35, 0.35}, scale = 1.5, alignment = "center"})
end

function S.start(fn)
  local ok, message = pcall(fn)
  if not ok then S.fail(message) end
end

function S.on_tick(fn)
  script.on_nth_tick(1, function()
    if S.err then return end
    S.t = S.t + 1
    local ok, message = pcall(fn, S.t)
    if ok then ok, message = pcall(S.drift) end
    if not ok then S.fail(message) end
  end)
end

-- Camera of the tips window (1408x704 px); text keeps one size on screen whatever the zoom.
function S.camera(position, zoom)
  sim.camera_position = position
  sim.camera_zoom = zoom
  S.zoom = zoom
end

-- options.scale is relative: 1 = about 24 px high in the window
function S.text(target, text, options)
  options = options or {}
  return rendering.draw_text{text = text, surface = surface, target = target, color = options.color or {1, 1, 1},
    scale = 1.6 * (options.scale or 1) / (S.zoom or 1), font = options.font or "default-bold",
    alignment = options.align or "center", vertical_alignment = "middle", use_rich_text = true}
end

-- Text over a character's head
function S.head(entity, text, color)
  return S.text({entity = entity, offset = {0, -2.9}}, text, {color = color, scale = 0.8})
end

function S.rect(left_top, right_bottom, color, filled)
  return rendering.draw_rectangle{surface = surface, left_top = left_top, right_bottom = right_bottom, color = color,
    filled = filled ~= false, width = 2}
end

function S.bar(left, top, width, color, height)
  local bar = {left = left, top = top, width = width, height = height or 0.4}
  bar.back = S.rect({left, top}, {left + width, top + bar.height}, {0.05, 0.05, 0.05, 0.8})
  bar.fill = S.rect({left, top}, {left, top + bar.height}, color or {0.35, 0.8, 0.35, 1})
  return bar
end

function S.set_bar(bar, fraction, color)
  fraction = math.max(0, math.min(1, fraction or 0))
  bar.fill.right_bottom = {bar.left + bar.width * fraction, bar.top + bar.height}
  if color then bar.fill.color = color end
end

function S.board(x1, y1, x2, y2)
  surface.build_checkerboard{{x1, y1}, {x2, y2}}
end

function S.create(name, position, extra)
  local spec = {name = name, position = position, force = force, create_build_effect_smoke = false}
  for key, value in pairs(extra or {}) do spec[key] = value end
  local entity = surface.create_entity(spec)
  if not entity then error("cannot create " .. name .. " at " .. position[1] .. "," .. position[2]) end
  return entity
end

-- Smog cloud over an area: nested translucent layers (soft edge) and puffs drifting east inside it, all on the
-- ground (colours are premultiplied). S.haze(cloud, strength) changes its thickness (0 = gone).
local clouds = {}
local function tint(a) return {0.55 * a, 0.48 * a, 0.18 * a, a} end
function S.smog(x1, y1, x2, y2, strength)
  local cloud = {x1 = x1, y1 = y1, x2 = x2, y2 = y2, strength = strength or 1, layers = {}, puffs = {}}
  for i = 0, 3 do
    cloud.layers[#cloud.layers + 1] = rendering.draw_rectangle{surface = surface, filled = true, draw_on_ground = true,
      left_top = {x1 + i * 0.7, y1 + i * 0.7}, right_bottom = {x2 - i * 0.7, y2 - i * 0.7}, color = tint(0.07 * cloud.strength)}
  end
  local n = math.max(4, math.floor((x2 - x1) * (y2 - y1) / 14))
  for k = 1, n do
    local u, v = (math.sin(k * 12.9898) + 1) / 2, (math.cos(k * 78.233) + 1) / 2
    local puff = {x = x1 + 2 + u * (x2 - x1 - 4), y = y1 + 2 + v * (y2 - y1 - 4), speed = 0.006 + 0.003 * (k % 4)}
    puff.object = rendering.draw_circle{surface = surface, target = {puff.x, puff.y}, radius = 1.6 + 0.6 * (k % 3),
      filled = true, draw_on_ground = true, color = tint(0)}
    cloud.puffs[k] = puff
  end
  clouds[#clouds + 1] = cloud
  return cloud
end

function S.haze(cloud, strength)
  cloud.strength = strength
  for _, layer in ipairs(cloud.layers) do layer.color = tint(0.07 * strength) end
end

function S.drift()
  for _, cloud in ipairs(clouds) do
    for _, puff in ipairs(cloud.puffs) do
      puff.x = puff.x + puff.speed
      if puff.x > cloud.x2 - 1 then puff.x = cloud.x1 + 1 end
      local edge = math.max(0, math.min(1, (puff.x - cloud.x1) / 4, (cloud.x2 - puff.x) / 4))
      puff.object.target = {puff.x, puff.y}
      puff.object.color = tint(0.06 * cloud.strength * edge)
    end
  end
end

-- Burning stone furnaces: real smoke over the smog (stone to bricks: the build smelts iron ore elsewhere)
function S.furnaces(list)
  local made = {}
  for _, position in ipairs(list) do
    local ok, furnace = pcall(S.create, "stone-furnace", position)
    if ok then
      pcall(furnace.insert, {name = "coal", count = 50})
      pcall(furnace.insert, {name = "stone", count = 100})
      made[#made + 1] = furnace
    end
  end
  return made
end

function S.power(x, y)
  S.create("substation", {x, y})
  S.create("electric-energy-interface", {x + 2, y})
end

-- Armor slot of a character: nil name empties it
function S.put_on(character, name, count)
  local inventory = character.get_inventory(defines.inventory.character_armor)
  inventory.clear()
  if name then inventory.insert{name = name, count = count or 1} end
  return inventory
end

-- Walks a character to x (same row). If the engine does not move a character without a player, it is moved by
-- teleport steps instead (S.stats.walk tells which).
local walkers = {}
function S.walk(character, x)
  local p = character.position
  local dx = x - p.x
  local w = walkers[character.unit_number] or {}
  walkers[character.unit_number] = w
  if math.abs(dx) < 0.3 then
    character.walking_state = {walking = false}
    w.last = nil
    return true
  end
  if w.last and math.abs(w.last - p.x) < 0.01 then
    character.teleport({p.x + (dx > 0 and 0.15 or -0.15), p.y})
    S.stats.walk = "teleport"
  elseif w.last then
    S.stats.walk = S.stats.walk or "walking"
  end
  character.walking_state = {walking = true, direction = dx > 0 and defines.direction.east or defines.direction.west}
  w.last = character.position.x
  return false
end

-- Intoxication model, as scripts/model.lua (research level 0)
function S.rate(inhaled, zone)
  local excess = inhaled - K.tolerance
  if excess > 0 then return P.rate_max * excess / (excess + P.rate_half) end
  local share = math.min(1, -excess / K.tolerance)
  local decay = P.decay_min + (P.decay_max - P.decay_min) * share
  return -decay * (zone and P.zone_factor or 1)
end

function S.step(x, rate, seconds)
  return math.max(0, math.min(100, x + rate * seconds))
end

-- Share of max health lost per second
function S.harm(x, inhaled)
  if inhaled <= K.tolerance or x <= P.damage_from then return 0 end
  return P.damage_share * (x - P.damage_from) / (100 - P.damage_from)
end

-- Filter resource spent per second by the worn item
function S.wear(reaching, item)
  local harmful = reaching - K.tolerance
  if harmful <= 0 then return 0 end
  return harmful * (1 - item.share) / P.wear_div / item.endurance
end

function S.color(x)
  if x >= K.tiers[3] then return {1, 0.3, 0.25} end
  if x >= K.tiers[2] then return {1, 0.6, 0.2} end
  if x >= K.tiers[1] then return {1, 0.9, 0.3} end
  return {0.5, 1, 0.5}
end

function S.f1(value) return string.format("%.1f", value) end
function S.int(value) return tostring(math.floor(value + 0.5)) end

function S.duration(seconds)
  if seconds < 120 then return {"tpr-time.s", S.int(seconds)} end
  local minutes = math.floor(seconds / 60 + 0.5)
  if minutes < 120 then return {"tpr-time.min", tostring(minutes)} end
  return {"tpr-time.h", tostring(math.floor(minutes / 60)), tostring(minutes % 60)}
end

function S.hurt(character, share)
  if share > 0 and character.valid then character.damage(character.max_health * share, "neutral", K.damage_type) end
end
]=]

local function simulation(body, extra)
	local definition = { init = PRELUDE .. body }
	for key, value in pairs(extra or {}) do definition[key] = value end
	return definition
end

local simulations = {}

-- Without protection: into the smog, intoxication rises, from 50 % health damage; out of it the damage stops at once.
simulations.smog = simulation([=[
S.start(function()
  S.camera({0, 0}, 1.6)
  S.board(-40, -24, 40, 24)
  local POLLUTION, EDGE = 1500, 0
  S.smog(EDGE - 1, -9, 17, 9)
  S.furnaces({{5, -4.5}, {8, -4.5}, {11, -4.5}})
  S.text({-7, -6.1}, {"tpr-tips-sim.clean-air"}, {color = {0.6, 1, 0.6}})
  S.text({7, -6.1}, {"tpr-tips-sim.smog", POLLUTION, K.tolerance}, {color = {1, 0.85, 0.4}, scale = 0.9})
  local character = S.create("character", {-9, 0.5})
  local head = S.head(character, "")
  S.text({-13.2, 4.2}, {"tpr-tips-sim.intoxication"}, {align = "left", scale = 0.75})
  local x_bar = S.bar(-8.5, 4.0, 7, {0.5, 1, 0.5, 1}, 0.4)
  S.rect({-8.5 + 7 * P.damage_from / 100 - 0.05, 3.8}, {-8.5 + 7 * P.damage_from / 100 + 0.05, 4.6}, {1, 1, 1, 1})
  local x_text = S.text({-1.2, 4.2}, "", {align = "left", scale = 0.75})
  S.text({-13.2, 5.1}, {"tpr-tips-sim.health"}, {align = "left", scale = 0.75})
  local h_bar = S.bar(-8.5, 4.9, 7, {0.85, 0.2, 0.2, 1}, 0.4)
  local h_text = S.text({-1.2, 5.1}, "", {align = "left", scale = 0.75})
  local status = S.text({-6.5, 6.2}, "", {scale = 0.75, font = "default"})
  S.stats.max_x, S.stats.min_health, S.stats.cycles = 0, 1, 0
  local x, phase, wait = 0, "in", 60
  S.on_tick(function()
    local inhaled = character.position.x > EDGE and POLLUTION or 0
    local rate = S.rate(inhaled, false)
    x = S.step(x, rate, 1 / 60)
    local harm = S.harm(x, inhaled)
    S.hurt(character, harm / 60)
    local health = character.get_health_ratio()
    if phase == "in" then
      if wait > 0 then wait = wait - 1 elseif S.walk(character, 6) then phase = "stay" end
    elseif phase == "stay" then
      if health <= 0.6 then phase = "out" end
    elseif phase == "out" then
      if S.walk(character, -9) and x <= 0 then phase, wait = "in", 120 S.stats.cycles = S.stats.cycles + 1 end
    end
    S.stats.max_x = math.max(S.stats.max_x, x)
    S.stats.min_health = math.min(S.stats.min_health, health)
    local color = S.color(x)
    S.set_bar(x_bar, x / 100, {color[1], color[2], color[3], 1})
    S.set_bar(h_bar, health)
    x_text.text = {"tpr-tips-sim.percent", S.int(x)}
    x_text.color = color
    h_text.text = {"tpr-tips-sim.percent", S.int(health * 100)}
    head.text = {"tpr-tips-sim.percent", S.int(x)}
    head.color = color
    if inhaled > K.tolerance then
      status.text = harm > 0 and {"", {"tpr-tips-sim.rising", S.f1(rate)}, " · ", {"tpr-tips-sim.damage", S.f1(harm * 100)}}
        or {"tpr-tips-sim.rising", S.f1(rate)}
      status.color = harm > 0 and {1, 0.4, 0.35} or {1, 0.85, 0.4}
    else
      status.text = {"tpr-tips-sim.falling", S.f1(-rate)}
      status.color = {0.6, 1, 0.6}
    end
  end)
end)
]=], { init_update_count = 120 })

-- One smog, three armor-slot items: the item takes the whole hit on its resource; a respirator from the stack replaces
-- the worn one; without anything left the body is poisoned.
simulations.protection = simulation([=[
S.start(function()
  S.camera({0, 0}, 1.4)
  S.board(-40, -24, 40, 24)
  local POLLUTION = 6000
  S.smog(-18, -9, 18, 9, 1.3)
  S.text({0, -7.1}, {"tpr-tips-sim.protection-title", POLLUTION, K.tolerance}, {scale = 0.8})
  local units = {{x = -10, item = K.respirator, count = 2}, {x = 0, item = K.gas_mask, count = 1}, {x = 10, item = K.heavy, count = 1}}
  for _, u in ipairs(units) do
    u.character = S.create("character", {u.x, -2.4})
    u.max = prototypes.item[u.item.name].get_durability() or u.item.max
    S.text({u.x, -5.8}, {"", "[item=" .. u.item.name .. "] ", prototypes.item[u.item.name].localised_name}, {scale = 0.8})
    S.text({u.x, -0.2}, {"tpr-tips-sim.toxin", S.int(u.item.share * 100)}, {scale = 0.65, font = "default", color = {1, 0.85, 0.4}})
    u.r_bar = S.bar(u.x - 4, 0.4, 8, {0.4, 0.75, 1, 1}, 0.4)
    u.r_text = S.text({u.x, 1.3}, "", {scale = 0.65, font = "default"})
    u.s_text = S.text({u.x, 2.1}, "", {scale = 0.65, font = "default", color = {0.75, 0.85, 1}})
    u.x_bar = S.bar(u.x - 4, 2.8, 8, {0.5, 1, 0.5, 1}, 0.4)
    u.x_text = S.text({u.x, 3.7}, "", {scale = 0.7})
    u.event = S.text({u.x, 4.7}, "", {scale = 0.75, color = {1, 0.85, 0.4}})
  end
  S.text({0, 6.6}, {"tpr-tips-sim.endurance", K.endurance}, {scale = 0.65, font = "default", color = {0.85, 0.85, 0.85}})
  S.stats.replaced, S.stats.bare = 0, false
  local hold
  local function reset()
    for _, u in ipairs(units) do
      u.n, u.res, u.x, u.flash = u.count, u.max, 0, 0
      S.put_on(u.character, u.item.name, u.count)
    end
    hold = nil
  end
  reset()
  S.on_tick(function()
    for _, u in ipairs(units) do
      local wear = 0
      if u.n > 0 then
        wear = S.wear(POLLUTION, u.item)
        u.res = u.res - wear / 60
        if u.res < P.exhausted then
          u.n = u.n - 1
          if u.n > 0 then
            u.res, u.flash = u.max, 180
            S.stats.replaced = S.stats.replaced + 1
          else
            u.res, u.flash = 0, 0
          end
          local inventory = u.character.get_inventory(defines.inventory.character_armor)
          if u.n > 0 then pcall(function() inventory[1].count = u.n end) else inventory.clear() end
        end
      end
      local protected = u.n > 0
      local inhaled = protected and 0 or POLLUTION
      local rate = S.rate(inhaled, false)
      u.x = S.step(u.x, rate, 1 / 60)
      S.set_bar(u.r_bar, u.res / u.max)
      u.r_text.text = {"tpr-tips-sim.resource", S.int(u.res), S.int(u.max)}
      if protected then
        u.s_text.text = u.count > 1 and {"", {"tpr-tips-sim.lasts", S.duration(u.res / wear)}, " · ", {"tpr-tips-sim.in-stack", u.n}}
          or {"tpr-tips-sim.lasts", S.duration(u.res / wear)}
      else
        u.s_text.text = {"tpr-tips-sim.worn-out"}
      end
      local color = S.color(u.x)
      S.set_bar(u.x_bar, u.x / 100, {color[1], color[2], color[3], 1})
      u.x_text.text = protected and {"tpr-tips-sim.protected", S.int(u.x)} or {"tpr-tips-sim.bare", S.int(u.x), S.f1(rate)}
      u.x_text.color = protected and {0.6, 1, 0.6} or {1, 0.45, 0.35}
      if u.flash > 0 then u.flash = u.flash - 1 end
      u.event.text = u.flash > 0 and {"tpr-tips-sim.next"} or ""
    end
    local first = units[1]
    if first.n == 0 then
      S.stats.bare = true
      if first.x >= 45 and not hold then hold = 120 end
    end
    if hold then
      hold = hold - 1
      if hold <= 0 then reset() end
    end
  end)
end)
]=], { init_update_count = 60 })

-- The alerts of the mod in their order (time sped up): smog in protection, the last protection running out,
-- no protection, damage. One alert is shown at a time, the highest priority wins (scripts/alerts.lua).
simulations.alerts = simulation([=[
S.start(function()
  S.camera({0, 0}, 1.5)
  S.board(-40, -24, 40, 24)
  -- time sped up; the respirator is already worn down to START of its resource
  local POLLUTION, EDGE, SPEED, START = 1200, 1, 3, 0.6
  local item = K.respirator
  S.smog(EDGE - 1, -2.6, 17, 9)
  S.furnaces({{6, 4.5}, {9, 4.5}, {12, 4.5}})
  S.text({9, 6.6}, {"tpr-tips-sim.smog", POLLUTION, K.tolerance}, {color = {1, 0.85, 0.4}, scale = 0.8})
  -- the alert panel
  S.rect({-14.2, -7}, {14.2, -3}, {0.06, 0.06, 0.08, 0.88})
  S.rect({-14.2, -7}, {14.2, -3}, {0.5, 0.5, 0.55, 1}, false)
  S.text({-13.8, -6.5}, {"tpr-tips-sim.alerts-title"}, {align = "left", scale = 0.55, font = "default", color = {0.75, 0.75, 0.75}})
  local icon
  local title = S.text({-11.4, -5.3}, "", {align = "left", scale = 0.72})
  local rule = S.text({-11.4, -4.0}, "", {align = "left", scale = 0.6, font = "default", color = {0.8, 0.8, 0.8}})
  local clock = S.text({-13.8, 6.6}, "", {align = "left", scale = 0.65, font = "default", color = {0.8, 0.8, 0.8}})
  local character = S.create("character", {-9, 1})
  local head = S.head(character, "")
  local max = prototypes.item[item.name].get_durability() or item.max
  local res, x, game_s = max * START, 0, 0
  local phase, wait, hold = "in", 60, 0
  local alert, alert_until, warned, harm_ref, smog_ready
  S.stats.seen, S.stats.first = {}, {}
  local ICONS = {smog = K.alert.smog, last = K.alert.filters, bare = K.alert.filters, danger = K.alert.danger}
  local PRIORITY = {smog = 1, last = 2, bare = 2, danger = 3}
  S.put_on(character, item.name, 1)
  S.on_tick(function()
    local dt = SPEED / 60
    game_s = game_s + dt
    local reaching = character.position.x > EDGE and POLLUTION or 0
    local protected = res >= P.exhausted
    local wear = protected and S.wear(reaching, item) or 0
    if protected then
      res = res - wear * dt
      if res < P.exhausted then
        res, protected = 0, false
        S.put_on(character, nil)
      end
    end
    local inhaled = protected and 0 or reaching
    local rate = S.rate(inhaled, false)
    x = S.step(x, rate, dt)
    local harm = S.harm(x, inhaled)
    S.hurt(character, harm * dt)
    -- alerts.lua: lasting condition, short event, priority
    local harmful = reaching - K.tolerance
    local lasting, event, item_title
    if harm > 0 then
      lasting, item_title = "danger", {"tpr-alert.danger", S.f1(character.max_health * harm)}
    elseif not protected and harmful > 0 then
      lasting, item_title = "bare", {"tpr-alert.unprotected"}
    end
    local event_title
    if protected and harmful > 0 then
      local eta = res / wear + math.max(0, P.damage_from - x) / S.rate(reaching, false)
      if res / max <= K.last_share or eta < K.last_seconds then
        if not warned then warned, event, event_title = true, "last", {"tpr-alert.last", item.name, S.duration(eta)} end
      end
    end
    if harmful > 0 then
      if not harm_ref and game_s >= (smog_ready or 0) then
        if protected and not event then
          event, event_title = "smog", {"tpr-alert.smog-protected", S.int(reaching), item.name}
          smog_ready = game_s + 30
        end
        harm_ref = harmful
      end
    else
      harm_ref = nil
    end
    if alert and ((not alert_until and alert ~= lasting) or (alert_until and game_s >= alert_until)) then alert = nil end
    if lasting and (not event or PRIORITY[lasting] >= PRIORITY[event]) then
      if alert ~= lasting then alert, alert_until = lasting, nil end
      title.text = item_title
    elseif event and (not alert or PRIORITY[event] >= PRIORITY[alert]) then
      alert, alert_until = event, game_s + 10
      title.text = event_title
    end
    if not alert then title.text = {"tpr-tips-sim.alert-none"} end
    if alert then
      S.stats.seen[alert] = true
      S.stats.first[alert] = S.stats.first[alert] or S.t
    end
    if (icon and icon.valid and icon.sprite ~= "virtual-signal/" .. (ICONS[alert] or "")) or (icon and not alert) then
      icon.destroy()
      icon = nil
    end
    if alert and not (icon and icon.valid) then
      icon = rendering.draw_sprite{sprite = "virtual-signal/" .. ICONS[alert], surface = surface, target = {-12.8, -4.7},
        x_scale = 0.9, y_scale = 0.9, render_layer = "cursor"}
    end
    rule.text = alert and {"tpr-tips-sim.alert-rule-" .. alert} or ""
    local m = math.floor(game_s / 60)
    clock.text = {"tpr-tips-sim.clock", string.format("%d:%02d", m, math.floor(game_s - m * 60)), SPEED}
    local color = S.color(x)
    head.text = protected and {"tpr-tips-sim.head-protected", "[item=" .. item.name .. "]", S.int(res / max * 100), S.int(x)}
      or {"tpr-tips-sim.percent", S.int(x)}
    head.color = color
    -- the walk: in, wait for the damage alert a while, out, recover, a new respirator
    if phase == "in" then
      if wait > 0 then wait = wait - 1 elseif S.walk(character, 6) then phase = "stay" end
    elseif phase == "stay" then
      if alert == "danger" then hold = hold + 1 end
      if hold >= 180 then phase = "out" end
    elseif phase == "out" then
      if S.walk(character, -9) and x <= 0 then
        res, warned, hold, phase, wait = max * START, nil, 0, "in", 90
        S.put_on(character, item.name, 1)
      end
    end
  end)
end)
]=], { init_update_count = 60 })

-- The pollution sensor: the mod writes the pollution of the chunk into the constant combinator once per second;
-- the wire takes it to the enable condition of the air filter. The polluting furnaces switch on and off.
simulations.sensor = simulation([=[
S.start(function()
  S.camera({0, 0}, 1.8)
  S.board(-40, -24, 40, 24)
  sim.camera_alt_info = true
  local THRESHOLD = 10
  S.text({0, -5.3}, {"tpr-tips-sim.sensor-title"}, {scale = 0.85})
  local cloud = S.smog(-12.5, -4.6, -3.5, 2.6, 0)
  local furnaces = S.furnaces({{-9.5, -2}, {-6.5, -2}})
  local furnace_text = S.text({-8, 0.4}, "", {scale = 0.65, font = "default"})
  local combinator = S.create("constant-combinator", {-1.5, 1.5})
  local value_text = S.text({-1.5, -0.2}, "", {scale = 1.1})
  local machine = S.create("CW-air-filter-machine-1", {5.5, 0.5})
  machine.insert{name = K.filter_item, count = 5}
  S.power(9, 4)
  local machine_text = S.text({5.5, -1.8}, "", {scale = 0.7})
  S.text({-1, 4.6}, {"tpr-tips-sim.sensor-condition", THRESHOLD}, {scale = 0.7, font = "default", color = {1, 0.85, 0.4}})
  local red = defines.wire_connector_id.circuit_red
  combinator.get_wire_connector(red, true).connect_to(machine.get_wire_connector(red, true), false)
  local control = machine.get_or_create_control_behavior()
  control.circuit_enable_disable = true
  local condition = {first_signal = {type = "virtual", name = K.signal}, comparator = ">", constant = THRESHOLD}
  if not pcall(function() control.circuit_condition = condition end) then control.circuit_condition = {condition = condition} end
  local section = combinator.get_or_create_control_behavior().get_section(1)
  local pollution, value = 0, 0
  S.stats.on, S.stats.off = 0, 0
  S.on_tick(function(t)
    local burning = (t % 1800) < 840
    for _, furnace in ipairs(furnaces) do furnace.disabled_by_script = not burning end
    local working = machine.status == defines.entity_status.working
    if t % 60 == 0 then
      pollution = math.max(0, pollution + (burning and 9 or 0) - (working and 6 or 0) - 0.5)
      value = math.floor(pollution)
      S.haze(cloud, math.min(1.4, pollution / 50))
      section.set_slot(1, {value = {type = "virtual", name = K.signal, quality = "normal"}, min = value})
    end
    value_text.text = {"tpr-tips-sim.sensor-value", value}
    furnace_text.text = burning and {"tpr-tips-sim.furnaces-on"} or {"tpr-tips-sim.furnaces-off"}
    furnace_text.color = burning and {1, 0.7, 0.4} or {0.7, 0.7, 0.7}
    machine_text.text = working and {"tpr-tips-sim.machine-on"} or {"tpr-tips-sim.machine-off"}
    machine_text.color = working and {0.6, 1, 0.6} or {1, 0.6, 0.5}
    if working then S.stats.on = S.stats.on + 1 else S.stats.off = S.stats.off + 1 end
  end)
end)
]=], { init_update_count = 120 })

-- First aid: a respirator stops the damage at once; next to a working air filter the intoxication falls twice
-- as fast (scripts/zones.lua: within the zone radius, only while the air breathed is already tolerable).
simulations.sos = simulation([=[
S.start(function()
  S.camera({0, 0}, 1.25)
  S.board(-40, -24, 40, 24)
  local POLLUTION, EDGE = 1500, -3
  S.smog(-19, -10, EDGE, 10)
  S.furnaces({{-15, -4.5}, {-12, -4.5}})
  S.text({-10.5, -7.9}, {"tpr-tips-sim.sos-step1"}, {scale = 0.75})
  S.text({8.5, -7.9}, {"tpr-tips-sim.sos-step2"}, {scale = 0.75})
  local machine = S.create("CW-air-filter-machine-1", {11.5, -2.5})
  machine.insert{name = K.filter_item, count = 5}
  S.power(14, 1.5)
  local center = {11.5, -2.5}
  rendering.draw_circle{surface = surface, target = center, radius = P.zone_radius, filled = false, width = 3,
    color = {0.3, 0.9, 0.4, 0.9}, draw_on_ground = true}
  rendering.draw_circle{surface = surface, target = center, radius = P.zone_radius, filled = true,
    color = {0.03, 0.1, 0.04, 0.1}, draw_on_ground = true}
  S.text({14, 6.4}, {"tpr-tips-sim.zone", P.zone_radius}, {scale = 0.6, font = "default", color = {0.6, 1, 0.6}})
  local a = {character = S.create("character", {-10.5, 1})}
  local b = {character = S.create("character", {7, 2}), zone = true}
  local c = {character = S.create("character", {-0.5, 2})}
  for _, u in ipairs({a, b, c}) do u.head = S.head(u.character, "") end
  a.status = S.text({-10.5, 3.8}, "", {scale = 0.7})
  b.status = S.text({7, 4.4}, "", {scale = 0.65, font = "default", color = {0.6, 1, 0.6}})
  c.status = S.text({-0.5, 4.4}, "", {scale = 0.65, font = "default", color = {0.85, 0.85, 0.85}})
  local t0
  S.stats.harm_after_mask, S.stats.harm_before_mask = 0, 0
  local function reset(t)
    t0 = t
    a.x, b.x, c.x = 70, 60, 60
    a.masked = false
    S.put_on(a.character, nil)
  end
  reset(0)
  S.on_tick(function(t)
    local s = t - t0
    if not a.masked and s >= 180 then
      a.masked = true
      S.put_on(a.character, K.respirator.name, 1)
    end
    -- left: in the smog
    local inhaled = a.masked and 0 or POLLUTION
    local rate = S.rate(inhaled, false)
    a.x = S.step(a.x, rate, 1 / 60)
    local harm = S.harm(a.x, inhaled)
    S.hurt(a.character, harm / 60)
    if a.masked then S.stats.harm_after_mask = S.stats.harm_after_mask + harm else S.stats.harm_before_mask = S.stats.harm_before_mask + harm end
    a.status.text = harm > 0 and {"tpr-tips-sim.damage", S.f1(harm * 100)} or {"tpr-tips-sim.mask-on", "[item=" .. K.respirator.name .. "]"}
    a.status.color = harm > 0 and {1, 0.4, 0.35} or {0.6, 1, 0.6}
    -- right: clean air, near and far from the working filter
    local zone = machine.status == defines.entity_status.working
    S.stats.zone = S.stats.zone or zone
    for _, u in ipairs({b, c}) do
      local r = S.rate(0, u.zone and zone)
      u.x = S.step(u.x, r, 1 / 60)
      u.status.text = {u.zone and "tpr-tips-sim.near" or "tpr-tips-sim.far", S.f1(-r)}
      if u.x <= 0 and not u.done then u.done = s end
    end
    S.stats.near_done, S.stats.far_done = S.stats.near_done or b.done, S.stats.far_done or c.done
    for _, u in ipairs({a, b, c}) do
      u.head.text = {"tpr-tips-sim.percent", S.int(u.x)}
      u.head.color = S.color(u.x)
    end
    if s >= 1260 then
      b.done, c.done = nil, nil
      reset(t)
    end
  end)
end)
]=], { init_update_count = 60 })

return simulations
