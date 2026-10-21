-- Geometry shared by the repair and the shield side: chunk keys and the rectangles of the ring
-- between two squares around one centre (a range change touches only that ring).
local A = {}

local CHUNK = 32
local OFF, SPAN = 131072, 262144 -- chunk coordinates within +-2^17 (+-4 M tiles), surface indices below 2^17
local floor = math.floor

A.CHUNK = CHUNK

-- One number per surface chunk (exact in a double: 17 + 18 + 18 bits).
function A.key(surface_index, cx, cy)
	return (surface_index * SPAN + cx + OFF) * SPAN + cy + OFF
end

function A.chunk_key(surface_index, x, y)
	return (surface_index * SPAN + floor(x / CHUNK) + OFF) * SPAN + floor(y / CHUNK) + OFF
end

-- Rectangles {{x1, y1}, {x2, y2}} that cover the ring between the squares +-r_in and +-r_out around
-- (x, y); r_in < 0: the whole square +-r_out. Every entity whose centre lies in the ring (or whose box
-- reaches into it) intersects one of them.
function A.ring(x, y, r_in, r_out)
	if r_in < 0 then
		return {{{x - r_out, y - r_out}, {x + r_out, y + r_out}}}
	end
	return {
		{{x - r_out, y - r_out}, {x + r_out, y - r_in}},
		{{x - r_out, y + r_in}, {x + r_out, y + r_out}},
		{{x - r_out, y - r_in}, {x - r_in, y + r_in}},
		{{x + r_in, y - r_in}, {x + r_out, y + r_in}},
	}
end

return A
