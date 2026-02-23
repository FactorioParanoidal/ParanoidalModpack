data:extend(
  {
    --violet catalyst
    {
      type = "item",
      name = "clowns-catalyst-metal-violet",
      icon = "__Clowns-Processing__/graphics/icons/catalyst-metal-violet.png",
      icon_size = 32,
      subgroup = "angels-petrochem-catalysts",
      order = "f",
      stack_size = 200
    },
    ---------------------------------
    -- depleted uranium processing --
    ---------------------------------
    --processed
    {
      type = "item",
      name = "clowns-processed-depleted-uranium",
      icon = "__Clowns-Processing__/graphics/icons/processed-depleted-uranium.png",
      icon_size = 32,
      subgroup = "clowns-depleted-uranium",
      order = "a",
      stack_size = 200,
    },
    --pellet
    {
      type = "item",
      name = "clowns-pellet-depleted-uranium",
      icon = "__Clowns-Processing__/graphics/icons/pellet-depleted-uranium.png",
      icon_size = 32,
      subgroup = "clowns-depleted-uranium",
      order = "b",
      stack_size = 200
    },
    --powder
    {
      type = "item",
      name = "clowns-powder-depleted-uranium",
      icon = "__Clowns-Processing__/graphics/icons/powder-depleted-uranium.png",
      icon_size = 32,
      subgroup = "clowns-depleted-uranium",
      order = "c",
      stack_size = 200
    },
    --powder-mix
    {
      type = "item",
      name = "clowns-casting-powder-depleted-uranium",
      icon = "__Clowns-Processing__/graphics/icons/powder-depleted-uranium-mix.png",
      icon_size = 32,
      subgroup = "clowns-depleted-uranium",
      order = "d",
      stack_size = 200
    },
    --plate
    {
      type = "item",
      name = "clowns-plate-depleted-uranium",
      icon = "__Clowns-Processing__/graphics/icons/plate-depleted-uranium.png",
      icon_size = 32,
      subgroup = "clowns-depleted-uranium-casting",
      order = "e",
      stack_size = 200
    },
    ---------------------------
    -- Phosphorus processing --
    ---------------------------
    --phosphorus ore
    {
      type = "item",
      name = "clowns-phosphorus-ore",
      icon = "__Clowns-Processing__/graphics/icons/phosphorus-ore.png",
      icon_size = 32,
      subgroup = "clowns-phosphorus",
      order = "a",
      stack_size = 200,
    },
    --white phosphorus
    {
      type = "item",
      name = "clowns-solid-white-phosphorus",
      icon = "__Clowns-Processing__/graphics/icons/solid-white-phosphorus.png",
      icon_size = 32,
      subgroup = "clowns-phosphorus",
      order = "b",
      stack_size = 200,
    },
    --phosphoric-acid
    {
      type = "fluid",
      name = "clowns-liquid-phosphoric-acid",
      icons = angelsmods.functions.create_liquid_fluid_icon({ "__Clowns-Processing__/graphics/icons/phosphoric-acid.png", 512 }, {{ r = 244, g = 125, b = 001 },{ 242, 242, 242 },{ 214, 012, 012 }}),--"__Clowns-Processing__/graphics/icons/liquid-phosphoric-acid.png",
      --icon_size = 32,
      default_temperature = 25,
      heat_capacity = "0.1kJ",
      base_color = {r = 0.957, g = 0.49, b = 0},
      flow_color = {r = 0.957, g = 0.49, b = 0},
      max_temperature = 100,
    },
    ------------------------
    -- Mercury processing --
    ------------------------
    --liquid mercury
    {
      type = "fluid",
      name = "clowns-liquid-mercury",
      icons = angelsmods.functions.create_viscous_liquid_fluid_icon({icon="__Clowns-Processing__/graphics/icons/Numbers/Hg.png", icon_size=32, icon_mipmaps=2},
      { { 184, 184, 208 },{ 184, 184, 208 },{ 184, 184, 208 } }),--"__Clowns-Processing__/graphics/icons/liquid-mercury.png",
      default_temperature = 25,
      heat_capacity = "0.1kJ",
      base_color = { 184, 184, 208 },
      flow_color = {r = 0.8, g = 0.8, b = 0},
      max_temperature = 100,
    },
    --liquid-dmm
    {
      type = "fluid",
      name = "clowns-liquid-dimethylmercury",
      icons = angelsmods.functions.create_viscous_liquid_fluid_icon(nil,{ { 118, 141, 138 },{ 94, 113, 110 },{ 94, 113, 110 } }),--"__Clowns-Processing__/graphics/icons/liquid-mercury.png",
      --icon = "__Clowns-Processing__/graphics/icons/liquid-dimethylmercury.png",
      --icon_size = 32,
      default_temperature = 25,
      heat_capacity = "0.1kJ",
      base_color = { 118, 141, 138 },
      flow_color = {r = 0.1, g = 0.8, b = 0.7},
      max_temperature = 100,
    },   
--    ----------------------
--    -- Boron processing --
--    -- incomplete, needs process and source
--    ----------------------
--    --Boric acid
--    {
--      type = "fluid",
--      name = "angels-liquid-boric-acid",
--      icons = angelsmods.functions.create_liquid_fluid_icon({ "__Clowns-Processing__/graphics/icons/boric-acid.png", 512 }, {{r=203/255,g=146/255,b=146/255},{ 214, 012, 012 },{ 242, 242, 242 }}),--"__Clowns-Processing__/graphics/icons/liquid-boric-acid.png",
--      --icon_size = 32,
--      default_temperature = 25,
--      heat_capacity = "0.1kJ",
--      base_color = {r = 1, g = 0.6, b = 0.6},
--      flow_color = {r = 1, g = 0.6, b = 0.6},
--      max_temperature = 100,
--    },
    --------------------------
    -- Magnesium processing --
    --------------------------
    --ore
    {
      type = "item",
      name = "clowns-magnesium-ore",
      icon = "__Clowns-Processing__/graphics/icons/magnesium-ore.png",
      icon_size = 32,
      subgroup = "clowns-magnesium",
      order = "a",
      stack_size = 200,
    },
    --processed
    {
      type = "item",
      name = "clowns-processed-magnesium",
      icon = "__Clowns-Processing__/graphics/icons/processed-magnesium.png",
      icon_size = 32,
      subgroup = "clowns-magnesium",
      order = "b",
      stack_size = 200,
    },
    --pellet
    {
      type = "item",
      name = "clowns-pellet-magnesium",
      icon = "__Clowns-Processing__/graphics/icons/pellet-magnesium.png",
      icon_size = 32,
      subgroup = "clowns-magnesium",
      order = "c",
      stack_size = 200
    },
    --ingot
    {
      type = "item",
      name = "clowns-ingot-magnesium",
      icon = "__Clowns-Processing__/graphics/icons/ingot-magnesium.png",
      icon_size = 32,
      subgroup = "clowns-magnesium",
      order = "c",
      stack_size = 200
    },
    --molten
    {
      type = "fluid",
      name = "clowns-liquid-molten-magnesium",
      icon = "__Clowns-Processing__/graphics/icons/molten-magnesium.png",
      icon_size = 32,
      default_temperature = 100,
      heat_capacity = "0kJ",
      base_color = {r = 242/255, g = 212/255, b = 194/255},
      flow_color = {r = 242/255, g = 212/255, b = 194/255},
      max_temperature = 100,
      auto_barrel = false
    },
    --plate
    {
      type = "item",
      name = "clowns-plate-magnesium",
      icon = "__Clowns-Processing__/graphics/icons/plate-magnesium.png",
      icon_size = 32,
      subgroup = "clowns-magnesium-casting",
      order = "f",
      stack_size = 200
    },
    -----------------------
    -- Osmium processing --
    -----------------------
    --ore
    {
      type = "item",
      name = "clowns-osmium-ore",
      icon = "__Clowns-Processing__/graphics/icons/osmium-ore.png",
      icon_size = 32,
      subgroup = "clowns-osmium",
      order = "a",
      stack_size = 200,
    },
    --processed
    {
      type = "item",
      name = "clowns-processed-osmium",
      icon = "__Clowns-Processing__/graphics/icons/processed-osmium.png",
      icon_size = 32,
      subgroup = "clowns-osmium",
      order = "b",
      stack_size = 200,
    },
    --pellet
    {
      type = "item",
      name = "clowns-pellet-osmium",
      icon = "__Clowns-Processing__/graphics/icons/pellet-osmium.png",
      icon_size = 32,
      subgroup = "clowns-osmium",
      order = "c",
      stack_size = 200
    },
    --powder
    {
      type = "item",
      name = "clowns-powder-osmium",
      icon = "__Clowns-Processing__/graphics/icons/powder-osmium.png",
      icon_size = 32,
      subgroup = "clowns-osmium",
      order = "d",
      stack_size = 200
    },
    --powder-mix
    {
      type = "item",
      name = "clowns-casting-powder-osmium",
      icon = "__Clowns-Processing__/graphics/icons/powder-osmium.png",
      icon_size = 32,
      subgroup = "clowns-osmium",
      order = "e",
      stack_size = 200
    },
    --plate
    {
      type = "item",
      name = "clowns-plate-osmium",
      icon = "__Clowns-Processing__/graphics/icons/plate-osmium.png",
      icon_size = 32,
      subgroup = "clowns-osmium-casting",
      order = "f",
      stack_size = 200
    },
    ----------------------------
    -- Uranium Ore processing --
    ----------------------------
    --UF6
    {
      type = "item",
      name = "clowns-solid-uranium-hexafluoride",
      icon = "__Clowns-Processing__/graphics/icons/solid-uranium-hexafluoride.png",
      icon_size = 32,
      subgroup = "clowns-uranium",
      order = "e",
      stack_size = 200,
    },
    --UF4
    {
      type = "item",
      name = "clowns-solid-uranium-tetrafluoride",
      icon = "__Clowns-Processing__/graphics/icons/solid-uranium-tetrafluoride.png",
      icon_size = 32,
      subgroup = "clowns-uranium",
      order = "d",
      stack_size = 200,
    },
    --UO2
    {
      type = "item",
      name = "clowns-solid-uranium-oxide",
      icon = "__Clowns-Processing__/graphics/icons/solid-uranium-oxide.png",
      icon_size = 32,
      subgroup = "clowns-uranium",
      order = "c",
      stack_size = 200,
    },
    --(NH4)2U2O7
    {
      type = "item",
      name = "clowns-solid-ammonium-diuranate",
      icon = "__Clowns-Processing__/graphics/icons/solid-ammonium-diuranate.png",
      icon_size = 32,
      subgroup = "clowns-uranium",
      order = "b",
      stack_size = 200,
    },
    --UO2(NO3)2
    {
      type = "item",
      name = "clowns-solid-uranyl-nitrate",
      icon = "__Clowns-Processing__/graphics/icons/solid-uranyl-nitrate.png",
      icon_size = 32,
      subgroup = "clowns-uranium",
      order = "a",
      stack_size = 200,
    },
    --F2
    {
      type = "fluid",
      name = "clowns-gas-fluorine",
      icons =  angelsmods.functions.create_gas_fluid_icon({ "__Clowns-Processing__/graphics/icons/fluorine.png", 216 }, "FFF"),-- "__Clowns-Processing__/graphics/icons/gas-fluorine.png",
      --icon_size = 32,
      default_temperature = 25,
      heat_capacity = "0.1kJ",
      base_color = {r = 0.71, g = 0.816, b = 0},
      flow_color = {r = 0.71, g = 0.816, b = 0},
      max_temperature = 100,
    },
    --Osmium Bullets
  }
)
osmiumbullet=table.deepcopy(data.raw.ammo["uranium-rounds-magazine"])
osmiumbullet.name="clowns-osmium-rounds-magazine"
if osmiumbullet.ammo_type.action and osmiumbullet.ammo_type.action.action_delivery then
  osmiumbullet.ammo_type.action.action_delivery.target_effects[2].damage = {amount = 20, type = "physical"}
  osmiumbullet.ammo_type.action.action_delivery.target_effects[3] = {type = "damage",damage = { amount = 6, type = "explosion"}}
else
  table.insert(osmiumbullet.ammo_type.action,{action_delivery={target_effects={{damage = {amount = 20, type = "physical"}},{type = "damage", damage = { amount = 6, type = "explosion"}}}}})
end
osmiumbullet.order = "a[basic-clips]-d[osmium-rounds-magazine]"
osmiumbullet.icon = nil
osmiumbullet.icons = {
  {icon = "__Clowns-Processing__/graphics/icons/osmium-rounds-magazine.png", icon_size = 64, icon_mipmaps = 4--[[, tint = {95,56,75}]]}
}
if not osmiumbullet.pictures then
  osmiumbullet.pictures = {layers={}}
else
    osmiumbullet.pictures.layers[1].filename = "__Clowns-Processing__/graphics/icons/osmium-rounds-magazine.png"
end
data:extend({osmiumbullet})