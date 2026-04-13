local achievement_name = "Stuckez12-Radiation-achievement-"
local mod_dir = "__Stuckez12_Radiation__/graphics/achievement/"

data:extend({
  {
    type = "achievement",
    name = achievement_name .. "that-tickles",

    icon = mod_dir .. "that-tickles.png",
    icon_size = 128,
    localised_name = {"achievement-name." .. achievement_name .. "that-tickles"},
    localised_description = {"achievement-description." .. achievement_name .. "that-tickles"}
  },
  {
    type = "achievement",
    name = achievement_name .. "cant-touch-me",

    icon = mod_dir .. "cant-touch-me.png",
    icon_size = 128,
    localised_name = {"achievement-name." .. achievement_name .. "cant-touch-me"},
    localised_description = {"achievement-description." .. achievement_name .. "cant-touch-me"}
  },
  {
    type = "achievement",
    name = achievement_name .. "too-much-spice",

    icon = mod_dir .. "too-much-spice.png",
    icon_size = 128,
    localised_name = {"achievement-name." .. achievement_name .. "too-much-spice"},
    localised_description = {"achievement-description." .. achievement_name .. "too-much-spice"}
  },
  {
    type = "achievement",
    name = achievement_name .. "never-stood-a-chance",

    icon = mod_dir .. "never-stood-a-chance.png",
    icon_size = 128,
    localised_name = {"achievement-name." .. achievement_name .. "never-stood-a-chance"},
    localised_description = {"achievement-description." .. achievement_name .. "never-stood-a-chance"}
  },
  {
    type = "achievement",
    name = achievement_name .. "resist-spicy-food",

    icon = mod_dir .. "resist-spicy-food.png",
    icon_size = 128,
    localised_name = {"achievement-name." .. achievement_name .. "resist-spicy-food"},
    localised_description = {"achievement-description." .. achievement_name .. "resist-spicy-food"}
  },
  {
    type = "achievement",
    name = achievement_name .. "gamma-or-gammon",

    icon = mod_dir .. "gamma-or-gammon.png",
    icon_size = 128,
    localised_name = {"achievement-name." .. achievement_name .. "gamma-or-gammon"},
    localised_description = {"achievement-description." .. achievement_name .. "gamma-or-gammon"}
  },
  {
    type = "achievement",
    name = achievement_name .. "i-am-invincible",

    icon = mod_dir .. "i-am-invincible.png",
    icon_size = 128,
    localised_name = {"achievement-name." .. achievement_name .. "i-am-invincible"},
    localised_description = {"achievement-description." .. achievement_name .. "i-am-invincible"}
  },
  {
    type = "achievement",
    name = achievement_name .. "god-of-radiation",

    icon = mod_dir .. "god-of-radiation.png",
    icon_size = 128,
    localised_name = {"achievement-name." .. achievement_name .. "god-of-radiation"},
    localised_description = {"achievement-description." .. achievement_name .. "god-of-radiation"}
  },
  {
    type = "equip-armor-achievement",
    name = achievement_name .. "spice-suit",
    armor = "radiation-suit",
    alternative_armor = "radiation-suit",
    limit_quality = "normal",

    icon = mod_dir .. "spice-suit.png",
    icon_size = 128,
    localised_name = {"achievement-name." .. achievement_name .. "spice-suit"},
    localised_description = {"achievement-description." .. achievement_name .. "spice-suit"}
  },
  {
    type = "achievement",
    name = achievement_name .. "outsourced-resistance",

    icon = mod_dir .. "outsourced-resistance.png",
    icon_size = 128,
    localised_name = {"achievement-name." .. achievement_name .. "outsourced-resistance"},
    localised_description = {"achievement-description." .. achievement_name .. "outsourced-resistance"}
  },
  {
    type = "achievement",
    name = achievement_name .. "naked-outsource",

    icon = mod_dir .. "naked-outsource.png",
    icon_size = 128,
    localised_name = {"achievement-name." .. achievement_name .. "naked-outsource"},
    localised_description = {"achievement-description." .. achievement_name .. "naked-outsource"}
  },
  {
    type = "research-achievement",
    name = achievement_name .. "diy-resistance",

    icon = mod_dir .. "diy-resistance.png",
    icon_size = 128,
    localised_name = {"achievement-name." .. achievement_name .. "diy-resistance"},
    localised_description = {"achievement-description." .. achievement_name .. "diy-resistance"},
    technology = "radiation-protection",
    research_all = false
  },
  {
    type = "research-achievement",
    name = achievement_name .. "rad-searcher",

    icon = mod_dir .. "rad-searcher.png",
    icon_size = 128,
    localised_name = {"achievement-name." .. achievement_name .. "rad-searcher"},
    localised_description = {"achievement-description." .. achievement_name .. "rad-searcher"},
    technology = "advanced-radiation-protection",
    research_all = false
  },
  {
    type = "research-achievement",
    name = achievement_name .. "resistance-master",

    icon = mod_dir .. "resistance-master.png",
    icon_size = 128,
    localised_name = {"achievement-name." .. achievement_name .. "resistance-master"},
    localised_description = {"achievement-description." .. achievement_name .. "resistance-master"},
    technology = "near-total-radiation-protection",
    research_all = false
  }
})
