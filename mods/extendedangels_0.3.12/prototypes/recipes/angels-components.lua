--final fixes of angels to squeeze in a new construction tier material
local OV = angelsmods.functions.OV
--set local table for use in multiple functions
local building_types = {
  "assembling-machine",
  "mining-drill",
  "lab",
  "furnace",
  "offshore-pump",
  "pump",
  "rocket-silo",
  "radar",
  "beacon",
  "boiler",
  "generator",
  "solar-panel",
  "accumulator",
  "reactor",
  "electric-pole",
  "wall",
  "gate"
}
local block_ingredients={
  ["block-construction-0"]={new="stone",old="stone"},
  ["block-construction-1"]={new="stone-brick",old="stone"},
  ["block-construction-2"]={new="clay-brick",old="stone-brick"},
  ["block-construction-3"]={new="concrete-brick",old="clay-brick"},
  ["block-construction-4"]={new="reinforced-concrete-brick",old="concrete-brick"},
  ["block-construction-5"]={new="titanium-concrete-brick",old="reinforced-concrete-brick"}
}
data:extend(
{
  {
    type = "item",
    name = "block-construction-0", -- required at start
    icon = "__angelsindustries__/graphics/icons/block-construction-1.png",
    icon_size = 32,
    subgroup = "blocks-frames",
    order = "a",
    stack_size = 200,
  },
  {
    type = "recipe",
    name = "block-construction-0",
    enabled = true,
    category = "crafting",
    energy_required = 5,
    ingredients =
    {
      {type="item", name = "construction-frame-1", amount = 1},
      {type="item", name = "stone", amount = 3},
    },
    results=
    {
      {type="item", name="block-construction-0", amount=1},
    },
    icon_size = 32,
  },
})
local change_con_block_ingredients=function()
  for block,list in pairs(block_ingredients) do
    local ing_list=data.raw.recipe[block].ingredients
    if ing_list==nil then
      ing_list=data.raw.recipe[block].normal.ingredients
    end
    for n,_ in pairs(ing_list) do
      if ing_list[n].name == list.old then
        ing_list[n].name = list.new
      end
    end
   -- For Logging
   -- log(serpent.block(ing_list))
  end
end

--specifically build to be used for replace_con_mats function
local shuffle_blocks_list=function(ing_list)
  for n,_ in pairs(ing_list) do
    --block shuffle down
    if ing_list[n].name == "block-construction-1" then
      ing_list[n].name = "block-construction-0"
    end
    if ing_list[n].name == "block-construction-2" then
      ing_list[n].name = "block-construction-1"
    end
    if ing_list[n].name == "block-construction-3" then
      ing_list[n].name = "block-construction-2"
    end
    if ing_list[n].name == "block-construction-4" then
      ing_list[n].name = "block-construction-3"
    end
    if ing_list[n].name == "block-construction-5" then
      ing_list[n].name = "block-construction-4"
    end
    if ing_list[n].name == "titanium-concrete-brick" then
      ing_list[n].name = "block-construction-5"
    end
  end
end
--ADD BUILDING BLOCKS TO BUILDINGS
function rep_con_mats()
  for n,_ in pairs(building_types) do
    shuffle_con_mats(building_types[n])
  end
end
--REPLACE CONSTRUCTION BLOCKS
function shuffle_con_mats(buildings)
  for assembly_check, build in pairs(data.raw[buildings]) do
    if data.raw.recipe[assembly_check] then
      local rec_check = data.raw.recipe[assembly_check]
      if rec_check.normal then
        ing_list = rec_check.normal.ingredients
        shuffle_blocks_list(ing_list)
        ing_list = rec_check.expensive.ingredients
        shuffle_blocks_list(ing_list)
      else
        ing_list = rec_check.ingredients
        shuffle_blocks_list(ing_list)
      end
    end
  end
  change_con_block_ingredients()
end
