--Disable Electronic Assemblers
if settings.startup["bobmods-assembly-electronicmachines"].value == true then
data.raw["assembling-machine"]["electronics-machine-1"].module_specification = 
{
      module_slots = 0,
      module_info_icon_shift = {0, 0.5},
      module_info_multi_row_initial_height_modifier = -0.3
}
data.raw["assembling-machine"]["electronics-machine-2"].module_specification = 
{
      module_slots = 2,
      module_info_icon_shift = {0, 0.5},
      module_info_multi_row_initial_height_modifier = -0.3
}
data.raw["assembling-machine"]["electronics-machine-3"].module_specification = 
{
      module_slots = 4,
      module_info_icon_shift = {0, 0.5},
      module_info_multi_row_initial_height_modifier = -0.3
}
end
data.raw["assembling-machine"]["assembling-machine-2"].ingredient_count = 5

--Nerf Bob Assembly
if mods.bobassembly then
data.raw["assembling-machine"]["assembling-machine-3"].module_specification = 
{
      module_slots = 2,
      module_info_icon_shift = {0, 0.5},
      module_info_multi_row_initial_height_modifier = -0.3
}
data.raw["assembling-machine"]["assembling-machine-4"].module_specification = 
{
      module_slots = 3,
      module_info_icon_shift = {0, 0.5},
      module_info_multi_row_initial_height_modifier = -0.3
}
data.raw["assembling-machine"]["assembling-machine-5"].module_specification = 
{
      module_slots = 3,
      module_info_icon_shift = {0, 0.5},
      module_info_multi_row_initial_height_modifier = -0.3
}
data.raw["assembling-machine"]["assembling-machine-6"].module_specification = 
{
      module_slots = 4,
      module_info_icon_shift = {0, 0.5},
      module_info_multi_row_initial_height_modifier = -0.3
}

--Nerf Bob Assembly OIL
data.raw["assembling-machine"]["chemical-plant"].module_specification = 
{
      module_slots = 1,
      module_info_icon_shift = {0, 0.5},
      module_info_multi_row_initial_height_modifier = -0.3
}
data.raw["assembling-machine"]["chemical-plant-2"].module_specification = 
{
      module_slots = 2,
      module_info_icon_shift = {0, 0.5},
      module_info_multi_row_initial_height_modifier = -0.3
}
data.raw["assembling-machine"]["chemical-plant-3"].module_specification = 
{
      module_slots = 3,
      module_info_icon_shift = {0, 0.5},
      module_info_multi_row_initial_height_modifier = -0.3
}
data.raw["assembling-machine"]["chemical-plant-4"].module_specification = 
{
      module_slots = 4,
      module_info_icon_shift = {0, 0.5},
      module_info_multi_row_initial_height_modifier = -0.3
}
data.raw["assembling-machine"]["oil-refinery"].module_specification = 
{
      module_slots = 1,
      module_info_icon_shift = {0, 0.5},
      module_info_multi_row_initial_height_modifier = -0.3
}
data.raw["assembling-machine"]["oil-refinery-2"].module_specification = 
{
      module_slots = 2,
      module_info_icon_shift = {0, 0.5},
      module_info_multi_row_initial_height_modifier = -0.3
}
data.raw["assembling-machine"]["oil-refinery-3"].module_specification = 
{
      module_slots = 3,
      module_info_icon_shift = {0, 0.5},
      module_info_multi_row_initial_height_modifier = -0.3
}
data.raw["assembling-machine"]["oil-refinery-4"].module_specification = 
{
      module_slots = 4,
      module_info_icon_shift = {0, 0.5},
      module_info_multi_row_initial_height_modifier = -0.3
}

--FURNACES
data.raw.furnace["electric-furnace"].module_specification = 
{
      module_slots = 1,
      module_info_icon_shift = {0, 0.5},
      module_info_multi_row_initial_height_modifier = -0.3
}
data.raw.furnace["electric-furnace-2"].module_specification = 
{
      module_slots = 2,
      module_info_icon_shift = {0, 0.5},
      module_info_multi_row_initial_height_modifier = -0.3
}
data.raw.furnace["electric-furnace-3"].module_specification = 
{
      module_slots = 3,
      module_info_icon_shift = {0, 0.5},
      module_info_multi_row_initial_height_modifier = -0.3
}
data.raw["assembling-machine"]["electric-mixing-furnace"].module_specification = 
{
      module_slots = 1,
      module_info_icon_shift = {0, 0.5},
      module_info_multi_row_initial_height_modifier = -0.3
}
data.raw["assembling-machine"]["electric-chemical-mixing-furnace"].module_specification = 
{
      module_slots = 2,
      module_info_icon_shift = {0, 0.5},
      module_info_multi_row_initial_height_modifier = -0.3
}
data.raw["assembling-machine"]["electric-chemical-mixing-furnace-2"].module_specification = 
{
      module_slots = 3,
      module_info_icon_shift = {0, 0.5},
      module_info_multi_row_initial_height_modifier = -0.3
}
data.raw["assembling-machine"]["chemical-furnace"].module_specification = 
{
      module_slots = 1,
      module_info_icon_shift = {0, 0.5},
      module_info_multi_row_initial_height_modifier = -0.3
}
end

