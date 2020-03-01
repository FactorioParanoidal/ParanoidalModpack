function NeedMigration(data,mod_name)
	if data 
	 and data.mod_changes 
	 and data.mod_changes[mod_name] 
	 and data.mod_changes[mod_name].old_version then 
		return true 
	end
	return false
end

function GetOldVersion(data,mod_name)
	return FormatVersion(data.mod_changes[mod_name].old_version)
end

function GetNewVersion(data,mod_name)
	return FormatVersion(data.mod_changes[mod_name].new_version)
end

function FormatVersion(version)
	return string.format("%02d.%02d.%02d", string.match(version, "(%d+).(%d+).(%d+)"))
end

function Contains(tab,elem)
	for _,v in pairs(tab) do
		if v == elem then
			return true
		elseif type(v) == "table" then
			if Contains(v,elem) then
				return true
			end
		end
	end
	return false
end

function Remove(tab,i)
	for i,v in pairs(tab) do
		if v == elem then
			table.remove(tab,i)
			return true
		end
	end
	return false
end


function Count(list)
	local i = 0
	for _ in pairs(list) do
		i = i + 1
	end
	return i
end