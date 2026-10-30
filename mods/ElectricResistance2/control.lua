local RESISTOR = "hidden-electric-resistance"
local pole_filter = { { filter = "type", type = "electric-pole" } }

-- Сезоны NightBrightness: на Наувисе расход на столб зависит от сезона (seasons.lua) и меняется
-- ступенькой, когда NightBrightness объявляет сезон в чате (проверка раз в секунду). На других
-- поверхностях и без сезонов — значение стартовой настройки.
local SEASON_KW = require("seasons")
local BASE_KW = settings.startup["electric-resistance-power-consumption"].value
-- 2: входной лимит прототипа поднят под летние 3 кВт; старые резисторы пересоздаются один раз.
local REVISION = 2

local function nb_season()
  local api = remote.interfaces["NightBrightness"]
  if not (api and api.get_season) then return nil end
  local ok, season = pcall(remote.call, "NightBrightness", "get_season")
  if ok and SEASON_KW[season] then return season end
  return nil
end

local function kw_on(surface)
  local season = storage.season
  if season and surface.name == "nauvis" then return SEASON_KW[season] end
  return BASE_KW
end

local function set_kw(resistor, kw)
  resistor.power_usage = kw * 1000 / 60 -- Дж за тик
end

-- Скрытые столбы-спутники других модов (hidden / not-on-map: опоры эстакад, Bio Industries, Factorissimo,
-- ветряки) не часть видимой сети: резистор на них только умножал число потребителей в сети.
local skip_cache = {}
local function skipped(pole)
  local name = pole.name
  local skip = skip_cache[name]
  if skip == nil then
    local proto = pole.prototype
    skip = proto.hidden or proto.has_flag("not-on-map") or false
    skip_cache[name] = skip
  end
  return skip
end

local function add_resistor(pole)
  if not (pole and pole.valid) then return end
  if skipped(pole) then return end
  storage.poles = storage.poles or {}
  -- Скрытые столбы могут удаляться скриптом без события script_raised_destroy.
  storage.poles[script.register_on_object_destroyed(pole)] = {
    surface = pole.surface,
    position = pole.position,
  }
  -- защита от дубля (fast-replace / повторные события)
  local existing = pole.surface.find_entity(RESISTOR, pole.position)
  if existing then
    set_kw(existing, kw_on(pole.surface))
    return
  end
  local r = pole.surface.create_entity {
    name = RESISTOR,
    position = pole.position,
    force = pole.force,
    create_build_effect_smoke = false,
  }
  if r then
    r.destructible = false
    set_kw(r, kw_on(pole.surface))
  end
end

local function remove_resistor(pole)
  if not (pole and pole.valid) then return end
  local r = pole.surface.find_entity(RESISTOR, pole.position)
  if r then r.destroy() end
end

local function on_built(event) add_resistor(event.entity) end
local function on_removed(event) remove_resistor(event.entity) end

script.on_event(defines.events.on_built_entity, on_built, pole_filter)
script.on_event(defines.events.on_robot_built_entity, on_built, pole_filter)
script.on_event(defines.events.script_raised_built, on_built, pole_filter)
script.on_event(defines.events.script_raised_revive, on_built, pole_filter)

script.on_event(defines.events.on_player_mined_entity, on_removed, pole_filter)
script.on_event(defines.events.on_robot_mined_entity, on_removed, pole_filter)
script.on_event(defines.events.on_entity_died, on_removed, pole_filter)
script.on_event(defines.events.script_raised_destroy, on_removed, pole_filter)

script.on_event(defines.events.on_object_destroyed, function(event)
  local pole = storage.poles[event.registration_number]
  if not pole then return end
  storage.poles[event.registration_number] = nil
  if not pole.surface.valid then return end
  -- Событие приходит с задержкой: на этом месте уже может стоять замена столба.
  if pole.surface.count_entities_filtered { type = "electric-pole", position = pole.position, limit = 1 } > 0 then
    return
  end
  local r = pole.surface.find_entity(RESISTOR, pole.position)
  if r then r.destroy() end
end)

-- Полная пересборка: сносим все резисторы и создаём заново актуальным прототипом.
-- energy_source (буфер/потребление) фиксируется у сущности при создании — при смене
-- настройки consumption старые резисторы иначе остались бы на прежнем значении.
-- Срабатывает на on_init и on_configuration_changed (в т.ч. при смене startup-настроек).
local function resync()
  storage.poles = {}
  storage.season = nb_season()
  storage.revision = REVISION
  for _, surface in pairs(game.surfaces) do
    for _, r in pairs(surface.find_entities_filtered { name = RESISTOR }) do
      r.destroy()
    end
    for _, pole in pairs(surface.find_entities_filtered { type = "electric-pole" }) do
      add_resistor(pole)
    end
  end
end

-- Смена сезона: один проход по резисторам Наувиса.
local function apply_season()
  local surface = game.surfaces.nauvis
  if not surface then return end
  local kw = kw_on(surface)
  for _, r in pairs(surface.find_entities_filtered { name = RESISTOR }) do set_kw(r, kw) end
end

script.on_init(resync)
script.on_configuration_changed(resync)

script.on_nth_tick(60, function()
  if storage.revision ~= REVISION then return resync() end
  local season = nb_season()
  if season ~= storage.season then
    storage.season = season
    apply_season()
  end
end)

-- Только чтение: строка сезона EvoUI показывает расход сезона по запросу игрока.
remote.add_interface("ElectricResistance2", {
  get_season_kw = function(season) return SEASON_KW[season] end,
  get_kw = function(surface_index)
    local surface = game.get_surface(surface_index or "nauvis")
    return surface and kw_on(surface) or BASE_KW
  end,
})
