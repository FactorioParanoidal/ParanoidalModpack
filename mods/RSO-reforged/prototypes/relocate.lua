--[[ Value of a named noise expression at another point.

The map generator evaluates every expression at the current tile. RSO needs some properties at
the centre of a field (the soil geology that picks its resource, the elevation that keeps it out
of a lake). relocate.at(name, px, py) returns the text of an expression that computes the named
noise expression `name` at (px, py): the expression and every named expression and function it
depends on that reads the position are cloned into noise functions of (x, y), so that the built-in
x and y inside them become parameters. The values are those of the original expression on any
map (the clone is made from the final data), unless MapGenSettings.property_expression_names of
a surface replaces a part of it (e.g. another map type of the elevation).

Expressions that cannot be moved (multisample, entity/tile/decorative probabilities, a function
with own x/y parameters that also reads the position) give nil.
]]
local M = {}

local fmt = string.format
local defs, clones, deps = {}, {}, {}

-- tokens of a noise expression: {kind = "id"|"num"|"str"|"op"|"ws", text}
local function tokens(text)
	local list, i, n = {}, 1, #text
	while i <= n do
		local s, e = text:find("^%s+", i)
		local kind = "ws"
		if not s then s, e = text:find("^[%a_][%w_:]*", i); kind = "id" end
		if not s then s, e = text:find("^0x%x+", i); kind = "num" end
		if not s then
			s, e = text:find("^%d+%.?%d*", i)
			if not s then s, e = text:find("^%.%d+", i) end
			if s then
				local s2, e2 = text:find("^[eE]%-?%d+", e + 1)
				if s2 then e = e2 end
				kind = "num"
			end
		end
		if not s then s, e = text:find("^'[^']*'", i); kind = "str" end
		if not s then s, e = text:find('^"[^"]*"', i); kind = "str" end
		if not s then
			s, e = text:find("^[=~!<>%%]=", i)
			if not s then s, e = text:find("^%%%%", i) end
			if not s then s, e = i, i end
			kind = "op"
		end
		list[#list + 1] = {kind = kind, text = text:sub(s, e)}
		i = e + 1
	end
	return list
end

local function next_token(list, i)
	for j = i + 1, #list do
		if list[j].kind ~= "ws" then return list[j], j end
	end
end

local function sanitize(name)
	return (name:gsub("[^%w_]", "_"))
end

local function texts(prototype)
	-- every text of a prototype with the names its scope adds: {text, shadowed names}
	local scope = {}
	for _, p in ipairs(prototype.parameters or {}) do scope[p] = true end
	for k in pairs(prototype.local_expressions or {}) do scope[k] = true end
	for k in pairs(prototype.local_functions or {}) do scope[k] = true end
	local out = {{tostring(prototype.expression), scope}}
	for _, v in pairs(prototype.local_expressions or {}) do out[#out + 1] = {tostring(v), scope} end
	for _, f in pairs(prototype.local_functions or {}) do
		local inner = setmetatable({}, {__index = scope})
		for _, p in ipairs(f.parameters or {}) do inner[p] = true end
		out[#out + 1] = {tostring(f.expression), inner}
		for _, v in pairs(f.local_expressions or {}) do out[#out + 1] = {tostring(v), inner} end
	end
	return out
end

local depends_e, depends_f

-- does a text read the position (directly or through named expressions/functions)? nil: cannot move
local function text_depends(text, scope)
	local list = tokens(text)
	local result = false
	for i, t in ipairs(list) do
		if t.kind == "id" and not scope[t.text] then
			local after = next_token(list, i)
			local a = after and after.text
			if a == "(" or a == "{" then
				if t.text == "multisample" then return nil end
				if t.text == "var" then
					local arg = next_token(list, select(2, next_token(list, i)))
					if arg and arg.kind == "str" then
						local name = arg.text:sub(2, -2)
						if data.raw["noise-expression"][name] then
							local d = depends_e(name)
							if d == nil then return nil end
							result = result or d
						elseif name:find("^entity:") or name:find("^tile:") or name:find("^decorative:") then
							return nil
						end
					end
				elseif data.raw["noise-function"][t.text] then
					local d = depends_f(t.text)
					if d == nil then return nil end
					result = result or d
				end
			elseif a ~= "=" then -- not a named argument
				if t.text == "x" or t.text == "y" then
					result = true
				elseif data.raw["noise-expression"][t.text] then
					local d = depends_e(t.text)
					if d == nil then return nil end
					result = result or d
				elseif t.text:find("^entity:") or t.text:find("^tile:") or t.text:find("^decorative:") then
					return nil
				end
			end
		end
	end
	return result
end

local function prototype_depends(prototype)
	local result = false
	for _, entry in ipairs(texts(prototype)) do
		local d = text_depends(entry[1], entry[2])
		if d == nil then return nil end
		result = result or d
	end
	return result
end

function depends_e(name)
	local key = "e:" .. name
	if deps[key] == nil then
		deps[key] = "busy" -- noise expressions are not recursive; this only guards the walk
		local d = prototype_depends(data.raw["noise-expression"][name])
		deps[key] = d == nil and "no" or d
	end
	local d = deps[key]
	if d == "no" then return nil end
	return d == true
end

function depends_f(name)
	local key = "f:" .. name
	if deps[key] == nil then
		deps[key] = "busy"
		local f = data.raw["noise-function"][name]
		local d = prototype_depends(f)
		for _, p in ipairs(f.parameters or {}) do
			if d and (p == "x" or p == "y") then d = nil end -- x/y taken by parameters
		end
		deps[key] = d == nil and "no" or d
	end
	local d = deps[key]
	if d == "no" then return nil end
	return d == true
end

local clone_e, clone_f

-- the text with every moved reference rewritten; x and y are left as they are (in the clone they
-- are its parameters)
local function rewrite(text, scope)
	local list = tokens(text)
	local out, append = {}, {}
	local depth, pending = 0, {}
	local i = 1
	while i <= #list do
		local t = list[i]
		local done = false
		if t.kind == "id" and not scope[t.text] then
			local after, j = next_token(list, i)
			local a = after and after.text
			if (a == "(" or a == "{") and t.text == "var" then
				local arg, k = next_token(list, j)
				local close, l = next_token(list, k)
				local name = arg and arg.kind == "str" and arg.text:sub(2, -2)
				if name and data.raw["noise-expression"][name] and depends_e(name) and close and close.text == ")" then
					out[#out + 1] = clone_e(name) .. "(x, y)"
					i = l + 1
					done = true
				end
			elseif (a == "(" or a == "{") and data.raw["noise-function"][t.text] and depends_f(t.text) then
				out[#out + 1] = clone_f(t.text)
				pending[depth + 1] = a -- append the position before the matching bracket
				done = true
				i = i + 1
			elseif a ~= "(" and a ~= "{" and a ~= "=" and data.raw["noise-expression"][t.text] and depends_e(t.text) then
				out[#out + 1] = clone_e(t.text) .. "(x, y)"
				done = true
				i = i + 1
			end
		end
		if not done then
			if t.kind == "op" and (t.text == "(" or t.text == "{") then
				depth = depth + 1
				append[depth] = pending[depth]
				pending[depth] = nil
				out[#out + 1] = t.text
				local nxt = next_token(list, i)
				append[-depth] = nxt and (nxt.text == ")" or nxt.text == "}") -- empty argument list
			elseif t.kind == "op" and (t.text == ")" or t.text == "}") then
				local kind = append[depth]
				if kind then
					local sep = append[-depth] and "" or ", "
					out[#out + 1] = kind == "(" and sep .. "x, y" or sep .. "x = x, y = y"
				end
				append[depth], append[-depth] = nil, nil
				depth = depth - 1
				out[#out + 1] = t.text
			else
				out[#out + 1] = t.text
			end
			i = i + 1
		end
	end
	return table.concat(out)
end

local function clone_prototype(prototype, name, parameters)
	local scope = {}
	for _, p in ipairs(parameters) do scope[p] = true end
	for k in pairs(prototype.local_expressions or {}) do scope[k] = true end
	for k in pairs(prototype.local_functions or {}) do scope[k] = true end
	local copy = {type = "noise-function", name = name, parameters = parameters,
		expression = rewrite(tostring(prototype.expression), scope)}
	if prototype.local_expressions then
		copy.local_expressions = {}
		for k, v in pairs(prototype.local_expressions) do copy.local_expressions[k] = rewrite(tostring(v), scope) end
	end
	if prototype.local_functions then
		copy.local_functions = {}
		for k, f in pairs(prototype.local_functions) do
			local inner = setmetatable({}, {__index = scope})
			for _, p in ipairs(f.parameters or {}) do inner[p] = true end
			local g = {parameters = f.parameters, expression = rewrite(tostring(f.expression), inner)}
			if f.local_expressions then
				g.local_expressions = {}
				for kk, v in pairs(f.local_expressions) do g.local_expressions[kk] = rewrite(tostring(v), inner) end
			end
			copy.local_functions[k] = g
		end
	end
	return copy
end

function clone_e(name)
	local key = "e:" .. name
	if not clones[key] then
		local clone = "rso_at_" .. sanitize(name)
		clones[key] = clone
		-- the clone first: cloning it appends the clones it needs
		local prototype = clone_prototype(data.raw["noise-expression"][name], clone, {"x", "y"})
		defs[#defs + 1] = prototype
	end
	return clones[key]
end

function clone_f(name)
	local key = "f:" .. name
	if not clones[key] then
		local clone = "rso_atf_" .. sanitize(name)
		clones[key] = clone
		local f = data.raw["noise-function"][name]
		local parameters = {}
		for k, p in ipairs(f.parameters or {}) do parameters[k] = p end
		parameters[#parameters + 1] = "x"
		parameters[#parameters + 1] = "y"
		local prototype = clone_prototype(f, clone, parameters)
		defs[#defs + 1] = prototype
	end
	return clones[key]
end

-- expression text of the named expression `name` at (px, py), or nil
function M.at(name, px, py)
	if not data.raw["noise-expression"][name] then return nil end
	local d = depends_e(name)
	if d == nil then
		log("RSO: noise expression " .. name .. " cannot be evaluated at another point")
		return nil
	end
	if not d then return fmt("(%s)", name) end -- the same everywhere
	return fmt("%s(%s, %s)", clone_e(name), px, py)
end

-- prototypes of the clones made so far (to data:extend once, after all at() calls)
function M.prototypes()
	return defs
end

return M
