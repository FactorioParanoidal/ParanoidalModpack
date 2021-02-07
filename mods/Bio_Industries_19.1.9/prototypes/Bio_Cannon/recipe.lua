--~ local BioInd = require('common')('Bio_Industries')

if BI.Settings.Bio_Cannon then

  data:extend({

  -- Hive Buster Turret
   {
    type = "recipe",
    name = "bi-bio-cannon",
    localised_name = {"entity-name.bi-bio-cannon"},
    localised_description = {"entity-description.bi-bio.cannon"},
    normal = {
        enabled = false,
        energy_required = 50,
        ingredients = {
          {"concrete", 100},
          {"radar", 1},
          {"steel-plate", 80},
          {"electric-engine-unit", 5},
        },
        result = "bi-bio-cannon-area",
        result_count = 1,
        allow_as_intermediate = false,  -- Added for 0.18.34/1.1.4
        always_show_made_in = false,    -- Added for 0.18.34/1.1.4
        allow_decomposition = true,     -- Added for 0.18.34/1.1.4
      },
      expensive = {
        enabled = false,
        energy_required = 100,
        ingredients = {
          {"concrete", 100},
          {"radar", 1},
          {"steel-plate", 120},
          {"electric-engine-unit", 15},
        },
        result = "bi-bio-cannon-area",
        result_count = 1,
        allow_as_intermediate = false,  -- Added for 0.18.34/1.1.4
        always_show_made_in = false,    -- Added for 0.18.34/1.1.4
        allow_decomposition = true,     -- Added for 0.18.34/1.1.4
      },
      allow_as_intermediate = false,
      always_show_made_in = false,      -- Changed for 0.18.34/1.1.4
      allow_decomposition = true,       -- Changed for 0.18.34/1.1.4
      subgroup = "defensive-structure",
      order = "b[turret]-e[bi-prototype-artillery-turret]"
   },

  })

end
