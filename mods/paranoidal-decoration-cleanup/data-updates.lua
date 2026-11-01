-- Floor tiles (from Clean Floor): every tile that removes decorations at all removes all of them.
-- Base and AAI stone path, concrete and refined concrete (0.15-0.25) are covered here too.
for _, tile in pairs(data.raw.tile or {}) do
	if (tile.decorative_removal_probability or 0) > 0 then
		tile.decorative_removal_probability = 1
	end
end

-- Map generation (from UnPollock): fewer decoratives and no decorative rocks.
local rate = settings.startup["unpollock-decorative-rate"].value
local rocks = settings.startup["unpollock-fake-rocks"].value
if rocks == "keep" then rocks = nil end
if not rocks and rate >= 1 then return end

-- True when `word` occurs in `s` and is not part of a longer alphanumeric token.
local function has_word(s, word)
	local init = 1
	while true do
		local i, j = s:find(word, init, true)
		if not i then return false end
		if not s:sub(i - 1, i - 1):find("%w") and not s:sub(j + 1, j + 1):find("%w") then return true end
		init = i + 1
	end
end

local function has_any(s, names)
	if type(s) ~= "string" then return false end
	for name in pairs(names) do
		if has_word(s, name) then return true end
	end
	return false
end

-- Does a noise expression, noise function or autoplace refer to one of `names`?
local function uses(e, names)
	if type(e) ~= "table" then return has_any(e, names) end
	if has_any(e.expression or e.probability_expression, names) then return true end
	for _, s in pairs(e.local_expressions or {}) do
		if has_any(s, names) then return true end
	end
	for _, f in pairs(e.local_functions or {}) do
		if has_any(f.expression, names) then return true end
	end
	return false
end

-- "by-control": the "rocks" planet control and every noise function/expression built on it.
local rock_names = {["control:rocks"] = true}
if rocks == "by-control" then
	local changed = true
	while changed do
		changed = false
		for _, kind in pairs({"noise-function", "noise-expression"}) do
			for name, def in pairs(data.raw[kind] or {}) do
				if not rock_names[name] and uses(def, rock_names) then
					rock_names[name] = true
					changed = true
				end
			end
		end
	end
end

local function is_rock(decorative, autoplace)
	if rocks == "by-control" then
		return autoplace.control == "rocks" or uses(autoplace, rock_names)
	elseif rocks == "by-order" then
		return (decorative.order or ""):find("[rock]", 1, true) ~= nil
			or (autoplace.order or ""):find("[rock]", 1, true) ~= nil
	elseif rocks == "by-name" then
		for word in decorative.name:gmatch("%w*rock%w*") do
			if word == "rock" or word == "rocks" then return true end
		end
	end
	return false
end

for _, decorative in pairs(data.raw["optimized-decorative"] or {}) do
	local autoplace = decorative.autoplace
	if autoplace and autoplace.probability_expression ~= nil then
		if rate <= 0 or (rocks and is_rock(decorative, autoplace)) then
			autoplace.probability_expression = "0"
		elseif rate < 1 then
			autoplace.probability_expression = "(" .. autoplace.probability_expression .. ")*" .. rate
		end
	end
end
