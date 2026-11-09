---@diagnostic disable: different-requires

local type = type
local tostring = tostring
local SERPENT_ARGS = { maxlevel = 5, maxnum = 20, nocode = true }
local serpent_line = serpent.line
local tlib = require("lib.core.table")
local EMPTY = tlib.EMPTY
local relm = require("lib.core.relm.relm")
local ultros = require("lib.core.relm.ultros")

local Pr = relm.Primitive

local lib = {}

local function stringify(val)
	local val_t = type(val)
	if
		val_t == "nil"
		or val_t == "number"
		or val_t == "string"
		or val_t == "boolean"
	then
		return tostring(val)
	elseif val_t == "function" then
		return "(function)"
	else
		return serpent_line(val, SERPENT_ARGS)
	end
end
lib.stringify = stringify

---@param k LocalisedString
---@param v any
local function default_renderer(k, v)
	return ultros.BoldLabel(k), ultros.RtMultilineLabel(stringify(v))
end
lib.default_renderer = default_renderer

---@alias Core.RelmTableRendererer fun(key: string|number, value: any, primitive_style: table, whole_table: table): Relm.Children

---@param n_cols int Number of columns in the table. If 1, a vertical flow is used instead.
---@param tbl table Table to render.
---@param renderers {[string|number]: Core.RelmTableRendererer}? Optional renderers for specific keys.
---@param default Core.RelmTableRendererer? Default renderer if no specific renderer is found. If `nil`, entries without renderers are ignored.
---@param primdef table? Additional primitive definition fields to apply to the table or flow.
---@param renderer_driven? boolean If true, iterate the renderers rather than the table. This preserves rendering order but misses keys with no corresponding renderer.
---@return Relm.Children
function lib.render_table(
	n_cols,
	tbl,
	renderers,
	default,
	primdef,
	renderer_driven
)
	renderers = renderers or EMPTY
	if primdef then
		primdef = tlib.assign({}, primdef)
	else
		primdef = { horizontally_stretchable = true }
	end
	---@cast primdef table

	local children = {}
	if renderer_driven then
		for k, renderer in pairs(renderers or EMPTY) do
			local v = tbl[k]
			if v ~= nil then
				tlib.append(children, renderer(k, tbl[v], primdef, tbl))
			end
		end
	else
		for k, v in pairs(tbl) do
			local renderer = renderers[k]
			if (renderer == nil) and default then renderer = default end
			if renderer then tlib.append(children, renderer(k, v, primdef, tbl)) end
		end
	end

	if n_cols == 1 then
		primdef.type = "flow"
		primdef.direction = "vertical"
		return Pr(primdef, children)
	else
		primdef.type = "table"
		primdef.column_count = n_cols
		return Pr(primdef, children)
	end
end

return lib
