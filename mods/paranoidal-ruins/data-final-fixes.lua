-- Legendary ruins: relics take the final categories / science packs of the buildings they copy,
-- after the other mods have extended those buildings.
local function union(...)
  local seen, out = {}, {}
  for _, list in ipairs({ ... }) do
    for _, v in ipairs(list or {}) do
      if not seen[v] then
        seen[v] = true
        out[#out + 1] = v
      end
    end
  end
  return out
end

local function get(type_name, name) return data.raw[type_name] and data.raw[type_name][name] end

local daedalus = get("assembling-machine", "pd-relic-daedalus-workshop")
local am2 = get("assembling-machine", "assembling-machine-2")
if daedalus and am2 then daedalus.crafting_categories = union(am2.crafting_categories) end

local forge = get("furnace", "pd-relic-hephaestus-forge")
if forge then
  local stone, steel = get("furnace", "stone-furnace"), get("furnace", "steel-furnace")
  forge.crafting_categories = union(stone and stone.crafting_categories, steel and steel.crafting_categories, forge.crafting_categories)
end

local archive, lab = get("lab", "pd-relic-archive"), get("lab", "lab")
if archive and lab then archive.inputs = union(lab.inputs) end

local drill = get("mining-drill", "pd-relic-deep-drill")
if drill then
  local electric, area = get("mining-drill", "electric-mining-drill"), get("mining-drill", "bob-area-mining-drill-1")
  drill.resource_categories = union(electric and electric.resource_categories, area and area.resource_categories, drill.resource_categories)
  -- No spoiler in the "Mined by" list of every ore tooltip.
  drill.hidden = true
end

-- Relics are found only in legendary ruins: report a recipe that makes one (another mod).
for name, recipe in pairs(data.raw.recipe) do
  for _, result in pairs(recipe.results or {}) do
    if type(result) == "table" and type(result.name) == "string" and result.name:find("^pd%-relic%-") then
      log("[legendary] warning: recipe " .. name .. " produces relic " .. result.name)
    end
  end
end

-- No spoilers before contact: the relics (items, buildings, their recipes and categories) are hidden
-- in the Factoriopedia, which shows them from the start of the game.
for _, protos in pairs(data.raw) do
  for name, proto in pairs(protos) do
    if type(name) == "string" and name:find("^pd%-relic%-") then proto.hidden_in_factoriopedia = true end
  end
end
