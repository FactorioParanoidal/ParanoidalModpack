if data.raw["lab"]["neural_computer"] then
  data.raw["lab"]["neural_computer"].inputs =
  {
    --"datacell-empty",
    "datacell-raw-data",
    "datacell-equation",
    "datacell-ai-model-data",
    "datacell-solved-equation",
    "datacell-cosmic-data-outsignal",
    "datacell-cosmic-data",
  }
end

-- fix for potential other mods adding ingredients to all techs

local function add_tech_unit(tech, count, time, ingredients)
  if data.raw["technology"][tech] and count and time and ingredients then
    data.raw["technology"][tech].unit =
    {
      count = count,
      ingredients = ingredients,
      time = time,
    }
  end
end


add_tech_unit("moshine-tech-cosmic-data-outsignal-creation",   50, 80,         {{"datacell-raw-data", 1},{"datacell-ai-model-data", 1},{"datacell-solved-equation", 1},} )
add_tech_unit("moshine-tech-cosmicscanner-construction3",      375, 60,         {{"datacell-equation", 1}} )
add_tech_unit("moshine-tech-cosmicscanner-construction4",      450, 80,         {{"datacell-raw-data", 1}, {"datacell-solved-equation", 1},} )
add_tech_unit("moshine-tech-cosmicscanner-construction5",      500, 300,         {{"datacell-raw-data", 1}, {"datacell-ai-model-data", 1}, {"datacell-solved-equation", 1}, {"datacell-cosmic-data-outsignal", 1},} )

add_tech_unit("moshine-tech-data-extractor",      40, 60,         {{"datacell-equation", 1}} )
add_tech_unit("moshine-tech-3d-data-storage",     200, 60,        {{"datacell-raw-data", 1}} )
add_tech_unit("moshine-tech-data-processor",      1000, 10,       {{"datacell-raw-data", 1},{"datacell-equation", 1}} )
add_tech_unit("moshine-tech-ai-trainer",          50, 80,         {{"datacell-raw-data", 1}, {"datacell-ai-model-data", 1}} )
add_tech_unit("moshine-tech-processing-grid",     100, 100,       {{"datacell-raw-data", 10},{"datacell-ai-model-data", 1}} )
add_tech_unit("moshine-tech-ai-tier-2",           10, 2*500,      {{"datacell-raw-data", 1}, {"datacell-equation", 1}} )
add_tech_unit("big-solar-energy",                 13, 3*500,      {{"datacell-raw-data", 1}, {"datacell-equation", 1}, {"datacell-ai-model-data", 1}} )
add_tech_unit("moshine-tech-ai-tier-3",           15, 16*500,     {{"datacell-raw-data", 1}, {"datacell-equation", 1}, {"datacell-ai-model-data", 1}} )
add_tech_unit("moshine-tech-ai-tier-4",           20, 54*500,     {{"datacell-raw-data", 1}, {"datacell-equation", 1}, {"datacell-ai-model-data", 1}} )
add_tech_unit("snouz_better_substation_tech",     40, 27*500,     {{"datacell-raw-data", 1}, {"datacell-equation", 1}, {"datacell-ai-model-data", 1}} )
add_tech_unit("moshine-tech-ai-tier-5",           25, 128*500,    {{"datacell-raw-data", 1}, {"datacell-ai-model-data", 1},{"datacell-solved-equation", 1},} )
add_tech_unit("moshine-tech-ai-tier-6",           30, 250*500,    {{"datacell-raw-data", 1}, {"datacell-ai-model-data", 1},{"datacell-solved-equation", 1},} )
add_tech_unit("long-stack-inserter",              1000, 2.45*500, {{"datacell-raw-data", 1}, {"datacell-ai-model-data", 1},{"datacell-solved-equation", 1},{"datacell-cosmic-data-outsignal", 1}} )
add_tech_unit("moshine-tech-ai-tier-7",           35, 432*500,    {{"datacell-raw-data", 1}, {"datacell-ai-model-data", 1},{"datacell-solved-equation", 1},{"datacell-cosmic-data-outsignal", 1}} )
add_tech_unit("electric-energy-big-accumulators", 36, 437*500,    {{"datacell-raw-data", 1}, {"datacell-ai-model-data", 1},{"datacell-solved-equation", 1},{"datacell-cosmic-data-outsignal", 1}} )
add_tech_unit("moshine-tech-ai-tier-8",           40, 686*500,    {{"datacell-raw-data", 1}, {"datacell-ai-model-data", 1},{"datacell-solved-equation", 1},{"datacell-cosmic-data-outsignal", 1}} )
add_tech_unit("moshine-tech-ai-tier-9",           45, 1024*500,   {{"datacell-raw-data", 1}, {"datacell-ai-model-data", 1},{"datacell-solved-equation", 1},{"datacell-cosmic-data-outsignal", 1},{"datacell-cosmic-data", 1}} )
add_tech_unit("moshine-tech-ai-tier-10",          50, 1458*500,   {{"datacell-raw-data", 1}, {"datacell-equation", 1}, {"datacell-ai-model-data", 1},{"datacell-solved-equation", 1},{"datacell-cosmic-data-outsignal", 1},{"datacell-cosmic-data", 1}} )


if data.raw["technology"]["moshine-tech-quantum-processor-productivity"] then
  data.raw["technology"]["moshine-tech-quantum-processor-productivity"].unit =
    {
      count_formula = "1.4^L*35",
      ingredients =
      {
        {"datacell-raw-data", 1},
        {"datacell-solved-equation", 1},
        {"datacell-cosmic-data-outsignal", 1},
        {"datacell-cosmic-data", 1},
      },
      time = 6000
    }
end

-- compat omnimatter_compression
if data.raw["technology"]["omnipressed-moshine-tech-quantum-processor-productivity"] then
  data.raw["technology"]["omnipressed-moshine-tech-quantum-processor-productivity"] = nil
end


--if data.raw.recipe["moshine_cosmicscanner-construction-stage-1-recycling"] then
--  data.raw.recipe["moshine_cosmicscanner-construction-stage-1-recycling"] = nil
--end
-- Paranoidal (Space Age branch): the module category of the AI cores comes last, here (Moshine loads after the other
-- mods of the build: module-category-defaults loads after them). The build's own data stages make module lists of
-- machines and recipes from every module category of the game (Angels' snapshot, the Beta 8 modules of zzzparanoidal),
-- and with "ai-speed" among them the home machines lost Bob's and Beta 8 modules and took the AI cores. Then the
-- machines without a list get every other category (module-category-defaults), and the recipes made in machines that
-- take AI cores allow them (their lists were made without this category).
data:extend({
  {
    type = "module-category",
    name = "ai-speed"
  },
})
if ModuleCategoryDefaults then
  ModuleCategoryDefaults.process_entity_prototypes()
end
local ai_crafting = {}
for _, kind in pairs({"assembling-machine", "furnace", "rocket-silo"}) do
  for _, machine in pairs(data.raw[kind] or {}) do
    for _, category in pairs(machine.allowed_module_categories or {}) do
      if category == "ai-speed" then
        for _, crafting in pairs(machine.crafting_categories or {}) do ai_crafting[crafting] = true end
      end
    end
  end
end
for _, recipe in pairs(data.raw.recipe) do
  local list = recipe.allowed_module_categories
  if list then
    local made_there, present = false, false
    for _, crafting in pairs(recipe.categories or {"crafting"}) do
      if ai_crafting[crafting] then made_there = true end
    end
    for _, category in pairs(list) do
      if category == "ai-speed" then present = true end
    end
    if made_there and not present then table.insert(list, "ai-speed") end
  end
end
