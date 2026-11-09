local simulations = require("__SpidertronPatrols__/prototypes/tips-and-tricks-simulations")

data:extend{
  {
    type = "tips-and-tricks-item-category",
    name = "spidertron-patrols",
    order = "--b[spidertron-patrols]"
  },
  {
    type = "tips-and-tricks-item",
    name = "sp-spidertron-patrols",
    tag = "[item=sp-spidertron-patrol-remote]",
    category = "spidertron-patrols",
    is_title = true,
    order = "a",
    starting_status = "unlocked",
    trigger = {type = "build-entity", entity = "spidertron", match_type_only = true},
    simulation = simulations.spidertron_patrols
  },
}
if settings.startup["sp-enable-dock"].value then
  data:extend{
  {
    type = "tips-and-tricks-item",
    name = "sp-dock",
    localised_name = data.raw["proxy-container"]["sp-spidertron-dock"].localised_name,
    tag = "[entity=sp-spidertron-dock]",
    category = "spidertron-patrols",
    order = "b",
    indent = 1,
    starting_status = "unlocked",
    trigger = {type = "unlock-recipe", recipe = "sp-spidertron-dock"},
    simulation = simulations.dock
  }}
end
data:extend{
  {
    type = "tips-and-tricks-item",
    name = "sp-spidertron-automation",
    tag = "[item=sp-spidertron-patrol-remote]",
    category = "spidertron-patrols",
    order = "c",
    indent = 1,
    starting_status = "unlocked",
    trigger = {type = "build-entity", entity = "spidertron", match_type_only = true},
    simulation = simulations.spidertron_automation
  },
  {
    type = "tips-and-tricks-item",
    name = "sp-wait-conditions",
    tag = "[img=utility/clock]",
    category = "spidertron-patrols",
    order = "d",
    indent = 1,
    starting_status = "unlocked",
    trigger = {type = "build-entity", entity = "spidertron", match_type_only = true},
    image = "__SpidertronPatrols__/graphics/tips-and-tricks/wait-conditions-tip.png"
  },
}
if mods["lex-aircraft"] or mods["maraxsis"] then
  data:extend{
  {
    type = "tips-and-tricks-item",
    name = "sp-automatic-refueling",
    tag = "[item=rocket-fuel]",
    category = "spidertron-patrols",
    order = "e",
    indent = 1,
    starting_status = "unlocked",
    trigger = {type = "build-entity", entity = "spidertron", match_type_only = true},
  }}
end
if mods["lex-aircraft"] then
  data:extend{
  {
    type = "tips-and-tricks-item",
    name = "sp-aircraft-automation",
    tag = "[entity=lex-flying-cargo]",
    category = "spidertron-patrols",
    order = "f",
    indent = 1,
    starting_status = "unlocked",
    trigger = {
      type = "or", triggers = {
        {type = "unlock-recipe", recipe = "lex-flying-gunship"},
        {type = "unlock-recipe", recipe = "lex-flying-cargo"},
        {type = "unlock-recipe", recipe = "lex-flying-heavyship"},
      },
    },
    simulation = simulations.aircraft
  }}
end
if mods["maraxsis"] then
  data:extend{
  {
    type = "tips-and-tricks-item",
    name = "sp-submarine-automation",
    tag = "[entity=maraxsis-diesel-submarine]",
    category = "spidertron-patrols",
    order = "g",
    indent = 1,
    starting_status = "unlocked",
    trigger = {
      type = "or", triggers = {
        {type = "unlock-recipe", recipe = "maraxsis-diesel-submarine"},
        {type = "unlock-recipe", recipe = "maraxsis-nuclear-submarine"},
      },
    },
    simulation = simulations.submarine
  }}
end
