local function dbg(str)
	if not global.dbg then global.dbg = 1 end
		if type(str) ~= "number" and type(str) ~= "string" then
		if str == true then
			str = "true"
		elseif str == false then
			str = "false"
		elseif type(str) == "table" then
			str = serpent.line(str)
		else
			str = type(str)
		end
	end
	game.players[1].print(global.dbg.."/"..game.tick..": "..str)
	global.dbg = global.dbg + 1
end

local function msg(s)
	game.print(s)
	--for _, player in pairs(game.players) do
	--	if player.connected then
	--		player.print(s)
	--	end
	--end
end

-- function logging(message)
	-- game.write_file("RealisticReactors.log","\r\n[" .. game.tick .. "] " .. message,true)
-- end


local function union_tables(t1, t2)
	for i,v in ipairs(t2) do
		table.insert(t1, v)
	end
	return t1
end

local function tablemax(tbl)
	local ret = 1 --actually 0 or nil, but for this usecase i need at least 1
	for _, val in pairs(tbl) do
		if val > ret then
			ret = val
		end
	end
	return ret
end



local function isempty(t) return not next(t) end


local function noop() end


return { -- exports
	dbg=dbg, msg=msg,
	union_tables = union_tables,
	tablemax = tablemax,
	isempty = isempty,
	noop = noop,
}
