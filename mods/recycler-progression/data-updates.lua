data.raw.item["recycler"].icon = "__recycler-progression__/graphics/icons/recycler-4.png"
data.raw.item["recycler"].order = "dd[recycler]"

-- Recycler 4 stays on the Quality "recycling" technology; chain it after Recycler 3.
local recycling_tech = data.raw.technology["recycling"]
recycling_tech.prerequisites = recycling_tech.prerequisites or {}
table.insert(recycling_tech.prerequisites, "recycler-3")
-- Paranoidal decision: original mod cost (500) instead of Quality's 5000.
recycling_tech.unit.count = 500
recycling_tech.localised_name = {"technology-name.recycler-4"}
recycling_tech.localised_description = {"technology-description.recycler-4"}
