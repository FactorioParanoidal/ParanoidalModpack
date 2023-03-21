return
{
  entities =
  {
    {"reactor-sarcophagus", {x = 0.5, y = -1}, {fluids = {
        ["reactor-sarcophagus-amount"] = {type = "random", min = 1e3, max = 1e6},
    }, dmg = {type = "radioactivity-gamma-radiation", dmg = {type = "random", min = 0, max = 900}}, }},
    {"pipe-to-ground", {x = -3.5, y =  0}, {dir = "east", dmg = {dmg = {type = "random", min = 0, max = 119}}, }},
    {"pipe-to-ground", {x = -1.5, y =  1}, {dir = "east", dmg = {dmg = {type = "random", min = 0, max = 119}}, }},
    {"pipe-to-ground", {x =  2.5, y =  2}, {dir = "nord", dmg = {dmg = {type = "random", min = 0, max = 119}}, }},
    {"pipe-to-ground", {x =  1.5, y =  1}, {dir = "nord", dmg = {dmg = {type = "random", min = 0, max = 119}}, }},
    {"pipe", {x = -2.5, y =  0}, {dmg = {dmg = {type = "random", min = 0, max = 90}}, }},
    {"pipe", {x = -1.5, y =  0}, {dmg = {dmg = {type = "random", min = 0, max = 90}}, }},
    {"pipe", {x =  2.5, y =  0}, {dmg = {dmg = {type = "random", min = 0, max = 90}}, }},
    {"pipe", {x = -0.5, y =  1}, {dmg = {dmg = {type = "random", min = 0, max = 90}}, }},
    {"pipe", {x =  2.5, y =  1}, {dmg = {dmg = {type = "random", min = 0, max = 90}}, }},
  },
}
