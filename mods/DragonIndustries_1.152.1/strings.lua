function lastIndexOf(str, seek)
	local flip = string.reverse(str)
	local s,e = string.find(str, seek, 1, true)
	--log(flip .. " > " .. (s and s or "nil"))
	if s and e then
		s = string.len(str)-s
		e = string.len(str)-e
		return s,e
	end
end

function splitAfter(str, mark)
	local s,e = lastIndexOf(str, mark)
	if s and e then
		local part = string.sub(str, e+1)
		--log(part)
		return tonumber(part)
	end
end

function splitString(str, seek)
	local ret = {}
	for s in str:gmatch("([^" .. seek .. "]+)") do
		table.insert(ret, s)
	end
	return ret
end

function literalReplace(str, seek, repl)
	if seek == repl then return str end
	local idx,idx2 = str:find(seek, 1, true)
	local ret = str
	while idx and idx2 do
		ret = ret:sub(1,idx-1) .. repl .. ret:sub(idx2+1, #ret)
		idx,idx2 = ret:find(seek, 1, true)
	end
	return ret
end

function stringStartsWith(str, seek)
	return string.sub(str, 1, string.len(seek)) == seek
end

function stringEndsWith(str, seek)
	return string.sub(str, -#seek) == seek

end