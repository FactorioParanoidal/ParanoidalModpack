table.insert(
data.raw.recipe["bronze-alloy"].results, {
type="item", name="bronze-alloy", amount=2}
)
data.raw.recipe["bronze-alloy"].icon = "__bobplates__/graphics/icons/plate/bronze-plate.png"
data.raw.recipe["bronze-alloy"].icon_size = 64
data.raw.recipe["bronze-alloy"].subgroup = "bob-alloy"


table.insert(
data.raw.recipe["brass-alloy"].results, {
type="item", name="brass-alloy", amount=2}
	)
data.raw.recipe["brass-alloy"].icon = "__bobplates__/graphics/icons/plate/brass-plate.png"
data.raw.recipe["brass-alloy"].icon_size = 64
data.raw.recipe["brass-alloy"].subgroup = "bob-alloy"

table.insert(
data.raw.recipe["copper-tungsten-alloy"].results, {
type="item", name="copper-tungsten-alloy", amount=2}

)
data.raw.recipe["copper-tungsten-alloy"].icon = "__bobplates__/graphics/icons/plate/copper-tungsten-plate.png"
data.raw.recipe["copper-tungsten-alloy"].icon_size = 32
data.raw.recipe["copper-tungsten-alloy"].subgroup = "bob-alloy"

table.insert(
data.raw.recipe["tungsten-carbide"].ingredients, {
      {type="item", name="carbon", amount=1},
      {type="item", name="tungsten-oxide", amount=3}})
	  
table.insert(
data.raw.recipe["tungsten-carbide"].results, {type="item", name="tungsten-carbide", amount=1}
)
data.raw.recipe["tungsten-carbide"].icon = "__bobplates__/graphics/icons/plate/tungsten-carbide-plate.png"
data.raw.recipe["tungsten-carbide"].icon_size = 64


table.insert(
data.raw.recipe["tungsten-carbide-2"].ingredients, {
      {type="item", name="carbon", amount=1},
      {type="item", name="powdered-tungsten", amount=2}
    })
	
table.insert(
data.raw.recipe["tungsten-carbide-2"].results, {type="item", name="tungsten-carbide", amount=1}
)
data.raw.recipe["tungsten-carbide-2"].icon = "__bobplates__/graphics/icons/plate/tungsten-carbide-plate.png"
data.raw.recipe["tungsten-carbide-2"].icon_size = 64


table.insert(
data.raw.recipe["invar-alloy"].results, {
type="item", name="invar-alloy", amount=2}
)
data.raw.recipe["invar-alloy"].icon = "__bobplates__/graphics/icons/plate/invar-plate.png"
data.raw.recipe["invar-alloy"].icon_size = 64


table.insert(
data.raw.recipe["nitinol-alloy"].results, {
type="item", name="nitinol-alloy", amount=2}
)
data.raw.recipe["nitinol-alloy"].icon = "__bobplates__/graphics/icons/plate/nitinol-plate.png"
data.raw.recipe["nitinol-alloy"].icon_size = 32

--[[
table.insert(
data.raw.recipe["cobalt-steel-alloy"].results, {
type="item", name="cobalt-steel-alloy", amount=5})
]]