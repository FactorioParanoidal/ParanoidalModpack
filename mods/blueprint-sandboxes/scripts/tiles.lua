-- Custom Planners to add/remove Resources
local Tiles = {}

Tiles.name = BPSB.pfx .. "sandbox-tiles"
Tiles.pfx = BPSB.pfx .. "sbt-"
local pfxLength = string.len(Tiles.pfx)

-- Whether the Thing is a Tile Planner
function Tiles.IsTilePlanner(name)
    return string.sub(name, 1, pfxLength) == Tiles.pfx
end

-- Extract the Resource Name from a Tile Planner
function Tiles.GetResourceName(name)
    return string.sub(name, pfxLength + 1)
end

return Tiles
