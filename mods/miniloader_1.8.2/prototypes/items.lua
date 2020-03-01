local function create_items(prefix, base_underground_name, tint)
  local name = prefix .. "miniloader"
  local filter_name = prefix .. "filter-miniloader"

  local item = util.table.deepcopy(data.raw.item[base_underground_name])
  item.name = name
  item.localised_name = {"entity-name." .. name}
  item.icon = nil
  item.icons = {
    {
      icon = "__miniloader__/graphics/item/template.png",
      icon_size = 32,
    },
    {
      icon = "__miniloader__/graphics/item/mask.png",
      icon_size = 32,
      tint = tint,
    },
  }
  item.order, _ = string.gsub(item.order, "^b%[underground%-belt%]", "e[miniloader]", 1)
  item.order, _ = string.gsub(item.order, "^c%[rapid%-transport%-belt%-to%-ground.*%]", "e[miniloader]", 1)
  item.place_result = name .. "-inserter"

  local filter_item = util.table.deepcopy(item)
  filter_item.name = filter_name
  filter_item.localised_name = {"entity-name." .. filter_name}
  filter_item.icons[1].icon = "__miniloader__/graphics/item/filter-template.png"
  filter_item.order, _ = string.gsub(item.order, "e%[", "f[filter-", 1)
  filter_item.place_result = filter_name .. "-inserter"

  data:extend{
    item,
    filter_item,
  }
end

return {
  create_items = create_items,
}
