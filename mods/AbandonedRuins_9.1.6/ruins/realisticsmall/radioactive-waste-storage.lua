return
{
  entities =
  {
    {"storage-tank", {x = 0.5, y = 1}, {dir = "east", fluids = {
        ["radioactive-contaminated-water"] = {type = "random", min = 1e3, max = 25e3},
    }, dmg = {dmg = {type = "random", min = 0, max = 420}}, }},
    {"pipe-to-ground", {x =  0.5, y = -2}, {dir = "east", dmg = {dmg = {type = "random", min = 0, max = 119}}, }},
    {"pipe-to-ground", {x =  3.5, y =  0}, {dir = "west", dmg = {dmg = {type = "random", min = 0, max = 119}}, }},
    {"pipe-to-ground", {x = -3.5, y =  2}, {dir = "east", dmg = {dmg = {type = "random", min = 0, max = 119}}, }},
    {"pipe-to-ground", {x = -0.5, y =  4}, {dir = "nord", dmg = {dmg = {type = "random", min = 0, max = 119}}, }},
    {"pipe", {x =  1.5, y = -2}, {dmg = {dmg = {type = "random", min = 0, max = 90}}, }},
    {"pipe", {x =  1.5, y = -1}, {dmg = {dmg = {type = "random", min = 0, max = 90}}, }},
    {"pipe", {x =  2.5, y =  0}, {dmg = {dmg = {type = "random", min = 0, max = 90}}, }},
    {"pipe", {x = -2.5, y =  2}, {dmg = {dmg = {type = "random", min = 0, max = 90}}, }},
    {"pipe", {x = -1.5, y =  2}, {dmg = {dmg = {type = "random", min = 0, max = 90}}, }},
    {"pipe", {x = -0.5, y =  3}, {dmg = {dmg = {type = "random", min = 0, max = 90}}, }},
  },
}
