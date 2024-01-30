-- File Licence: You can copy and distribute this file regardless of the mod's general licence. This licence exception does not affect other files of this mod.
local collision_mask_util_extended = {}

-- see collision_mask_util_extended_extended.lua for full instructions.
--[[
-- Example usage

local collision_mask_util_extended = require("collision-mask-util-control")
function check_collision_layers()
  collision_mask_util_extended.named_collision_mask_integrity_check()
  local flying_layer = collision_mask_util_extended.get_named_collision_mask("flying-layer")
end

script.on_init(check_collision_layers)
script.on_configuration_changed(check_collision_layers)

function find_flying_entities(surface)
  local flying_layer = collision_mask_util_extended.get_named_collision_mask("flying-layer")
  return surface.find_entities_filtered{collision_mask={flying_layer}}
end
]]

function collision_mask_util_extended.get_named_collision_mask(mask_name)
  local prototype = game.entity_prototypes["collision-mask-"..mask_name]
  if prototype then
    local layer
    for mask_name, collides in pairs(prototype.collision_mask) do
      if layer then
        error("\n\n\nA reserved collision mask object "..mask_name.." has been compromised by 1 or more of your installed mods. Object must have only 1 collision mask.\n\n")
      else
        layer = mask_name
      end
    end
    if not layer then
      error("\n\n\nA reserved collision mask object "..mask_name.." has been compromised by 1 or more of your installed mods. Object is missing collision_mask.\n\n")
    end
    return layer
  else
    error("\n\n\nA reserved collision mask object "..mask_name.." has been removed.\n\n")
  end
end

function collision_mask_util_extended.named_collision_mask_integrity_check()
  -- This function will check that collision mask marker objects have 1 collision mask
  -- Run this on the events: on_init and on_configuration_changed
  -- It will not detect collision mask marker objects that have been removed from the game
  -- However: collision_mask_util_extended.get_named_collision_mask(mask_name) will
  local prototypes = game.get_filtered_entity_prototypes({{filter = "type", type = "arrow"}})
  for _, prototype in pairs(prototypes) do
    if string.find(prototype.name, "collision-mask-") then
      local layer
      for mask_name, collides in pairs(prototype.collision_mask) do
        if layer then
          error("\n\n\nA reserved collision mask object "..mask_name.." has been compromised by 1 or more of your installed mods. Object must have only 1 collision mask.\n\n")
        else
          layer = mask_name
        end
      end
      if not layer then
        error("\n\n\nA reserved collision mask object "..mask_name.." has been compromised by 1 or more of your installed mods. Object is missing collision_mask.\n\n")
      end
    end
  end

end

return collision_mask_util_extended
