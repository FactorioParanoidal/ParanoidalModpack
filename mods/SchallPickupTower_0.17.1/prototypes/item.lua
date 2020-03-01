local pickup_tower_icon_path = {icon = "__SchallPickupTower__/graphics/icons/pickup-tower.png"}
local mk1_icon_overlay = {icon = "__SchallPickupTower__/graphics/icons/mk1.png"}
local mk2_icon_overlay = {icon = "__SchallPickupTower__/graphics/icons/mk2.png"}



data:extend(
{
  -- Pickup Tower
  {
    type = "item",
    name = "Schall-pickup-tower-R32",
    icons = { pickup_tower_icon_path,
              mk1_icon_overlay },
    icon_size = 32,
    subgroup = "storage",
    -- subgroup = "logistic-network",
    order = "i[pickup]-1",
    place_result = "Schall-pickup-tower-R32",
    stack_size = 20
  },
  {
    type = "item",
    name = "Schall-pickup-tower-R32-upper",
    icons = { pickup_tower_icon_path,
              mk1_icon_overlay },
    icon_size = 32,
    flags = {"hidden"},
    subgroup = "storage",
    -- subgroup = "logistic-network",
    order = "i[pickup]-1",
    place_result = "Schall-pickup-tower-R32-upper",
    stack_size = 20
  },
  {
    type = "item",
    name = "Schall-pickup-tower-R64",
    icons = { pickup_tower_icon_path,
              mk2_icon_overlay },
    icon_size = 32,
    subgroup = "storage",
    -- subgroup = "logistic-network",
    order = "i[pickup]-2",
    place_result = "Schall-pickup-tower-R64",
    stack_size = 20
  },
  {
    type = "item",
    name = "Schall-pickup-tower-R64-upper",
    icons = { pickup_tower_icon_path,
              mk2_icon_overlay },
    icon_size = 32,
    flags = {"hidden"},
    subgroup = "storage",
    -- subgroup = "logistic-network",
    order = "i[pickup]-2",
    place_result = "Schall-pickup-tower-R64-upper",
    stack_size = 20
  },

}
)
