


for _, type in pairs(textplates.types) do
  local size = type.size
  local material = type.material
  local count = 0

  count = count + 1

  local base_item = {
    type = "item",
    name = type.name, -- no symbol suffix
    icon = "__textplates__/graphics/entity/"..material.."/blank.png",
    icon_size = 128,
    flags = {}, -- not hidden
    subgroup = "textplates",
    order = "e[textplates]-"..material.."-"..(size == "small" and 1 or 2).."-"..string.format( "%03d", count ),
    stack_size = 100,
    place_result = type.name,
    localised_name = { "item-name.textplate", { "textplates."..size }, {"textplates.".. material } }
  }
  if size == "large" then
    base_item.icon = "__textplates__/graphics/entity/"..material.."/square.png"
  end

  data:extend({ base_item })

  for _, symbol in pairs(type.symbols) do
    local symbol_item = {
      type = "item",
      name = type.name .. "-" .. symbol, -- all symbols must have the base item name fillowered by "-".. symbol
      icon = "__textplates__/graphics/entity/"..material.."/"..symbol..".png",
      icon_size = 128,
      flags = {},
      hidden = true,
      subgroup = "textplates",
      order = "e[textplates]-"..material.."-"..(size == "small" and 1 or 2).."-"..string.format( "%03d", count ),
      stack_size = 100,
      place_result = type.name,
      localised_name = { "item-name.textplate", { "textplates."..size }, {"textplates.".. material } }
    }
    data:extend({ symbol_item })
  end
end
