

data:extend({{
    name = "NE_Alien_Artifacts",
    type = "bool-setting",
    setting_type = "startup",
    default_value = true,
    order = "a[modifier]-a1[Artifacts]",
    per_user = false
}, 
-------
--Alien Artifacts turn into worms...
-------
{
  name = "NE_Alien_Artifact_Eggs",
  type = "bool-setting",
  setting_type = "startup",
  default_value = true,
  order = "a[modifier]-a2[Artifacts]",
  per_user = false
}, 
{
    name = "NE_Scorched_Earth",
    type = "bool-setting",
    setting_type = "startup",
    default_value = true,
    order = "a[modifier]-b[Scorched_Earth]",
    per_user = false
}, 
{
    name = "NE_Burning_Buildings",
    type = "bool-setting",
    setting_type = "startup",
    default_value = true,
    order = "a[modifier]-c[Burning_Buildings]",
    per_user = false
}, 
{
    name = "NE_Remove_Blood_Spatter",
    type = "bool-setting",
    setting_type = "startup",
    default_value = true,
    order = "a[modifier]-e[Remove_Blood_Spatter]",
    per_user = false
}, 
{
    name = "NE_Remove_Vanilla_Spawners",
    type = "bool-setting",
    setting_type = "startup",
    default_value = false,
    order = "a[modifier]-f[NE_Remove_Vanilla_Spawners]",
    per_user = false
}, 
{
    name = "NE_Adjust_Vanilla_Worms",
    type = "bool-setting",
    setting_type = "startup",
    default_value = true,
    order = "a[modifier]-g[NE_Adjust_Vanilla_Worms]",
    per_user = false
}, 
--- Spawners and Unit Removal
{
    name = "NE_Blue_Spawners",
    type = "bool-setting",
    setting_type = "startup",
    default_value = true,
    order = "a[modifier]-h[NE_Blue_Spawners-0]",
    per_user = false
}, 
{
  name = "NE_Biter_Breeder",
  type = "bool-setting",
  setting_type = "startup",
  default_value = true,
  order = "a[modifier]-h[NE_Blue_Spawners-1]",
  per_user = false
}, 
{
  name = "NE_Spitter_Breeder",
  type = "bool-setting",
  setting_type = "startup",
  default_value = true,
  order = "a[modifier]-h[NE_Blue_Spawners-2]",
  per_user = false
}, 
{
    name = "NE_Red_Spawners",
    type = "bool-setting",
    setting_type = "startup",
    default_value = true,
    order = "a[modifier]-i[NE_Red_Spawners-0]",
    per_user = false
},
{
  name = "NE_Biter_Fire",
  type = "bool-setting",
  setting_type = "startup",
  default_value = true,
  order = "a[modifier]-i[NE_Red_Spawners-1]",
  per_user = false
},
{
  name = "NE_Spitter_Fire",
  type = "bool-setting",
  setting_type = "startup",
  default_value = true,
  order = "a[modifier]-i[NE_Red_Spawners-2]",
  per_user = false
},
{
    name = "NE_Green_Spawners",
    type = "bool-setting",
    setting_type = "startup",
    default_value = true,
    order = "a[modifier]-j[NE_Green_Spawners-0]",
    per_user = false
}, 
{
  name = "NE_Biter_Fast",
  type = "bool-setting",
  setting_type = "startup",
  default_value = true,
  order = "a[modifier]-j[NE_Green_Spawners-1]",
  per_user = false
}, 
{
  name = "NE_Spitter_Ulaunch",
  type = "bool-setting",
  setting_type = "startup",
  default_value = true,
  order = "a[modifier]-j[NE_Green_Spawners-2]",
  per_user = false
}, 
{
    name = "NE_Yellow_Spawners",
    type = "bool-setting",
    setting_type = "startup",
    default_value = true,
    order = "a[modifier]-k[NE_Yellow_Spawners-0]",
    per_user = false
}, 
{
  name = "NE_Biter_Wallbreaker",
  type = "bool-setting",
  setting_type = "startup",
  default_value = true,
  order = "a[modifier]-k[NE_Yellow_Spawners-1]",
  per_user = false
}, 
{
  name = "NE_Spitter_Webshooter",
  type = "bool-setting",
  setting_type = "startup",
  default_value = true,
  order = "a[modifier]-k[NE_Yellow_Spawners-2]",
  per_user = false
}, 
{
    name = "NE_Pink_Spawners",
    type = "bool-setting",
    setting_type = "startup",
    default_value = true,
    order = "a[modifier]-l[NE_Pink_Spawners-0]",
    per_user = false
}, 
{
  name = "NE_Biter_Tank",
  type = "bool-setting",
  setting_type = "startup",
  default_value = true,
  order = "a[modifier]-l[NE_Pink_Spawners-1]",
  per_user = false
}, 
{
  name = "NE_Spitter_Mine",
  type = "bool-setting",
  setting_type = "startup",
  default_value = true,
  order = "a[modifier]-l[NE_Pink_Spawners-2]",
  per_user = false
}, 

----- Use Alternative Graphics
{
  name = "NE_Alternative_Graphics",
  type = "bool-setting",
  setting_type = "startup",
  default_value = true,
  order = "a[modifier]-m1[NE_Alternative_Graphics]",
  per_user = false
}, 

---------
{
  name = "NE_Flying_Units",
  type = "bool-setting",
  setting_type = "startup",
  default_value = true,
  order = "a[modifier]-m2[NE_Flying_Units]",
  per_user = false
}, 

--------- Blood Spatter removal to increase performance

{
  name = "NE_Blood_Removal",
  type = "bool-setting",
  setting_type = "startup",
  default_value = false,
  order = "a[modifier]-m3[NE_Blood_Removal]",
  per_user = false
},



----------------------------------------
{
    name = "NE_Challenge_Mode",
    type = "bool-setting",
    setting_type = "startup",
    default_value = false,
    order = "a[modifier]-m4[NE_Challenge_Mode]",
    per_user = false
}, 
{
    name = "NE_Remove_Biter_Search",
    type = "bool-setting",
    setting_type = "runtime-global",
    default_value = false,
    order = "a[modifier]-n[NE_Remove_Biter_Search]",
    --per_user = false
}, 
{
    name = "NE_Expansion_Management",
    type = "bool-setting",
    setting_type = "startup",
    default_value = true,
    order = "a[modifier]-o[NE_Expansion_Management]",
    per_user = false
}, 
{
    name = "NE_Difficulty",
    type = "int-setting",
    setting_type = "startup",
    default_value = 1,
    maximum_value = 5,
    minimum_value = 1,
    allowed_values = { 1, 2, 3, 4, 5 },


    order = "a[modifier]-q[Difficulty]",
    per_user = false
}, 
{
    name = "NE_Starting_Evolution",
    type = "int-setting",
    setting_type = "startup",
    default_value = 0,
    maximum_value = 100,
    minimum_value = 0,
    order = "a[modifier]-r[NE_Starting_Evolution]",
    per_user = false
},
{
  name = "NE_QC_Mode",
  type = "bool-setting",
  setting_type = "runtime-global",
  default_value = false,
  order = "a[modifier]-xxxx[NE_QC_Mode]",
  --per_user = false
}


})

