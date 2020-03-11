local filter_machine_1 = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-1"])
filter_machine_1.name = "CW-air-filter-machine-1"
filter_machine_1.icon = "__CW-carbon-capture-reforged__/graphics/icons/air-filter-machine-1.png"
filter_machine_1.icon_size = 32
filter_machine_1.minable.result = "CW-air-filter-machine-1"
filter_machine_1.fast_replaceable_group = "CW-air-filter-machine"
filter_machine_1.max_health = 300
filter_machine_1.corpse = "small-remnants"
filter_machine_1.collision_box = {{-1.2, -1.2}, {1.2, 1.2}}
filter_machine_1.selection_box = {{-1.5, -1.5}, {1.5, 1.5}}
filter_machine_1.animation =
    {
      filename = "__CW-carbon-capture-reforged__/graphics/entity/air-filter-machine-1.png",
      priority = "high",
      width = 99,
      height = 112,
      frame_count = 8,
      line_length = 4,
	  animation_speed = 0.15,
      shift = util.by_pixel(8, -13), --{0.2, -0.05},
	  --scale = 0.7,
	  repeat_count = 4
    }
filter_machine_1.next_upgrade = "CW-air-filter-machine-2"
filter_machine_1.crafting_categories = {"CW-air-filter"}
filter_machine_1.fixed_recipe = "CW-filter-air"
filter_machine_1.source_inventory_size = 1
filter_machine_1.result_inventory_size = 1
filter_machine_1.crafting_speed = 1
filter_machine_1.energy_source.emissions_per_minute = -50
filter_machine_1.energy_source.drain = "5KW"
filter_machine_1.energy_usage = "250KW"
filter_machine_1.allowed_effects = nil
filter_machine_1.working_sound =
    {
      sound = { { filename = "__base__/sound/electric-furnace.ogg", volume = 0.7 } },
      idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 1.5
    }
filter_machine_1.module_specification =
    {
      module_slots = 0,
    }



local filter_machine_2 = table.deepcopy(filter_machine_1)
filter_machine_2.name = "CW-air-filter-machine-2"
filter_machine_2.icon = "__CW-carbon-capture-reforged__/graphics/icons/air-filter-machine-2.png"
filter_machine_2.minable.result = "CW-air-filter-machine-2"
filter_machine_2.animation.filename = "__CW-carbon-capture-reforged__/graphics/entity/air-filter-machine-2.png"
filter_machine_2.next_upgrade = "CW-air-filter-machine-3"
filter_machine_2.crafting_speed = 1.5
filter_machine_2.energy_source.emissions_per_minute = -80
filter_machine_2.energy_usage = "500KW"
filter_machine_2.module_specification =
    {
      module_slots = 1,
      module_info_icon_shift = {0, 0.5},
      module_info_multi_row_initial_height_modifier = -0.3
    }
filter_machine_2.allowed_effects = {"consumption", "speed"}

local filter_machine_3 = table.deepcopy(filter_machine_1)
filter_machine_3.name = "CW-air-filter-machine-3"
filter_machine_3.icon = "__CW-carbon-capture-reforged__/graphics/icons/air-filter-machine-3.png"
filter_machine_3.minable.result = "CW-air-filter-machine-3"
filter_machine_3.animation.filename = "__CW-carbon-capture-reforged__/graphics/entity/air-filter-machine-3.png"
filter_machine_3.next_upgrade = "CW-air-filter-machine-4"
filter_machine_3.crafting_speed = 2
filter_machine_3.energy_source.emissions_per_minute = -125
filter_machine_3.energy_usage = "1200KW"
filter_machine_3.module_specification =
    {
      module_slots = 1,
      module_info_icon_shift = {0, 0.5},
      module_info_multi_row_initial_height_modifier = -0.3
    }
filter_machine_3.allowed_effects = {"consumption", "speed"}

local filter_machine_4 = table.deepcopy(filter_machine_1)
filter_machine_4.name = "CW-air-filter-machine-4"
filter_machine_4.icon = "__CW-carbon-capture-reforged__/graphics/icons/air-filter-machine-4.png"
filter_machine_4.minable.result = "CW-air-filter-machine-4"
filter_machine_4.animation.filename = "__CW-carbon-capture-reforged__/graphics/entity/air-filter-machine-4.png"
filter_machine_4.next_upgrade = "CW-air-filter-machine-5"
filter_machine_4.crafting_speed = 4
filter_machine_4.energy_source.emissions_per_minute = -300
filter_machine_4.energy_usage = "2500KW"
filter_machine_4.module_specification =
    {
      module_slots = 2,
      module_info_icon_shift = {0, 0.5},
      module_info_multi_row_initial_height_modifier = -0.3
    }
filter_machine_4.allowed_effects = {"consumption", "speed"}

local filter_machine_5 = table.deepcopy(filter_machine_1)
filter_machine_5.name = "CW-air-filter-machine-5"
filter_machine_5.icon = "__CW-carbon-capture-reforged__/graphics/icons/air-filter-machine-5.png"
filter_machine_5.minable.result = "CW-air-filter-machine-5"
filter_machine_5.animation.filename = "__CW-carbon-capture-reforged__/graphics/entity/air-filter-machine-5.png"
filter_machine_5.next_upgrade = "CW-air-filter-machine-6"
filter_machine_5.crafting_speed = 6
filter_machine_5.energy_source.emissions_per_minute = -550
filter_machine_5.energy_usage = "4500KW"
filter_machine_5.module_specification =
    {
      module_slots = 2,
      module_info_icon_shift = {0, 0.5},
      module_info_multi_row_initial_height_modifier = -0.3
    }
filter_machine_5.allowed_effects = {"consumption", "speed"}

local filter_machine_6 = table.deepcopy(filter_machine_1)
filter_machine_6.name = "CW-air-filter-machine-6"
filter_machine_6.icon = "__CW-carbon-capture-reforged__/graphics/icons/air-filter-machine-6.png"
filter_machine_6.minable.result = "CW-air-filter-machine-6"
filter_machine_6.animation.filename = "__CW-carbon-capture-reforged__/graphics/entity/air-filter-machine-6.png"
filter_machine_6.next_upgrade = ""
filter_machine_6.crafting_speed = 9
filter_machine_6.energy_source.emissions_per_minute = -900
filter_machine_6.energy_usage = "6900KW"
filter_machine_6.module_specification =
    {
      module_slots = 3
    }
filter_machine_6.allowed_effects = {"consumption", "speed"}


data:extend({filter_machine_1,filter_machine_2,filter_machine_3,filter_machine_4,filter_machine_5,filter_machine_6})





