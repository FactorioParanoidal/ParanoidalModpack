-- Restore the electronics capability Bob 1.1 added to crafting assemblers.
if data.raw["recipe-category"].electronics then
  local categories = data.raw["assembling-machine"]["salvaged-assembling-machine"].crafting_categories
  local found = false
  for _, category in ipairs(categories) do
    if category == "electronics" then found = true end
  end
  if not found then categories[#categories + 1] = "electronics" end
end

-- Paranoidal: the character swings the pickaxe only at simple-entity prototypes. Each small wreck
-- gets a simple-entity twin with the same look and loot; control.lua swaps a wreck for its twin
-- when a player selects it. The originals stay, because freeplay's crash site destroys every
-- simple-entity next to a freshly placed part.
local small_wrecks = data.raw["simple-entity-with-owner"]
for index = 1, 6 do
  local wreck = small_wrecks["crash-site-spaceship-wreck-small-" .. index]
  if wreck then
    local twin = table.deepcopy(wreck)
    twin.type = "simple-entity"
    twin.name = wreck.name .. "-salvage"
    twin.localised_name = twin.localised_name or {"entity-name.crash-site-spaceship-wreck-small"}
    data:extend({twin})
  end
end
