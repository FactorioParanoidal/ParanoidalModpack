-- 2.0 port: trimmed to the helpers this mod actually uses
-- (the 1.1 original bundled a large generic library, most of it unused here
-- and referencing 1.1-only prototypes like data.raw.player)
local util = require("util")

util.path = function(str)
  return "__MIRV2__/" .. str
end

util.empty_sprite = function()
  return
  {
    filename = util.path("tf_util/empty-sprite.png"),
    height = 1,
    width = 1,
    frame_count = 1,
    direction_count = 1
  }
end

util.ammo_category = function(name)
  if not data.raw["ammo-category"][name] then
    data:extend{{type = "ammo-category", name = name, localised_name = {"ammo-category-name." .. name}}}
  end
  return name
end

util.copy = util.table.deepcopy

-- From the tf_util of MIRV 2.1.0, used by the ballistic missile silo (silo.lua)
util.scale_vector = function(vector, scale)
  if vector[1] then
    return {vector[1] * scale, vector[2] * scale}
  end
  return {x = vector.x * scale, y = vector.y * scale}
end

-- Scales every sprite and light in a prototype, visiting shared tables only once
util.scale_graphics = function(prototype, scale)
  local visited = {}
  local recurse
  recurse = function(array)
    if visited[array] then return end
    visited[array] = true
    if (array.filename or array.filenames or array.stripes) and (array.width or array.size) then
      array.scale = (array.scale or 1) * scale
      if array.shift then
        array.shift = util.scale_vector(array.shift, scale)
      end
    elseif type(array.intensity) == "number" and type(array.size) == "number" then
      array.size = array.size * scale
      if array.shift then
        array.shift = util.scale_vector(array.shift, scale)
      end
    end
    for k, v in pairs (array) do
      if type(v) == "table" then
        recurse(v)
      end
    end
  end
  recurse(prototype)
end

return util
