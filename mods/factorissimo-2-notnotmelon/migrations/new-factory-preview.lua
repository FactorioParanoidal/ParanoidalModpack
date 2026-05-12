local mod_gui = require "mod-gui"

for _, player in pairs(game.players) do
    local buttonflow = mod_gui.get_button_flow(player)
    local button = buttonflow.factory_camera_toggle_button
    if button then button.destroy() end
    local frameflow = mod_gui.get_frame_flow(player)
    local camera_frame = frameflow.factory_camera_frame
    if camera_frame then camera_frame.destroy() end
end

storage.player_preview_active = nil
