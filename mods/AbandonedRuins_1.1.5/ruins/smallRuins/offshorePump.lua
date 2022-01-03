return
{
  entities =
  {
    {"storage-tank", {x = -1.5, y = -1.5}, {dir = "east", dmg = {dmg = {type = "random", min = 40, max = 150}}, dead = 0.3}},
    {"pipe", {x = -2.5, y = 1.5}, {dmg = {dmg = {type = "random", min = 0, max = 50}}}},
    {"pipe", {x = -2.5, y = 0.5}, {dmg = {dmg = {type = "random", min = 0, max = 50}}}},
    {"offshore-pump", {x = -1.5, y = 1.5}, {dir = "east"}},
  },
  tiles =
  {
    {"water", {x = -1, y = 0}},
    {"water", {x = -1, y = 1}},
    {"water", {x = -1, y = 2}},
    {"water", {x = 0, y = -1}},
    {"water", {x = 0, y = 0}},
    {"water", {x = 0, y = 1}},
    {"water", {x = 0, y = 2}},
    {"water", {x = 1, y = -1}},
    {"water", {x = 1, y = 0}},
    {"water", {x = 1, y = 1}},
    {"water", {x = 1, y = 2}},
    {"water", {x = 2, y = -1}},
    {"water", {x = 2, y = 0}},
    {"water", {x = 2, y = 1}},
    {"water", {x = 2, y = 2}},
  }
}
