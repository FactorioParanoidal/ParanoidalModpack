local BioInd = require('common')('Bio_Industries')

local ICONPATH = BioInd.modRoot .. "/graphics/technology/"

if BI.Settings.BI_Bio_Fuel then

        data:extend(
        {

                {
                        type = "technology",
                        name = "bi-tech-organic-plastic",
                        icon_size = 128,
                        icon = ICONPATH .. "Cellulose_128.png",
                        icons = {
                          {
                            icon = ICONPATH .. "Cellulose_128.png",
                            icon_size = 128,
                          }
                        },
                        effects = {
                                {
                                        type = "unlock-recipe",
                                        recipe = "bi-plastic-1"
                                },
                                {
                                        type = "unlock-recipe",
                                        recipe = "bi-plastic-2"
                                }
                        },
                        prerequisites = {
                                "bi-tech-advanced-biotechnology"
                        },
                        unit = {
                                count = 200,
                                ingredients = {
                                        {"automation-science-pack", 1},
                                        {"logistic-science-pack", 1},
                                        {"chemical-science-pack", 1},
                                        {"production-science-pack", 1},
                                },
                                time = 30
                        }
                },

        })

end
