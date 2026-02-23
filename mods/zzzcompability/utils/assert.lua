local Assert = {}
Assert._enabled_ = true

Assert.Assert = function(cond, message)
	if not Assert._enabled_ then
		return
	end
	assert(cond, message)
end

Assert.Debug = function(cond, message)
	Assert.Assert(cond, "DEBUG: " .. message)
end

Assert.AssertOutdated = function(cond, message)
	Assert.Assert(cond, message .. " Maybe current fix outdated?")
end

Assert.Expected = function(cond, expectedType, given, prefix)
	Assert.Assert(
		cond,
		(prefix and tostring(prefix) or "")
			.. ": Expected: ["
			.. expectedType
			.. "] but given: "
			.. serpent.block(given, { maxlevel = 1 })
	)
end

setmetatable(Assert, {
	__call = function(AssertTable, cond, message)
		return AssertTable.Assert(cond, message)
	end,
})

return Assert
