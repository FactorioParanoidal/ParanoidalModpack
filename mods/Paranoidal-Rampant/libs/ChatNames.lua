-- Presentation only: saved tactic/state IDs and remote results stay unchanged.
local M = {}
M.names = {
  assault = "лобовая атака", flank = "обход с фланга", probe = "разведка боем",
  feint = "отвлекающий манёвр", raider = "налёт", sapper = "подрыв",
  counterBattery = "контрбатарейный огонь", pincer = "охват клещами",
  ambush = "засада", sabotage = "диверсия", shore = "атака с воды",
  outpost = "атака аванпоста", deep = "удар в глубину базы",
  stage = "сбор у рубежа", strike = "удар", approach = "подход к цели",
  extra = "дополнительный отряд", ["follow-up"] = "последующий удар",
}
M.states = {[1] = "мир", [2] = "агрессия", [4] = "рейды", [5] = "миграция",
  [6] = "осада", [7] = "натиск", [8] = "расширение"}
function M.name(id)
  return M.names[id] or (id ~= nil and tostring(id) or "не задано")
end
function M.state(id)
  return M.states[id] or tostring(id)
end
return M
