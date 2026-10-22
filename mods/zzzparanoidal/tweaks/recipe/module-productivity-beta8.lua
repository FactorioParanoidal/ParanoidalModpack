-- These renamed recipes were in both Beta 8 productivity whitelists.
-- Apply after the generated module integration; leave hidden solder, unlocks,
-- ingredients, outputs and maximum_productivity unchanged.
local categories = { "productivity", "raw-productivity", "god" }
for _, name in ipairs({
    "bob-silicon-wafer",
    "clowns-thorium-mixed-oxide",
    "angels-liquid-plastic-bio",
    "angels-liquid-plastic-bio-1",
    "angels-liquid-resin-bio",
    "angels-liquid-rubber-bio",
    "barrel",
    "lithium-plate",
}) do
    local recipe = data.raw.recipe[name]
    if recipe then
        recipe.allow_productivity = true
        -- A missing category filter already permits all categories.
        if recipe.allowed_module_categories then
            local allowed = table.deepcopy(recipe.allowed_module_categories)
            for _, category in ipairs(categories) do
                local present = false
                for _, existing in ipairs(allowed) do
                    if existing == category then present = true; break end
                end
                if not present and data.raw["module-category"][category] then
                    allowed[#allowed + 1] = category
                end
            end
            table.sort(allowed)
            recipe.allowed_module_categories = allowed
        end
    end
end

-- Сортировки Clowns используют разрешения соответствующих Angel/zzz-рецептов.
if mods["Clowns-Extended-Minerals"] then
    local function match_sorting_modules(recipe_name, reference_name)
      local recipe = data.raw.recipe[recipe_name]
      local reference = data.raw.recipe[reference_name]
      if not recipe or recipe.hidden or not reference then return end

      recipe.allow_productivity = reference.allow_productivity
      recipe.allowed_module_categories = reference.allowed_module_categories
        and table.deepcopy(reference.allowed_module_categories) or nil
      recipe.maximum_productivity = reference.maximum_productivity
    end

    for i = 1, 9 do
      for _, stage in ipairs({ "crushed", "chunk", "crystal", "pure" }) do
        match_sorting_modules("clowns-ore" .. i .. "-" .. stage .. "-processing",
          "angels-ore1-" .. stage .. "-processing")
      end
    end

    for i = 11, 15 do
      for _, stage in ipairs({ "crushed", "powder", "dust", "crystal" }) do
        match_sorting_modules("clownsore" .. i .. "-" .. stage .. "-processing",
          "angels-ore8-" .. stage .. "-processing")
      end
    end

    local sorting_module_references = {
      ["clowns-crushed-mix1-processing"] = "angels-ore-crushed-mix1-processing",
      ["clowns-crushed-mix2-processing"] = "angels-ore-crushed-mix2-processing",
      ["clowns-crushed-mix3-processing"] = "angels-ore-crushed-mix4-processing",
      ["clowns-crushed-mix4-processing"] = "angels-ore-crushed-mix3-processing",
      ["clowns-crushed-mix5-processing"] = "angelsore-crushed-manganese-processing",
      ["clowns-crushed-mix6-processing"] = "angels-ore-crushed-mix1-processing",
      ["clowns-chunk-mix1-processing"] = "angels-ore-chunk-mix6-processing",
      ["clowns-chunk-mix2-processing"] = "angels-ore-chunk-mix1-processing",
      ["clowns-chunk-mix3-processing"] = "angels-ore-chunk-mix2-processing",
      ["clowns-chunk-mix4-processing"] = "angels-ore-chunk-mix4-processing",
      ["clowns-chunk-mix5-processing"] = "angels-ore-chunk-mix3-processing",
      ["clowns-chunk-mix6-processing"] = "angels-ore-chunk-mix5-processing",
      ["clowns-crystal-mix1-processing"] = "angels-ore-crystal-mix3-processing",
      ["clowns-crystal-mix2-processing"] = "angels-ore-crystal-mix2-processing",
      ["clowns-crystal-mix3-processing"] = "angels-ore-crystal-mix1-processing",
      ["clowns-crystal-mix4-processing"] = "angels-ore-crystal-mix5-processing",
      ["clowns-crystal-mix5-processing"] = "angels-ore-crystal-mix1-processing",
      ["clowns-pure-mix1-processing"] = "angels-ore-pure-mix1-processing",
      ["clowns-pure-mix2-processing"] = "angels-ore-crystal-mix6-processing",
      ["clowns-pure-mix3-processing"] = "angelsore-pure-chrome-processing",
      ["clowns-pure-mix4-processing"] = "angelsore-pure-platinum-processing",
      ["clowns-pure-mix5-processing"] = "angels-ore-pure-mix1-processing",
      ["angels-manganese-pure-processing"] = "angelsore-crushed-manganese-processing",
      ["clowns-phosphorus-pure-processing"] = "angels-ore-crushed-mix1-processing",
      ["angels-chrome-pure-processing"] = "angelsore-pure-chrome-processing",
      ["clowns-magnesium-pure-processing"] = "angels-ore-chunk-mix2-processing",
      ["clowns-platinum-pure-processing"] = "angelsore-pure-platinum-processing",
      ["clowns-osmium-pure-processing"] = "angels-ore-pure-mix1-processing",
      ["angels-thorium-pure-processing"] = "angels-ore-crystal-mix6-processing",
    }
    for recipe_name, reference_name in pairs(sorting_module_references) do
      match_sorting_modules(recipe_name, reference_name)
    end
end
