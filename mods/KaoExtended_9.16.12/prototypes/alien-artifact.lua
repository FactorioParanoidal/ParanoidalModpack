data:extend(
{
  {
    type = "item",
    name = "alien-artifact",
    icon = "__bobenemies__/graphics/icons/alien-artifact.png",
    icon_size = 32,
    flags = {  },
    subgroup = "raw-material",
    order = "g[alien-artifact]-a[pink]",
    stack_size = 500,
    default_request_amount = 10
  },
}
)


data:extend(
{
  {
    type = "item",
    name = "alien-artifact-red",
    icon = "__bobenemies__/graphics/icons/alien-artifact-red.png",
    icon_size = 32,
    --flags = {},
    subgroup = "raw-material",
    order = "g[alien-artifact]-b[red]",
    stack_size = 500,
    default_request_amount = 10
  },

  {
    type = "item",
    name = "alien-artifact-orange",
    icon = "__bobenemies__/graphics/icons/alien-artifact-orange.png",
    icon_size = 32,
    --flags = {},
    subgroup = "raw-material",
    order = "g[alien-artifact]-c[orange]",
    stack_size = 500,
    default_request_amount = 10
  },

  {
    type = "item",
    name = "alien-artifact-yellow",
    icon = "__bobenemies__/graphics/icons/alien-artifact-yellow.png",
    icon_size = 32,
    --flags = {},
    subgroup = "raw-material",
    order = "g[alien-artifact]-d[yellow]",
    stack_size = 500,
    default_request_amount = 10
  },

  {
    type = "item",
    name = "alien-artifact-green",
    icon = "__bobenemies__/graphics/icons/alien-artifact-green.png",
    icon_size = 32,
    --flags = {},
    subgroup = "raw-material",
    order = "g[alien-artifact]-e[green]",
    stack_size = 500,
    default_request_amount = 10
  },

  {
    type = "item",
    name = "alien-artifact-blue",
    icon = "__bobenemies__/graphics/icons/alien-artifact-blue.png",
    icon_size = 32,
    --flags = {},
    subgroup = "raw-material",
    order = "g[alien-artifact]-f[blue]",
    stack_size = 500,
    default_request_amount = 10
  },

  {
    type = "item",
    name = "alien-artifact-purple",
    icon = "__bobenemies__/graphics/icons/alien-artifact-purple.png",
    icon_size = 32,
    --flags = {},
    subgroup = "raw-material",
    order = "g[alien-artifact]-g[purple]",
    stack_size = 500,
    default_request_amount = 10
  },
}
)

if data.raw.item["small-alien-artifact"] then

    table.insert(data.raw.unit["small-biter"].loot, {  item = "small-alien-artifact",  count_min = 0,  count_max = 1,  probability = 0.01 } ) --DrD all enemy count_min
	table.insert(data.raw.unit["small-spitter"].loot, {  item = "small-alien-artifact",  count_min = 0,  count_max = 1,  probability = 0.01 } )
	table.insert(data.raw.unit["medium-biter"].loot, {  item = "small-alien-artifact",  count_min = 0,  count_max = 3,  probability = 0.01 } )
	table.insert(data.raw.unit["medium-spitter"].loot, {  item = "small-alien-artifact",  count_min = 0,  count_max = 3,  probability = 0.01 } )
	table.insert(data.raw.unit["big-biter"].loot, {  item = "small-alien-artifact",  count_min = 0,  count_max = 4,  probability = 0.01 } )
	table.insert(data.raw.unit["big-spitter"].loot, {  item = "small-alien-artifact",  count_min = 0,  count_max = 4,  probability = 0.01 } )

    table.insert(data.raw.unit["behemoth-biter"].loot, {  item = "small-alien-artifact",  count_min = 0,  count_max = 12,  probability = 0.01 } )
	table.insert(data.raw.unit["behemoth-spitter"].loot, {  item = "small-alien-artifact",  count_min = 0,  count_max = 12,  probability = 0.01 } )
	
	table.insert(data.raw.unit["bob-big-piercing-biter"].loot, {  item = "small-alien-artifact-blue",  count_min = 0,  count_max = 3,  probability = 0.01 } )
    table.insert(data.raw.unit["bob-big-piercing-biter"].loot, {  item = "small-alien-artifact",  count_min = 0,  count_max = 1,  probability = 0.01 } )
	
	table.insert(data.raw.unit["bob-big-electric-spitter"].loot, {  item = "small-alien-artifact-orange",  count_min = 0,  count_max = 3,  probability = 0.01 } )
    table.insert(data.raw.unit["bob-big-electric-spitter"].loot, {  item = "small-alien-artifact",  count_min = 0,  count_max = 1,  probability = 0.01 } )
	
      table.insert(data.raw.unit["bob-huge-acid-biter"].loot, {  item = "small-alien-artifact-blue",  count_min = 0,  count_max = 1,  probability = 0.01 } )
      table.insert(data.raw.unit["bob-huge-acid-biter"].loot, {  item = "small-alien-artifact-purple",  count_min = 0,  count_max = 3,  probability = 0.01 } )
      table.insert(data.raw.unit["bob-huge-acid-biter"].loot, {  item = "small-alien-artifact",  count_min = 0,  count_max = 1,  probability = 0.01 } )
	  
      table.insert(data.raw.unit["bob-huge-explosive-biter"].loot, {  item = "small-alien-artifact-blue",  count_min = 0,  count_max = 1,  probability = 0.01 } )
      table.insert(data.raw.unit["bob-huge-explosive-biter"].loot, {  item = "small-alien-artifact-yellow",  count_min = 0,  count_max = 3,  probability = 0.01 } )
      table.insert(data.raw.unit["bob-huge-explosive-biter"].loot, {  item = "small-alien-artifact",  count_min = 0,  count_max = 1,  probability = 0.01 } )
	  
      table.insert(data.raw.unit["bob-huge-explosive-spitter"].loot, {  item = "small-alien-artifact-orange",  count_min = 0,  count_max = 1,  probability = 0.01 } )
      table.insert(data.raw.unit["bob-huge-explosive-spitter"].loot, {  item = "small-alien-artifact-yellow",  count_min = 0,  count_max = 3,  probability = 0.01 } )
      table.insert(data.raw.unit["bob-huge-explosive-spitter"].loot, {  item = "small-alien-artifact",  count_min = 0,  count_max = 1,  probability = 0.01 } )
	  
      table.insert(data.raw.unit["bob-huge-acid-spitter"].loot, {  item = "small-alien-artifact-orange",  count_min = 0,  count_max = 1,  probability = 0.01 } )
      table.insert(data.raw.unit["bob-huge-acid-spitter"].loot, {  item = "small-alien-artifact-purple",  count_min = 0,  count_max = 3,  probability = 0.01 } )
      table.insert(data.raw.unit["bob-huge-acid-spitter"].loot, {  item = "small-alien-artifact",  count_min = 0,  count_max = 1,  probability = 0.01 } )

      table.insert(data.raw.unit["bob-giant-poison-biter"].loot, {  item = "small-alien-artifact-blue",  count_min = 0,  count_max = 3,  probability = 0.01 } )
      table.insert(data.raw.unit["bob-giant-poison-biter"].loot, {  item = "small-alien-artifact-green",  count_min = 0,  count_max = 3,  probability = 0.01 } )
      table.insert(data.raw.unit["bob-giant-poison-biter"].loot, {  item = "small-alien-artifact",  count_min = 0,  count_max = 2,  probability = 0.01 } )

      table.insert(data.raw.unit["bob-giant-fire-biter"].loot, {  item = "small-alien-artifact-blue",  count_min = 0,  count_max = 3,  probability = 0.01 } )
      table.insert(data.raw.unit["bob-giant-fire-biter"].loot, {  item = "small-alien-artifact-red",  count_min = 0,  count_max = 3,  probability = 0.01 } )
      table.insert(data.raw.unit["bob-giant-fire-biter"].loot, {  item = "small-alien-artifact",  count_min = 0,  count_max = 2,  probability = 0.01 } )
	  
      table.insert(data.raw.unit["bob-giant-fire-spitter"].loot, {  item = "small-alien-artifact-orange",  count_min = 0,  count_max = 3,  probability = 0.01 } )
      table.insert(data.raw.unit["bob-giant-fire-spitter"].loot, {  item = "small-alien-artifact-red",  count_min = 0,  count_max = 3,  probability = 0.01 } )
      table.insert(data.raw.unit["bob-giant-fire-spitter"].loot, {  item = "small-alien-artifact",  count_min = 0,  count_max = 2,  probability = 0.01 } )
	  
      table.insert(data.raw.unit["bob-giant-poison-spitter"].loot, {  item = "small-alien-artifact-orange",  count_min = 0,  count_max = 3,  probability = 0.01 } )
      table.insert(data.raw.unit["bob-giant-poison-spitter"].loot, {  item = "small-alien-artifact-green",  count_min = 0,  count_max = 3,  probability = 0.01 } )
      table.insert(data.raw.unit["bob-giant-poison-spitter"].loot, {  item = "small-alien-artifact",  count_min = 0,  count_max = 2,  probability = 0.01 } )
	  
	  table.insert(data.raw.unit["bob-giant-poison-spitter"].loot, {  item = "small-alien-artifact-orange",  count_min = 0,  count_max = 3,  probability = 0.01 } )
      table.insert(data.raw.unit["bob-giant-poison-spitter"].loot, {  item = "small-alien-artifact-green",  count_min = 0,  count_max = 3,  probability = 0.01 } )
      table.insert(data.raw.unit["bob-giant-poison-spitter"].loot, {  item = "small-alien-artifact",  count_min = 0,  count_max = 2,  probability = 0.01 } )
	  
      table.insert(data.raw.unit["bob-titan-spitter"].loot, {  item = "small-alien-artifact-orange",  count_min = 0,  count_max = 3,  probability = 0.01 } )
      table.insert(data.raw.unit["bob-titan-spitter"].loot, {  item = "small-alien-artifact-yellow",  count_min = 0,  count_max = 3,  probability = 0.01 } )
      table.insert(data.raw.unit["bob-titan-spitter"].loot, {  item = "small-alien-artifact-red",  count_min = 0,  count_max = 3,  probability = 0.01 } )
      table.insert(data.raw.unit["bob-titan-spitter"].loot, {  item = "small-alien-artifact",  count_min = 0,  count_max = 3,  probability = 0.01 } )

      table.insert(data.raw.unit["bob-behemoth-biter"].loot, {  item = "small-alien-artifact-blue",  count_min = 0,  count_max = 3,  probability = 0.01 } )
      table.insert(data.raw.unit["bob-behemoth-biter"].loot, {  item = "small-alien-artifact-purple",  count_min = 0,  count_max = 3,  probability = 0.01 } )
      table.insert(data.raw.unit["bob-behemoth-biter"].loot, {  item = "small-alien-artifact-green",  count_min = 0,  count_max = 3,  probability = 0.01 } )
      table.insert(data.raw.unit["bob-behemoth-biter"].loot, {  item = "small-alien-artifact-red",  count_min = 0,  count_max = 3,  probability = 0.01 } )
      table.insert(data.raw.unit["bob-behemoth-biter"].loot, {  item = "small-alien-artifact",  count_min = 0,  count_max = 3,  probability = 0.01 } )
	  
      table.insert(data.raw.unit["bob-behemoth-spitter"].loot, {  item = "small-alien-artifact-orange",  count_min = 0,  count_max = 3,  probability = 0.01 } )
      table.insert(data.raw.unit["bob-behemoth-spitter"].loot, {  item = "small-alien-artifact-yellow",  count_min = 0,  count_max = 3,  probability = 0.01 } )
      table.insert(data.raw.unit["bob-behemoth-spitter"].loot, {  item = "small-alien-artifact-green",  count_min = 0,  count_max = 3,  probability = 0.01 } )
      table.insert(data.raw.unit["bob-behemoth-spitter"].loot, {  item = "small-alien-artifact-red",  count_min = 0,  count_max = 3,  probability = 0.01 } )
      table.insert(data.raw.unit["bob-behemoth-spitter"].loot, {  item = "small-alien-artifact",  count_min = 0,  count_max = 3,  probability = 0.01 } )
	  
    table.insert(data.raw.unit["bob-leviathan-biter"].loot, {  item = "alien-artifact-blue",  count_min = 1,  count_max = 2,  probability = 0.5 } )
    table.insert(data.raw.unit["bob-leviathan-biter"].loot, {  item = "alien-artifact-orange",  count_min = 1,  count_max = 2,  probability = 0.5 } )
    table.insert(data.raw.unit["bob-leviathan-biter"].loot, {  item = "alien-artifact-purple",  count_min = 1,  count_max = 2,  probability = 0.5 } )
    table.insert(data.raw.unit["bob-leviathan-biter"].loot, {  item = "alien-artifact-yellow",  count_min = 1,  count_max = 2,  probability = 0.5 } )
    table.insert(data.raw.unit["bob-leviathan-biter"].loot, {  item = "alien-artifact-green",  count_min = 1,  count_max = 2,  probability = 0.5 } )
    table.insert(data.raw.unit["bob-leviathan-biter"].loot, {  item = "alien-artifact-red",  count_min = 1,  count_max = 2,  probability = 0.5 } )
    table.insert(data.raw.unit["bob-leviathan-biter"].loot, {  item = "alien-artifact",  count_min = 1,  count_max = 1,  probability = 0.5 } )
	
    table.insert(data.raw.unit["bob-leviathan-spitter"].loot, {  item = "alien-artifact-blue",  count_min = 1,  count_max = 2,  probability = 0.5 } )
    table.insert(data.raw.unit["bob-leviathan-spitter"].loot, {  item = "alien-artifact-orange",  count_min = 1,  count_max = 2,  probability = 0.5 } )
    table.insert(data.raw.unit["bob-leviathan-spitter"].loot, {  item = "alien-artifact-purple",  count_min = 1,  count_max = 2,  probability = 0.5 } )
    table.insert(data.raw.unit["bob-leviathan-spitter"].loot, {  item = "alien-artifact-yellow",  count_min = 1,  count_max = 2,  probability = 0.5 } )
    table.insert(data.raw.unit["bob-leviathan-spitter"].loot, {  item = "alien-artifact-green",  count_min = 1,  count_max = 2,  probability = 0.5 } )
    table.insert(data.raw.unit["bob-leviathan-spitter"].loot, {  item = "alien-artifact-red",  count_min = 1,  count_max = 2,  probability = 0.5 } )
    table.insert(data.raw.unit["bob-leviathan-spitter"].loot, {  item = "alien-artifact",  count_min = 1,  count_max = 1,  probability = 0.5 } )
  end