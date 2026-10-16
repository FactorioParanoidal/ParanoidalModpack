-- ZCS Trash Landfill - control.lua (Factorio 2.0)
-- Every period each landfill destroys its next non-empty slot and emits pollution.

local TICKS_PER_SECOND = 60
local CHECK_INTERVAL = 60
local INV_TYPE = defines.inventory.chest
local ENTITY_NAME = "zcs-trash-landfill"
local NAME_FILTER = {{filter = "name", name = ENTITY_NAME}}

local SETTINGS = {
  period = "zcs_trash_period_seconds",
  per_item = "zcs_trash_pollution_per_item",
  exponent = "zcs_trash_pollution_exponent",
  cap = "zcs_trash_pollution_cap",
}

-- =============== Settings =================

local function setting_value(name, default)
  local s = settings.global[name]
  return (s and s.value) or default
end

local function read_settings()
  storage.cfg = {
    consume_period_ticks = math.max(1, math.floor(setting_value(SETTINGS.period, 60) * TICKS_PER_SECOND)),
    pollution_per_item = setting_value(SETTINGS.per_item, 0.02),
    exponent = math.max(1.0, setting_value(SETTINGS.exponent, 1.35)),
    cap = math.max(0.0, setting_value(SETTINGS.cap, 100.0)), -- 0 = unlimited
  }
end

local function cfg()
  if not storage.cfg then read_settings() end
  return storage.cfg
end

-- =============== Registration =================

-- Adds a landfill; an existing record keeps its slot pointer and timer.
local function register_landfill(entity)
  if not (entity and entity.valid and entity.name == ENTITY_NAME) then return end
  storage.landfills = storage.landfills or {}
  local unit = entity.unit_number
  local data = storage.landfills[unit]
  if data then
    data.entity = entity
  else
    local now = game.tick
    storage.landfills[unit] = {
      entity = entity,
      slot_index = 1,
      start_tick = now,
      next_tick = now + cfg().consume_period_ticks,
    }
  end
  -- Covers removal without events (destroy() without raise_destroy).
  script.register_on_object_destroyed(entity)
end

local function repopulate_from_world()
  storage.landfills = storage.landfills or {}
  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered{name = ENTITY_NAME}) do
      register_landfill(entity)
    end
  end
end

local function on_built(e)
  register_landfill(e.entity or e.destination)
end

-- =============== Lifecycle =================

local function init()
  storage.landfills = storage.landfills or {}
  read_settings()
  repopulate_from_world()
end

script.on_init(init)
script.on_configuration_changed(init)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(e)
  if e.setting_type ~= "runtime-global" then return end
  if e.setting == SETTINGS.per_item or e.setting == SETTINGS.exponent or e.setting == SETTINGS.cap then
    read_settings()
  elseif e.setting == SETTINGS.period then
    read_settings()
    -- Re-anchor the timers at now, keeping the relative progress of the current cycle.
    local now = game.tick
    local new_period = storage.cfg.consume_period_ticks
    for _, d in pairs(storage.landfills or {}) do
      if d.next_tick and d.start_tick then
        local span = math.max(1, d.next_tick - d.start_tick)
        local p = math.min(span, math.max(0, now - d.start_tick)) / span
        d.start_tick = now
        d.next_tick = now + math.max(1, math.floor(new_period * (1 - p)))
      end
    end
  end
end)

script.on_event(defines.events.on_built_entity, on_built, NAME_FILTER)
script.on_event(defines.events.on_robot_built_entity, on_built, NAME_FILTER)
script.on_event(defines.events.script_raised_built, on_built, NAME_FILTER)
script.on_event(defines.events.script_raised_revive, on_built, NAME_FILTER)
script.on_event(defines.events.on_entity_cloned, on_built, NAME_FILTER)

-- Mined, died, script destroy and destroy() without raise all end here.
script.on_event(defines.events.on_object_destroyed, function(e)
  if e.type == defines.target_type.entity and storage.landfills then
    storage.landfills[e.useful_id] = nil
  end
end)

-- =============== Main loop =================

-- Returns the first non-empty slot starting at `start`, wrapping around once.
local function find_filled_slot(inv, size, start)
  for offset = 0, size - 1 do
    local i = (start + offset - 1) % size + 1
    if inv[i].valid_for_read then return i end
  end
  return nil
end

local function consume(ent, data, c)
  local inv = ent.get_inventory(INV_TYPE)
  if not (inv and inv.valid) or inv.is_empty() then return end
  local size = #inv
  local start = data.slot_index
  if not start or start < 1 or start > size then start = 1 end

  local index = find_filled_slot(inv, size, start)
  if not index then return end
  local stack = inv[index]

  local total = c.pollution_per_item * (stack.count ^ c.exponent)
  if c.cap > 0 and total > c.cap then total = c.cap end

  stack.clear()
  if total > 0 then
    ent.surface.pollute(ent.position, total, ENTITY_NAME)
  end
  data.slot_index = index % size + 1
end

script.on_nth_tick(CHECK_INTERVAL, function()
  local landfills = storage.landfills
  if not landfills then return end
  local tick = game.tick
  local c = cfg()

  for unit, data in pairs(landfills) do
    local ent = data.entity
    if not (ent and ent.valid) then
      landfills[unit] = nil
    elseif not data.next_tick then
      data.start_tick = tick
      data.next_tick = tick + c.consume_period_ticks
    elseif data.next_tick <= tick then
      consume(ent, data, c)
      data.start_tick = tick
      data.next_tick = tick + c.consume_period_ticks
    end
  end
end)
