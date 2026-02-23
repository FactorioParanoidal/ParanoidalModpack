local gui_overlay = {}


function gui_overlay.create_radiation_display(player)
    local screen_flow = player.gui.screen

    if not screen_flow.radiation_logo then
        local logo = screen_flow.add{
            type = "sprite",
            name = "radiation_logo",
            sprite = "no_sprite",
            color = {r = 1, g = 0, b = 0, a = 0.5},
            ignored_by_interaction = true
        }

        local res = player.display_resolution
        local sprite_size = 384  -- replace with actual sprite size in px

        logo.location = {
            (res.width - sprite_size) / 2,
            (res.height - sprite_size) / 2
        }
    end
end


function gui_overlay.update_sprite_overlay(player, damage)
    local screen_flow = player.gui.screen

    if not screen_flow.radiation_logo then
        gui_overlay.create_radiation_display(player)
    end

    local sprite = screen_flow.radiation_logo
    local index = tostring(math.random(1,10))
    local image = "no_sprite"

    if not player.mod_settings["Stuckez12-Radiation-Enable-GUI-Effect"].value then
        sprite.sprite = image

        goto continue
    end

    if damage <= 50 and damage > 0 then
        image = "GUILowRadiation" .. index
    elseif damage <= 250 and damage > 50 then
        image = "GUIMediumRadiation" .. index
    elseif damage > 250 then
        image = "GUIHighRadiation" .. index
    end

    sprite.sprite = image

    ::continue::
end


return gui_overlay
