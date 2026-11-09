-- https://github.com/notnotmelon/maraxsis/issues/411

if not mods["science-tab"] then return end

if mods["Krastorio2-spaced-out"] then
    data.raw["item-subgroup"]["kr-tech-cards-cooling"].group = "science"
else
    data.raw["item-subgroup"]["maraxsis-deepsea-research"].group = "science"
end

data.raw["item-subgroup"]["omega-3"].group = "science"