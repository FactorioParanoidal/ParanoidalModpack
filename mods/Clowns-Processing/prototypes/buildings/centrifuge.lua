if settings.startup["MCP_enable_centrifuges"].value then
  data.raw.item["centrifuge"].icons = angelsmods.functions.add_number_icon_layer(
    {
      {
        icon = "__base__/graphics/icons/centrifuge.png",
        icon_size = 64, icon_mipmaps = 4, scale = 0.5
      }
    },
    1, angelsmods.refining.number_tint)

  local centrifuge_2_item = util.table.deepcopy(data.raw.item["centrifuge"])
  centrifuge_2_item.localised_name={"centrifuge","MK2"}
  centrifuge_2_item.name = "centrifuge-mk2"
  centrifuge_2_item.place_result = "centrifuge-mk2"
  centrifuge_2_item.order = "a-b"--base centrifuge is g, overriden to a-a
  centrifuge_2_item.icons = angelsmods.functions.add_number_icon_layer(
    {
      {
        icon = "__base__/graphics/icons/centrifuge.png",
        icon_size = 64, icon_mipmaps = 4, scale = 0.5
      }
    },
    2, angelsmods.refining.number_tint)

  local centrifuge_3_item = util.table.deepcopy(data.raw.item["centrifuge"])
  centrifuge_3_item.name = "centrifuge-mk3"
  centrifuge_3_item.place_result = "centrifuge-mk3"
  centrifuge_3_item.localised_name={"centrifuge","MK3"}
  centrifuge_3_item.order = "a-c"
  centrifuge_3_item.icons = angelsmods.functions.add_number_icon_layer(
    {
      {
        icon = "__base__/graphics/icons/centrifuge.png",
        icon_size = 64, icon_mipmaps = 4, scale = 0.5
      }
    },
    3, angelsmods.refining.number_tint)

  local centrifuge_2 = util.table.deepcopy(data.raw["assembling-machine"]["centrifuge"])
  centrifuge_2.name = "centrifuge-mk2"
  centrifuge_2.minable.result = "centrifuge-mk2"
  centrifuge_2.fast_replaceable_group = "centrifuge"
  centrifuge_2.crafting_speed = 1.25
  centrifuge_2.energy_usage = "450kW"
  centrifuge_2.localised_name = {"centrifuge","MK2"}
  local centrifuge_2r = util.table.deepcopy(data.raw.recipe["centrifuge"])
  centrifuge_2r.name = "centrifuge-mk2"
  centrifuge_2r.results = {{type="item",name="centrifuge-mk2",amount=1}}
  centrifuge_2r.energy_required = 4
  local ings_2 =
  {
    {type = "item", name = "centrifuge", amount = 1},
    {type = "item", name = "processing-unit", amount = 100}
  }
  if data.raw.item["titanium-plate"] then
    ings_2[#ings_2+1] = {type = "item", name = "bob-titanium-plate", amount = 50}
  else --vanilla materials
    ings_2[#ings_2+1] = {type = "item", name = "steel-plate", amount = 200}
  end
  if data.raw.item["titanium-gear-wheel"] then
    ings_2[#ings_2+1] = {type = "item", name = "bob-titanium-gear-wheel", amount = 100}
  else --vanilla materials
    ings_2[#ings_2+1] = {type = "item", name = "angels-concrete-brick", amount = 200}
  end
  centrifuge_2r.ingredients = ings_2

  local centrifuge_3 = util.table.deepcopy(data.raw["assembling-machine"]["centrifuge"])
  centrifuge_3.name = "centrifuge-mk3"
  centrifuge_3.minable.result = "centrifuge-mk3"
  centrifuge_3.fast_replaceable_group = "centrifuge"
  centrifuge_3.crafting_speed = 2
  centrifuge_3.energy_usage = "550kW"
  centrifuge_3.localised_name={"centrifuge","MK3"}
  local centrifuge_3r = util.table.deepcopy(data.raw.recipe["centrifuge"])
  centrifuge_3r.name = "centrifuge-mk3"
  centrifuge_3r.results = {{type="item",name="centrifuge-mk3",amount=1}}
  centrifuge_3r.energy_required = 4
  local ings_3 =
  {
    {type = "item", name = "centrifuge-mk2", amount = 1}
  }
  if data.raw.item["bobadvanced-processing-unit"] then
    ings_3[#ings_3+1]= {type="item", name="bob-advanced-processing-unit", amount=100}
  else
    ings_3[#ings_3+1] = {type = "item", name = "processing-unit", amount = 200}
  end
  if data.raw.item["bob-copper-tungsten-alloy"] and data.raw.item["bob-tungsten-gear-wheel"] then
    ings_3[#ings_3+1] = {type = "item", name = "bob-copper-tungsten-alloy", amount = 50}
    ings_3[#ings_3+1] = {type = "item", name = "bob-tungsten-gear-wheel", amount = 100}
  elseif data.raw.item["angels-tungsten-plate"] then
    ings_3[#ings_3+1] = {type = "item", name = "angels-tungsten-plate", amount = 200}
    ings_3[#ings_3+1] = {type = "item", name = "angels-concrete-brick", amount = 300}
  else --vanilla materials
    ings_3[#ings_3+1] = {type = "item", name = "steel-plate", amount = 300}
    ings_3[#ings_3+1] = {type = "item", name = "concrete", amount = 300}
  end
  centrifuge_3r.ingredients = ings_3
  data:extend(
  {
    centrifuge_2_item,
    centrifuge_3_item,
    centrifuge_2,
    centrifuge_3,
    centrifuge_2r,
    centrifuge_3r
  })
end