-- Dihedral group operations for 2D rotations and flips.

local bextract = bit32.extract
local breplace = bit32.replace

local lib = {}

---Packed integer describing an element `r^n * s^m` of a dihedral group.
---The lower 9 bits encode the index of the element in the group in the
---following array:
---`[0, r, r^2, ..., r^(n-1), s, r*s, r^2*s, ..., r^(n-1)*s]`
---The next 8 bits encode the order of the rotation subgroup (half the order
---of the dihedral group).
---@alias Core.Dihedral int32

---Get the index of a dihedral group element from its exploded form.
---@param order int32
---@param r int
---@param s 0|1
local function index(order, r, s) return (s == 0) and r or (order + r) end
lib.index = index

---Given an element index and the order, get the exploded form.
---@param order int32
---@param idx int32
---@return int32 order
---@return int32 r
---@return 0|1 s
local function elt(order, idx)
	if idx < order then
		return order, idx, 0
	else
		return order, idx - order, 1
	end
end
lib.elt = elt

---Bitwise encode a dihedral group element from its exploded form.
---@param order int32
---@param r int
---@param s int
---@return Core.Dihedral
local function encode(order, r, s)
	local x = breplace(0, (s == 0) and r or (order + r), 0, 9) --[[@as int]]
	return breplace(x, order, 9, 8) --[[@as int32]]
end
lib.encode = encode

---Bitwise decode a dihedral group element into its exploded form.
---@param x Core.Dihedral
---@return integer
---@return integer
---@return 0|1
local function decode(x)
	local order = bextract(x, 9, 8)
	local idx = bextract(x, 0, 9)
	if idx < order then
		return order, idx, 0
	else
		return order, idx - order, 1
	end
end
lib.decode = decode

---Check equality of two dihedral group elements in exploded form.
---@param x1 integer
---@param x2 integer
---@param x3 0|1
---@param y1 integer
---@param y2 integer
---@param y3 0|1
local function exploded_eq(x1, x2, x3, y1, y2, y3)
	return x1 == y1 and x2 == y2 and x3 == y3
end
lib.exploded_eq = exploded_eq

---Check equality of two dihedral group elements.
---@param A Core.Dihedral
---@param B Core.Dihedral
---@return boolean
local function eq(A, B) return A == B end
lib.eq = eq

---Invert a dihedral group element in exploded form.
---@param order integer
---@param r integer
---@param s 0|1
---@return integer, integer, 0|1
local function exploded_invert(order, r, s)
	if order == 0 then
		-- Degenerate case of order 0 dihedral group
		return 0, 0, 0
	end

	if s == 0 then
		return order, (order - r) % order, s
	else
		return order, r, s
	end
end
lib.exploded_invert = exploded_invert

---Invert a dihedral group element.
---@param x Core.Dihedral
---@return Core.Dihedral
function lib.invert(x) return encode(exploded_invert(decode(x))) end

---Compose two dihedral group elements in exploded form.
---@param x1 integer
---@param x2 integer
---@param x3 0|1
---@param y1 integer
---@param y2 integer
---@param y3 0|1
---@return integer, integer, 0|1
local function exploded_product(x1, x2, x3, y1, y2, y3)
	if x1 ~= y1 then error("Mismatched dihedral group orders") end
	if x1 == 0 or y1 == 0 then
		-- Degenerate case of order 0 dihedral group
		return 0, 0, 0
	end
	if x3 == 0 and y3 == 0 then
		-- r^a * r^b = r^(a+b)
		return x1, (x2 + y2) % x1, 0
	elseif x3 == 0 and y3 == 1 then
		-- r^a * r^b * s = r^(a+b) * s
		return x1, (x2 + y2) % x1, 1
	elseif x3 == 1 and y3 == 0 then
		-- r^a * s * r^b = r^(a-b) * s
		return x1, (x2 - y2) % x1, 1
	elseif x3 == 1 and y3 == 1 then
		-- r^a * s * r^b * s = r^(a-b)
		return x1, (x2 - y2) % x1, 0
	else
		error("Invalid dihedral group element")
	end
end
lib.exploded_product = exploded_product

---Exponentiate a dihedral group element in exploded form.
---@param order int32
---@param r int32
---@param s 0|1
---@param n int32
---@return int32 order_out
---@return int32 r_out
---@return 0|1 s_out
local function exploded_power(order, r, s, n)
	if order == 0 then
		-- Degenerate case of order 0 dihedral group
		return 0, 0, 0
	end

	-- (r^a)^n = r^(a*n)
	-- (r^a * s)^2 = 1
	-- thus if n is even, (r^a * s)^n = 1
	-- and if n is odd, (r^a * s)^n = r^a * s
	if s == 0 then
		return order, (r * n) % order, 0
	else
		if n % 2 == 0 then
			return order, 0, 0
		else
			return order, r, 1
		end
	end
end
lib.exploded_power = exploded_power

---Compose dihedral group elements.
---@param A Core.Dihedral
---@param ... Core.Dihedral
---@return Core.Dihedral
function lib.product(A, ...)
	local x1, x2, x3 = decode(A)
	for i = 1, select("#", ...) do
		local B = select(i, ...)
		local y1, y2, y3 = decode(B)
		x1, x2, x3 = exploded_product(x1, x2, x3, y1, y2, y3)
	end
	return encode(x1, x2, x3)
end

---Compute a power of a dihedral group element.
---@param x Core.Dihedral
---@param n int32
---@return Core.Dihedral
function lib.power(x, n)
	local order, r, s = decode(x)
	local order_out, r_out, s_out = exploded_power(order, r, s, n)
	return encode(order_out, r_out, s_out)
end

return lib
