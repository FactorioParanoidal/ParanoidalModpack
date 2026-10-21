local data = _G.data
------------------------------------------------------------------------------------------------------
if not data.raw["item-subgroup"]["inserter-cranes"] then
	local group = "logistics"
	local order = "c"
	if mods["boblogistics"] then
		group = "bob-logistics"
		order = "c-z-a"
	end
	data:extend(
		{
			{
				type = "item-subgroup",
				name = "inserter-cranes",
				group = group,
				order = order
			}
		}
	)
end
