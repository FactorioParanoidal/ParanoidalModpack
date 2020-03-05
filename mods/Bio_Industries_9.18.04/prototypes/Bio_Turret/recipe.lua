local iconpath = "__Bio_Industries__/graphics/icons/"

data:extend({


        --- Basic Dart Ammo
        {
                type = "recipe",
                name = "bi-dart-magazine-basic",
                icon = iconpath .. "basic_dart_icon.png",
                icon_size = 32,
                normal =
                {
                        enabled = true,
                        energy_required = 4,
                        ingredients =
                        {
                                {"wood", 10},
                        },
                  result = "bi-dart-magazine-basic",
                  result_count = 10,
                  main_product = "",
                },
                expensive =
                {
                        enabled = true,
                        energy_required = 6,
                        ingredients =
                        {
                                {"wood", 10},
                        },
                  result = "bi-dart-magazine-basic",
                  result_count = 8,
                  main_product = "",
                },
                always_show_made_in = true,
                allow_decomposition = false,
                subgroup = "bi-ammo",
                order = "[bio-ammo]-a-[darts]-1",
        },

        --- Standard Dart Ammo
        {
                type = "recipe",
                name = "bi-dart-magazine-standard",
                icon = iconpath .. "standard_dart_icon.png",
                icon_size = 32,
                normal =
                {
                        enabled = false,
                        energy_required = 5,
                        ingredients =
                        {
                                {"bi-dart-magazine-basic", 10},
                                {"copper-plate", 5},
                        },
                  result = "bi-dart-magazine-standard",
                  result_count = 10,
                  main_product = "",
                },
                expensive =
                {
                        enabled = false,
                        energy_required = 8,
                        ingredients =
                        {
                                {"bi-dart-magazine-basic", 8},
                                {"copper-plate", 5},
                        },
                  result = "bi-dart-magazine-standard",
                  result_count = 8,
                  main_product = "",
                },
                always_show_made_in = true,
                allow_decomposition = false,
                subgroup = "bi-ammo",
                order = "[bio-ammo]-a-[darts]-2",
        },

        --- Enhanced Dart Ammo
        {
                type = "recipe",
                name = "bi-dart-magazine-enhanced",
                icon = iconpath .. "enhanced_dart_icon.png",
                icon_size = 32,
                normal =
                {
                        enabled = false,
                        energy_required = 6,
                        ingredients =
                        {
                                {"bi-dart-magazine-standard", 10},
                                {"plastic-bar", 5},
                        },
                  result = "bi-dart-magazine-enhanced",
                  result_count = 10,
                  main_product = "",
                },
                expensive =
                {
                        enabled = false,
                        energy_required = 9,
                        ingredients =
                        {
                                {"bi-dart-magazine-standard", 8},
                                {"plastic-bar", 5},
                        },
                  result = "bi-dart-magazine-enhanced",
                  result_count = 8,
                  main_product = "",
                },
                always_show_made_in = true,
                allow_decomposition = false,
                subgroup = "bi-ammo",
                order = "[bio-ammo]-a-[darts]-3",
        },

        --- Poison Dart Ammo
        {
                type = "recipe",
                name = "bi-dart-magazine-poison",
                icon = iconpath .. "poison_dart_icon.png",
                icon_size = 32,
                normal =
                {
                  enabled = false,
                  energy_required = 8,
                  ingredients =
                  {
                    {"bi-dart-magazine-enhanced", 10},
                    {"poison-capsule", 5},
                  },
                  result = "bi-dart-magazine-poison",
                  result_count = 10,
                  main_product = "",
                },
                expensive =
                {
                  enabled = false,
                  energy_required = 12,
                  ingredients =
                  {
                    {"bi-dart-magazine-enhanced", 8},
                    {"poison-capsule", 5},
                  },
                  result = "bi-dart-magazine-poison",
                  result_count = 8,
                  main_product = "",
                },
                always_show_made_in = true,
                allow_decomposition = false,
                subgroup = "bi-ammo",
                order = "[bio-ammo]-a-[darts]-4",
        },

        --- Dart Turret
  {
    type = "recipe",
    name = "bi-dart-turret",
    icon = iconpath .. "bio_turret_icon.png",
    icon_size = 32,
        normal =
                {
                  enabled = true,
                  energy_required = 8,
                  ingredients =
                  {
                    {"iron-gear-wheel", 5},
                    {"wood", 20},
                  },
                  result = "bi-dart-turret",
                  result_count = 1,
                  main_product = "",
                },

        expensive =
        {
          enabled = true,
          energy_required = 16,
          ingredients =
          {
            {"iron-gear-wheel", 10},
            {"wood", 25},
          },
          result = "bi-dart-turret",
          result_count = 1,
          main_product = "",
        },
        always_show_made_in = true,
        allow_decomposition = false,
        subgroup = "defensive-structure",
        order = "b[turret]-e[bi-dart-turret]",
  },

--- Dart Rifle

  {
    type = "recipe",
    name = "bi-dart-rifle",
    icon = iconpath .. "bi_dart_rifle_icon.png",
    icon_size = 32,
        normal =
        {
          enabled = true,
          energy_required = 8,
          ingredients =
          {
            {"copper-plate", 5},
            {"wood", 15},
          },
          result = "bi-dart-rifle",
          result_count = 1,
          main_product = "",
        },
        expensive =
        {
          enabled = true,
          energy_required = 16,
          ingredients =
          {
            {"copper-plate", 10},
            {"wood", 25},
          },
          result = "bi-dart-rifle",
          result_count = 1,
          main_product = "",
        },
        always_show_made_in = true,
        allow_decomposition = false,
        subgroup = "gun",
        --~ order = "[bi-dart-rifle]"
        order = "a[basic-clips]-b[bi-dart-rifle]"
  },

})
