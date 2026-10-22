-- Start, raw resources, Angels refining and smelting, Bob metals and intermediates.
-- Entry fields: see kinds.lua. name_key: one shared name "<name>: <target>" for a family.
local lib = require("prototypes.content.lib")

return lib.list(
  {id = "salvaged-assembler", kind = "build", entity = "salvaged-assembling-machine"},
  {id = "salvaged-generator", kind = "build", entity = "salvaged-generator"},
  {id = "salvaged-lab", kind = "build", entity = "salvaged-lab"},
  {id = "stone-age", kind = "produce", item = "stone", amounts = {1e6, 1e9, 1e12}},
  {id = "lumberjack", kind = "produce", item = "wood", amounts = {1e6, 1e9, 1e12}},
  {id = "stoker", kind = "produce-per-hour", item = "coal", amounts = {1e5, 1e6, 1e7}},

  lib.each({1, 2, 3, 4, 5, 6}, function(ore)
    return {id = "crushed-ore-" .. ore, kind = "produce", item = "angels-ore" .. ore .. "-crushed",
      amount = 1e6, name_key = "crushed"}
  end),
  {id = "slag", kind = "produce", item = "angels-slag", amounts = {1e6, 1e9, 1e12}},
  lib.each({"aluminium", "chrome", "cobalt", "copper", "gold", "iron", "lead", "manganese", "nickel",
    "platinum", "silica", "silver", "tin", "titanium", "tungsten", "zinc"}, function(metal)
    return {id = "pellet-" .. metal, kind = "produce", item = "angels-pellet-" .. metal,
      amount = 1e6, name_key = "pellets"}
  end),
  {id = "coke", kind = "produce", item = "angels-pellet-coke", amount = 1e6},
  {id = "platinum", kind = "produce", item = "angels-plate-platinum", amount = 1e6},
  lib.each({"aluminium", "cobalt", "gold", "lead", "nickel", "silver", "tin", "titanium", "zinc"}, function(metal)
    return {id = "element-" .. metal, kind = "produce", item = "bob-" .. metal .. "-plate",
      amount = 1e6, name_key = "mendeleev"}
  end),
  lib.each({"ruby", "sapphire", "emerald", "amethyst", "topaz", "diamond"}, function(gem)
    return {id = "gem-" .. gem, kind = "produce", item = "bob-" .. gem .. "-5", amount = 1e4, name_key = "jeweler"}
  end),
  {id = "solder", kind = "produce", item = "bob-solder", amount = 1e6},
  {id = "silicon-valley", kind = "produce", item = "bob-silicon-wafer", amounts = {1e6, 1e9}},
  lib.each({"basic-circuit-board", "circuit-board", "superior-circuit-board", "multi-layer-circuit-board"},
    function(board)
      return {id = "board-" .. board, kind = "produce", item = "bob-" .. board, amount = 1e6, name_key = "boards"}
    end),
  lib.each({"hydrogen", "chlorine", "nitrogen", "oxygen"}, function(gas)
    return {id = "gas-" .. gas, kind = "produce", fluid = "angels-gas-" .. gas, amount = 1e9, name_key = "gas-giant"}
  end),
  lib.each({"bob-advanced-logistic-science-pack", "bob-science-pack-gold", "bob-alien-science-pack",
    "bob-alien-science-pack-red", "bob-alien-science-pack-orange", "bob-alien-science-pack-yellow",
    "bob-alien-science-pack-green", "bob-alien-science-pack-blue", "bob-alien-science-pack-purple"}, function(pack)
    return {id = "science-" .. pack:gsub("^bob%-", ""), kind = "produce", item = pack,
      amounts = {1e6, 1e9, 1e12}, name_key = "bob-science"}
  end)
)
