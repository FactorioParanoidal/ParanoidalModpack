local sin, cos, pi = math.sin, math.cos, math.pi
local min, max = math.min, math.max
local function clamp(x, a, b)
	return max(min(x, b or 1), a or 0)
end

local color = {}

-- OKLAB, OKHSV conversion functions yoinked from Björn Ottosson
-- https://bottosson.github.io/posts/colorpicker/

function color.oklab_to_linear_srgb(L, a, b)

	local l_ = L + 0.3963377774 * a + 0.2158037573 * b;
	local m_ = L - 0.1055613458 * a - 0.0638541728 * b;
	local s_ = L - 0.0894841775 * a - 1.2914855480 * b;

	local l = l_*l_*l_;
	local m = m_*m_*m_;
	local s = s_*s_*s_;

	return
		 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
		-1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
		-0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s
end

-- Finds the maximum saturation possible for a given hue that fits in sRGB
-- Saturation here is defined as S = C/L
-- a and b must be normalized so a^2 + b^2 == 1
local function compute_max_saturation(a, b)
	-- Max saturation will be when one of r, g or b goes below zero.

	-- Select different coefficients depending on which component goes below zero first
	local k0, k1, k2, k3, k4, wl, wm, ws;

	if -1.88170328 * a - 0.80936493 * b > 1 then
		-- Red component
		k0 = 1.19086277; k1 = 1.76576728; k2 = 0.59662641; k3 = 0.75515197; k4 = 0.56771245;
		wl = 4.0767416621; wm = -3.3077115913; ws = 0.2309699292;
	elseif 1.81444104 * a - 1.19445276 * b > 1 then
		-- Green component
		k0 = 0.73956515; k1 = -0.45954404; k2 = 0.08285427; k3 = 0.12541070; k4 = 0.14503204;
		wl = -1.2684380046; wm = 2.6097574011; ws = -0.3413193965;
	else
		-- Blue component
		k0 = 1.35733652; k1 = -0.00915799; k2 = -1.15130210; k3 = -0.50559606; k4 = 0.00692167;
		wl = -0.0041960863; wm = -0.7034186147; ws = 1.7076147010;
	end

	-- Approximate max saturation using a polynomial:
	local S = k0 + k1 * a + k2 * b + k3 * a * a + k4 * a * b;

	-- Do one step Halley's method to get closer
	-- this gives an error less than 10e6, except for some blue hues where the dS/dh is close to infinite
	-- this should be sufficient for most applications, otherwise do two/three steps 

	local k_l =  0.3963377774 * a + 0.2158037573 * b;
	local k_m = -0.1055613458 * a - 0.0638541728 * b;
	local k_s = -0.0894841775 * a - 1.2914855480 * b;

	do
		local l_ = 1 + S * k_l;
		local m_ = 1 + S * k_m;
		local s_ = 1 + S * k_s;

		local l = l_ * l_ * l_;
		local m = m_ * m_ * m_;
		local s = s_ * s_ * s_;

		local l_dS = 3 * k_l * l_ * l_;
		local m_dS = 3 * k_m * m_ * m_;
		local s_dS = 3 * k_s * s_ * s_;

		local l_dS2 = 6 * k_l * k_l * l_;
		local m_dS2 = 6 * k_m * k_m * m_;
		local s_dS2 = 6 * k_s * k_s * s_;

		local f  = wl * l     + wm * m     + ws * s;
		local f1 = wl * l_dS  + wm * m_dS  + ws * s_dS;
		local f2 = wl * l_dS2 + wm * m_dS2 + ws * s_dS2;

		S = S - f * f1 / (f1*f1 - 0.5 * f * f2);
	end

	return S
end

local function find_cusp(a, b)
	-- First, find the maximum saturation (saturation S = C/L)
	local S_cusp = compute_max_saturation(a, b);

	-- Convert to linear sRGB to find the first point where at least one of r,g or b >= 1:
	local rgb_at_max = {color.oklab_to_linear_srgb(1, S_cusp * a, S_cusp * b)}
	local L_cusp = (1 / max(max(rgb_at_max[1], rgb_at_max[2]), rgb_at_max[3])) ^ (1/3)
	local C_cusp = L_cusp * S_cusp;

	return L_cusp , C_cusp
end

local function get_ST_max(a_, b_, cusp)
	if not cusp then
		cusp = {find_cusp(a_, b_)}
	end
	local L = cusp[1];
	local C = cusp[2];
	return C/L, C/(1-L)
end

local function toe_inv(x)
	local k_1 = 0.206
	local k_2 = 0.03
	local k_3 = (1+k_1)/(1+k_2)
	return (x*x + k_1*x)/(k_3*(x+k_2))
end

local function srgb_transfer_function(value)
	-- if value <= 0.04045 then
	-- 	return value / 12.92
	-- end
	-- return ((value + 0.055) / 1.055) ^ 2.4;
	return .0031308 >= value and (12.92 * value) or (1.055 * math.pow(value, .4166666666666667) - .055)
end

function color.linear_srgb_to_rgb(sr, sg, sb)
	return
		srgb_transfer_function(sr),
		srgb_transfer_function(sg),
		srgb_transfer_function(sb)
end

function color.okhsv_to_srgb(h, s, v)
	local a_ = cos(2*pi*h)
	local b_ = sin(2*pi*h)

	local ST_max = {get_ST_max(a_,b_)};
	local S_max = ST_max[1];
	local S_0 = 0.5;
	local T  = ST_max[2]
	local k = 1 - S_0/S_max;

	local L_v = 1 - s*S_0/(S_0+T - T*k*s)
	local C_v = s*T*S_0/(S_0+T-T*k*s)

	local L = v*L_v;
	local C = v*C_v;

	local L_vt = toe_inv(L_v);
	local C_vt = C_v * L_vt/L_v;

	local L_new =  toe_inv(L); -- * L_v/L_vt;
	C = C * L_new/L;
	L = L_new;

	local rgb_scale = {color.oklab_to_linear_srgb(L_vt,a_*C_vt,b_*C_vt)};
	local scale_L = (1/(max(rgb_scale[1],rgb_scale[2],rgb_scale[3],0))) ^ (1/3)

	L = L * scale_L;
	C = C * scale_L;

	--local rgb = color.oklab_to_linear_srgb(L, C*a_, C*b_);
	-- apply srgb transfer function

	return color.oklab_to_linear_srgb(L, C*a_, C*b_)
end



function color.hue_sequence(n)
	local r,g,b = color.okhsv_to_srgb((n * math.phi) % 1, 1, 1)
	return {clamp(r), clamp(g), clamp(b)}
	--return {r, g, b}
end


return color
