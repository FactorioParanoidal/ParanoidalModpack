local buildingmulti = angelsmods.marathon.buildingmulti
local buildingtime = angelsmods.marathon.buildingtime

if angelsmods.bioprocessing then

angelsmods.functions.RB.build({
           {
            type = "recipe",
            name = "algae-farm-4",
            normal =
            {
                energy_required = 5,
                enabled = false,
                ingredients =
                {
                  {"algae-farm-3", 1},
                  {"t4-plate", 2},
                  {"t4-circuit", 5},
                  {"t4-brick", 5},
                  {"t4-pipe", 10},
                },
                  result= "algae-farm-4",
                },
                expensive =
                {
                  energy_required = 5 * buildingtime,
                  enabled = false,
                  ingredients =
                  {
                    {"algae-farm-3", 1},
                    {"t4-plate", 10 * buildingmulti},
                    {"t4-circuit", 5 * buildingmulti},
                    {"t4-brick", 5 * buildingmulti},
                    {"t4-pipe", 10 * buildingmulti},
                  },
                  result= "algae-farm-4",
                },
               },

   --TREE GENERATOR
  {
    type = "recipe",
    name = "bio-generator-temperate-2",
    normal =
    {
      energy_required = 5,
      enabled = false,
      ingredients =
      {
        {"bio-generator-temperate-1", 1},
        {"t2-plate", 2},
        {"t2-circuit", 2},
        {"t2-brick", 1},
        {"t2-pipe", 3},
      },
      result= "bio-generator-temperate-2",
    },
    expensive =
    {
      energy_required = 5 * buildingtime,
      enabled = false,
      ingredients =
      {
        {"bio-generator-temperate-1", 1},
        {"t2-plate", 2 * buildingmulti},
        {"t2-circuit", 2 * buildingmulti},
        {"t2-brick", 1 * buildingmulti},
        {"t2-pipe", 3 * buildingmulti},
      },
      result= "bio-generator-temperate-2",
    },
  },
  {
    type = "recipe",
    name = "bio-generator-swamp-2",
    normal =
    {
      energy_required = 5,
      enabled = false,
      ingredients =
      {
        {"bio-generator-swamp-1", 1},
        {"t2-plate", 2},
        {"t2-circuit", 2},
        {"t2-brick", 1},
        {"t2-pipe", 3},
      },
      result= "bio-generator-swamp-2",
    },
    expensive =
    {
      energy_required = 5 * buildingtime,
      enabled = false,
      ingredients =
      {
        {"bio-generator-swamp-1", 2},
        {"t2-plate", 2 * buildingmulti},
        {"t2-circuit", 2 * buildingmulti},
        {"t2-brick", 1 * buildingmulti},
        {"t2-pipe", 3 * buildingmulti},
      },
      result= "bio-generator-swamp-2",
    },
  },
  {
    type = "recipe",
    name = "bio-generator-desert-2",
    normal =
    {
      energy_required = 5,
      enabled = false,
      ingredients =
      {
        {"bio-generator-desert-1", 1},
        {"t2-plate", 2},
        {"t2-circuit", 2},
        {"t2-brick", 1},
        {"t2-pipe", 3},
      },
      result= "bio-generator-desert-2",
    },
    expensive =
    {
      energy_required = 5 * buildingtime,
      enabled = false,
      ingredients =
      {
        {"bio-generator-desert-1", 1},
        {"t2-plate", 2 * buildingmulti},
        {"t2-circuit", 2 * buildingmulti},
        {"t2-brick", 1 * buildingmulti},
        {"t2-pipe", 3 * buildingmulti},
      },
      result= "bio-generator-desert-2",
    },
  },
  --ARBORETUM
  {
    type = "recipe",
    name = "bio-arboretum-2",
    normal =
    {
      energy_required = 5,
      enabled = false,
      ingredients =
      {
        {"bio-arboretum-1", 1},
        {"t2-plate", 6},
        {"t2-circuit", 2},
        {"t2-brick", 6},
        {"t2-pipe", 8},
      },
      result= "bio-arboretum-2",
    },
    expensive =
    {
      energy_required = 5 * buildingtime,
      enabled = false,
      ingredients =
      {
        {"bio-arboretum-1", 1},
        {"t2-plate", 6 * buildingmulti},
        {"t2-circuit", 2 * buildingmulti},
        {"t2-brick", 6 * buildingmulti},
        {"t2-pipe", 8 * buildingmulti},
      },
      result= "bio-arboretum-2",
    },
  },

     --TREE GENERATOR
  {
    type = "recipe",
    name = "bio-generator-temperate-3",
    normal =
    {
      energy_required = 5,
      enabled = false,
      ingredients =
      {
        {"bio-generator-temperate-2", 1},
        {"t3-plate", 2},
        {"t3-circuit", 2},
        {"t3-brick", 1},
        {"t3-pipe", 3},
      },
      result= "bio-generator-temperate-3",
    },
    expensive =
    {
      energy_required = 5 * buildingtime,
      enabled = false,
      ingredients =
      {
        {"bio-generator-temperate-2", 1},
        {"t3-plate", 2 * buildingmulti},
        {"t3-circuit", 2 * buildingmulti},
        {"t3-brick", 1 * buildingmulti},
        {"t3-pipe", 3 * buildingmulti},
      },
      result= "bio-generator-temperate-3",
    },
  },
  {
    type = "recipe",
    name = "bio-generator-swamp-3",
    normal =
    {
      energy_required = 5,
      enabled = false,
      ingredients =
      {
        {"bio-generator-swamp-2", 1},
        {"t3-plate", 2},
        {"t3-circuit", 2},
        {"t3-brick", 1},
        {"t3-pipe", 3},
      },
      result= "bio-generator-swamp-3",
    },
    expensive =
    {
      energy_required = 5 * buildingtime,
      enabled = false,
      ingredients =
      {
        {"bio-generator-swamp-2", 1},
        {"t3-plate", 2 * buildingmulti},
        {"t3-circuit", 2 * buildingmulti},
        {"t3-brick", 1 * buildingmulti},
        {"t3-pipe", 3 * buildingmulti},
      },
      result= "bio-generator-swamp-3",
    },
  },
  {
    type = "recipe",
    name = "bio-generator-desert-3",
    normal =
    {
      energy_required = 5,
      enabled = false,
      ingredients =
      {
        {"bio-generator-desert-2", 1},
        {"t3-plate", 2},
        {"t3-circuit", 2},
        {"t3-brick", 1},
        {"t3-pipe", 3},
      },
      result= "bio-generator-desert-3",
    },
    expensive =
    {
      energy_required = 5 * buildingtime,
      enabled = false,
      ingredients =
      {
        {"bio-generator-desert-2", 1},
        {"t3-plate", 2 * buildingmulti},
        {"t3-circuit", 2 * buildingmulti},
        {"t3-brick", 1 * buildingmulti},
        {"t3-pipe", 3 * buildingmulti},
      },
      result= "bio-generator-desert-3",
    },
  },
  --ARBORETUM
  {
    type = "recipe",
    name = "bio-arboretum-3",
    normal =
    {
      energy_required = 5,
      enabled = false,
      ingredients =
      {
        {"bio-arboretum-2", 1},
        {"t3-plate", 6},
        {"t3-circuit", 2},
        {"t3-brick", 6},
        {"t3-pipe", 8},
      },
      result= "bio-arboretum-3",
    },
    expensive =
    {
      energy_required = 5 * buildingtime,
      enabled = false,
      ingredients =
      {
        {"bio-arboretum-2", 1},
        {"t3-plate", 6 * buildingmulti},
        {"t3-circuit", 2 * buildingmulti},
        {"t3-brick", 6 * buildingmulti},
        {"t3-pipe", 8 * buildingmulti},
      },
      result= "bio-arboretum-3",
    },
  },
}
    )

  end