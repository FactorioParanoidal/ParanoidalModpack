-- Copyright (C) 2022  veden

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.



data:extend({
        {
            type = "shortcut",
            name = "rampant-maintenance--info",
            action = "lua",
            localised_name = {"controls.rampant-maintenance--toggle-maintenance-info"},
            toggleable = true,
            icon =
                {
                    filename = "__core__/graphics/icons/alerts/too-far-from-roboport-icon.png",
                    priority = "extra-high-no-scale",
                    scale = 1,
                    size = 64,
                    flags = {"icon"}
                }
        }
})

local function buildResearches(name)
    local tint = {r=0.65,g=0.65,b=0.65}
    if (name=="damage") then
        tint = {r=0.65,g=0.4,b=0.65}
    elseif (name=="downtime") then
        tint = {r=0.55,g=0.55,b=0.85}
    elseif (name=="damage-failure") then
        tint = {r=0.45,g=0.7,b=0.5}
    elseif (name=="failure") then
        tint = {r=0.75,g=0.4,b=0.65}
    elseif (name=="tile") then
        tint = {r=0.8,g=0.8,b=0.45}
    elseif (name=="pollution") then
        tint = {r=0.3,g=0.3,b=0.3}
    elseif (name=="energy") then
        tint = {r=0.6,g=0.3,b=0.0}
    end

    data:extend({
            {
                type = "technology",
                name = "rampant-maintenance-reduce-" .. name .. "-1",
                localised_name = {"technology-name.rampant-maintenance-reduce-" .. name},
                localised_description = {"technology-description.rampant-maintenance-reduce-" .. name},
                icons = {
                    {icon="__base__/graphics/technology/advanced-electronics.png",icon_size=256,icon_mipmaps=4,shift={0,10},scale=0.75},
                    {icon="__base__/graphics/technology/effectivity-module-1.png",icon_size=256,icon_mipmaps=4,tint=tint,shift={-48,-68},scale=0.25}
                },
                effects =
                    {
                        {
                            type = "nothing",
                            effect_description = {"description.rampant-maintenance-reduce-" .. name}
                        }
                    },
                unit =
                    {
                        count = 200,
                        ingredients =
                            {
                                {"automation-science-pack", 1},
                                {"logistic-science-pack", 1}
                            },
                        time = 10
                    },
                upgrade = true,
                prerequisites = {"advanced-electronics", "sulfur-processing"},
                order = "c-a"
            },
            {
                type = "technology",
                name = "rampant-maintenance-reduce-" .. name .. "-2",
                localised_name = {"technology-name.rampant-maintenance-reduce-" .. name},
                localised_description = {"technology-description.rampant-maintenance-reduce-" .. name},
                icons = {
                    {icon="__base__/graphics/technology/advanced-electronics.png",icon_size=256,icon_mipmaps=4,shift={0,10},scale=0.75},
                    {icon="__base__/graphics/technology/effectivity-module-1.png",icon_size=256,icon_mipmaps=4,tint=tint,shift={-48,-68},scale=0.25}
                },
                effects =
                    {
                        {
                            type = "nothing",
                            effect_description = {"description.rampant-maintenance-reduce-" .. name}
                        }
                    },
                unit =
                    {
                        count = 800,
                        ingredients =
                            {
                                {"automation-science-pack", 1},
                                {"logistic-science-pack", 1}
                            },
                        time = 30
                    },
                upgrade = true,
                prerequisites = {"rampant-maintenance-reduce-" .. name .. "-1"},
                order = "c-a"
            },
            {
                type = "technology",
                name = "rampant-maintenance-reduce-" .. name .. "-3",
                localised_name = {"technology-name.rampant-maintenance-reduce-" .. name},
                localised_description = {"technology-description.rampant-maintenance-reduce-" .. name},
                icons = {
                    {icon="__base__/graphics/technology/advanced-electronics.png",icon_size=256,icon_mipmaps=4,shift={0,10},scale=0.75},
                    {icon="__base__/graphics/technology/effectivity-module-1.png",icon_size=256,icon_mipmaps=4,tint=tint,shift={-48,-68},scale=0.25}
                },
                effects =
                    {
                        {
                            type = "nothing",
                            effect_description = {"description.rampant-maintenance-reduce-" .. name}
                        }
                    },
                unit =
                    {
                        count = 1600,
                        ingredients =
                            {
                                {"automation-science-pack", 1},
                                {"logistic-science-pack", 1},
                                {"chemical-science-pack", 1}
                            },
                        time = 30
                    },
                upgrade = true,
                prerequisites = {"rampant-maintenance-reduce-" .. name .. "-2"},
                order = "c-a"
            },
            {
                type = "technology",
                name = "rampant-maintenance-reduce-" .. name .. "-4",
                localised_name = {"technology-name.rampant-maintenance-reduce-" .. name},
                localised_description = {"technology-description.rampant-maintenance-reduce-" .. name},
                icons = {
                    {icon="__base__/graphics/technology/advanced-electronics.png",icon_size=256,icon_mipmaps=4,shift={0,10},scale=0.75},
                    {icon="__base__/graphics/technology/effectivity-module-2.png",icon_size=256,icon_mipmaps=4,tint=tint,shift={-48,-68},scale=0.25}
                },
                effects =
                    {
                        {
                            type = "nothing",
                            effect_description = {"description.rampant-maintenance-reduce-" .. name}
                        }
                    },
                unit =
                    {
                        count = 2400,
                        ingredients =
                            {
                                {"automation-science-pack", 1},
                                {"logistic-science-pack", 1},
                                {"chemical-science-pack", 1}
                            },
                        time = 45
                    },
                upgrade = true,
                prerequisites = {"rampant-maintenance-reduce-" .. name .. "-3"},
                order = "c-a"
            },
            {
                type = "technology",
                name = "rampant-maintenance-reduce-" .. name .. "-5",
                localised_name = {"technology-name.rampant-maintenance-reduce-" .. name},
                localised_description = {"technology-description.rampant-maintenance-reduce-" .. name},
                icons = {
                    {icon="__base__/graphics/technology/advanced-electronics.png",icon_size=256,icon_mipmaps=4,shift={0,10},scale=0.75},
                    {icon="__base__/graphics/technology/effectivity-module-2.png",icon_size=256,icon_mipmaps=4,tint=tint,shift={-48,-68},scale=0.25}
                },
                effects =
                    {
                        {
                            type = "nothing",
                            effect_description = {"description.rampant-maintenance-reduce-" .. name}
                        }
                    },
                unit =
                    {
                        count = 4000,
                        ingredients =
                            {
                                {"automation-science-pack", 1},
                                {"logistic-science-pack", 1},
                                {"chemical-science-pack", 1},
                                {"production-science-pack", 1}
                            },
                        time = 60
                    },
                upgrade = true,
                prerequisites = {"rampant-maintenance-reduce-" .. name .. "-4"},
                order = "c-a"
            },
            {
                type = "technology",
                name = "rampant-maintenance-reduce-" .. name .. "-6",
                localised_name = {"technology-name.rampant-maintenance-reduce-" .. name},
                localised_description = {"technology-description.rampant-maintenance-reduce-" .. name},
                icons = {
                    {icon="__base__/graphics/technology/advanced-electronics.png",icon_size=256,icon_mipmaps=4,shift={0,10},scale=0.75},
                    {icon="__base__/graphics/technology/effectivity-module-2.png",icon_size=256,icon_mipmaps=4,tint=tint,shift={-48,-68},scale=0.25}
                },
                effects =
                    {
                        {
                            type = "nothing",
                            effect_description = {"description.rampant-maintenance-reduce-" .. name}
                        }
                    },
                unit =
                    {
                        count = 6000,
                        ingredients =
                            {
                                {"automation-science-pack", 1},
                                {"logistic-science-pack", 1},
                                {"chemical-science-pack", 1},
                                {"production-science-pack", 1}
                            },
                        time = 75
                    },
                upgrade = true,
                prerequisites = {"rampant-maintenance-reduce-" .. name .. "-5"},
                order = "c-a"
            },
            {
                type = "technology",
                name = "rampant-maintenance-reduce-" .. name .. "-7",
                localised_name = {"technology-name.rampant-maintenance-reduce-" .. name},
                localised_description = {"technology-description.rampant-maintenance-reduce-" .. name},
                icons = {
                    {icon="__base__/graphics/technology/advanced-electronics.png",icon_size=256,icon_mipmaps=4,shift={0,10},scale=0.75},
                    {icon="__base__/graphics/technology/effectivity-module-3.png",icon_size=256,icon_mipmaps=4,tint=tint,shift={-48,-68},scale=0.25}
                },
                effects =
                    {
                        {
                            type = "nothing",
                            effect_description = {"description.rampant-maintenance-reduce-" .. name}
                        }
                    },
                unit =
                    {
                        count = 10000,
                        ingredients =
                            {
                                {"automation-science-pack", 1},
                                {"logistic-science-pack", 1},
                                {"chemical-science-pack", 1},
                                {"production-science-pack", 1},
                                {"utility-science-pack", 1}
                            },
                        time = 85
                    },
                upgrade = true,
                prerequisites = {"rampant-maintenance-reduce-" .. name .. "-6"},
                order = "c-a"
            },
            {
                type = "technology",
                name = "rampant-maintenance-reduce-" .. name .. "-8",
                localised_name = {"technology-name.rampant-maintenance-reduce-" .. name},
                localised_description = {"technology-description.rampant-maintenance-reduce-" .. name},
                icons = {
                    {icon="__base__/graphics/technology/advanced-electronics.png",icon_size=256,icon_mipmaps=4,shift={0,10},scale=0.75},
                    {icon="__base__/graphics/technology/effectivity-module-3.png",icon_size=256,icon_mipmaps=4,tint=tint,shift={-48,-68},scale=0.25}
                },
                effects =
                    {
                        {
                            type = "nothing",
                            effect_description = {"description.rampant-maintenance-reduce-" .. name}
                        }
                    },
                unit =
                    {
                        count = 20000,
                        ingredients =
                            {
                                {"automation-science-pack", 1},
                                {"logistic-science-pack", 1},
                                {"chemical-science-pack", 1},
                                {"production-science-pack", 1},
                                {"utility-science-pack", 1}
                            },
                        time = 100
                    },
                upgrade = true,
                prerequisites = {"rampant-maintenance-reduce-" .. name .. "-7"},
                order = "c-a"
            },
            {
                type = "technology",
                name = "rampant-maintenance-reduce-" .. name .. "-9",
                localised_name = {"technology-name.rampant-maintenance-reduce-" .. name},
                localised_description = {"technology-description.rampant-maintenance-reduce-" .. name},
                icons = {
                    {icon="__base__/graphics/technology/advanced-electronics.png",icon_size=256,icon_mipmaps=4,shift={0,10},scale=0.75},
                    {icon="__base__/graphics/technology/effectivity-module-3.png",icon_size=256,icon_mipmaps=4,tint=tint,shift={-48,-68},scale=0.25}
                },
                effects =
                    {
                        {
                            type = "nothing",
                            effect_description = {"description.rampant-maintenance-reduce-" .. name}
                        }
                    },
                unit =
                    {
                        count = 40000,
                        ingredients =
                            {
                                {"automation-science-pack", 1},
                                {"logistic-science-pack", 1},
                                {"chemical-science-pack", 1},
                                {"production-science-pack", 1},
                                {"utility-science-pack", 1},
                                {"space-science-pack", 1}
                            },
                        time = 120
                    },
                upgrade = true,
                prerequisites = {"rampant-maintenance-reduce-" .. name .. "-8"},
                order = "c-a"
            }
    })
end

buildResearches("failure")
buildResearches("damage")
buildResearches("damage-failure")
buildResearches("downtime")
buildResearches("checks")
buildResearches("energy")
if settings.startup["rampant-maintenance--tile-modifier"].value then
    buildResearches("tile")
end
if settings.startup["rampant-maintenance--pollution-modifier"].value then
    buildResearches("pollution")
end
