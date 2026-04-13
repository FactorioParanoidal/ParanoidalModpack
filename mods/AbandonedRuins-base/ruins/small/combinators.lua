return
{
  entities =
  {
    {"constant-combinator", {x = -1.5, y = -2.5}, {dir = "south", dmg = {dmg = {type = "random", min = 20, max = 120}}, dead = 0.2}},
    {"constant-combinator", {x = 1.5, y = -3.5}, {dir = "south", dmg = {dmg = {type = "random", min = 20, max = 120}}, dead = 0.2}},
    {"arithmetic-combinator", {x = 1.5, y = -2}, {dir = "south", dead = 0.1}},
    {"decider-combinator", {x = -1.5, y = -1}, {dir = "south", dead = 0.1}},
    {"medium-electric-pole-remnants", {x = 0.5, y = -1.5}, {}},
    {"programmable-speaker", {x = 1.5, y = 1.5}, {dead = 0.1}},
  },
}
