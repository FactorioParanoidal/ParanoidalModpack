function enableIfExists(table, key)
	if (table[key] ~= nil)
	then
		table[key].enable = true
	end
end

for index, force in pairs(game.forces) do

	force.reset_recipes()
	force.reset_technologies()

	local tech = force.technologies
	local rec = force.recipes

	if settings.startup["dectorio-landscaping"].value then
		if tech["dect-landscaping"].researched then
			enableIfExists(rec, "dect-base-tree-01")
			enableIfExists(rec, "dect-base-tree-02")
			enableIfExists(rec, "dect-base-tree-03")
			enableIfExists(rec, "dect-base-tree-04")
			enableIfExists(rec, "dect-base-tree-05")
			enableIfExists(rec, "dect-base-tree-06")
			enableIfExists(rec, "dect-base-tree-07")
			enableIfExists(rec, "dect-base-tree-08")
			enableIfExists(rec, "dect-base-tree-09")
			enableIfExists(rec, "dect-base-dead-dry-hairy-tree")
			enableIfExists(rec, "dect-base-dead-grey-trunk")
			enableIfExists(rec, "dect-base-dead-tree-desert")
			enableIfExists(rec, "dect-base-dry-hairy-tree")
			enableIfExists(rec, "dect-base-dry-tree")
		end
	end
end
