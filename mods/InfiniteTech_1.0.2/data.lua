-- reset technologies to base
local expected_tech_ranks = {
  ["inserter-capacity-bonus"] = 7,
  ["worker-robots-storage"] = 3,
}

if not mods["boblogistics"] then
  for _,tech in pairs(data.raw["technology"]) do
    local name, rank = string.match(tech.name, "^(%D+)-(%d+)$")
    rank = tonumber(rank)
    if rank and expected_tech_ranks[name] and rank > expected_tech_ranks[name] then
      -- log("removing technology \""..tech.name.."\"")
      data.raw["technology"][tech.name] = nil
    end
  end

  require("modules.bot-capacity")
  require("modules.inserter-capacity")
end

require("modules.bot-battery")
require("modules.fixes")
