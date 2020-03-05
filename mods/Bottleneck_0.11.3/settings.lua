local icons = {
  "none",
  "none small",
  "alert",
  "alert small",
  "cross",
  "cross small",
  "minus",
  "minus small",
  "pause",
  "pause small",
  "stop",
  "stop small",
  "alert3D",
  "alert3D small",
  "cross3D",
  "cross3D small",
  "minus3D",
  "minus3D small",
  "pause3D",
  "pause3D small",
  "stop3D",
  "stop3D small"
}

local colors = {
  "off",
  "white",
  "blue",
  "red",
  "green",
  "yellow"
}

local settings_values = {
  ["working"] = {
    color = "green",
    icon = "none"
  },
  ["no_power"] = {
    color = "red",
    icon = "alert"
  },
  ["no_fuel"] = {
    color = "red",
    icon = "alert"
  },
  ["no_input_fluid"] = {
    color = "red",
    icon = "alert"
  },
  ["no_research_in_progress"] = {
    color = "white",
    icon = "pause small"
  },
  ["no_minable_resources"] = {
    color = "red",
    icon = "stop"
  },
  ["low_input_fluid"] = {
    color = "yellow",
    icon = "alert"
  },
  ["low_power"] = {
    color = "yellow",
    icon = "alert"
  },
  ["disabled_by_control_behavior"] = {
    color = "white",
    icon = "stop small"
  },
  ["disabled_by_script"] = {
    color = "white",
    icon = "stop small"
  },
  ["fluid_ingredient_shortage"] = {
    color = "red",
    icon = "alert"
  },
  ["fluid_production_overload"] = {
    color = "yellow",
    icon = "pause"
  },
  ["item_ingredient_shortage"] = {
    color = "red",
    icon = "alert"
  },
  ["item_production_overload"] = {
    color = "yellow",
    icon = "pause"
  },
  ["missing_required_fluid"] = {
    color = "red",
    icon = "alert"
  },
  ["missing_science_packs"] = {
    color = "red",
    icon = "alert"
  },
  ["waiting_for_source_items"] = {
    color = "red",
    icon = "alert"
  },
  ["waiting_for_space_in_destination"] = {
    color = "yellow",
    icon = "pause"
  },
}

local settings = {
  {
    type = "int-setting",
    name = "bottleneck-signals-per-tick",
    setting_type = "runtime-global",
    default_value = 40,
    maximum_value = 2000,
    minimum_value = 1,
    order = "bottleneck-01",
  }
}

local order = 2
for status_name, _ in pairs(defines.entity_status) do
  local defaults = settings_values[status_name]
  if defaults == nil then
    defaults = {
      color = "off",
      icon = "none"
    }
  end
  log(status_name .. " - " .. defaults.color .. " " .. defaults.icon)
  local color_setting = {
    type = "string-setting",
    name = "bottleneck-show-" .. status_name .. "-color",
    setting_type = "runtime-global",
    default_value = defaults.color,
    allowed_values = colors,
    order = string.format("bottleneck-%02d", order)
  }
  order = order + 1
  local icon_setting = {
    type = "string-setting",
    name = "bottleneck-show-" .. status_name .. "-icon",
    setting_type = "runtime-global",
    default_value = defaults.icon,
    allowed_values = icons,
    order = string.format("bottleneck-%02d", order)
  }
  settings[#settings+1] = color_setting
  settings[#settings+1] = icon_setting
  order = order + 1
end

data:extend(settings)
