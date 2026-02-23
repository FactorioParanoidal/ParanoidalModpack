local function rgba(h)
    local a, v, s = 1, 1, 0.75
  local r, g, b
  local i = math.floor(h * 6);
  local f = h * 6 - i;
  local p = v * (1 - s);
  local q = v * (1 - f * s);
  local t = v * (1 - (1 - f) * s);
  i = i % 6
  if i == 0 then r, g, b = v, t, p
  elseif i == 1 then r, g, b = q, v, p
  elseif i == 2 then r, g, b = p, v, t
  elseif i == 3 then r, g, b = p, q, v
  elseif i == 4 then r, g, b = t, p, v
  elseif i == 5 then r, g, b = v, p, q
  end
  return { r = r, g = g, b = b, a = a }
end

local function standard_status_colours()
return {
    no_power = {0,0,0,0}, -- transparent
    idle = rgba(7/12),
    no_minable_resources = rgba(7/12),
    disabled = rgba(1),
    full_output = rgba(1/12),
    insufficient_input = rgba(1/12),
    low_power = rgba(1),
    working = rgba(4/12),
}
end

local function standard_status_light()
    return {
        intensity = 0.5,
        size = 3,
        shift = {0,0.75-(6/64)},
    }
  end


-------------------------------------------------------------
local flib = {}
flib.standard_status_light = standard_status_light
flib.standard_status_colours = standard_status_colours
return flib