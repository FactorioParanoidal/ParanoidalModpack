local util = require('modules/util')
local actions = require('modules/actions')

local Wireswap = {}

function Wireswap.swap(player, event, action)
    local bp = util.get_blueprint(player)
    if not bp then return end
    local ents = bp.get_blueprint_entities()

    if ents then
        for i,ent in pairs(ents) do
			for _, wire in ipairs(ent.wires or {}) do
				-- Tausche die Drahtanschluss-IDs (Farben)
				if wire[2] == defines.wire_connector_id.circuit_red then
					wire[2] = defines.wire_connector_id.circuit_green
				elseif wire[2] == defines.wire_connector_id.circuit_green then
					wire[2] = defines.wire_connector_id.circuit_red
				end

				if wire[4] == defines.wire_connector_id.circuit_red then
					wire[4] = defines.wire_connector_id.circuit_green
				elseif wire[4] == defines.wire_connector_id.circuit_green then
					wire[4] = defines.wire_connector_id.circuit_red
				end
			end
        end
        bp.set_blueprint_entities(ents)
    end
end

actions[mod.prefix.."wireswap"].handler = Wireswap.swap

--script.on_event("Kux-BlueprintExtensions_wireswap", function(event) return Wireswap.swap(game.players[event.player_index]) end)


return Wireswap
