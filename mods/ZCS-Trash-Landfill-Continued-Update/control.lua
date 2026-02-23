-- ZCS Trash Landfill - control.lua (Factorio 2.0)

local TICKS_PER_SECOND = 60
local INV_TYPE = defines.inventory.chest
local ENTITY_NAME = "zcs-trash-landfill"

-- =============== Settings =================

local function read_settings()
  local s = settings.global
  local seconds = (s["zcs_trash_period_seconds"] and s["zcs_trash_period_seconds"].value) or 60
  local ppi     = (s["zcs_trash_pollution_per_item"] and s["zcs_trash_pollution_per_item"].value) or 0.02
  local expo    = (s["zcs_trash_pollution_exponent"] and s["zcs_trash_pollution_exponent"].value) or 1.35
  local cap     = (s["zcs_trash_pollution_cap"] and s["zcs_trash_pollution_cap"].value) or 100.0

  storage.cfg = storage.cfg or {}
  storage.cfg.consume_period_ticks = math.max(1, math.floor(seconds * TICKS_PER_SECOND))
  storage.cfg.pollution_per_item   = ppi
  storage.cfg.exponent             = math.max(1.0, expo)
  storage.cfg.cap                  = math.max(0.0, cap)   -- 0 = sin límite
end

local function pollution_per_item(name)
  local base = (storage.cfg and storage.cfg.pollution_per_item) or 0.02
  local o = storage.POLLUTION_OVERRIDES and storage.POLLUTION_OVERRIDES[name]
  return o or base
end

local function period_ticks()
  return (storage.cfg and storage.cfg.consume_period_ticks) or (60 * TICKS_PER_SECOND)
end

-- =============== Registro / Desregistro =================

local function register_landfill(entity, now_tick)
  if not (entity and entity.valid and entity.name == ENTITY_NAME) then return end
  storage.landfills = storage.landfills or {}
  local u = entity.unit_number
  local now = now_tick or game.tick
  storage.landfills[u] = {
    unit = u,
    entity = entity, -- referencia directa, más fiable
    pos = { x = entity.position.x, y = entity.position.y },
    surface_index = entity.surface.index,
    slot_index = 1,
    start_tick = now,
    next_tick = now + period_ticks()
  }
end

local function unregister_landfill_entity(entity)
  if storage.landfills and entity and entity.valid and entity.unit_number then
    storage.landfills[entity.unit_number] = nil
  end
end

local function unregister_landfill_by_unit(unit_number)
  if storage.landfills and unit_number then
    storage.landfills[unit_number] = nil
  end
end

-- Repara una entrada cuya entity quedó inválida: intenta reencontrarla por posición
local function try_recover_entity(data)
  if not data then return nil end
  local surface = game.surfaces[data.surface_index]
  if not surface then return nil end
  local ent = surface.find_entity(ENTITY_NAME, data.pos)
  if ent and ent.valid then
    data.entity = ent
    return ent
  end
  return nil
end

-- Vuelve a indexar todo lo colocado en el mapa (para on_init/config-change)
local function repopulate_from_world()
  storage.landfills = storage.landfills or {}
  local count = 0
  for _, surface in pairs(game.surfaces) do
    local list = surface.find_entities_filtered { name = ENTITY_NAME }
    for _, e in pairs(list) do
      if e and e.valid then
        register_landfill(e)
        count = count + 1
      end
    end
  end
  return count
end

-- =============== Lifecycle =================

script.on_init(function()
  storage.landfills = storage.landfills or {}
  storage.POLLUTION_OVERRIDES = storage.POLLUTION_OVERRIDES or {}
  read_settings()
  repopulate_from_world()
end)

script.on_configuration_changed(function()
  storage.landfills = storage.landfills or {}
  storage.POLLUTION_OVERRIDES = storage.POLLUTION_OVERRIDES or {}
  read_settings()
  repopulate_from_world()
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(e)
  if e.setting == "zcs_trash_period_seconds"
     or e.setting == "zcs_trash_pollution_per_item"
     or e.setting == "zcs_trash_pollution_exponent"
     or e.setting == "zcs_trash_pollution_cap" then
    local old_period = period_ticks()
    read_settings()
    -- Ajusta todos los timers para evitar “quedar colgados” tras cambiar periodo
    local new_period = period_ticks()
    if storage.landfills then
      local now = game.tick
      for _, d in pairs(storage.landfills) do
        if d and d.next_tick and d.start_tick then
          -- re-ancora el ciclo al now manteniendo el progreso (opcional: simple reset)
          local span = math.max(1, d.next_tick - d.start_tick)
          local elapsed = math.min(span, math.max(0, now - d.start_tick))
          local p = elapsed / span
          d.start_tick = now
          d.next_tick  = now + math.max(1, math.floor(new_period * (1 - p)))
        end
      end
    end
  end
end)

-- Construcción (jugador/robot/raised/clon)
script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity, defines.events.script_raised_built, defines.events.on_entity_cloned}, function(e)
  local ent = e.created_entity or e.entity or e.destination
  register_landfill(ent)
end)

-- Remoción / muerte / raised-destroy / mined-pre
script.on_event({defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity, defines.events.on_entity_died, defines.events.script_raised_destroy}, function(e)
  local ent = e.entity
  if ent and ent.valid and ent.name == ENTITY_NAME then
    unregister_landfill_entity(ent)
  end
end)

-- =============== Loop principal =================

script.on_nth_tick(60, function()
  if not storage.landfills then return end
  local tick = game.tick
  local PERIOD = period_ticks()

  for unit, data in pairs(storage.landfills) do
    -- Sanea referencias inválidas
    local ent = (data and data.entity and data.entity.valid) and data.entity or try_recover_entity(data)
    if not (ent and ent.valid) then
      unregister_landfill_by_unit(unit)
    else
      -- Inicializa timers faltantes (por si viniera de save viejo)
      if not data.start_tick then data.start_tick = tick end
      if not data.next_tick  then data.next_tick  = tick + PERIOD end

      if data.next_tick <= tick then
        local inv = ent.get_inventory(INV_TYPE)
        if inv and inv.valid then
          local size = #inv
          if size > 0 then
            if (not data.slot_index) or data.slot_index < 1 or data.slot_index > size then
              data.slot_index = 1
            end

            local stack = inv[data.slot_index]
            if stack and stack.valid_for_read then
              -- Fórmula exponencial con cap
              local base = pollution_per_item(stack.name)
              local exp  = (storage.cfg and storage.cfg.exponent) or 1.35
              local cap  = (storage.cfg and storage.cfg.cap) or 100.0

              local total = base * (stack.count ^ exp)
              if cap > 0 then total = math.min(total, cap) end

              stack.clear()
              ent.surface.pollute(ent.position, total)
            end

            -- avanza al siguiente slot, reajusta si cambió el tamaño
            data.slot_index = data.slot_index + 1
            if data.slot_index > size then data.slot_index = 1 end
          else
            -- inventario vacío: normaliza índice
            data.slot_index = 1
          end
        end
        -- reprograma ciclo
        data.start_tick = tick
        data.next_tick  = tick + PERIOD
      end
    end
  end
end)
