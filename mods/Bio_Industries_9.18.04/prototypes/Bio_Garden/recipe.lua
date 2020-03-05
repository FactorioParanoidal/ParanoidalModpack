local iconpath = "__Bio_Industries__/graphics/icons/"

--- Bio Gardens
data:extend({


  --- Garden (ENTITY)
        {
                type = "recipe",
                name = "bi-bio-garden",
                icon = iconpath .. "bio_garden_icon.png",
                icon_size = 32,
                enabled = false,
                energy_required = 10,
                ingredients =
                {
                  {"stone-wall", 12},
                  {"stone-crushed", 50},
                  {"seedling", 50}
                },
                result = "bi-bio-garden",
                main_product = "",
                subgroup = "bio-bio-gardens-fluid",
                order = "a[bi]",
                --~ subgroup = "production-machine",
                --~ order = "x[bi]-b[bi_bio_garden]",
                always_show_made_in = true,
                allow_decomposition = false,
        },


 --- Clean Air 1
        {
                type = "recipe",
                name = "bi-purified-air-1",
                localised_name = {"recipe-name.bi-purified-air-1"},
                localised_description = {"recipe-description.bi-purified-air-1"},
                icon = iconpath .. "clean-air_mk1.png",
                icon_size = 32,
                order = "zzz-clean-air",
                category = "clean-air",
                subgroup = "bio-bio-gardens-fluid",
                order = "bi-purified-air-1",
                enabled = false,
                always_show_made_in = true,
                allow_decomposition = false,
                energy_required = 40,
                ingredients =
                {
                  {type="fluid", name="water", amount=50},
                  {type="item", name="fertiliser", amount=1}
                },
                results=
                {
                  {type="item", name="bi-purified-air", amount=1, probability=0},
                },
                main_product = "",
        },


 --- Clean Air 2
        {
                type = "recipe",
                name = "bi-purified-air-2",
                localised_name = {"recipe-name.bi-purified-air-2"},
                localised_description = {"recipe-description.bi-purified-air-2"},
                icon = iconpath .. "clean-air_mk2.png",
                icon_size = 32,
                order = "zzz-clean-air2",
                category = "clean-air",
                subgroup = "bio-bio-gardens-fluid",
                order = "bi-purified-air-2",
                enabled = false,
                always_show_made_in = true,
                allow_decomposition = false,
                energy_required = 100,
                ingredients =
                {
                  {type="fluid", name="water", amount=50},
                  {type="item", name="bi-adv-fertiliser", amount=1},
                },
                results=
                {
                  {type="item", name="bi-purified-air", amount=1, probability=0},
                },
                main_product = "",
        },

  }
)
