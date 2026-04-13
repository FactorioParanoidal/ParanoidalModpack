
if BI.Settings.Bio_Cannon then

  data:extend({

  -- Hive Buster Turret
   {
    type = "recipe",
    name = "bi-bio-cannon",
    localised_name = {"entity-name.bi-bio-cannon"},
    localised_description = {"entity-description.bi-bio.cannon"},
        enabled = false,
        energy_required = 50,
        ingredients = {
          {type="item", name="concrete", amount=100},
          {type="item", name="radar", amount=1},
          {type="item", name="steel-plate", amount=80},
          {type="item", name="electric-engine-unit", amount=5},
        },
        results = {{type="item", name="bi-bio-cannon", amount=1}},
        allow_as_intermediate = false,  -- Added for 0.18.34/1.1.4
        always_show_made_in = true,    -- Added for 0.18.34/1.1.4
        allow_decomposition = false,     -- Added for 0.18.34/1.1.4
      subgroup = "defensive-structure",
      order = "b[turret]-e[bi-prototype-artillery-turret]"
   },

  })

end
