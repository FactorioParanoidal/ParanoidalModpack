local this = {}
local util = scripts.util
local metatables = scripts.metatables
local config = require("config")

local helpers = scripts.helpers
local _ = helpers.on

local function getSprite(item)
    return "item/"..item
end

local function getShortCount(count)
    if count == nil then return 0 end
    if count >= 1000000000 then return (math.floor(count / 1000000) / 10).."G" end
    if count >= 1000000    then return (math.floor(count / 10000) / 10).."M" end
    if count >= 1000       then return (math.floor(count / 100) / 10).."K" end
    return count
end

local function getCountColor(count)
    if count == 0 or count == nil then
        return config.colors.insufficientItems
    else
        return config.colors.default
    end
end

function helpers:mark(player, item, count) -- create highlight-box marker with item and count
    
    if item ~= nil then

        local box = _(self.selection_box)
        local width = box:boxwidth()
        local height = box:boxheight()
        local scale = 0.63 * math.min(width, height)
        
        return {
            box = self.surface.create_entity{
                name = "highlight-box",
                position = self.position,
                source = self,
                render_player_index = player and player.index,
                box_type = "electricity",
                blink_interval = 0,
            },
            bg = rendering.draw_sprite{
                sprite = "utility/entity_info_dark_background",
                render_layer = "selection-box",
                target = self,
                players = player and {player},
                surface = self.surface,
                x_scale = scale,
                y_scale = scale,
            },
            icon = rendering.draw_sprite{
                sprite = getSprite(item),
                render_layer = "selection-box",
                target = self,
                players = player and {player},
                surface = self.surface,
                x_scale = scale,
                y_scale = scale,
            },
            text = rendering.draw_text({
                text = getShortCount(count),
                target = self,
                --target_offset = { -0.9 * width * 0.5, -0.9 * height * 0.5 },
                players = player and {player},
                surface = self.surface,
                alignment = "center",
                color = getCountColor(count),
            })
        }
    else
        -- blink animation
        self.surface.create_entity{
            name = "highlight-box",
            position = self.position,
            source = self,
            render_player_index = player and player.index,
            box_type = "electricity",
            blink_interval = 6,
            time_to_live = 60 * 1,
        }
    end
end

function this.update(marker, item, count)
    if marker then
        rendering.set_sprite(marker.icon, getSprite(item))
        rendering.set_text(marker.text, getShortCount(count))
        rendering.set_color(marker.text, getCountColor(count))
    end
end

function helpers:unmark() -- destroy distribution marker of entity
    if self:is("object") then return self:is("valid") and self.destroy() end
    
    local source, player
    self:where("table", function(__, marker)
            marker.destroy()
        end)
        :where("number", function(__, id)
            if rendering.is_valid(id) then
                if not source and rendering.get_target(id)  then source = _(rendering.get_target(id).entity) end
                if not player and rendering.get_players(id) then player = _(rendering.get_players(id)[1]) end
                rendering.destroy(id)
            end
        end)

    if source and player and source:is("valid") and player:is("valid player") then source:mark(player) end
end

function this.unmark(cache) -- destroy all distribution markers of a player (using cache)
	_(cache.markers):each(function(markers)
        _(markers):unmark()
	end)
	
	cache.markers = metatables.new("entityAsIndex")
end

function helpers:destroyTransferText() -- remove flying text from stack transfer
	local surface = self.surface
	local pos = self.position
	
	util.destroyIfValid(surface.find_entities_filtered{
		name = "flying-text",
		area = {{pos.x, pos.y - 1}, {pos.x, pos.y}},
		limit = 1
	}[1])
end

function helpers:spawnDistributionText(item, amount, offY, color) -- spawn distribution text on entity
	local surface = self.surface
	local pos = self.position

	surface.create_entity{ -- spawn text
		name = "distribution-text",
		position = { pos.x - 0.5, pos.y + (offY or 0) },
		text = {"", "       ", -amount, " ", game.item_prototypes[item].localised_name},
		color = color or config.colors.default
	}
end

return this