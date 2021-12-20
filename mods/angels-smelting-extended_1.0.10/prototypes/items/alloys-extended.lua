local AF = angelsmods.functions
if mods["bobplates"] then
  data:extend(
    --Molten ALLOYS
    {
      --Bronze (CuSn)
      --[[{
        type = "fluid",
        name = "liquid-molten-bronze",
        icon = "__angelssmelting__/graphics/icons/molten-bronze.png",
        icon_size=32,
        default_temperature = 100,
        heat_capacity = "0KJ",
        base_color = ASE.tables.coil_metals["bronze"].tint,
        flow_color = AF.fluid_color("Cu8Sn"),
        max_temperature = 100,
        auto_barrel = false
      },
      --Brass (CuZn)
      {
        type = "fluid",
        name = "liquid-molten-brass",
        icon = "__angelssmelting__/graphics/icons/molten-brass.png",
        icon_size=32,
        default_temperature = 100,
        heat_capacity = "0KJ",
        base_color = ASE.tables.coil_metals["brass"].tint,
        flow_color = AF.fluid_color("Cu13Zn7"),
        max_temperature = 100,
        auto_barrel = false
      },
      --Gunmetal (CuSnZn)
      {
        type = "fluid",
        name = "liquid-molten-gunmetal",
        icon = "__angelssmelting__/graphics/icons/molten-gunmetal.png",
        icon_size=32,
        default_temperature = 100,
        heat_capacity = "0KJ",
        base_color = ASE.tables.coil_metals["gunmetal"].tint,
        flow_color = AF.fluid_color("Cu22Sn2Zn"),
        max_temperature = 100,
        auto_barrel = false
      },]]
      --Invar (FeNi)
      {
        type = "fluid",
        name = "liquid-molten-invar",
        icon = "__angelssmelting__/graphics/icons/molten-invar.png",
        icon_size = 64,
        icon_mipmaps = 4,
        default_temperature = 100,
        heat_capacity = "0KJ",
        base_color = ASE.tables.coil_metals["invar"].tint,
        flow_color = AF.fluid_color("Fe2Ni"),
        max_temperature = 100,
        auto_barrel = false
      },
      --Nitinol (TiNi)
      --[[{
        type = "fluid",
        name = "liquid-molten-nitinol",
        icon = "__angelssmelting__/graphics/icons/molten-nitinol.png",
        icon_size=32,
        default_temperature = 100,
        heat_capacity = "0KJ",
        base_color = ASE.tables.coil_metals["nitinol"].tint,
        flow_color = AF.fluid_color("Ni3Ti2"),
        max_temperature = 100,
        auto_barrel = false
      },
      --Cobalt Steel (FeCCo)
      {
        type = "fluid",
        name = "liquid-molten-cobalt-steel",
        icon = "__angelssmelting__/graphics/icons/molten-cobalt-steel.png",
        icon_size=32,
        default_temperature = 100,
        heat_capacity = "0KJ",
        base_color = ASE.tables.coil_metals["nitinol"].tint,
        flow_color = AF.fluid_color("Ni3Ti2"),
        max_temperature = 100,
        auto_barrel = false
      },]]
    }
  )
  --create plates if they don't exist
  --[[local plates = {}
  if not data.raw.item["angels-plate-bronze"] or data.raw.item["bronze-plate"] then



  data:extend(
    {
      {
        type = "item",
        name = "angels-plate-bronze",
        icon = "__angelssmelting__/graphics/icons/plate-bronze.png",
        icon_size=32,
        flags={"hidden"},
        subgroup = "angels-copper-casting",
        order = "ya",
        stack_size = 200
      },

      {
        type = "item",
        name = "angels-plate-brass",
        icon = "__angelssmelting__/graphics/icons/plate-brass.png",
        icon_size=32,
        flags={"hidden"},
        subgroup = "angels-copper-casting",
        order = "yb",
        stack_size = 200
      },
      
      {
        type = "item",
        name = "angels-plate-gunmetal",
        icon = "__angelssmelting__/graphics/icons/plate-gunmetal.png",
        icon_size=32,
        flags={"hidden"},
        subgroup = "angels-copper-casting",
        order = "yc",
        stack_size = 200
      },
      
      {
        type = "item",
        name = "angels-plate-invar",
        icon = "__angelssmelting__/graphics/icons/plate-invar.png",
        icon_size=32,
        flags={"hidden"},
        subgroup = "angels-iron-casting",
        order = "ya",
        stack_size = 200
      },
      
      {
        type = "item",
        name = "angels-plate-nitinol",
        icon = "__angelssmelting__/graphics/icons/plate-nitinol.png",
        icon_size=32,
        flags={"hidden"},
        subgroup = "angels-titanium-casting",
        order = "ya",
        stack_size = 200
      },
      {
        type = "item",
        name = "angels-plate-cobalt-steel",
        icon = "__angelssmelting__/graphics/icons/plate-cobalt-steel.png",
        icon_size=32,
        flags={"hidden"},
        subgroup = "angels-cobalt-casting",
        order = "ya",
        stack_size = 200
      },

  })]]
end