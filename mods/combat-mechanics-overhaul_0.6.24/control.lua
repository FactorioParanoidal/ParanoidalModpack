local collision_mask_util = require("__combat-mechanics-overhaul__/collision-mask-util-extended/control/collision-mask-util-control")
local Util = require("scripts/util")

local exclude_names = {
  "farl_player",
  "yarm-remote-viewer",
}

function prototype_check_collision_layers(prototype)
  if not (
    prototype.collision_mask_with_flags ["colliding-with-tiles-only"]
    or global.collision_layers.flying_layer
    or global.collision_layers.projectile_layer
    or global.collision_layers.player_layer
    or global.collision_layers.train_layer) then
      for _, exclude_name in pairs(exclude_names) do
        if string.find(prototype.name, exclude_name, 1, true) then return end
      end
      if not Util.table_contains(exclude_names, prototype.name) then
        error(prototype.type.." "..prototype.name.." must have at least 1 of the following collision masks: player-layer, train-layer, flying-layer or projectile-layer.\n"..serpent.block(prototype.collision_mask))
      end
  end
end

function check_collision_layers()

  -- general check
  collision_mask_util.named_collision_mask_integrity_check()

  global.collision_layers = {}
  global.collision_layers.flying_layer = collision_mask_util.get_named_collision_mask("flying-layer")
  global.collision_layers.projectile_layer = collision_mask_util.get_named_collision_mask("projectile-layer")
  global.collision_layers.player_layer = "player-layer"
  global.collision_layers.train_layer = "train-layer"

  -- make sure that projectiles can actually hit what they are shooting at
  local prototypes = game.get_filtered_entity_prototypes({
    {filter = "type", type = "car"},
    {filter = "type", type = "spider-vehicle"},
    {filter = "type", type = "character"},
    {filter = "type", type = "unit"},
    {filter = "type", type = "combat-robot"}
  })
  for _, prototype in pairs(prototypes) do
    prototype_check_collision_layers(prototype)
  end
end

script.on_init(check_collision_layers)
script.on_configuration_changed(check_collision_layers)
