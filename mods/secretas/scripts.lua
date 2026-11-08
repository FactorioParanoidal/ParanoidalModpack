local util_scripts = {}

util_scripts.table_contains = function (table, value, key)
	-- log("table_contains:")
	-- log("**table")
	-- log(serpent.block(table))
	-- log("**value")
	-- log(serpent.block(value))
	-- log("**key")
	-- log(serpent.block(key))
	for i, localVal in ipairs(table) do
			if(key ~= nil and localVal[key] == value or localVal == value) then
					return true
			end
	end
	return false
end

util_scripts.get_all_science_from_all_labs = function ()
	local all_science = {}
	--[[
	for _, lab in pairs(data.raw['lab']) do
			for __, lab_input in pairs(lab.inputs) do
					if(not util_scripts.table_contains(all_science, lab_input)) then
							table.insert(all_science, lab_input)
					end
			end
	end
	--]]
	for __, lab_input in pairs(data.raw['lab']['lab'].inputs) do --just parse the default lab, other labs are causing problems....
		if(not util_scripts.table_contains(all_science, lab_input)) then
				table.insert(all_science, lab_input)
		end
	end



	-- log("**all_science:")
	-- log(serpent.block(all_science))
	return all_science
end

return util_scripts