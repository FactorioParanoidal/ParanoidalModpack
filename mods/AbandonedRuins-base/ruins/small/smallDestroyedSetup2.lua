return
{
  entities =
  {
    {"transport-belt", {x = -2.5, y = -2.5}, {dir = "south", dead = 0.2}},
    {"transport-belt", {x = -2.5, y = -1.5}, {dir = "south", dead = 0.2}},
    {"transport-belt", {x = -2.5, y = -0.5}, {dir = "south", dead = 0.2}},
    {"transport-belt", {x = -0.5, y = -1.5}, {dir = "east", dmg = {dmg = {type = "random", min = 5, max = 35}}, dead = 0.2}},
    {"assembling-machine-1", {x = 2.5, y = 0.5}, {dmg = {dmg = {type = "random", min = 50, max = 150}}, dead = 0.2}},
    {"transport-belt", {x = 1.5, y = -1.5}, {dir = "east", dmg = {dmg = {type = "random", min = 5, max = 35}}, dead = 0.2}},
    {"transport-belt", {x = 0.5, y = -1.5}, {dir = "east", dmg = {dmg = {type = "random", min = 5, max = 35}}, dead = 0.2}},
    {"inserter", {x = -2.5, y = 0.5}, {dead = 0.2}},
    {"assembling-machine-1", {x = -1.5, y = 2.5}, {dmg = {dmg = {type = "random", min = 50, max = 150}}, dead = 0.2}},
    {"inserter", {x = 0.5, y = 1.5}, {dir = "west", dead = 0.2}},
    {"inserter", {x = 1.5, y = 2.5}, {dead = 0.2}},
  },
}
