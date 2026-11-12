-- Our technologies reference prerequisites and science packs of the build; drop the ones a modset lacks
-- instead of failing to load (logged). Science packs of this build are items, not tools.
local S = require("shared")
local tools = data.raw.tool or {}
for name, tech in pairs(data.raw.technology) do
  if name:sub(1, 4) == "ppd-" then
    if tech.prerequisites then
      local keep = {}
      for _, p in ipairs(tech.prerequisites) do
        if data.raw.technology[p] then keep[#keep + 1] = p else log("ppd: prerequisite " .. p .. " missing for " .. name) end
      end
      tech.prerequisites = keep
    end
    if tech.unit and tech.unit.ingredients then
      local keep = {}
      for _, i in ipairs(tech.unit.ingredients) do
        if tools[i[1]] or data.raw.item[i[1]] then keep[#keep + 1] = i else log("ppd: science pack " .. i[1] .. " missing for " .. name) end
      end
      tech.unit.ingredients = keep
    end
  end
end
for _, t in ipairs(S.TIERS) do
  local r = data.raw.recipe[t.name]
  if r then
    local keep = {}
    for _, i in ipairs(r.ingredients) do
      if data.raw.item[i.name] then keep[#keep + 1] = i else log("ppd: ingredient " .. i.name .. " missing for " .. t.name) end
    end
    r.ingredients = keep
  end
end
