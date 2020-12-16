function ReplaceRollIcons(metal)
  local RollItem=data.raw.item["angels-roll-"..metal]
  local RollConvRecipe=data.raw.recipe["angels-roll-"..metal.."-converting"]
  local RollCreateRecipe=data.raw.recipe["angels-roll-"..metal.."-casting"]
  local RollCreateRecipe2=data.raw.recipe["angels-roll-"..metal.."-casting-fast"]
  if metal=="brass" or metal=="bronze" or metal=="nitinol" then
    RollItem.icons={
      {
        icon = "__angels-smelting-extended__/graphics/icons/roll-"..metal..".png",
        icon_size=32
      }
    }
    RollConvRecipe.icons = {
      {
        icon = "__angelssmelting__/graphics/icons/plate-"..metal..".png",
        icon_size=32
      },
      {
        icon = "__angels-smelting-extended__/graphics/icons/roll-"..metal..".png",
        icon_size=32,
        scale = 0.4375,
        shift = {-10, -10}
      },
    }
    RollCreateRecipe.icons={
      {
        icon="__angels-smelting-extended__/graphics/icons/roll-"..metal..".png",
        icon_size=32
      },
      {
        icon = "__angelsrefining__/graphics/icons/num_1.png",
        icon_size=32,
        tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
        scale = 0.32,
        shift = {-12, -12},
      },
    }
    RollCreateRecipe2.icons={
      {
        icon="__angels-smelting-extended__/graphics/icons/roll-"..metal..".png",
        icon_size=32
      },
      {
        icon = "__angelsrefining__/graphics/icons/num_2.png",
        icon_size=32,
        tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
        scale = 0.32,
        shift = {-12, -12},
      },
    }
  elseif metal=="invar" or metal=="gunmetal" or metal=="cobalt-steel" then
  else
    RollItem.icons={
      {
        icon="__angelssmelting__/graphics/icons/roll-"..metal..".png",
        icon_size=32
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
    RollCreateRecipe.icons={
      {
        icon="__angelssmelting__/graphics/icons/roll-"..metal..".png",
        icon_size=32
      },
      {
        icon = "__angelsrefining__/graphics/icons/num_1.png",
        icon_size=32,
        tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
        scale = 0.32,
        shift = {-12, -12},
      },
    }
    RollCreateRecipe2.icons={
      {
        icon="__angelssmelting__/graphics/icons/roll-"..metal..".png",
        icon_size=32
      },
      {
        icon = "__angelsrefining__/graphics/icons/num_2.png",
        icon_size=32,
        tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
        scale = 0.32,
        shift = {-12, -12},
      },
    }
  end
end
