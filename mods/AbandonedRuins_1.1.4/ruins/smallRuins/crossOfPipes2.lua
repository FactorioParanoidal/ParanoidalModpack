return
{
  entities =
  {
    {"pipe-to-ground", {x = 0.5, y = -1.5}, {dir = "south", fluids = {["crude-oil"] = {type = "random", min = 0, max = 100}}}},
    {"pipe", {x = 0.5, y = -0.5}, {}},
    {"pipe-to-ground", {x = -0.5, y = 0.5}, {dir = "east", }},
    {"pipe", {x = 0.5, y = 1.5}, {}},
    {"pipe", {x = 0.5, y = 0.5}, {}},
    {"pipe-to-ground", {x = 1.5, y = 0.5}, {dir = "west", }},
    {"pipe-to-ground", {x = 0.5, y = 2.5}, {fluids = {["crude-oil"] = {type = "random", min = 0, max = 100}}}},
  },
}
