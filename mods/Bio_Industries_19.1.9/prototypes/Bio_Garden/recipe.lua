data:extend({
-- Bio garden
{
    type = "recipe",
    name = "bi-bio-garden",
    localised_name = {"entity-name.bi-bio-garden"},
    localised_description = {"entity-description.bi-bio-garden"},
    enabled = false,
    energy_required = 10,
    ingredients = 
    {
      {"stone-wall", 10},
      {"stone-crushed", 50},
      {"seedling", 30}
    },
    result = "bi-bio-garden",
    subgroup = "bio-bio-gardens-fluid",
    order = "a[bi]-1",
    allow_as_intermediate = true,
    always_show_made_in = false,
    allow_decomposition = true,
  },
--###############################################################################################
-- Large garden
{
  type = "recipe",
  name = "bi-bio-garden-large",
  localised_name = {"entity-name.bi-bio-garden-large"},
  --localised_description = {"entity-description.bi-bio-garden-large"},
  enabled = false,
  energy_required = 25,
  ingredients = 
  {
    {"bi-bio-garden", 9},
    {"seedling", 10},
    {"concrete", 10}
  },
  result = "bi-bio-garden-large",
  subgroup = "bio-bio-gardens-fluid",
  order = "a[bi]-2",
  allow_as_intermediate = true,
  always_show_made_in = false,
  allow_decomposition = true,
},
--###############################################################################################
-- Huge garden
{
  type = "recipe",
  name = "bi-bio-garden-huge",
  localised_name = {"entity-name.bi-bio-garden-huge"},
  --localised_description = {"entity-description.bi-bio-garden-huge"},
  enabled = false,
  energy_required = 60,
  ingredients = 
  {
    {"bi-bio-garden-large", 9},
    {"iron-plate", 30},
    {"concrete", 40},
    {"seedling", 100}
  },
  result = "bi-bio-garden-huge",
  subgroup = "bio-bio-gardens-fluid",
  order = "a[bi]-3",
  allow_as_intermediate = true,
  always_show_made_in = false,
  allow_decomposition = true,
},
--###############################################################################################
-- Clean Air 1
{
    type = "recipe",
    name = "bi-purified-air-1",
    icons = 
    {
      {icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/signal/bi_signal_recycle.png",
      icon_size = 64, icon_mipmaps = 4},
      {icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/signal/bi_signal_pollution_particle.png",
      icon_size = 64, icon_mipmaps = 4, scale = 0.3},
      {icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/fertilizer.png",
      icon_size = 64, icon_mipmaps = 4, scale = 0.25, shift = {-8, 8}}
    },
    category = "clean-air",
    subgroup = "bio-bio-gardens-fluid",
    order = "bi-purified-air-1",
    enabled = false,
    hide_from_player_crafting = true,
    always_show_products = false,
    always_show_made_in = true,
    allow_decomposition = false,
    show_amount_in_title = false,
    energy_required = 40,
    ingredients = 
    {
      {type = "fluid", name = "water", amount = 50},
      {type = "item", name = "fertilizer", amount = 1}
    },
    results = {{type = "item", name = "bi-purified-air", amount = 1, probability = 0}},
    crafting_machine_tint = 
    {
      primary     = {r = 0.43, g = 0.73, b = 0.37, a = 0.60},
      secondary   = {r = 0, g = 0, b = 0, a = 0},
      tertiary    = {r = 0, g = 0, b = 0, a = 0},
      quaternary  = {r = 0, g = 0, b = 0, a = 0}
    }
},
--###############################################################################################
  --- Clean Air 2
{
    type = "recipe",
    name = "bi-purified-air-2",
    icons = 
    {
      {icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/signal/bi_signal_recycle.png",
      icon_size = 64, icon_mipmaps = 4},
      {icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/signal/bi_signal_pollution_particle.png",
      icon_size = 64, icon_mipmaps = 4, scale = 0.3},
      {icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/fertilizer_advanced.png",
      icon_size = 64, icon_mipmaps = 4, scale = 0.25, shift = {-8, 8}}
    },
    category = "clean-air",
    subgroup = "bio-bio-gardens-fluid",
    order = "bi-purified-air-2",
    enabled = false,
    hide_from_player_crafting = true,
    always_show_products = false,
    always_show_made_in = true,
    allow_decomposition = false,
    show_amount_in_title = false,
    energy_required = 100,
    ingredients = 
    {
      {type = "fluid", name = "water", amount = 50},
      {type = "item", name = "bi-adv-fertilizer", amount = 1},
    },
    results = {{type = "item", name = "bi-purified-air", amount = 1, probability = 0}},
    crafting_machine_tint = 
    {
      primary     = {r = 0.73, g = 0.37, b = 0.52, a = 0.60},
      secondary   = {r = 0, g = 0, b = 0, a = 0},
      tertiary    = {r = 0, g = 0, b = 0, a = 0},
      quaternary  = {r = 0, g = 0, b = 0, a = 0}
    }
},
--###############################################################################################
-- Clean Air 0
{
  type = "recipe",
  name = "bi-purified-air-0",
  icons = 
  {
    {icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/signal/bi_signal_recycle.png",
    icon_size = 64, icon_mipmaps = 4},
    {icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/signal/bi_signal_pollution_particle.png",
    icon_size = 64, icon_mipmaps = 4, scale = 0.3},
    --{icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/fertilizer.png",
    --icon_size = 64, icon_mipmaps = 4, scale = 0.25, shift = {-8, 8}}
  },
  category = "clean-air",
  subgroup = "bio-bio-gardens-fluid",
  order = "bi-purified-air-0",
  enabled = false,
  hide_from_player_crafting = true,
  always_show_products = false,
  always_show_made_in = true,
  allow_decomposition = false,
  show_amount_in_title = false,
  energy_required = 10,
  ingredients = 
  {
    {type = "fluid", name = "water", amount = 50},
    --{type = "item", name = "fertilizer", amount = 1}
  },
  results = {{type = "item", name = "bi-purified-air", amount = 1, probability = 0}},
  crafting_machine_tint = 
  {
    primary     = {r = 255, g = 255, b = 255, a = 0.60},
    secondary   = {r = 0, g = 0, b = 0, a = 0},
    tertiary    = {r = 0, g = 0, b = 0, a = 0},
    quaternary  = {r = 0, g = 0, b = 0, a = 0}
  }
},

})