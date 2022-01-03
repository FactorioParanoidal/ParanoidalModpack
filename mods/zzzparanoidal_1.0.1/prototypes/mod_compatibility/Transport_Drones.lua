--подкрутка мода для интеграции в параноидал

if mods["Transport_Drones"] then

-- в настройках в качестве топлива нужно указать водород
--settings.startup["fuel-fluid"].value = "gas-hydrogen"

--подкрутка технологий
bobmods.lib.tech.remove_prerequisite("transport-system", "engine")
bobmods.lib.tech.remove_prerequisite("transport-system", "angels-oil-processing")
bobmods.lib.tech.add_prerequisite("transport-system", "steel-processing")
bobmods.lib.tech.add_prerequisite("transport-system", "angels-fluid-control")
bobmods.lib.tech.add_prerequisite("transport-system", "basic-chemistry-2")

bobmods.lib.tech.remove_science_pack("transport-system", "logistic-science-pack")
-------------------------------------------------------------------------------------------------
--поправка технологий
bobmods.lib.tech.add_prerequisite ("transport-drone-speed-1", "logistic-science-pack")
bobmods.lib.tech.add_prerequisite ("transport-drone-capacity-1", "logistic-science-pack")
-------------------------------------------------------------------------------------------------
--подкрутка рецептов
--депо
bobmods.lib.recipe.add_ingredient("fuel-depot", {"angels-storage-tank-3", 4})
bobmods.lib.recipe.add_ingredient("fuel-depot", {"valve-underflow", 1})
bobmods.lib.recipe.add_ingredient("fuel-depot", {"basic-structure-components", 5})
bobmods.lib.recipe.add_ingredient("fuel-depot", {"electronic-circuit", 10})

bobmods.lib.recipe.set_ingredient("fuel-depot", {"steel-plate", 30})

bobmods.lib.recipe.remove_ingredient("fuel-depot", "iron-plate")
bobmods.lib.recipe.remove_ingredient("fuel-depot", "iron-gear-wheel")
-------------------------------------------------------------------------------------------------
--депо запроса
bobmods.lib.recipe.add_ingredient("request-depot", {"basic-structure-components", 1})
bobmods.lib.recipe.add_ingredient("request-depot", {"electronic-circuit", 10})
bobmods.lib.recipe.add_ingredient("request-depot", {"steel-chest", 1})
bobmods.lib.recipe.add_ingredient("request-depot", {"steel-plate", 10})

bobmods.lib.recipe.remove_ingredient("request-depot", "iron-plate")
bobmods.lib.recipe.remove_ingredient("request-depot", "iron-gear-wheel")
bobmods.lib.recipe.remove_ingredient("request-depot", "iron-stick")
-------------------------------------------------------------------------------------------------
--депо снабжения
bobmods.lib.recipe.add_ingredient("supply-depot", {"basic-structure-components", 1})
bobmods.lib.recipe.add_ingredient("supply-depot", {"electronic-circuit", 10})
bobmods.lib.recipe.add_ingredient("supply-depot", {"steel-chest", 2})
bobmods.lib.recipe.add_ingredient("supply-depot", {"steel-plate", 10})

bobmods.lib.recipe.remove_ingredient("supply-depot", "iron-plate")
bobmods.lib.recipe.remove_ingredient("supply-depot", "iron-gear-wheel")
bobmods.lib.recipe.remove_ingredient("supply-depot", "iron-stick")
-------------------------------------------------------------------------------------------------
--депо буфер
bobmods.lib.recipe.add_ingredient("buffer-depot", {"basic-structure-components", 1})
bobmods.lib.recipe.add_ingredient("buffer-depot", {"electronic-circuit", 10})
bobmods.lib.recipe.add_ingredient("buffer-depot", {"steel-chest", 1})
bobmods.lib.recipe.add_ingredient("buffer-depot", {"steel-plate", 10})

bobmods.lib.recipe.remove_ingredient("buffer-depot", "iron-plate")
bobmods.lib.recipe.remove_ingredient("buffer-depot", "iron-gear-wheel")
bobmods.lib.recipe.remove_ingredient("buffer-depot", "iron-stick")
-------------------------------------------------------------------------------------------------
--депо жидкость
bobmods.lib.recipe.add_ingredient("fluid-depot", {"basic-structure-components", 1})
bobmods.lib.recipe.add_ingredient("fluid-depot", {"electronic-circuit", 10})
bobmods.lib.recipe.add_ingredient("fluid-depot", {"angels-storage-tank-3", 1})
bobmods.lib.recipe.add_ingredient("fluid-depot", {"steel-plate", 10})

bobmods.lib.recipe.remove_ingredient("fluid-depot", "iron-plate")
bobmods.lib.recipe.remove_ingredient("fluid-depot", "iron-gear-wheel")
bobmods.lib.recipe.remove_ingredient("fluid-depot", "iron-stick")
-------------------------------------------------------------------------------------------------
--дорога
bobmods.lib.recipe.add_ingredient("road", {"stone", 20})
bobmods.lib.recipe.add_ingredient("road", {"coal-crushed", 10})
bobmods.lib.recipe.add_ingredient("road", {"resin", 10})

bobmods.lib.recipe.remove_ingredient("road", "stone-brick")
bobmods.lib.recipe.remove_ingredient("road", "coal")

data.raw.recipe.road.energy_required = 5
data.raw.recipe.road.category = "smelting"

--замена графики на асфальт
--[[data.raw.tile["transport-drone-proxy-tile"].variants = 
{
    main = 
    {
        {picture = "__zzzparanoidal__/graphics/asphalt/asphalt.png", count = 16, size = 1},
        {picture = "__zzzparanoidal__/graphics/asphalt/asphalt2.png", count = 4, size = 2, probability = 0.3,},
        {picture = "__zzzparanoidal__/graphics/asphalt/asphalt4.png", count = 4, size = 4, probability = 0.8,},
    },
    inner_corner = {picture = "__zzzparanoidal__/graphics/asphalt/asphalt-inner-corner.png", count = 8},
    outer_corner = {picture = "__zzzparanoidal__/graphics/asphalt/asphalt-outer-corner.png", count = 8},
    side = {picture = "__zzzparanoidal__/graphics/asphalt/asphalt-side.png", count = 8},
    u_transition = {picture = "__zzzparanoidal__/graphics/asphalt/asphalt-u.png", count = 8},
    o_transition = {picture = "__zzzparanoidal__/graphics/asphalt/asphalt-o.png", count = 1}
}
]]
data.raw.tile["transport-drone-road"].variants = 
{
    main = 
    {
        {picture = "__zzzparanoidal__/graphics/asphalt/asphalt.png", count = 16, size = 1},
        {picture = "__zzzparanoidal__/graphics/asphalt/asphalt2.png", count = 4, size = 2, probability = 0.3,},
        {picture = "__zzzparanoidal__/graphics/asphalt/asphalt4.png", count = 4, size = 4, probability = 0.8,},
    },
    inner_corner = {picture = "__zzzparanoidal__/graphics/asphalt/asphalt-inner-corner.png", count = 8},
    outer_corner = {picture = "__zzzparanoidal__/graphics/asphalt/asphalt-outer-corner.png", count = 8},
    side = {picture = "__zzzparanoidal__/graphics/asphalt/asphalt-side.png", count = 8},
    u_transition = {picture = "__zzzparanoidal__/graphics/asphalt/asphalt-u.png", count = 8},
    o_transition = {picture = "__zzzparanoidal__/graphics/asphalt/asphalt-o.png", count = 1}
}

data.raw.tile["transport-drone-road"].map_color = {r = 10, g = 10, b = 10} --{r = 43, g = 41, b = 37}
data.raw.tile["transport-drone-road"].vehicle_friction_modifier = 1
data.raw.tile["transport-drone-road"].tint = {0.5, 0.5, 0.5}
data.raw.tile["transport-drone-road"].layer = 250
-------------------------------------------------------------------------------------------------
--fast road
bobmods.lib.recipe.replace_ingredient("fast-road", "concrete", "refined-concrete")
-------------------------------------------------------------------------------------------------
--машинка
bobmods.lib.recipe.add_ingredient("transport-drone", {"steel-bearing", 4})
bobmods.lib.recipe.add_ingredient("transport-drone", {"electronic-circuit", 3})
bobmods.lib.recipe.add_ingredient("transport-drone", {"simple-io", 1})
bobmods.lib.recipe.add_ingredient("transport-drone", {"motor", 3})

bobmods.lib.recipe.set_ingredient("transport-drone", {"steel-plate", 10})

bobmods.lib.recipe.remove_ingredient("transport-drone", "engine-unit")
bobmods.lib.recipe.remove_ingredient("transport-drone", "iron-gear-wheel")
-------------------------------------------------------------------------------------------------
end