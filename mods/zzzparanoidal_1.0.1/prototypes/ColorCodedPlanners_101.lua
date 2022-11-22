local changes = {
  ["blueprint"] = {
    ["blueprint"] = {
      selection_cursor_box_type = "electricity",
      alt_selection_cursor_box_type = "electricity"
    }
  },
  ["copy-paste-tool"] = {
    ["cut-paste-tool"] = {
      selection_cursor_box_type = "not-allowed",
      alt_selection_cursor_box_type = "not-allowed"
    },
    ["copy-paste-tool"] = {
      selection_cursor_box_type = "electricity",
      alt_selection_cursor_box_type = "electricity"
    }
  },
  ["deconstruction-item"] = {
    ["deconstruction-planner"] = {
      selection_cursor_box_type = "not-allowed",
      alt_selection_cursor_box_type = "not-allowed"
    }
  },
  ["upgrade-item"] = {
    ["upgrade-planner"] = {
      selection_cursor_box_type = "copy",
      alt_selection_cursor_box_type = "copy"
    }
  }
}

for category, items in pairs(changes) do
  local category_data = data.raw[category]
  for name, mods in pairs(items) do
    local item = category_data[name]
    for k, v in pairs(mods) do
      item[k] = v
    end
  end
end

data.raw["utility-sprites"]["default"]["upgrade_mark"].filename = "__zzzparanoidal__/graphics/upgrade.png"