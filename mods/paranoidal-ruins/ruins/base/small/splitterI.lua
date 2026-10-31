return
{
  variables =
  {
    {name = "random-splitter", type = "entity-expression", value = {type = "random-of-entity-type", entity_type = "splitter"}}
  },
  entities =
  {
    {{type = "variable", name = "random-splitter"}, {x = 0, y = -1.5}, {dir = "south", dmg = {dmg = {type = "random", min = 30, max = 300}}}},
    {{type = "variable", name = "random-splitter"}, {x = 1, y = -0.5}, {dir = "south", dmg = {dmg = {type = "random", min = 30, max = 300}}}},
    {{type = "variable", name = "random-splitter"}, {x = 2, y = -1.5}, {dir = "south", dmg = {dmg = {type = "random", min = 30, max = 300}}}},
    {{type = "variable", name = "random-splitter"}, {x = 0, y = 0.5}, {dir = "south", dmg = {dmg = {type = "random", min = 30, max = 300}}}},
    {{type = "variable", name = "random-splitter"}, {x = 1, y = 1.5}, {dir = "south", dmg = {dmg = {type = "random", min = 30, max = 300}}}},
    {{type = "variable", name = "random-splitter"}, {x = 2, y = 0.5}, {dir = "south", dmg = {dmg = {type = "random", min = 30, max = 300}}}},
  },
}
