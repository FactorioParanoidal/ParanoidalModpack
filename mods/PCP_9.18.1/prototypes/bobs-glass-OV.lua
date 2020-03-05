data:extend({{
   type = "recipe",
   name = "pmma-glass",
   category = "chemistry",
 subgroup = "petrochem-solids",
   energy_required = 2,
 enabled = "false",
   ingredients ={
  {type="item", name="solid-pmma", amount=1},
 },
   results=
   {
    {type="item", name="glass", amount=10},
   },
   --icon = "",
   order = "ea[pmma-glass]",
},
{
   type = "recipe",
   name = "pc-glass",
   category = "chemistry",
 subgroup = "petrochem-solids",
   energy_required = 2,
 enabled = "false",
   ingredients ={
  {type="item", name="solid-pc", amount=1},
 },
   results=
   {
    {type="item", name="glass", amount=2},--1
   },
   --icon = "",
   order = "fb[pc-glass]",
},})
