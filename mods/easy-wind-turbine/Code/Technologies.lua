---@class data.TechnologyPrototype
local Tech = data.raw.technology
---@class LuaSettings
local SS = settings.startup

data:extend({
	{
        type = "technology",
        name = "EasyWindTurbine-1",
        icon = "__easy-wind-turbine__/graphics/Tech/windturbine1.png",
        icon_size = 128,
        prerequisites = {"steel-processing"},
        effects = {
            {
                type = "unlock-recipe",
                recipe = "EasyWindTurbine1"
            }
        },
        unit = {
            count = 250,
            ingredients = {
                {"automation-science-pack", 1},
            },
            time = 10
        }
    },
	{
        type = "technology",
        name = "EasyWindTurbine-2",
        icon = "__easy-wind-turbine__/graphics/Tech/windturbine2.png",
        icon_size = 128,
        prerequisites = {"engine", "EasyWindTurbine-1"},
        effects = {
            {
                type = "unlock-recipe",
                recipe = "EasyWindTurbine2"
            }
        },
        unit = {
            count = 250,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
            },
            time = 15
        }
    },
	{
        type = "technology",
        name = "EasyWindTurbine-3",
        icon = "__easy-wind-turbine__/graphics/Tech/windturbine3.png",
        icon_size = 128,
        prerequisites = {"EasyWindTurbine-2"},
        effects = {
            {
                type = "unlock-recipe",
                recipe = "EasyWindTurbine3"
            }
        },
        unit = {
            count = 250,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
            },
            time = 20
        }
    },
    {
        type = "technology",
        name = "EasyWindTurbine-4",
        icon = "__easy-wind-turbine__/graphics/Tech/windturbine4.png",
        icon_size = 128,
        prerequisites = {"production-science-pack", "EasyWindTurbine-3"},
        effects = {
            {
                type = "unlock-recipe",
                recipe = "EasyWindTurbine4"
            }
        },
        unit = {
            count = 250,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
				{"production-science-pack", 1},
            },
            time = 15
        }
    },
	{
        type = "technology",
        name = "EasyWindTurbine-5",
        icon = "__easy-wind-turbine__/graphics/Tech/windturbine5.png",
        icon_size = 128,
        prerequisites = {"EasyWindTurbine-4"},
        effects = {
            {
                type = "unlock-recipe",
                recipe = "EasyWindTurbine5"
            }
        },
        unit = {
            count = 250,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
				{"production-science-pack", 1},
                {"utility-science-pack", 1},
            },
            time = 20
        }
    }
})
if not mods["space-age"]then
    table.insert(Tech["EasyWindTurbine-5"].prerequisites, "utility-science-pack")
    table.insert(Tech["EasyWindTurbine-3"].prerequisites, "chemical-science-pack")
end
if mods["space-age"] then
	table.insert(Tech["EasyWindTurbine-3"].unit.ingredients, {"space-science-pack", 		     1})
    table.insert(Tech["EasyWindTurbine-3"].prerequisites, "planet-discovery-fulgora")

	table.insert(Tech["EasyWindTurbine-4"].unit.ingredients, {"space-science-pack", 		     1})
	table.insert(Tech["EasyWindTurbine-4"].unit.ingredients, {"agricultural-science-pack",       1})
	table.insert(Tech["EasyWindTurbine-4"].unit.ingredients, {"metallurgic-science-pack",        1})
	table.insert(Tech["EasyWindTurbine-4"].unit.ingredients, {"electromagnetic-science-pack",    1})
    table.insert(Tech["EasyWindTurbine-4"].prerequisites, "planet-discovery-vulcanus")
    table.insert(Tech["EasyWindTurbine-4"].prerequisites, "planet-discovery-gleba")

	table.insert(Tech["EasyWindTurbine-5"].unit.ingredients, {"space-science-pack", 		     1})
	table.insert(Tech["EasyWindTurbine-5"].unit.ingredients, {"agricultural-science-pack",       1})
	table.insert(Tech["EasyWindTurbine-5"].unit.ingredients, {"metallurgic-science-pack",        1})
	table.insert(Tech["EasyWindTurbine-5"].unit.ingredients, {"electromagnetic-science-pack",    1})
	table.insert(Tech["EasyWindTurbine-5"].unit.ingredients, {"cryogenic-science-pack",          1})
    table.insert(Tech["EasyWindTurbine-5"].prerequisites, "planet-discovery-aquilo")
end