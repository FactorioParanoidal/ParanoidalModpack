data:extend{
  {
    type = "item-subgroup",
    name = "virtual-signal-corpse",
    group = "signals",
    order = "m"  -- Standard ones are a to e
  },
}

for name, corpse in pairs(data.raw["character-corpse"]) do
  if corpse.icon or corpse.icons then
    data:extend{
      {
        type = "virtual-signal",
        name = name,
        localised_name = corpse.localised_name or {"entity-name." .. name},
        localised_description = corpse.localised_description or {"entity-description." .. name},
        icon = corpse.icon,
        icon_size = corpse.icon_size,
        icon_mipmaps = corpse.icon_mipmaps,
        icons = corpse.icons,
        subgroup = "virtual-signal-corpse",
      }
    }
  end
end