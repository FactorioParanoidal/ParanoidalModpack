return
{
  entities =
  {
    {"pumpjack", {x = -0.5, y = -2.5}, {dir = "east", dead = 1}},
    {"crude-oil", {x = -0.5, y = -2.5}, {}},
    {"storage-tank", {x = 2.5, y = -2.5}, {dmg = {dmg = {type = "random", min = 0, max = 80}}, dead = 0.4}},
    {"medium-electric-pole", {x = 0.5, y = -0.5}, {dmg = {dmg = {type = "random", min = 0, max = 80}}, dead = 0.4}},
    {"storage-tank", {x = 2.5, y = 0.5}, {dir = "east", dmg = {dmg = {type = "random", min = 0, max = 80}}, dead = 0.4}},
    {"pipe", {x = -3.5, y = 0.5}, {dmg = {dmg = {type = "random", min = 0, max = 80}}, dead = 0.4}},
    {"pipe", {x = -2.5, y = 0.5}, {dmg = {dmg = {type = "random", min = 0, max = 80}}, dead = 0.4}},
    {"pipe", {x = -1.5, y = 0.5}, {dmg = {dmg = {type = "random", min = 0, max = 80}}, dead = 0.4}},
    {"pipe", {x = -1.5, y = 1.5}, {dmg = {dmg = {type = "random", min = 0, max = 80}}, dead = 0.4}},
    {"pump", {x = 0, y = 1.5}, {dir = "west", dmg = {dmg = {type = "random", min = 0, max = 80}}, dead = 0.4}},
  },
}
