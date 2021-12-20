function ASE.functions.ReplaceRollIcons(metal)
  local RollItem = data.raw.item["angels-roll-"..metal]
  local RollConvRecipe = data.raw.recipe["angels-roll-"..metal.."-converting"]
  local RollCreateRecipe = data.raw.recipe["angels-roll-"..metal.."-casting"]
  local RollCreateRecipe2 = data.raw.recipe["angels-roll-"..metal.."-casting-fast"]
  --these icons are stored locally
  if metal=="brass" or metal=="bronze" or metal=="nitinol" or metal=="tungsten" or metal=="invar" or metal=="gunmetal" or metal=="cobalt-steel" then
    RollItem.icons={
      {
        icon = "__angels-smelting-extended__/graphics/icons/roll-"..metal..".png",
        icon_size=64,
        icon_mipmaps=4
      }
    }
    RollConvRecipe.icons = {
      {
        icon = "__angelssmelting__/graphics/icons/plate-"..metal..".png",
        icon_size=32
      },
      {
        icon = "__angels-smelting-extended__/graphics/icons/roll-"..metal..".png",
        icon_size=64,
        icon_mipmaps=4,
        scale = 0.4375*0.5,
        shift = {-10, -10}
      },
    }
    RollCreateRecipe.icons = angelsmods.functions.add_number_icon_layer({
      {
        icon="__angels-smelting-extended__/graphics/icons/roll-"..metal..".png",
        icon_size=64,
        icon_mipmaps=4
      },}, 1 , angelsmods.smelting.number_tint)

    RollCreateRecipe2.icons = angelsmods.functions.add_number_icon_layer({
      {
        icon="__angels-smelting-extended__/graphics/icons/roll-"..metal..".png",
        icon_size=64,
        icon_mipmaps=4
      },}, 2 , angelsmods.smelting.number_tint)
  --elseif metal=="invar" or metal=="gunmetal" or metal=="cobalt-steel" then
    --don't change
  else -- all others are found in angels icons
    RollItem.icons={
      {
        icon="__angelssmelting__/graphics/icons/roll-"..metal..".png",
        icon_size=64,
        icon_mipmaps=4
      }
    }
    RollConvRecipe.icons = {
      {
        icon = "__angelssmelting__/graphics/icons/plate-"..metal..".png",
        icon_size=32
      },
      {
        icon = "__angelssmelting__/graphics/icons/roll-"..metal..".png",
        icon_size=32,
        scale = 0.4375,
        shift = {-10, -10}
      },
    }
    RollCreateRecipe.icons = angelsmods.functions.add_number_icon_layer({
      {
        icon="__angelssmelting__/graphics/icons/roll-"..metal..".png",
        icon_size=64,
        icon_mipmaps=4
      },}, 1 , angelsmods.smelting.number_tint)
    RollCreateRecipe2.icons = angelsmods.functions.add_number_icon_layer({
      {
        icon="__angelssmelting__/graphics/icons/roll-"..metal..".png",
        icon_size=64,
        icon_mipmaps=4
      },}, 2 , angelsmods.smelting.number_tint)
  end
end
