-- debug rendering library
local table_insert = table.insert

---@class DebugRendering
---@field _state State
---@field _enabled boolean Does drawing do anything
---@field _register boolean Add to render objects to be removed
local drawing_meta = {}
drawing_meta.__index = drawing_meta

function drawing_meta:draw_circle(t)
	if not self._enabled then return end
	local state = self._state --[[@as State]]

	local C = state.coords
	local x, y
	if t.integer then
		x, y = C.ix1, C.iy1
	else
		x, y = C.gx, C.gy
	end
	local tx, ty = t.x, t.y

	t.surface	= state.surface
	t.players	= {state.player}
	t.width		= t.width or 3
	t.color		= t.color or {1, 1, 1}
	t.radius	= t.radius or 0.5
	t.target	= { x + tx, y + ty }
	local id = rendering.draw_circle(t)
	if self._register then
		table_insert(state._render_objects, id)
	end
end

function drawing_meta:draw_line(t)
	if not self._enabled then return end
	local state = self._state --[[@as State]]

	local C = state.coords
	local x, y
	if t.integer then
		x, y = C.ix1, C.iy1
	else
		x, y = C.gx, C.gy
	end

	local tx, ty = t.x or t.x1, t.y or t.y1
	local target1 = {x + tx, y + ty}
	local target2
	if t.x2 and t.y2 then
		target2 = {x + t.x2, y + t.y2}
	elseif t.w and t.h then
		target2 = {x + tx + (t.w or 0), y + ty + (t.h or 0)}
	else
		return
	end

	t.surface	= state.surface
	t.players	= {state.player}
	t.width		= t.width 			or 3
	t.color		= t.color 			or {1, 1, 1}
	t.from		= t.from			or target1
	t.to		= t.to				or target2
	local id = rendering.draw_line(t)
	if self._register then
		table_insert(state._render_objects, id)
	end
end

function drawing_meta:draw_rectangle(t)
	if not self._enabled then return end

	local state = self._state --[[@as State]]

	local C = state.coords
	local x, y
	if t.integer then
		x, y = C.ix1, C.iy1
	else
		x, y = C.gx, C.gy
	end

	local tx, ty = t.x or t.x1, t.y or t.y1
	local target1 = {x + tx, y + ty}
	local target2
	if t.x2 and t.y2 then
		target2 = {x + t.x2, y + t.y2}
	elseif t.w and t.h then
		target2 = {x + tx + (t.w or 0), y + ty + (t.h or 0)}
	else
		return
	end

	t.surface		= state.surface
	t.players		= {state.player}
	t.width			= t.width 			or 3
	t.color			= t.color 			or {1, 1, 1}
	t.left_top		= t.left_top		or target1
	t.right_bottom	= t.right_bottom	or target2
	local id = rendering.draw_rectangle(t)
	if self._register then
		table_insert(state._render_objects, id)
	end
end

function drawing_meta:draw_text(t)
	if not self._enabled then return end

	local state = self._state --[[@as State]]

	local C = state.coords
	local x, y
	if t.integer then
		x, y = C.ix1, C.iy1
	else
		x, y = C.gx, C.gy
	end
	local tx, ty = t.x, t.y

	t.surface		= state.surface
	t.players		= {state.player}
	t.width			= t.width 			or 3
	t.color			= t.color 			or {1, 1, 1}
	t.target		= { x + tx, y + ty }
	t.scale			= t.scale 			or 1
	t.alignment 	= t.alignment		or "center"
	t.vertical_alignment = t.vertical_alignment or "middle"

	local id = rendering.draw_text(t)
	if self._register then
		table_insert(state._render_objects, id)
	end
end

---comment
---@param state State 
---@param enabled boolean Enable drawing
local function drawing(state, enabled, register)
	return setmetatable({_state=state, _enabled=(not not enabled), _register=(not not register)}, drawing_meta)
end

return drawing
