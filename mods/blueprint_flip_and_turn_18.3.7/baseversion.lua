return function()
	local v = mods and mods.base
	local M,m,p,_ = v:match("^([0-9]+)%.([0-9]+)%.([0-9]+)(.*)$")
	-- 0.17.54
	-- => "0.17", "0", "17", "54", ""
	return M.."."..m, M, m, p, _
end
