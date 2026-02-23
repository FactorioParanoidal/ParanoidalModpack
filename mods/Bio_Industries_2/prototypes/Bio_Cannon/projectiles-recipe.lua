
if BI.Settings.Bio_Cannon then

  data:extend({

    -- Prototype Artillery Proto Ammo
    {
      type= "recipe",
      name= "bi-bio-cannon-proto-ammo",
      localised_name = {"item-name.bi-bio-cannon-proto-ammo"},
      localised_description = {"item-description.bi-bio-cannon-proto-ammo"},
      enabled = false,
      energy_required = 2,
      ingredients = {{type="item", name="iron-plate", amount=10}, {type="item", name="explosives", amount=10}},
      results = {{type="item", name="bi-bio-cannon-proto-ammo", amount=1}},
      subgroup = "bi-ammo",
      order = "z[Bio_Cannon_Ammo]-a[Proto]",
      allow_as_intermediate = true,     -- Added for 0.18.34/1.1.4
      always_show_made_in = false,      -- Added for 0.18.34/1.1.4
      allow_decomposition = true,       -- Added for 0.18.34/1.1.4
    },

    -- Prototype Artillery Basic Ammo
    {
      type= "recipe",
      name= "bi-bio-cannon-basic-ammo",
      localised_name = {"item-name.bi-bio-cannon-basic-ammo"},
      localised_description = {"item-description.bi-bio-cannon-basic-ammo"},
      enabled = false,
      energy_required = 4,
      ingredients = {{type="item", name="bi-bio-cannon-proto-ammo", amount=1}, {type="item", name="rocket", amount=10}},
      results = {{type="item", name="bi-bio-cannon-basic-ammo", amount=1}},
      subgroup = "bi-ammo",
      order = "z[Bio_Cannon_Ammo]-b[Basic]",
      allow_as_intermediate = false,    -- Added for 0.18.34/1.1.4
      always_show_made_in = false,      -- Added for 0.18.34/1.1.4
      allow_decomposition = true,       -- Added for 0.18.34/1.1.4
    },

    -- Prototype Artillery Poison Ammo
    {
      type= "recipe",
      name= "bi-bio-cannon-poison-ammo",
      localised_name = {"item-name.bi-bio-cannon-poison-ammo"},
      localised_description = {"item-description.bi-bio-cannon-poison-ammo"},
      enabled = false,
      energy_required = 8,
      ingredients = {{type="item", name="bi-bio-cannon-basic-ammo", amount=1}, {type="item", name="poison-capsule", amount=5}, {type="item", name="explosive-rocket", amount=5}},
      results = {{type="item", name="bi-bio-cannon-poison-ammo", amount=1}},
      subgroup = "bi-ammo",
      order = "z[Bio_Cannon_Ammo]-c[Poison]",
      allow_as_intermediate = false,    -- Added for 0.18.34/1.1.4
      always_show_made_in = false,      -- Added for 0.18.34/1.1.4
      allow_decomposition = true,       -- Added for 0.18.34/1.1.4
    },
  })
end
