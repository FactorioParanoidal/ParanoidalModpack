-- Russian Station Names: список русских названий для Namelists.
-- Порт RussianStations 9.1.2 (Beta 8, Factorio 1.1) на Factorio 2.0.

-- stations.lua задаёт глобальную таблицу stations с названиями
require("stations")

-- Имя remote-интерфейса и функции, которые регистрируются в Namelists
local LIST_INTERFACE = script.mod_name
local LIST_FUNC = "pick_name"
-- Вес списка при смешивании с другими списками Namelists
local LIST_WEIGHT = #stations

local function pick_name(entity)
  return stations[math.random(#stations)]
end

remote.add_interface(LIST_INTERFACE, {pick_name = pick_name})

-- Тип сущности -> настройка, включающая список для этого типа
local TYPE_SETTINGS = {
  {setting = "russian-stations-roboports", target = "roboport"},
  {setting = "russian-stations-labs", target = "lab"},
  {setting = "russian-stations-stations", target = "train-stop"},
  {setting = "russian-stations-locomotives", target = "locomotive"},
  {setting = "russian-stations-radars", target = "radar"},
}

local function register_interfaces()
  if not remote.interfaces["Namelists"] then return end
  for _, entry in pairs(TYPE_SETTINGS) do
    if settings.global[entry.setting].value then
      remote.call("Namelists", "register",
        {interface = LIST_INTERFACE, func = LIST_FUNC, category = "type", target = entry.target, weight = LIST_WEIGHT})
    end
  end
  if settings.global["russian-stations-default"].value then
    remote.call("Namelists", "register",
      {interface = LIST_INTERFACE, func = LIST_FUNC, weight = LIST_WEIGHT})
  end
end

-- Namelists поднимает on_list_rebuild при on_init, on_configuration_changed и смене своих настроек.
-- Регистрация пишет в storage Namelists, поэтому в on_load выполняется только подписка на событие
-- (в оригинале регистрация вызывалась и из on_load).
local function subscribe()
  if not remote.interfaces["Namelists"] then return end
  local events = remote.call("Namelists", "get_events")
  script.on_event(events.on_list_rebuild, register_interfaces)
end

script.on_init(function()
  subscribe()
  register_interfaces()
end)
script.on_load(subscribe)

local MOD_SETTINGS = {
  ["russian-stations-roboports"] = true,
  ["russian-stations-labs"] = true,
  ["russian-stations-stations"] = true,
  ["russian-stations-locomotives"] = true,
  ["russian-stations-radars"] = true,
  ["russian-stations-default"] = true
}

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  if MOD_SETTINGS[event.setting] and remote.interfaces["Namelists"] then
    remote.call("Namelists", "rebuild")
  end
end)

-- Добавлено в порте. Namelists не переименовывает станции, поставленные вручную (не из призрака),
-- поэтому они сохраняют имя бэкера, выданное движком. Если у такой станции имя из списка бэкеров
-- игры, выбираем новое через Namelists. Имя, перенесённое из призрака/чертежа, не из списка бэкеров
-- и остаётся без изменений.
local backer_set = nil

local function is_backer_name(name)
  if not backer_set then
    backer_set = {}
    for _, backer in pairs(game.backer_names) do
      backer_set[backer] = true
    end
  end
  return backer_set[name] == true
end

script.on_event(defines.events.on_built_entity, function(event)
  local entity = event.entity
  if not (entity and entity.valid) then return end
  if not settings.global["russian-stations-stations"].value then return end
  if not remote.interfaces["Namelists"] then return end
  if not is_backer_name(entity.backer_name) then return end
  local new_name = remote.call("Namelists", "pick_name", entity)
  if new_name then
    entity.backer_name = new_name
  end
end, {{filter = "type", type = "train-stop"}})
