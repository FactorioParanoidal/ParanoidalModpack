local Util = require('modules/util')
local actions = require('modules/actions')

local Rotate = {}

local function transform(ents)
    for _,ent in pairs(ents) do
        ent.direction = isV1 and ((ent.direction or 0) + 2) % 8 or ((ent.direction or 0) + 4) % 16
	    ent.position.x, ent.position.y = ent.position.y * -1, ent.position.x * 1
    end
    return ents
end
--
--local function pseudomatrixmultiply(position, mult)
--	position.x, position.y = position.y * mult.x, position.x * mult.y
--end


function Rotate.rotate_action(player, event, action)
    local bp = Util.get_blueprint(player)
    if not bp then return end

    local ents
    ents = bp.get_blueprint_entities()
    if ents then bp.set_blueprint_entities(transform(ents)) end

    ents = bp.get_blueprint_tiles()
    if ents then bp.set_blueprint_tiles(transform(ents)) end
end


actions[mod.prefix..'rotate-clockwise'].handler = Rotate.rotate_action


return Rotate
