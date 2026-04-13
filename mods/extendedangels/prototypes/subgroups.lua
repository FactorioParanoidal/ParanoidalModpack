data:extend({
  {
    type = "item-subgroup",
    name = "angels-copper-tungsten",
    group = "angels-smelting",
    order = "t",
  },

  {
    type = "item-subgroup",
    name = "angels-copper-tungsten-casting",
    group = "angels-casting",
    order = "u",
  },
  {
    type = "item-subgroup",
    name = "angels-petrochem-argon",
    group = "angels-petrochem-refining",
    order = "cab",
  },
  {
    type = "item-subgroup",
    name = "angels-tungsten-carbide",
    group = "angels-smelting",
    order = "v",
  },
  {
    type = "item-subgroup",
    name = "angels-tungsten-carbide-casting",
    group = "angels-casting",
    order = "w",
  },
})

-- Storage categories
if mods["angelsaddons-storage"] then
  data:extend({
    {
      type = "item-subgroup",
      name = "angels-warehouses-2",
      group = "logistics",
      order = "af",
    },
    {
      type = "item-subgroup",
      name = "angels-warehouses-3",
      group = "logistics",
      order = "ag",
    },
    {
      type = "item-subgroup",
      name = "angels-warehouses-4",
      group = "logistics",
      order = "ah",
    },
  })
end

-- Subgroup adjustments
if settings.startup["extangels-adjust-ordering"].value then
  -- Petrochem building sorting
  data:extend({
    {
      type = "item-subgroup",
      name = "angels-petrochem-buildings-air-filter",
      group = "angels-petrochem-refining",
      order = "za[buildings]-aa",
    },
    {
      type = "item-subgroup",
      name = "angels-petrochem-buildings-liquifier",
      group = "angels-petrochem-refining",
      order = "za[buildings]-ab",
    },
    {
      type = "item-subgroup",
      name = "angels-petrochem-buildings-advanced-chemical-plant",
      group = "angels-petrochem-refining",
      order = "za[buildings]-ba",
    },
    {
      type = "item-subgroup",
      name = "angels-petrochem-buildings-advanced-gas-refinery",
      group = "angels-petrochem-refining",
      order = "za[buildings]-ca",
    },
    {
      type = "item-subgroup",
      name = "angels-petrochem-buildings-separator",
      group = "angels-petrochem-refining",
      order = "za[buildings]-da",
    },
  })

  -- Bioprocessing building sorting
  if angelsmods.bioprocessing then
    data:extend({
      {
        type = "item-subgroup",
        name = "angels-bio-processing-buildings-nauvis-a",
        group = "angels-bio-processing-nauvis",
        order = "za",
      },
      {
        type = "item-subgroup",
        name = "angels-bio-processing-buildings-nauvis-b",
        group = "angels-bio-processing-nauvis",
        order = "zb",
      },
      {
        type = "item-subgroup",
        name = "angels-bio-processing-buildings-vegetabilis-a",
        group = "angels-bio-processing-vegetables",
        order = "z[buildings]-a",
      },
      {
        type = "item-subgroup",
        name = "angels-bio-processing-buildings-vegetabilis-b",
        group = "angels-bio-processing-vegetables",
        order = "z[buildings]-b",
      },
      {
        type = "item-subgroup",
        name = "angels-bio-processing-buildings-vegetabilis-c",
        group = "angels-bio-processing-vegetables",
        order = "z[buildings]-c",
      },
      {
        type = "item-subgroup",
        name = "angels-bio-processing-buildings-vegetabilis-d",
        group = "angels-bio-processing-vegetables",
        order = "z[buildings]-d",
      },
      {
        type = "item-subgroup",
        name = "angels-bio-processing-buildings-vegetabilis-e",
        group = "angels-bio-processing-vegetables",
        order = "z[buildings]-e",
      },
      {
        type = "item-subgroup",
        name = "angels-bio-processing-buildings-alien-a",
        group = "angels-bio-processing-alien",
        order = "zc",
      },
      {
        type = "item-subgroup",
        name = "angels-bio-processing-buildings-alien-b",
        group = "angels-bio-processing-alien",
        order = "zd",
      },
    })
  end
end
