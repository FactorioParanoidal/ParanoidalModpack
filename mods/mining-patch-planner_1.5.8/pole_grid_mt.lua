---@class PowerPoleGrid
local pole_grid_mt = {}
pole_grid_mt.__index = pole_grid_mt

---@class GridPole
---@field x number Position in the full grid
---@field y number Position in the full grid
---@field ix number Position in the pole grid
---@field iy number Position in the pole grid
---@field built boolean Is the pole really built
---@field entity LuaEntity Pole ghost LuaEntity

---@param x number
---@param y number
---@param p GridPole
function pole_grid_mt:set_pole(x, y, p)
	if not self[x] then self[x] = {} end
	self[x][y] = p
end

---@param x number
---@param y number
---@return GridPole | nil
function pole_grid_mt:get_pole(x, y)
	if self[x] then return self[x][y] end
end

return pole_grid_mt
