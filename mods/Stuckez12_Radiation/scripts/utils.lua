local utils = {}

function utils.is_item(name) return prototypes.item[name] ~= nil end

function utils.is_resource(name) local proto = game.entity_prototypes[name] return proto and proto.type == "resource" end

function utils.distance(entity_1, entity_2) return math.sqrt((entity_1.position.x - entity_2.position.x)^2 + (entity_1.position.y - entity_2.position.y)^2) end

return utils
