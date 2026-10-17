-- SpaceExploration related functionality
local SpaceExploration = {}

SpaceExploration.name = "space-exploration"
function SpaceExploration.enabled()
    return not not remote.interfaces[SpaceExploration.name]
end

return SpaceExploration
