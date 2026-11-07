-- Hides Space Age from the settings and data stages of the other mods (Space Age branch, user decision 2026-11-07,
-- variant A1): there mods["space-age"] reads nil, so their own Space Age branches stay off and the build keeps its
-- balance, while the expansion itself (platforms, asteroids, its buildings) works. Factorio's own mods still see it.
-- Called from settings.lua and data.lua: each stage has its own Lua state. The mod has no dependencies, so it loads
-- right after base, before every mod with a dependency; a mod loaded earlier would still see Space Age.
-- Control scripts read script.active_mods, which another mod cannot change: those checks are patched where they are.
-- Returns the Space Age version, or nil when Space Age is off.
local SPACE_AGE = "space-age"

-- Mods that still see Space Age, by internal name.
local visible_to = {
	core = true, base = true, quality = true, recycler = true, ["elevated-rails"] = true, ["space-age"] = true,
	-- Own Space Age content of the branch: the warp sectors, drive and hub (stage 2 of ПР-077).
	["paranoidal-warp"] = true,
}

return function(stage)
	local version = rawget(mods, SPACE_AGE)
	if version == nil then return nil end -- Space Age off, or already hidden in this Lua state
	if getmetatable(mods) ~= nil then
		log("paranoidal-space-age-filter: the mods table already has a metatable, Space Age stays visible")
		return nil
	end
	local reported = {}
	rawset(mods, SPACE_AGE, nil)
	setmetatable(mods, {
		__index = function(_, key)
			-- Any mod asking for an absent mod tells space-age-platforms.lua that it runs (data stage only).
			local platforms = type(data) == "table" and rawget(data, "paranoidal_space_age_filter")
			if platforms then platforms.check() end
			if key ~= SPACE_AGE then return nil end
			-- Level 2 is the code that read the table; its chunk is "@__<mod>__/<file>".
			local info = debug.getinfo(2, "Sl")
			local owner = info and type(info.source) == "string" and info.source:match("^@?__(.-)__/") or nil
			if owner and visible_to[owner] then return version end
			local who = owner or "?"
			if not reported[who] then
				reported[who] = true
				log("paranoidal-space-age-filter: Space Age hidden from " .. who .. " (" .. tostring(info and info.short_src)
					.. ":" .. tostring(info and info.currentline) .. ")")
			end
			return nil
		end,
	})
	log("paranoidal-space-age-filter: " .. stage .. " stage: Space Age " .. version .. " hidden from the other mods")
	return version
end
