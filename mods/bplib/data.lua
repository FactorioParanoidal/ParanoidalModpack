require("types")

data:extend({
	{
		type = "custom-event",
		name = "bplib-extract",
	},
	{
		type = "custom-event",
		name = "bplib-overlaps",
	},
	{
		type = "custom-event",
		name = "bplib-positions",
	},
	{
		type = "mod-data",
		name = "bplib",
		data_type = "bplib.ModData",
		data = {
			overlap_entity_names = {},
			position_entity_names = {},
			extract_entity_names = {},
		} --[[@as bplib.ModData]],
	},
})
