-- Registry of legendary ruin kinds. Order = order in the journal and the README.
local NAMES = {
  -- trials: beaten by skill with early gear; rewards help from the start
  "labyrinth", "minesweeper", "pyramid", "searchlight", "dune", "gates", "crypt", "mirrors", "frozen",
  "bazaar", "forge",
  -- citadels: need green-science weapons; rewards for the green-science era
  "colosseum", "hive", "director", "reactor", "oilfield", "quarantine", "hammer", "mothership",
  "observatory", "yggdrasil", "cemetery",
}

local list, by_name = {}, {}
for _, name in ipairs(NAMES) do
  local kind = require("legendary.kinds." .. name)
  assert(kind.name == name, "имя типа legendary не совпадает: " .. name)
  assert(kind.size % 32 == 0, "размер типа legendary должен быть кратен 32: " .. name)
  list[#list + 1] = kind
  by_name[name] = kind
end

return { list = list, by_name = by_name }
