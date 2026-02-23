require ("__base__/prototypes/entity/assemblerpipes")
local sounds = require("__base__/prototypes/entity/sounds.lua")

local allowed_effects = {"speed"} -- {"consumption", "speed", "productivity", "pollution"}
local ENTITYPATH = "__Rocket-Silo-Construction__/graphics/entity/"

local PW_MP = settings.startup["rsc-st-power-mp"].value

local resistances = {
    {
        type = "fire",
        percent = 70
    },
    {
        type = "impact",
        percent = 60
    }
}


local base_pw = math.ceil(150 * PW_MP)
local energy_usage = tostring(base_pw) .. "MW"
local max_health = 3000
local stages = {}

function entitylayer(num, shadow)
return {
    filename = ENTITYPATH .. "hr-rs-stage" .. num .. ".png",
    width = 608,
    height = 596,
    draw_as_shadow = shadow or false,
    --shift = util.by_pixel(5, -2),
    scale = 0.5
}
end

function entitylayerserlp(num, shadow)
return {
    filename = ENTITYPATH .. "hr-rs-stage" .. num .. "-serlp.png",
    width = 640,
    height = 640,
    draw_as_shadow = shadow or false,
    --shift = util.by_pixel(-5, 16),
    scale = 0.5
}
end

local rocketsiloremnant2 = {
  type = "corpse",
  name = "rsc-silo-stage2_remnant",
  icon = "__base__/graphics/icons/remnants.png",
  icon_size = 64,
  icon_mipmaps = 4,
  flags = {"placeable-neutral", "building-direction-8-way", "not-on-map"},
  subgroup = "remnants",
  order = "z-z-z",
  selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
  tile_width = 9,
  tile_height = 9,
  selectable_in_game = false,
  time_before_removed = 60 * 60 * 15, -- 15 minutes
  final_render_layer = "remnants",
  remove_on_tile_placement = false,
  animation = 
  {
      filename = ENTITYPATH .. "hr-rs-stage2_remnant.png",
      width = 608,
      height = 596,
      line_length = 1,
      frame_count = 1,
      direction_count = 1,
      scale = 0.5
  }
}
local rocketsiloremnant3 = {
  type = "corpse",
  name = "rsc-silo-stage3_remnant",
  icon = "__base__/graphics/icons/remnants.png",
  icon_size = 64,
  icon_mipmaps = 4,
  flags = {"placeable-neutral", "building-direction-8-way", "not-on-map"},
  subgroup = "remnants",
  order = "z-z-z",
  selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
  tile_width = 9,
  tile_height = 9,
  selectable_in_game = false,
  time_before_removed = 60 * 60 * 15, -- 15 minutes
  final_render_layer = "remnants",
  remove_on_tile_placement = false,
  animation =
  {
      filename = ENTITYPATH .. "hr-rs-stage3_remnant.png",
      width = 608,
      height = 596,
      line_length = 1,
      frame_count = 1,
      direction_count = 1,
      scale = 0.5
  }
}

local rocketsiloremnant4 = {
  type = "corpse",
  name = "rsc-silo-stage4_remnant",
  icon = "__base__/graphics/icons/remnants.png",
  icon_size = 64,
  icon_mipmaps = 4,
  flags = {"placeable-neutral", "building-direction-8-way", "not-on-map"},
  subgroup = "remnants",
  order = "z-z-z",
  selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
  tile_width = 9,
  tile_height = 9,
  selectable_in_game = false,
  time_before_removed = 60 * 60 * 15, -- 15 minutes
  final_render_layer = "remnants",
  remove_on_tile_placement = false,
  animation =
  {
      filename = ENTITYPATH .. "hr-rs-stage4_remnant.png",
      width = 608,
      height = 596,
      line_length = 1,
      frame_count = 1,
      direction_count = 1,
      scale = 0.5
  }
}


stages[1] = {
    type = "assembling-machine",
    name = "rsc-silo-stage1",
    icons = icons_rsc,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 60, result = "rsc-excavation-site"},
    max_health = max_health,
    corpse = "rsc-silo-stage3_remnant",
    dying_explosion = "massive-explosion",
    --alert_icon_shift = util.by_pixel(-3, -12),
    resistances = resistances,
    fluid_boxes = {}, -- zerado
    collision_box = {{-4.40, -4.40}, {4.40, 4.40}}, -- colision do silo
    selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
    graphics_set = {animation = {
        layers = {
            entitylayer("1")
        }
    }},
    vehicle_impact_sound = sounds.generic_impact,
    working_sound = {
        sound = {
            filename = "__base__/sound/electric-mining-drill.ogg",
            volume = 1
        },
        apparent_volume = 2
    },
    crafting_categories = {"rsc-stage1"}, --so advanced-crafting
    fixed_recipe = "rsc-construction-stage1",
    crafting_speed = 1,
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input", -- silo usa primary-input
        emissions_per_minute = { pollution = 200}
    },
    energy_usage = energy_usage,
    module_specification = {module_slots = 0},
    allowed_effects = allowed_effects,
    open_sound = sounds.machine_open,
    close_sound = sounds.machine_close
}

stages[2] = {
    type = "assembling-machine",
    name = "rsc-silo-stage2",
    order = "r-s",
    icons = icons_rsc,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 60, result = "rsc-excavation-site"},
    hidden=true,
    max_health = max_health,
    corpse = "rsc-silo-stage2_remnant",
    dying_explosion = "massive-explosion",
    --alert_icon_shift = util.by_pixel(-3, -12),
    resistances = resistances,
    collision_box = {{-4.40, -4.40}, {4.40, 4.40}}, -- colision do silo
    selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
    graphics_set = {animation = {
        layers = {
            entitylayer("2")
        }
    }},
    vehicle_impact_sound = sounds.generic_impact,
    working_sound = {
        sound = {
            filename = "__base__/sound/electric-mining-drill.ogg",
            volume = 1
        },
        apparent_volume = 2
    },
    crafting_categories = {"rsc-stage2", "crafting-with-fluid"}, --so advanced-crafting
    fixed_recipe =  "rsc-construction-stage2", --,"concrete",
    crafting_speed = 1,
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input", -- silo usa primary-input
        emissions_per_minute = { pollution = 200}
    },
    energy_usage = energy_usage,
    module_specification = {module_slots = 0},
    allowed_effects = allowed_effects,
    open_sound = sounds.machine_open,
    close_sound = sounds.machine_close,

    
  fluid_boxes =
    {
      {
		volume = 1000,
        production_type = "input",
        --pipe_picture = {},
        pipe_covers = pipecoverspictures(),
        base_area = 81,
        base_level = -1,
        pipe_connections = {
			  { flow_direction="input", position = {0, -4} , direction = defines.direction.north},
              { flow_direction="input", position = {-4, 0} , direction = defines.direction.west},
              { flow_direction="input", position = {4, 0}  , direction = defines.direction.east},
              { flow_direction="input", position = {0, 4}  , direction = defines.direction.south}
			  },
        --secondary_draw_orders = { north = -1 }
      },
    },  
}





stages[3] = {
    type = "assembling-machine",
    name = "rsc-silo-stage3",
    order = "r-s",
    icons = icons_rsc,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 60, result = "rsc-excavation-site"},
    max_health = max_health,
    hidden=true,
    corpse = "rsc-silo-stage3_remnant",
    dying_explosion = "massive-explosion",
    --alert_icon_shift = util.by_pixel(-3, -12),
    resistances = resistances,
    fluid_boxes = {}, -- zerado
    collision_box = {{-4.40, -4.40}, {4.40, 4.40}}, -- colision do silo
    selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
    graphics_set = {animation = {
        layers = {
            entitylayer("3")
        }
    }},
    vehicle_impact_sound = sounds.generic_impact,
    working_sound = {
        sound = {
            filename = "__base__/sound/electric-mining-drill.ogg",
            volume = 1
        },
        apparent_volume = 2
    },
    crafting_categories = {"rsc-stage3"}, --so advanced-crafting
    fixed_recipe = "rsc-construction-stage3",
    crafting_speed = 1,
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input", -- silo usa primary-input
        emissions_per_minute = { pollution = 200}
    },
    energy_usage = energy_usage,
    module_specification = {module_slots = 0},
    allowed_effects = allowed_effects,
    open_sound = sounds.machine_open,
    close_sound = sounds.machine_close
}

stages[4] = {
    type = "assembling-machine",
    name = "rsc-silo-stage4",
    order = "r-s",
    hidden=true,
    icons = icons_rsc,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 60, result = "rsc-excavation-site"},
    max_health = max_health,
    corpse = "rsc-silo-stage4_remnant",
    dying_explosion = "massive-explosion",
    --alert_icon_shift = util.by_pixel(-3, -12),
    resistances = resistances,
    fluid_boxes = {}, -- zerado
    collision_box = {{-4.40, -4.40}, {4.40, 4.40}}, -- colision do silo
    selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
    graphics_set = {animation = {
        layers = {
            entitylayer("4")
        }
    }},
    vehicle_impact_sound = sounds.generic_impact,
    working_sound = {
        sound = {
            filename = "__base__/sound/electric-mining-drill.ogg",
            volume = 1
        },
        apparent_volume = 2
    },
    crafting_categories = {"rsc-stage4"}, --so advanced-crafting
    fixed_recipe = "rsc-construction-stage4",
    crafting_speed = 1,
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input", -- silo usa primary-input
        emissions_per_minute = { pollution = 200}
    },
    energy_usage = energy_usage,
    module_specification = {module_slots = 0},
    allowed_effects = allowed_effects,
    open_sound = sounds.machine_open,
    close_sound = sounds.machine_close
}

stages[5] = {
    type = "assembling-machine",
    name = "rsc-silo-stage5",
    icons = icons_rsc,
    hidden=true,
    order = "r-s",
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 60, result = "rsc-excavation-site"},
    max_health = max_health,
    corpse = "rocket-silo-remnants",
    dying_explosion = "massive-explosion",
    --alert_icon_shift = util.by_pixel(-3, -12),
    resistances = resistances,
    fluid_boxes = {}, -- zerado
    collision_box = {{-4.40, -4.40}, {4.40, 4.40}}, -- colision do silo
    selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
    graphics_set = {animation = {
        layers = {
            entitylayer("5"),
            entitylayer("5_shadow", true)
        }
    }},
    vehicle_impact_sound = sounds.generic_impact,
    working_sound = {
        sound = {
            filename = "__base__/sound/electric-mining-drill.ogg",
            volume = 1
        },
        apparent_volume = 2
    },
    crafting_categories = {"rsc-stage5"}, --so advanced-crafting
    fixed_recipe = "rsc-construction-stage5",
    crafting_speed = 1,
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input", -- silo usa primary-input
        emissions_per_minute = { pollution = 200}
    },
    energy_usage = energy_usage,
    module_specification = {module_slots = 0},
    allowed_effects = allowed_effects,
    open_sound = sounds.machine_open,
    close_sound = sounds.machine_close
}

stages[6] = {
    type = "assembling-machine",
    name = "rsc-silo-stage6",
    icons = icons_rsc,
    hidden=true,
    order = "r-s",
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 60, result = "rsc-excavation-site"},
    max_health = max_health,
    corpse = "rocket-silo-remnants",
    dying_explosion = "massive-explosion",
    --alert_icon_shift = util.by_pixel(-3, -12),
    resistances = resistances,
    fluid_boxes = {}, -- zerado
    collision_box = {{-4.40, -4.40}, {4.40, 4.40}}, -- colision do silo
    selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
    graphics_set = {animation = {
        layers = {
            entitylayer("6"),
            entitylayer("6_shadow", true)
        }
    }},
    vehicle_impact_sound = sounds.generic_impact,
    working_sound = {
        sound = {
            filename = "__base__/sound/electric-mining-drill.ogg",
            volume = 1
        },
        apparent_volume = 2
    },
    crafting_categories = {"rsc-stage6"}, --so advanced-crafting
    fixed_recipe = "rsc-construction-stage6",
    crafting_speed = 1,
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input", -- silo usa primary-input
        emissions_per_minute = { pollution = 200}
    },
    energy_usage = energy_usage,
    module_specification = {module_slots = 0},
    allowed_effects = allowed_effects,
    open_sound = sounds.machine_open,
    close_sound = sounds.machine_close
}
data:extend({
  rocketsiloremnant2,
  rocketsiloremnant3,
  rocketsiloremnant4,
})
for s = 1, 6 do
    data:extend({stages[s]})
end

local pipe_p = 4.5
local function update_proto_serlp(s, sufix_name, collision_box, localised_name, icons)
  local new = table.deepcopy(stages[s])
  new.name = new.name .. sufix_name
  new.icons = icons
  new.localised_name = localised_name
  new.minable.result = "rsc-excavation-site" .. sufix_name
  new.collision_box = collision_box --  {{-4.85, -4.85}, {4.85, 4.85}}
  new.selection_box = collision_box
  --new.animation.layers[1].scale=1
  --new.animation.layers[1].hr_version.scale=0.5
  if s==2 and sufix_name=="-serlp" then
  new.graphics_set.animation = entitylayerserlp("2")
  new.fluid_boxes =
  {
    {
	  volume = 1000,
      production_type = "input",
      pipe_covers = pipecoverspictures(),
      base_area = 100,
      base_level = -1,
      pipe_connections =
      {
        { flow_direction="input",position = {-pipe_p, -0.5}, direction = defines.direction.west   },
        { flow_direction="input",position = {pipe_p,  -0.5}, direction = defines.direction.east  },
        { flow_direction="input",position = {-0.5, -pipe_p}, direction = defines.direction.north  },
        { flow_direction="input",position = {-0.5,  pipe_p}, direction = defines.direction.south },
        { flow_direction="input",position = {-pipe_p, 0.5}, direction = defines.direction.west },
        { flow_direction="input",position = {pipe_p,  0.5}, direction = defines.direction.east },
        { flow_direction="input",position = {0.5, -pipe_p}, direction = defines.direction.north },
        { flow_direction="input",position = {0.5,  pipe_p}, direction = defines.direction.south },
      },
    },
  }
  end
  return new
end


if data.raw.item["se-rocket-launch-pad"] then
    local enable_se_cargo = settings.startup["rsc-st-enable-se-cargo-silo"].value
    if enable_se_cargo then
        local collision_box = data.raw.container["se-rocket-launch-pad"].collision_box
        for s = 1, 6 do
            data:extend(
                {
                    update_proto_serlp(
                        s,
                        "-serlp",
                        collision_box,
                        {"", {"entity-name.se-rocket-launch-pad"}, {"RSC.construction_site", tostring(s)}},
                        icons_se_crs
                    )
                }
            )
        end
    end
end

if data.raw["rocket-silo"]["se-space-probe-rocket-silo"] then
    local enable_se_probe = settings.startup["rsc-st-enable-se-probe-silo"].value
    if enable_se_probe then
        local collision_box = data.raw["rocket-silo"]["se-space-probe-rocket-silo"].collision_box
        for s = 1, 6 do
            data:extend(
                {
                    update_proto_serlp(
                        s,
                        "-sesprs",
                        collision_box,
                        {"", {"entity-name.se-space-probe-rocket-silo"}, {"RSC.construction_site", tostring(s)}},
                        icons_se_sp
                    )
                }
            )
        end
        data.raw["assembling-machine"]["rsc-silo-stage5-sesprs"].fixed_recipe = "rsc-construction-stage5-sesprs"
        data.raw["assembling-machine"]["rsc-silo-stage6-sesprs"].fixed_recipe = "rsc-construction-stage6-sesprs"
    end
end
