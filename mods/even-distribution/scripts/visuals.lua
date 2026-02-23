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
                source = self:toPlain(),
                render_player_index = player and player.index,
                box_type = "electricity",
                blink_interval = 0,
            },
            bg = rendering.draw_sprite{
                sprite = "utility/entity_info_dark_background",
                render_layer = "selection-box",
                target = self:toPlain(),
                target_offset = self.type == "spider-vehicle" and {0,-box:boxheight()*3/4} or nil,
                players = player and {player:toPlain()},
                surface = self.surface,
                x_scale = scale,
                y_scale = scale,
            },
            icon = rendering.draw_sprite{
                sprite = getSprite(item),
                render_layer = "selection-box",
                target = self:toPlain(),
                target_offset = self.type == "spider-vehicle" and {0,-box:boxheight()*3/4} or nil,
                players = player and {player:toPlain()},
                surface = self.surface,
                x_scale = scale,
                y_scale = scale,
            },
            text = rendering.draw_text({
                text = getShortCount(count),
                target = self:toPlain(),
                target_offset = self.type == "spider-vehicle" and {0,-box:boxheight()*3/4} or nil,
                --target_offset = { -0.9 * width * 0.5, -0.9 * height * 0.5 },
                players = player and {player:toPlain()},
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
            source = self:toPlain(),
            render_player_index = player and player.index,
            box_type = "electricity",
            blink_interval = 6,
            time_to_live = 60 * 1,
        }
    end
end

function this.update(marker, item, count, color)
    if marker then
        marker.icon.sprite = getSprite(item)
        marker.text.text = getShortCount(count)
        marker.text.color = color or getCountColor(count)
    end
end

function helpers:unmark() -- destroy distribution marker of entity
    if self:is("userdata") then return self:is("valid") and self.destroy() end
    
    self:where("userdata", "valid", function(__, marker)
            marker.destroy()
        end)
end

function this.unmark(cache) -- destroy all distribution markers of a player (using cache)
	_(cache.markers):each(function(markers)
        _(markers):unmark()
	end)
	
	cache.markers = metatables.new("entityAsIndex")
end

function helpers:spawnDistributionText(player, item, amount, offY, color) -- spawn distribution text on entity
	local pos = self.position

    player.create_local_flying_text{ -- spawn text
        text = {"", "       ", -amount, " ", prototypes.item[item].localised_name},
		position = { pos.x - 0.5, pos.y + (offY or 0) },
		color = color or config.colors.default
	}
end

return this