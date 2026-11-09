if not mods["aai-industry"] then return end

data.raw.recipe["motor"].categories = data.raw.recipe["motor"].categories or {"crafting"}
data.raw.recipe["electric-motor"].categories = data.raw.recipe["electric-motor"].categories or {"crafting"}
table.insert(data.raw.recipe["motor"].categories, "maraxsis-hydro-plant")
table.insert(data.raw.recipe["electric-motor"].categories, "maraxsis-hydro-plant")

data.raw.item["maraxsis-glass-panes"].localised_name = {"item-name.maraxsis-reinforced-glass"}
