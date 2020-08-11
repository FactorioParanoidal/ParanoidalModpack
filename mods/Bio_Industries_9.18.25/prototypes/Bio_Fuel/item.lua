local BioInd = require('common')('Bio_Industries')

local ICONPATH = BioInd.modRoot .. "/graphics/icons/"

if BI.Settings.BI_Bio_Fuel then

        data:extend(
        {


                ---- Celluluse
                {
                        type = "item",
                        name = "bi-cellulose",
                        icon = ICONPATH .. "cellulose.png",
                        icon_size = 64,
                        icons = {
                          {
                            icon = ICONPATH .. "cellulose.png",
                            icon_size = 64,
                          }
                        },
                        --flags = {"goes-to-main-inventory"},
                        subgroup = "intermediate-product",
                        order = "b[cellulose]",
                        stack_size = 200
                },

                --- BioReactor
                {
                        type = "item",
                        name = "bi-bio-reactor",
                        icon = ICONPATH .. "bioreactor.png",
                        icon_size = 64,
                        icons = {
                          {
                            icon = ICONPATH .. "bioreactor.png",
                            icon_size = 64,
                          }
                        },
                        --flags = {"goes-to-quickbar"},
                        subgroup = "production-machine",
                        order = "z[bi]-a[bi-bio-reactor]",
                        place_result = "bi-bio-reactor",
                        stack_size = 10
                },
                --- Bio Boiler
                {
                        type = "item",
                        name = "bi-bio-boiler",
                        icon = ICONPATH .. "bio_boiler.png",
                        icon_size = 64,
                        icons = {
                          {
                            icon = ICONPATH .. "bio_boiler.png",
                            icon_size = 64,
                          }
                        },
                        --flags = {"goes-to-quickbar"},
                        subgroup = "energy",
                        order = "b[steam-power]-b[boiler]",
                        place_result = "bi-bio-boiler",
                        stack_size = 50
                },

        })

end
