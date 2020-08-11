return function(f)
	local ok, v = pcall(f)
	return ok and v or nil
end
