local RESISTOR = "hidden-electric-resistance"
local pole_filter = { { filter = "type", type = "electric-pole" } }

-- Сезоны NightBrightness: на Наувисе расход на столб зависит от сезона (seasons.lua) и меняется
-- ступенькой, когда NightBrightness объявляет сезон в чате (проверка раз в секунду). На других
-- поверхностях и без сезонов — значение стартовой настройки.
local SEASON_KW = require("seasons")
local BASE_KW = settings.startup["electric-resistance-power-consumption"].value
-- 3: записи хранят сам потребитель; пересборка также убирает остатки от прежних сдвигов.
local REVISION = 3

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

local function sync_resistor(pole)
  if storage.revision ~= REVISION or not (pole and pole.valid) or skipped(pole) then return end
  -- Регистрация остаётся той же при сдвиге и позволяет привязать нагрузку к столбу, а не к клетке.
  local id = script.register_on_object_destroyed(pole)
  local surface, position = pole.surface, pole.position
  local r = storage.poles[id]
  if r and r.valid then
    local old = r.position
    if r.surface ~= surface or ((old.x ~= position.x or old.y ~= position.y)
        and not r.teleport(position, nil, false, false)) then
      r.destroy()
      r = nil
    end
  else
    r = nil
  end
  if not r then
    r = surface.create_entity {
      name = RESISTOR,
      position = position,
      force = pole.force,
      snap_to_grid = false,
      create_build_effect_smoke = false,
    }
    if r then r.destructible = false end
  end
  storage.poles[id] = r
  if r then
    if r.force ~= pole.force then r.force = pole.force end
    set_kw(r, kw_on(surface))
  end
end

local function remove_resistor(id)
  if storage.revision ~= REVISION then return end
  local r = storage.poles[id]
  storage.poles[id] = nil
  if r and r.valid then r.destroy() end
end

local function on_built(event) sync_resistor(event.entity) end
local function on_removed(event)
  local pole = event.entity
  if pole and pole.valid and not skipped(pole) then remove_resistor(script.register_on_object_destroyed(pole)) end
end

script.on_event(defines.events.on_built_entity, on_built, pole_filter)
script.on_event(defines.events.on_robot_built_entity, on_built, pole_filter)
script.on_event(defines.events.script_raised_built, on_built, pole_filter)
script.on_event(defines.events.script_raised_revive, on_built, pole_filter)
-- Dollies teleports several times for checks, but raises this event only on the final successful move.
script.on_event(defines.events.script_raised_teleported, on_built, pole_filter)
script.on_event(defines.events.on_entity_cloned, function(event)
  local entity = event.destination
  if not (entity and entity.valid) then return end
  if entity.name == RESISTOR then
    entity.destroy() -- area cloning can copy both members in either order; the pole owns its load
  else
    sync_resistor(entity)
  end
end, {{filter = "type", type = "electric-pole"}, {filter = "name", name = RESISTOR}})

script.on_event(defines.events.on_player_mined_entity, on_removed, pole_filter)
script.on_event(defines.events.on_robot_mined_entity, on_removed, pole_filter)
script.on_event(defines.events.on_entity_died, on_removed, pole_filter)
script.on_event(defines.events.script_raised_destroy, on_removed, pole_filter)

script.on_event(defines.events.on_object_destroyed, function(event)
  remove_resistor(event.registration_number)
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
      sync_resistor(pole)
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
