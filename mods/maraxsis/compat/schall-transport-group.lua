if not mods["SchallTransportGroup"] then return end

data.raw.item["sp-spidertron-dock"].subgroup = "vehicles-civilian"
data.raw["item-with-entity-data"]["maraxsis-diesel-submarine"].subgroup = "vehicles-civilian"
data.raw["item-with-entity-data"]["maraxsis-nuclear-submarine"].subgroup = "vehicles-civilian"

data.raw.item["sp-spidertron-dock"].order = "j[maraxsis]-a[sp-spidertron-dock]"
data.raw["item-with-entity-data"]["maraxsis-diesel-submarine"].order = "j[maraxsis]-c[maraxsis-diesel-submarine]"
data.raw["item-with-entity-data"]["maraxsis-nuclear-submarine"].order = "j[maraxsis]-d[maraxsis-nuclear-submarine]"
