require("prototypes.loot")
local names = require("item-names")

-- Run after all data.lua files, when optional loot items have been registered.
for _, kind in ipairs({"container", "simple-entity-with-owner"}) do
  for name, entity in pairs(data.raw[kind]) do
    if name == "crash-site-spaceship"
      or name:match("^crash%-site%-spaceship%-wreck%-big%-[12]$")
      or name:match("^crash%-site%-spaceship%-wreck%-medium%-[123]$")
      or name:match("^crash%-site%-spaceship%-wreck%-small%-[123456]$") then
      local results = {}
      for _, result in ipairs(entity.minable.results) do
        result.name = names[result.name] or result.name
        result.type = "item"
        if data.raw.item[result.name] or data.raw.tool[result.name] then
          results[#results + 1] = result
        else
          log("LootingSpaceshipWrecks: optional mining loot unavailable: " .. result.name)
        end
      end
      entity.minable.results = results
    end
  end
end

-- Beta 8 zzzparanoidal/prototypes/micro-final-fix.lua added this pump to the hull.
if mods["zzzparanoidal"] and data.raw.item["offshore-mk0-pump"] then
  table.insert(data.raw.container["crash-site-spaceship"].minable.results,
    {type = "item", name = "offshore-mk0-pump", amount = 1})
end
