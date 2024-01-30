-- File Licence: You can copy and distribute this file regardless of the mod's general licence. This licence exception does not affect other files of this mod.
local collision_mask_util_extended = require("__core__/lualib/collision-mask-util")

--[[

Named collision masks allow a collision mask to be passed to the control phase.
The arrow object used to stor the mask is accessible under: game.entity_prototypes["collision-mask-flying-layer"]
The layer used is therefore: game.entity_prototypes["collision-mask-flying-layer"].collision_mask .. something

--------------------------------------------------------------------------------
-- INSTRUCTIONS
--------------------------------------------------------------------------------

-- flying-layer example:
-- data phase ------------------------------------------------------------------
(data.lua data-updates.lua data-final-fixes.lua etc) get/make a layer:

-- load the modified util
local collision_mask_util_extended = require("collision-mask-util-extended")

-- get a collision layer by name, if the name is not assigned to a layer it will assign one
local flying_layer = collision_mask_util_extended.get_make_named_collision_mask("flying-layer")

-- control phase ---------------------------------------------------------------
(conrtol.lua) Note: most mods don't need to know collision layers in control code.
local collision_mask_util_extended = require("collision-mask-util-control")

-- Example usage
local flying_layer = collision_mask_util_extended.get_named_collision_mask("flying-layer")
local entities = surface.find_entities_filtered{collision_mask={flying_layer}}

--------------------------------------------------------------------------------
-- Additional named layers
--------------------------------------------------------------------------------
"flying-layer"
-- local collision_mask_flying_layer = get_make_named_collision_mask("flying-layer")
Flying vehicles, units, and characters.
It is useful to also set the mask "not-colliding-with-itself" to prefent air-air collisions.
The mask can also be added to interior walls that are full height so can't be flown over.

"projectile-layer"
-- local collision_mask_projectile_layer = get_make_named_collision_mask("projectile-layer")
Projectiles. The the projectile should have the layers or most things it can hit (flying-layer).
Walls and shields can also use this layer to block the projectile.
Note: Projectiles use hit_collision_mask not collision_mask. force_condition = "not-friend" means it won't hit your stuff.
Note: Streams can't collide.

"vehicle-layer"
-- local collision_mask_vehicle_layer = get_make_named_collision_mask("vehicle-layer")
Car type vehicles and things that collide with them. Allows separation of vehicle-layer and player-layer in certain situations. Add to cars, trees, pipes

"space-tile"
-- local collision_mask_space_tile = get_make_named_collision_mask("space-tile")
All tiles in space zones (orbit/asteroid fields) including empty space and space platform.

"empty-space-tile"
-- local collision_mask_empty_space_tile = get_make_named_collision_mask("empty-space-tile")
tiles in space without flooring.
Different from void becuase there is no grravity and stuff can float there.

"interior-tile"
-- local collision_mask_interior_tile = get_make_named_collision_mask("interior-tile")
Tiles that represent interior spaces and don't have sky, like underground, factory building interiors, etc.
Rocket silos, artillery, telescopes, and space elevators may not be appropriate here.

"moving-tile"
-- local collision_mask_moving_tile = get_make_named_collision_mask("moving-tile")
Tiles that might change surface, such as spaceship tiles or warp structures.

"void-tile"
-- local collision_mask_void_tile = get_make_named_collision_mask("void-tile")
Tiles where there is a drop in to the ground (so you can't walk over or build on) but you can fly/jump over.

]]
local collision_flags =
{
  "consider-tile-transitions",
  "not-colliding-with-itself",
  "colliding-with-tiles-only"
}
collision_mask_util_extended.collision_flags = table.deepcopy(collision_flags)

collision_mask_util_extended.vanilla_named_collision_masks = {
  ["ground-tile"] = "ground-tile",
  ["water-tile"] = "water-tile",
  ["resource-layer"] = "resource-layer",
  ["doodad-layer"] = "doodad-layer",
  ["floor-layer"] = "floor-layer",
  ["item-layer"] = "item-layer",
  ["ghost-layer"] = "ghost-layer",
  ["object-layer"] = "object-layer",
  ["player-layer"] = "player-layer",
  ["train-layer"] = "train-layer",
  ["rail-layer"] = "rail-layer",
  ["transport-belt-layer"] = "transport-belt-layer"
}

-- fix issue reported in F1.1.5
collision_mask_util_extended.get_default_mask_vanilla = collision_mask_util_extended.get_default_mask
collision_mask_util_extended.get_default_mask = function (type)
  if type == "unit" then
    return {"player-layer", "train-layer", "not-colliding-with-itself"}
  else
    return collision_mask_util_extended.get_default_mask_vanilla(type)
  end
end

collision_mask_util_extended.get_default_hit_mask = function (type)
  if type == "projectile" then
    return {"player-layer", "train-layer", "object-layer",
     collision_mask_util_extended.get_make_named_collision_mask("flying-layer"),
     collision_mask_util_extended.get_make_named_collision_mask("projectile-layer"),
     collision_mask_util_extended.get_make_named_collision_mask("vehicle-layer"),
    "not-colliding-with-itself"}
  else
    return {}
  end
end

_named_collision_masks = _named_collision_masks or table.deepcopy(collision_mask_util_extended.vanilla_named_collision_masks) -- do not modify directly
named_collision_masks = table.deepcopy(_named_collision_masks) -- readonly
collision_mask_util_extended.named_collision_masks = named_collision_masks
-- tracks mod layers only. format: named_collision_masks[mask_name] == "layer-"..x

function collision_mask_util_extended.get_named_collision_mask(mask_name)
  return _named_collision_masks[mask_name]
end

function collision_mask_util_extended.get_make_named_collision_mask(mask_name)
  local layer = collision_mask_util_extended.get_named_collision_mask(mask_name)
  if not layer then
    layer = collision_mask_util_extended.get_first_unused_layer()
    log("Named collision layer ["..mask_name .."] set to layer ["..layer.."]")
    data:extend({
      {
        type = "arrow",
        name = "collision-mask-"..mask_name,
        collision_mask = {layer},
        flags = {"placeable-off-grid", "not-on-map"},
        circle_picture = { filename = "__core__/graphics/empty.png", priority = "low", width = 1, height = 1},
        arrow_picture = { filename = "__core__/graphics/empty.png", priority = "low", width = 1, height = 1}
      }
    })
  end
  _named_collision_masks[mask_name] = layer
  named_collision_masks = table.deepcopy(_named_collision_masks) -- readonly
  collision_mask_util_extended.named_collision_masks = named_collision_masks
  return layer
end

function collision_mask_util_extended.named_collision_mask_integrity_check()
  -- This function will check that collision mask marker objects have 1 collision mask
  for mask_name, layer_name in pairs(_named_collision_masks) do
    if not collision_mask_util_extended.vanilla_named_collision_masks[mask_name] then
      local mask_bearer = data.raw.arrow["collision-mask-"..mask_name]
      local layer
      if mask_bearer then
        if mask_bearer.collision_mask then
          for i, mask in pairs(mask_bearer.collision_mask) do
            if i == 1 then
              if  mask == "not-colliding-with-itself"
               or mask == "consider-tile-transitions"
               or mask == "colliding-with-tiles-only" then
                error("\n\n\nA reserved collision mask object "..mask_name.." has been compromised by 1 or more of your installed mods. Collision mask must be a collision layer, not a collision option.\n\n")
              end
              layer = mask
            else
              error("\n\n\nA reserved collision mask object "..mask_name.." has been compromised by 1 or more of your installed mods. Object must have only 1 collision mask.\n\n")
            end
          end
        else
          error("\n\n\nA reserved collision mask object "..mask_name.." has been compromised by 1 or more of your installed mods. Object is missing collision_mask.\n\n")
        end
      else
        error("\n\n\nA reserved collision mask object "..mask_name.." has been removed.\n\n")
      end
    end
  end
end

function collision_mask_util_extended.is_mask_empty(mask)
  for _, layer in pairs(mask) do
    local is_flag = false
    for _, option in pairs(collision_flags) do
      if layer == option then
        is_flag = true
      end
    end
    if not is_flag then
      return false
    end
  end
  return true
end

return collision_mask_util_extended
