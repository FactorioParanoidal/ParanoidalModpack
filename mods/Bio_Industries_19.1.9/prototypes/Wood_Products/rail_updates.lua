local BioInd = require('common')('Bio_Industries')


local vanilla, rail_group, bridge_group

-- "Transport drones" ruins rails by removing object-layer from the collision mask. That
-- causes problems for our "Wooden rail bridges" as they will also pass through cliffs.
local BI_rails = {
  ["bi-straight-rail-wood"] = true,
  ["bi-curved-rail-wood"] = true,
  ["bi-straight-rail-power"] = true,
  ["bi-curved-rail-power"] = true,
  --~ ["bi-straight-rail-wood-bridge"] = true,
  --~ ["bi-curved-rail-wood-bridge"] = true,
}

-- We may need to adjust the collision_masks of bridges, so we want to be able to check
-- if all layers are set. Let's make a lookup list of the layers we need for bridges!
local bridge_collision_layers = {}
for _, layer in ipairs(BioInd.RAIL_BRIDGE_MASK) do
  bridge_collision_layers[layer] = true
end

-- Name patterns for bridges from other mods should be inserted here.
local bridge_name_patterns = {
  "bi%-.+-rail%-wood%-bridge",
  --  Beautiful Bridge Railway
  "bbr%-[^-]+%-rail%-.+",
}

-- Make lookup lists of all bridges in the game!
local bridges = {
  curved = {},
  straight = {},
}
for f, form in ipairs({"straight", "curved"}) do
  for r, rail in pairs(data.raw[form .. "-rail"]) do
    for p, pattern in ipairs(bridge_name_patterns) do
      if r:match(pattern) then
        bridges[form][r] = true
      end
    end
  end
end
BioInd.show("bridges", bridges)

local mask, found_layer

for f, form in ipairs({"straight", "curved"}) do

  vanilla = data.raw[form .. "-rail"][form .. "-rail"]
  rail_group = vanilla and vanilla.fast_replaceable_group or "rail"
  vanilla.fast_replaceable_group = rail_group
  vanilla.collision_mask = BioInd.RAIL_MASK

  for rail_name, rail in pairs(data.raw[form .. "-rail"]) do
    -- Look for our own rails
    if BI_rails[rail_name] then
      -- Add collision masks to our rails
      rail.collision_mask = BioInd.RAIL_MASK
      BioInd.writeDebug("Set collision_mask of %s to %s", {rail_name, rail.collision_mask})

      -- Add fast_replaceable_group to our rails
      rail.fast_replaceable_group = rail_group
    end

    -- Look for all known bridges
    if bridges[form][rail_name] then
BioInd.show("Bridge found", rail_name)

      rail.collision_mask = rail.collision_mask or {}

      -- Adjust or create collision mask
      for need_layer, _ in pairs(bridge_collision_layers) do
        found_layer = false

        for l, layer in ipairs(rail.collision_mask) do
          -- Stop if the layer we're looking for already is in the collision mask!
          if need_layer == layer then
            found_layer = true
            break
          end
        end
        -- Add layer to collision mask
        if not found_layer then
          table.insert(rail.collision_mask, need_layer)
          BioInd.writeDebug("Added %s to collision mask of %s", {need_layer, rail_name})
        end
      end
BioInd.show("Collision mask", rail.collision_mask)
      -- Add fast_replaceable_group to the bridges
      rail.fast_replaceable_group = rail_group
    end
  end

end
