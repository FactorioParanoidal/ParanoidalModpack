local resistances = {
  { type = "fire", percent = 100 },
  { type = "explosion", percent = 50 },
  { type = "impact", percent = 50 }
}
--{"floor-layer", "player-layer", "water-tile", "object-layer"},
local collision_mask_blocking = {"player-layer", "object-layer"}
local collision_mask_nonblocking = {"item-layer"}
data:extend({
  {
    type = "container",
    name = "aai-big-ship-wreck-1",
    enable_inventory_bar = false,
    icon = "__base__/graphics/icons/ship-wreck/big-ship-wreck-1.png",
    icon_size = 32,
    flags = {"placeable-neutral"},
    subgroup = "wrecks",
    order = "d[remnants]-d[ship-wreck]-a[big]-a",
    max_health = 300,
    minable = {
      mining_time = 0.5 * 10,
      results={
        {name="iron-plate", amount = 62},
        {name="copper-plate", amount = 38},
        {name="steel-plate", amount = 7},
        {name="electronic-circuit", amount = 2}
      }
    },
    resistances = resistances,
    collision_box = {{-1.8, -1.5}, {1.8, 1.5}},
    collision_mask = collision_mask_blocking,
    selection_box = {{-2.7, -1.5}, {2.7, 1.5}},
    inventory_size = 3,
    picture =
    {
      filename = "__aai-industry__/graphics/entity/ship-wreck/big-ship-wreck-1.png",
      width = 256,
      height = 212,
      shift = {0.7, 0}
    }
  },
  {
    type = "container",
    name = "aai-big-ship-wreck-2",
    enable_inventory_bar = false,
    icon = "__base__/graphics/icons/ship-wreck/big-ship-wreck-2.png",
    icon_size = 32,
    flags = {"placeable-neutral"},
    subgroup = "wrecks",
    order = "d[remnants]-d[ship-wreck]-a[big]-b",
    max_health = 300,
    minable = {
      mining_time = 0.5 * 10,
      results={
        {name="iron-plate", amount = 58},
        {name="copper-plate", amount = 36},
        {name="steel-plate", amount = 3},
        {name="electronic-circuit", amount = 1}
      }
    },
    resistances = resistances,
    collision_box = {{-1.4, -1.2}, {1.4, 1.2}},
    collision_mask = collision_mask_blocking,
    selection_box = {{-2, -1.5}, {2, 1.5}},
    inventory_size = 3,
    picture =
    {
      filename = "__aai-industry__/graphics/entity/ship-wreck/big-ship-wreck-2.png",
      width = 164,
      height = 129,
      shift = {-0.5, 0.6}
    }
  },
  {
    type = "container",
    name = "aai-big-ship-wreck-3",
    enable_inventory_bar = false,
    icon = "__base__/graphics/icons/ship-wreck/big-ship-wreck-3.png",
    icon_size = 32,
    flags = {"placeable-neutral"},
    subgroup = "wrecks",
    order = "d[remnants]-d[ship-wreck]-a[big]-c",
    max_health = 300,
    minable = {
      mining_time = 0.5 * 10,
      results={
        {name="iron-plate", amount = 38},
        {name="copper-plate", amount = 44},
        {name="steel-plate", amount = 2},
        {name="electronic-circuit", amount = 1}
      }
    },
    resistances = resistances,
    collision_box = {{-0.8, -0.8}, {0.8, 0.8}},
    collision_mask = collision_mask_blocking,
    selection_box = {{-2, -1.5}, {2, 1.5}},
    inventory_size = 3,
    picture =
    {
      filename = "__aai-industry__/graphics/entity/ship-wreck/big-ship-wreck-3.png",
      width = 165,
      height = 131
    }
  },

  {
    type = "container",
    name = "aai-medium-ship-wreck-1",
    icon = "__base__/graphics/icons/ship-wreck/medium-ship-wreck.png",
    icon_size = 32,
    flags = {"placeable-neutral", "placeable-off-grid", "not-on-map"},
    subgroup = "wrecks",
    order = "d[remnants]-d[ship-wreck]-b[medium]-a",
    max_health = 200,
    minable = {
      mining_time = 0.5 * 5,
      results={
        {name="iron-plate", amount = 24},
      }
    },
    resistances = resistances,
    collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
    collision_mask = collision_mask_nonblocking,
    selection_box = {{-1.5, -1.2}, {1.5, 1.2}},
    inventory_size = 1,
    picture =
    {
      filename = "__aai-industry__/graphics/entity/ship-wreck/medium-ship-wreck-1.png",
      width = 120,
      height= 85
    }
  },
  {
    type = "container",
    name = "aai-medium-ship-wreck-2",
    icon = "__base__/graphics/icons/ship-wreck/medium-ship-wreck.png",
    icon_size = 32,
    flags = {"placeable-neutral", "placeable-off-grid", "not-on-map"},
    subgroup = "wrecks",
    order = "d[remnants]-d[ship-wreck]-b[medium]-a",
    max_health = 200,
    minable = {
      mining_time = 0.5 * 5,
      results={
        {name="copper-plate", amount = 18},
      }
    },
    resistances = resistances,
    collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
    collision_mask = collision_mask_nonblocking,
    selection_box = {{-1.5, -1.2}, {1.5, 1.2}},
    inventory_size = 1,
    picture =
    {
      filename = "__aai-industry__/graphics/entity/ship-wreck/medium-ship-wreck-2.png",
      width = 126,
      height= 107,
      shift = {0.3, 0.1}
    }
  },

  {
    type = "simple-entity",
    name = "aai-small-ship-wreck",
    icon = "__base__/graphics/icons/ship-wreck/small-ship-wreck.png",
    icon_size = 32,
    flags = {"placeable-neutral", "placeable-off-grid", "not-on-map"},
    subgroup = "wrecks",
    order = "d[remnants]-d[ship-wreck]-c[small]-a",
    max_health = 100,
    minable = {
      mining_time = 0.5 * 3,
      results={
        {name="iron-plate", probability = 0.75, amount_min=5, amount_max=25},
        {name="copper-plate", probability = 0.25, amount_min=5, amount_max=25}
      }
    },
    resistances = resistances,
    collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
    collision_mask = collision_mask_nonblocking,
    selection_box = {{-1.3, -1.1}, {1.3, 1.1}},
    pictures =
    {
      {
        filename = "__aai-industry__/graphics/entity/ship-wreck/small-ship-wreck-a.png",
        width = 65,
        height= 68
      },
      {
        filename = "__aai-industry__/graphics/entity/ship-wreck/small-ship-wreck-b.png",
        width = 109,
        height= 67
      },
      {
        filename = "__aai-industry__/graphics/entity/ship-wreck/small-ship-wreck-c.png",
        width = 63,
        height= 54
      },
      {
        filename = "__aai-industry__/graphics/entity/ship-wreck/small-ship-wreck-d.png",
        width = 82,
        height= 67
      },
      {
        filename = "__aai-industry__/graphics/entity/ship-wreck/small-ship-wreck-e.png",
        width = 78,
        height= 75,
        shift={0.3, -0.2}
      },
      {
        filename = "__aai-industry__/graphics/entity/ship-wreck/small-ship-wreck-f.png",
        width = 58,
        height= 35
      },
      {
        filename = "__aai-industry__/graphics/entity/ship-wreck/small-ship-wreck-g.png",
        width = 80,
        height= 72
      },
      {
        filename = "__aai-industry__/graphics/entity/ship-wreck/small-ship-wreck-h.png",
        width = 79,
        height= 54
      },
      {
        filename = "__aai-industry__/graphics/entity/ship-wreck/small-ship-wreck-i.png",
        width = 56,
        height= 55
      }
    },
    render_layer = "object",
  }
})
