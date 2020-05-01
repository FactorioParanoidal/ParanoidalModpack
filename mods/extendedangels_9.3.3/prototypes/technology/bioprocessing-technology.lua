if angelsmods.bioprocessing then

data:extend(
{
    {
        type = "technology",
        name = "angels-advanced-bio-processing",
        icon = "__angelsbioprocessing__/graphics/technology/algae-farm-tech.png",
        icon_size = 128,
        prerequisites =
        {
        "bio-processing-red",

        },
        effects =
        {
          {
            type = "unlock-recipe",
            recipe = "algae-farm-4"
          },
        },
        unit =
        {
          count = 150,
          ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1},
            {"utility-science-pack", 1},
          },
          time = 15
        },
        },
}
)

end