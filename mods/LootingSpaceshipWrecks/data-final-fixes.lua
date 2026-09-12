-- Bob 1.1 added these categories to every crafting assembler. Bob 2.0 no
-- longer does so; keep the salvaged assembler's Beta 8 electronics capability.
local assembler = data.raw["assembling-machine"]["salvaged-assembling-machine"]
for _, category in ipairs({"crafting-machine", "electronics", "electronics-machine"}) do
  if data.raw["recipe-category"][category] then
    local found = false
    for _, existing in ipairs(assembler.crafting_categories) do
      if existing == category then found = true; break end
    end
    if not found then table.insert(assembler.crafting_categories, category) end
  end
end
