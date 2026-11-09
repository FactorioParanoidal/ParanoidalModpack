local class = require("lib.core.class").class
local pos = require("lib.core.math.pos")

local lib = {}

---Destroy a collection of render objects.
---@param ros? LuaRenderObject[]
local function destroy_render_objects(ros)
	if not ros then return end
	for _, ro in pairs(ros) do
		ro.destroy()
	end
end
lib.destroy_render_objects = destroy_render_objects

---@class Core.MultiLineTextOverlay
---@field public backdrop LuaRenderObject
---@field public text_lines LuaRenderObject[]
---@field public width number
---@field public line_height number
local MultiLineTextOverlay = class("Core.MultiLineTextOverlay")
lib.MultiLineTextOverlay = MultiLineTextOverlay

---@param surface LuaSurface
---@param target ScriptRenderTargetTable Render target for top left of overlay.
function MultiLineTextOverlay:new(surface, target, width, line_height)
	return setmetatable({
		backdrop = rendering.draw_rectangle({
			left_top = target,
			right_bottom = target,
			filled = true,
			surface = surface,
			color = { r = 0, g = 0, b = 0, a = 0.75 },
			visible = false,
		}),
		text_lines = {},
		width = width,
		line_height = line_height,
	}, self)
end

---Destroy the overlay.
function MultiLineTextOverlay:destroy()
	if self.backdrop and self.backdrop.valid then self.backdrop.destroy() end
	for _, line in pairs(self.text_lines) do
		if line and line.valid then line.destroy() end
	end
end

---@param target ScriptRenderTargetTable
---@param dx number
---@param dy number
local function offset(target, dx, dy)
	local base_offset_x, base_offset_y = 0.0, 0.0
	if target.offset then
		---@diagnostic disable-next-line: assign-type-mismatch
		base_offset_x, base_offset_y =
			pos.pos_get(target.offset --[[@as MapPosition]])
	end
	if target.entity then
		return {
			entity = target.entity,
			---@diagnostic disable-next-line: need-check-nil
			offset = { base_offset_x + dx, base_offset_y + dy },
		}
	else
		local x0, y0 = pos.pos_get(target.position --[[@as MapPosition]])
		return {
			---@diagnostic disable-next-line: need-check-nil
			position = { x0 + dx, y0 + dy },
		}
	end
end

---@param lines LocalisedString[]
function MultiLineTextOverlay:set_text(lines)
	if (not lines) or (#lines == 0) then
		self.backdrop.visible = false
		for _, line in pairs(self.text_lines) do
			line.visible = false
		end
		return
	end
	local base_target = self.backdrop.left_top --[[@as ScriptRenderTargetTable]]
	self.backdrop.visible = true
	self.backdrop.right_bottom =
		offset(base_target, self.width, #lines * self.line_height)
	for i = 1, #lines do
		local line_ro = self.text_lines[i]
		if not line_ro then
			line_ro = rendering.draw_text({
				text = "",
				surface = self.backdrop.surface,
				target = offset(base_target, 0, (i - 1) * self.line_height),
				color = { r = 1, g = 1, b = 1 },
				use_rich_text = true,
				alignment = "left",
			})
			line_ro.bring_to_front()
			self.text_lines[i] = line_ro
		end
		line_ro.text = lines[i]
		line_ro.visible = true
	end
	for i = #lines + 1, #self.text_lines do
		self.text_lines[i].visible = false
	end
end

return lib
