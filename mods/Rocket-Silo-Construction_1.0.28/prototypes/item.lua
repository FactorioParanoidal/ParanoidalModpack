


data:extend({
      {
    type = "item",
    name = "rsc-building-stage2",
    icon = "__Rocket-Silo-Construction__/graphics/concrete.png",--excavator
	icon_size = 64,
    subgroup = "raw-material",
	flags = {"hidden"},
    order = "rsc-construction",
    stack_size = 100
  },
  
  {
    type = "item",
    name = "rsc-excavation-site",
	icons = icons_rsc,
    subgroup = "defensive-structure",
    order = "e[rocket-silo]",
    place_result = "rsc-silo-stage1",
    stack_size = 1
  },  
  
  
})


if data.raw.item['se-rocket-launch-pad'] then
local enable_se_cargo = settings.startup["rsc-st-enable-se-cargo-silo"].value 
local enable_se_probe = settings.startup["rsc-st-enable-se-probe-silo"].value 

if enable_se_cargo then
data:extend({
  {
    type = "item",
    name = "rsc-excavation-site-serlp",
	icons = icons_se_crs,
    subgroup = "rocket-logistics",
    order = "b",
    place_result = "rsc-silo-stage1-serlp",
    stack_size = 1
  }})
  end

if enable_se_probe then
data:extend({  
  {
    type = "item",
    name = "rsc-excavation-site-sesprs",
	icons = icons_se_sp,
    subgroup = "rocket-logistics",
    order = "b",
    place_result = "rsc-silo-stage1-sesprs",
    stack_size = 1
  }   
 })
 end

end