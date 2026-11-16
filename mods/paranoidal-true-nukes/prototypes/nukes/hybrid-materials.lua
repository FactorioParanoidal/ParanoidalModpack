local nuke_materials = require("prototypes.nukes.data-nukes-material")

-- Paranoidal 9.0.0, hybrid materials (user decision 2026-11-15): californium is bred from the curium and
-- americium of MOX reprocessing (Angels) instead of being centrifuged out of uranium, tritium is bred from
-- lithium instead of iron. Without those items the True Nukes recipes stay.
-- In data-final-fixes: Angels defines curium and americium after the data stage of this mod.
local function item(name) return data.raw.item[name] ~= nil end
local function ing(name, amount) return {type = "item", name = name, amount = amount} end
if item("angels-curium-245") and item("angels-americium-241") then
  local r = data.raw.recipe["californium-processing"]
  if r then
    r.ingredients = {ing("angels-curium-245", 1), ing("angels-americium-241", 1), ing("uranium-238", 10)}
    r.results = {{type = "item", name = "californium", amount = 10}}
  end
  r = data.raw.recipe["advanced-californium-processing"]
  if r then
    r.ingredients = {ing("angels-curium-245", 1), ing("angels-americium-241", 1), ing("uranium-238", 10), ing(nuke_materials.reflector, 2)}
    r.results = {{type = "item", name = "californium", amount = 20}, {type = "item", name = nuke_materials.reflector, amount = 1},
      {type = "item", name = nuke_materials.reflector, amount = 1, independent_probability = 0.6}}
    r.energy_required = 60
  end
end
if item("lithium-plate") then
  for _, name in pairs({"tritium-breeder-fuel-cell", "advanced-tritium-breeder-fuel-cell"}) do
    local r = data.raw.recipe[name]
    for _, i in pairs(r and r.ingredients or {}) do
      if i.name == "iron-plate" then i.name = "lithium-plate" end
    end
  end
end

-- Hybrid materials (9.0.0): curium/americium come from MOX reprocessing, lithium from Bob's lithium processing
local function add_prerequisite(tech, prerequisite)
  local t = data.raw.technology[tech]
  if t and data.raw.technology[prerequisite] then
    t.prerequisites = t.prerequisites or {}
    table.insert(t.prerequisites, prerequisite)
  end
end
local function uses(recipe, name)
  for _, i in pairs(data.raw.recipe[recipe] and data.raw.recipe[recipe].ingredients or {}) do
    if i.name == name then return true end
  end
  return false
end
if uses("californium-processing", "angels-curium-245") then add_prerequisite("californium-processing", "mixed-oxide-fuel") end
if uses("tritium-breeder-fuel-cell", "lithium-plate") then add_prerequisite("tritium-processing", "bob-lithium-processing") end

-- Paranoidal: Clowns switch Kovarex enrichment off (its unlocks go to MOX fuel), so the weapons that needed it could
-- never be researched. They need MOX fuel instead, as Clowns do for Bob's fission equipment.
local kovarex = data.raw.technology["kovarex-enrichment-process"]
if kovarex and kovarex.enabled == false then
  local replacement = data.raw.technology["mixed-oxide-fuel"] and "mixed-oxide-fuel" or nil
  for _, name in pairs({"expanded-atomics", "artillery-atomics", "californium-processing", "californium-weapons",
      "compact-full-fission-weapons"}) do
    local t = data.raw.technology[name]
    if t and t.prerequisites then
      local list, present = {}, {}
      for _, prerequisite in pairs(t.prerequisites) do
        if prerequisite == "kovarex-enrichment-process" then prerequisite = replacement end
        if prerequisite and not present[prerequisite] then
          present[prerequisite] = true
          list[#list + 1] = prerequisite
        end
      end
      t.prerequisites = list
    end
  end
end
