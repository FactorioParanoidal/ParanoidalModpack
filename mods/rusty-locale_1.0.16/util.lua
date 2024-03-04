local _M = {}


function _M.resolver(resolvers)
--- Make an empty table that calls a function from `resolvers` with the same name to resolve non-existent keys.
	return setmetatable({}, {
		__index = function(self, key)
			local f = resolvers[key]
			if f then
				self[key] = f(self)
				return self[key]
			end
			return nil
		end,
	})
end


return _M
