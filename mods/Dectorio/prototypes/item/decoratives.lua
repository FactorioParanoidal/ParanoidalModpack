-- item/decoratives

if DECT.ENABLED["decoratives"] then
	-- Add subgroup for decoratives
	data:extend(
		{
			{
				type = "item-subgroup",
				name = "decoratives",
				group = DECT.ITEM_GROUP,
				order = "e-b"
			}
		}
	)

	data:extend(
		{
			{
				type = "item",
				name = "dect-traffic-bollard",
				icon = "__Dectorio__/graphics/icons/traffic-bollard.png",
				icon_size = 64,
				icon_mipmaps = 1,
				subgroup = "decoratives",
				order = "a[traffic-bollard]",
				place_result = "dect-traffic-bollard",
				stack_size = 50
			}
		}
	)
end
