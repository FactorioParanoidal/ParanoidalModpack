-- Trains, Factorissimo, teleporters, storage, robots and nanobots.
local lib = require("prototypes.content.lib")

return lib.list(
  {id = "rusty-engine", kind = "build", entity = "yir_usl"},
  {id = "cyber-dispatcher", kind = "build", entity = "cybersyn-combinator", amounts = {10, 100}},
  {id = "metro", kind = "build", entity = "express-subterranean-belt", amount = 100},
  {id = "underground-plumbing", kind = "build", entity = "subterranean-pipe", amount = 100},
  {id = "bigger-inside", kind = "build", entity = "factory-3"},
  {id = "matryoshka", kind = "research", technology = "factory-recursion-t2"},
  {id = "portal", kind = "build", entity = "teleporter", amounts = {1, 10, 50}},
  {id = "bottomless-barrel", kind = "build", entity = "fluid-memory-unit", amount = 10},
  {id = "black-hole", kind = "build", entity = "memory-unit", amount = 10},
  {id = "postman", kind = "robots-deliver", amounts = {1e4, 1e6, 1e8}, icon = {entity = "logistic-robot"}},
  {id = "spring-cleaning", kind = "robots-deconstruct", amounts = {1e4, 1e6}, icon = {entity = "construction-robot"}},
  {id = "build-together", kind = "robots-construct", amounts = {1e5, 1e7}, icon = {entity = "construction-robot"}},
  {id = "nano-constructor", kind = "produce", item = "ammo-nano-constructors", amount = 1e4},
  {id = "nano-leveler", kind = "produce", item = "ammo-nano-levelers", amount = 1e4},
  {id = "swarm", kind = "combat-robots", amounts = {250, 500}, icon = {item = "destroyer-capsule"}}
)
