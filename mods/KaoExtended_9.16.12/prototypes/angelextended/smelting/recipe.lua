local function ch(recipe)
  data.raw["recipe"][recipe].energy_required = data.raw["recipe"][recipe].energy_required * bobExtended.angelsSmeltingTime
end
ch("iron-ore-processing")
ch("iron-processed-processing")
ch("iron-ore-smelting")
ch("processed-iron-smelting")
ch("pellet-iron-smelting")
ch("ingot-iron-smelting")
ch("molten-iron-smelting")

ch("bauxite-ore-processing")
ch("aluminium-processed-processing")
ch("bauxite-ore-smelting")
ch("processed-aluminium-smelting")
ch("pellet-aluminium-smelting")
ch("solid-aluminium-oxide-smelting")
ch("roll-aluminium-casting")
ch("molten-aluminium-smelting")
data.raw["recipe"]["molten-aluminium-smelting"].ingredients = {{"ingot-aluminium", 3}}

ch("cobalt-ore-processing")
ch("cobalt-processed-processing")
ch("cobalt-ore-smelting")
ch("processed-cobalt-smelting")
ch("pellet-cobalt-smelting")
ch("molten-cobalt-smelting")

ch("copper-ore-processing")
ch("copper-processed-processing")
ch("copper-ore-smelting")
ch("processed-copper-smelting")
ch("pellet-copper-smelting")
ch("molten-copper-smelting")

if data.raw["recipe"]["copper-ore-processing"].ingredients[1][2] == 3 then
  data.raw["recipe"]["copper-ore-processing"].ingredients = {{"copper-ore", 6}}
end
if data.raw["recipe"]["copper-ore-smelting"].ingredients[1].amount == 3 then
  data.raw["recipe"]["copper-ore-smelting"].ingredients = {{"copper-ore", 6}}
end

ch("gold-ore-processing")
ch("gold-processed-processing")
ch("gold-ore-smelting")
ch("processed-gold-smelting")
ch("pellet-gold-smelting")
ch("molten-gold-smelting")

ch("lead-ore-processing")
ch("lead-processed-processing")
ch("lead-ore-smelting")
ch("processed-lead-smelting")
ch("pellet-lead-smelting")
ch("solid-lead-oxide-smelting")
ch("molten-lead-smelting")

ch("nickel-ore-processing")
ch("nickel-processed-processing")
ch("nickel-ore-smelting")
ch("processed-nickel-smelting")
ch("pellet-nickel-smelting")
ch("molten-nickel-smelting")

ch("silica-ore-processing")
ch("silica-processed-processing")
ch("silicon-ore-smelting")
ch("processed-silicon-smelting")
ch("pellet-silicon-smelting")
ch("molten-silicon-smelting")

ch("silver-ore-processing")
ch("silver-processed-processing")
ch("silver-ore-smelting")
ch("processed-silver-smelting")
ch("pellet-silver-smelting")
ch("molten-silver-smelting")

ch("tin-ore-processing")
ch("tin-processed-processing")
ch("tin-ore-smelting")
ch("processed-tin-smelting")
ch("pellet-tin-smelting")
ch("molten-tin-smelting")

ch("zinc-ore-processing")
ch("zinc-processed-processing")
ch("zinc-ore-smelting")
ch("processed-zinc-smelting")
ch("pellet-zinc-smelting")
ch("molten-zinc-smelting")

ch("tungsten-ore-processing")
ch("tungsten-processed-processing")
ch("tungsten-ore-smelting")
ch("processed-tungsten-smelting")
ch("pellet-tungsten-smelting")
ch("molten-tungsten-smelting")
ch("solid-tungsten-oxide-smelting")
ch("solid-ammonium-paratungstate-smelting")

ch("titanium-ore-processing")
ch("titanium-processed-processing")
ch("titanium-ore-smelting")
ch("processed-titanium-smelting")
ch("pellet-titanium-smelting")
ch("molten-titanium-smelting")
ch("liquid-titanium-tetrachloride-smelting")
data.raw["recipe"]["liquid-titanium-tetrachloride-smelting"].ingredients = 
{{type="fluid", name="liquid-titanium-tetrachloride", amount=6}}
ch("sponge-titanium-smelting")

ch("angels-iron-plate")
ch("angels-copper-plate")
ch("molten-steel-smelting")
ch("angels-steel-plate")
ch("angels-bob-aluminium-plate")
ch("angels-bob-cobalt-plate")
ch("angels-bob-gold-plate")
ch("angels-bob-lead-plate")
ch("angels-bob-nickel-plate")
ch("angels-bob-silicon-plate")
ch("angels-bob-silver-plate")
ch("angels-bob-tin-plate")
ch("angels-bob-titanium-plate")
ch("angels-bob-tungsten-plate")
ch("angels-bob-zinc-plate")

local function nilrecipe(recipe)
  data.raw["recipe"][recipe].ingredients = {}
end
local function mu(recipe, number)
  if number == nil then number  = 1 end
  local recipe_name
  if number == 2 then
    recipe_name = "angels-"..recipe.."-plate"
  else
    recipe_name = "angels-bob-"..recipe.."-plate"
  end
  local molten_name = "liquid-molten-"..recipe
  --local ingot_name = "ingot-"..recipe
  local plate_name = recipe.."-plate"
  if recipe == "silicon" then plate_name = "silicon" end
  bobmods.lib.recipe.remove_result(recipe_name, plate_name)
  nilrecipe(recipe_name)
  if number == 2 then
    bobmods.lib.recipe.add_result(recipe_name, {plate_name, 10})
    bobmods.lib.recipe.add_new_ingredient(recipe_name, {molten_name, 8})
  else
  bobmods.lib.recipe.add_result(recipe_name, {plate_name, 5})
  bobmods.lib.recipe.add_new_ingredient(recipe_name, {molten_name, 4})
  end
end

mu("iron", 2)
mu("copper", 2)
mu("steel", 2)
mu("tin")
mu("lead")
mu("zinc")
mu("titanium")
mu("tungsten")
mu("gold")
mu("silver")
mu("silicon")
mu("nickel")
mu("cobalt")
mu("aluminium")


















