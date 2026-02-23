
---@class Changelog
local changelog = {}

local function getCallerModName(skip_frames)
	local src = debug.getinfo(2+skip_frames, "S").source -- z.B. "@__mymod__/control.lua"
	local mod = src:match("__([^_/]+)__")
	return mod
end

local function flatten(t)
	local tout = {}
	local function _flatten(tin)
		for _, v in ipairs(tin) do
			if type(v) == "table" then _flatten(v)
			else tout[#tout+1] = v end
		end
		return t
	end

	for i, v in ipairs(t) do
		if type(v) == "table" then _flatten(v) else tout[#tout+1] = v end
	end
	return tout
end

local function snapshot_core(root_keys, mod_name)
	root_keys = flatten(root_keys)
	mod_name = mod_name or ""
	data.changes = data.changes or {}

	for _, root_key in ipairs(root_keys) do
		if not data.raw[root_key] then error("Root '"..root_key.."' not found in data.raw") end
		data.changes[root_key] = data.changes[root_key] or {}
		if root_key =="gui-style" then
			data.changes[root_key]["default"] = data.changes[root_key]["default"] or {}
			for key, _ in pairs(data.raw["gui-style"]["default"]) do
				data.changes["gui-style"]["default"][key] = data.changes["gui-style"]["default"][key] or mod_name
			end
		else
			for key, _ in pairs(data.raw[root_key]) do
				data.changes[root_key][key] = data.changes[root_key][key] or mod_name
			end
		end
	end
end

---Creates a snapshot for the specified keys
---<p>Usage: <br>
---<code> changelog.start_snapshot({"foo"})</code> at the beginning of data.lua <br>
function changelog.start_snapshot(...)
	local args = {...}
	snapshot_core(args)
end

---Creates a snapshot for the specified keys
---<p>Usage: <br>
---<code> changelog.final_snapshot({"foo"}, mod_name)</code> at the end of data.lua <br>
function changelog.final_snapshot(...)
	local args = {...}
	snapshot_core(args, getCallerModName(1))
end


function changelog.log()
	local lines = {}
	local mod_name = getCallerModName(1)
	for k0, d0 in pairs(data.changes) do
		lines[#lines+1]="  ["..k0.."]"
		for k1, d1 in pairs(d0) do
			if type(d1)=="table" then
				lines[#lines+1]="  ["..k0.."]["..k1.."]"
				for k2, d2 in pairs(d1) do
					if d2==mod_name then
						lines[#lines+1]="    "..k2
					 end
				end
			else
				if d1==mod_name then
					lines[#lines+1]="    "..k1
				end
			end
		end
	end
	log("\n┌──[ data changelog of "..mod_name.." ]──────────────┐\n".. table.concat(lines, "\n").."\n└─── end of data changelog of "..mod_name.." ───┘")
end

return changelog