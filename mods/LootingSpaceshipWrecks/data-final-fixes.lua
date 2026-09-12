-- Restore the electronics capability Bob 1.1 added to crafting assemblers.
if not data.raw["recipe-category"].electronics then return end

local categories = data.raw["assembling-machine"]["salvaged-assembling-machine"].crafting_categories
for _, category in ipairs(categories) do
  if category == "electronics" then return end
end
categories[#categories + 1] = "electronics"
