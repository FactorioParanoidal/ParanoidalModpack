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
    data:extend{{type = "ammo-category", name = name, localised_name = {name}}}
  end
  return name
end

util.copy = util.table.deepcopy

return util
