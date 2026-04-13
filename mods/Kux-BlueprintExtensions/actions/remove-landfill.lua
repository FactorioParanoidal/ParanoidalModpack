local Util = require("modules/util")
local Tempprint = require('actions/tempprint')
local actions = require('modules/actions')

local RemoveLandfill = { }

---
---@param player LuaPlayer
---@param event any
---@param action any
function RemoveLandfill.RemoveLandfill_action(player, event, action)
	log("RemoveLandfill_action")
    local bp = Util.get_blueprint(player)
    if not bp then return end

    -- Collect current blueprint info.
    local entities = bp.get_blueprint_entities()
    if not entities then
        player.print({"bpex.landfill_no_entities_in_bp"})
        return
    end
    local tiles = {}

    local mode = player.mod_settings["Kux-BlueprintExtensions_remove-landfill-mode"].value
    if mode == 'update' then    -- Update the existing blueprint.
        bp.set_blueprint_tiles(tiles)
        return
    end

    local blueprint_icons = bp.preview_icons
    local label = bp.label
    local label_color = bp.label_color
    local name = bp.name

    if not player.clear_cursor() then
        player.print({"bpex.error_cannot_set_stack"})
        return
	end

    local stack = player.cursor_stack or error("invalid state")
    stack.set_stack(name)
    stack.set_blueprint_entities(entities)
    stack.set_blueprint_tiles(tiles)
    if label then stack.label = label end
    if label_color then stack.label_color = label_color end
    if blueprint_icons then stack.preview_icons = blueprint_icons end

    if mode == 'tempcopy' then
        Tempprint.set_temporary(player)
    end
end

actions['Kux-BlueprintExtensions_remove-landfill'].handler = RemoveLandfill.RemoveLandfill_action

return RemoveLandfill