data.raw.recipe["advanced-nuclear-fuel-reprocessing"].ingredients =
{
    {type="item", name="used-up-uranium-fuel-cell", amount=5},
    {type="fluid", name="liquid-nitric-acid", amount=300}--20
}
data.raw.recipe["advanced-nuclear-fuel-reprocessing"].results = {
    {type="item", name="uranium-238", amount=3},
    {type="item", name="plutonium-239", amount=1, probability=0.5},
    {type="item", name="strontium-90", amount=3},
    {type="item", name="caesium-137", amount=3},
    {type="fluid", name="water-radioactive-waste", amount=300}
}


data.raw.recipe["advanced-thorium-nuclear-fuel-reprocessing"].ingredients = {
    {type="item", name="used-up-thorium-fuel-cell", amount=5},
    {type="item", name="55%-uranium", amount=2},
    {type="item", name="uranium-238", amount=6},
    {type="fluid", name="liquid-nitric-acid", amount=300}
}
data.raw.recipe["advanced-thorium-nuclear-fuel-reprocessing"].results = {
    {type="item", name="thorium-232", amount=2},
    {type="item", name="plutonium-239", amount=1, probability=0.5},
    {type="item", name="protactinium-231", amount=8},
    {type="fluid", name="water-radioactive-waste", amount=300}
}

data.raw.recipe["advanced-thorium-nuclear-fuel-reprocessing|b"].ingredients = {
    {type="item", name="used-up-thorium-fuel-cell", amount=5},
    {type="fluid", name="liquid-nitric-acid", amount=150}
}
data.raw.recipe["advanced-thorium-nuclear-fuel-reprocessing|b"].results = {
    {type="item", name="thorium-232", amount=2},
    {type="item", name="plutonium-239", amount=1, probability=0.5},
    {type="item", name="strontium-90", amount=8},
    {type="fluid", name="water-radioactive-waste", amount=150}
}

data.raw.recipe["thorium-processing"].energy_required = 60 --from 10
--Вернем ядерное топливо в поезда
data.raw.item["nuclear-fuel"].burnt_result = ""
data.raw.item["nuclear-fuel"].fuel_category = "chemical"