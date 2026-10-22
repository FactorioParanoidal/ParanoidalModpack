require("chance-increment")

ic.conf = {
  level_multiplier = settings.startup["ic-more-qualities-multiplier"].value,
  quality_mode = settings.startup["ic-more-qualities-mode"].value
}
ic.quality_mode = {
  full = "full",
  only_expand = "only-expand",
  rework = "rework"
}

function ic.debug(node)
  local cache, stack, output = {}, {}, {}
  local depth = 1
  local output_str = "{\n"

  while true do
    local size = 0
    for k, v in pairs(node) do
      size = size + 1
    end

    local cur_index = 1
    for k, v in pairs(node) do
      if (cache[node] == nil) or (cur_index >= cache[node]) then
        if (string.find(output_str, "}", output_str:len())) then
          output_str = output_str .. ",\n"
        elseif not (string.find(output_str, "\n", output_str:len())) then
          output_str = output_str .. "\n"
        end
        -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
        table.insert(output, output_str)
        output_str = ""

        local key
        if (type(k) == "number" or type(k) == "boolean") then
          key = "[" .. tostring(k) .. "]"
        else
          key = "['" .. tostring(k) .. "']"
        end

        if (type(v) == "number" or type(v) == "boolean") then
          output_str = output_str .. string.rep('\t', depth) .. key .. " = " .. tostring(v)
        elseif (type(v) == "table") then
          output_str = output_str .. string.rep('\t', depth) .. key .. " = {\n"
          table.insert(stack, node)
          table.insert(stack, v)
          cache[node] = cur_index + 1
          break
        else
          output_str = output_str .. string.rep('\t', depth) .. key .. " = '" .. tostring(v) .. "'"
        end

        if (cur_index == size) then
          output_str = output_str .. "\n" .. string.rep('\t', depth - 1) .. "}"
        else
          output_str = output_str .. ","
        end
      else
        -- close the table
        if (cur_index == size) then
          output_str = output_str .. "\n" .. string.rep('\t', depth - 1) .. "}"
        end
      end

      cur_index = cur_index + 1
    end

    if (size == 0) then
      output_str = output_str .. "\n" .. string.rep('\t', depth - 1) .. "}"
    end

    if (#stack > 0) then
      node = stack[#stack]
      stack[#stack] = nil
      depth = cache[node] == nil and depth + 1 or depth - 1
    else
      break
    end
  end
  -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
  table.insert(output, output_str)
  output_str = table.concat(output)
  print(output_str)
end

function ic.trim(str)
  return str:gsub("^%s*(.-)%s*$", "%1")
end

function ic.split_with_comma(str)
  local fields = {}
  for field in str:gmatch('([^,]+)') do
    fields[#fields + 1] = ic.trim(field)
  end
  return fields
end

function ic.update_quality_name(quality, default_name)
  local loc = settings.startup["ic-more-qualities-localization-" .. ic.conf.quality_mode].value
  local map = ic.split_with_comma(loc)

  for i = 1, #map do
    local key, value = string.match(map[i], '(.+)=(.+)')
    local trim_key = ic.trim(key)
    local trim_value = ic.trim(value)

    if (trim_key == quality.name and trim_value ~= "nil") then
      quality.localised_name = trim_value
      return
    end
  end
  if default_name ~= nil then
    quality.localised_name = default_name
  end
end

function ic.unlock_quality(effects, quality_name)
  table.insert(effects, { type = "unlock-quality", quality = quality_name })
end

function ic.create_quality(in_name, in_icon_name, in_level, in_order, in_next_quality_name, in_beacon_power_usage_multiplier,
                              in_mining_drill_resource_drain_multiplier, in_science_pack_drain_multiplier, in_color)

  if in_icon_name == nil then
    in_icon_name = in_name
  end

  local entity = {
    type = "quality",
    name = in_name,
    level = math.floor(in_level * ic.conf.level_multiplier),
    color = in_color,
    order = in_order,
    next = in_next_quality_name,
    next_probability = ic.get_chance(),
    subgroup = "qualities",
    icon = "__ic-more-qualities__/graphics/icons/quality-" .. in_icon_name .. ".png",
    beacon_power_usage_multiplier = in_beacon_power_usage_multiplier,
    mining_drill_resource_drain_multiplier = in_mining_drill_resource_drain_multiplier,
    science_pack_drain_multiplier = in_science_pack_drain_multiplier
  }
  ic.update_quality_name(entity)
  return entity
end