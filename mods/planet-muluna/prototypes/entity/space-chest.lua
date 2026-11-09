local space_chest = table.deepcopy(data.raw["container"]["steel-chest"])

space_chest.name="space-chest-muluna"
space_chest.inventory_size = 1
space_chest.minable.result = "space-chest-muluna"
space_chest.surface_conditions = {{property="gravity",min=0,max=0}}
space_chest.subgroup = "space-platform"
space_chest.quality_affects_inventory_size = false
Muluna:extend{space_chest}