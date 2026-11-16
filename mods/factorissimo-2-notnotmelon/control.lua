-- Factorissimo 3 save bridge (Paranoidal). Up to 9.12.0 the Factorissimo fork of the build was the mod
-- factorissimo-2-notnotmelon; since 9.20.0 it is Paranoidal-factorissimo-4. Factorio keeps a mod's storage under the
-- mod name, so a save made before the rename keeps every factory in the storage of this mod.
-- Paranoidal-factorissimo-4 takes it in its on_init ("take") and empties this mod in its on_configuration_changed
-- ("release"). No prototypes, settings or events.

local MOD = script.mod_name
local GUI_ROOTS = {"top", "left", "center", "screen", "goal", "relative"}
-- Containers of the mod button bar (core lualib mod-gui) are shared by every mod that has a button there; the old
-- Factorissimo may have created them. Never destroyed here, only the old dispatcher button inside.
local SHARED = {mod_gui_top_frame = true, mod_gui_button_flow = true, mod_gui_frame_flow = true}
local DISPATCH_BUTTON = "factorissimo_dispatch_button"

local function own(element)
    return element and element.valid and element.get_mod() == MOD
end

remote.add_interface("factorissimo-2-notnotmelon-save-bridge", {
    -- the kept Factorissimo state (a copy goes to the caller), nil when there is none
    take = function()
        if storage.factories == nil then return nil end
        return storage
    end,

    -- forget the state; remove the GUI elements (dispatcher button and window, preview frames) and the render objects
    -- (names, overlay icons, port markers, planet icons) left by the old Factorissimo: Paranoidal-factorissimo-4
    -- builds and draws its own
    release = function()
        for key in pairs(storage) do
            storage[key] = nil
        end
        for _, player in pairs(game.players) do
            local gui = player.gui
            local top = gui.top
            local bar = top.mod_gui_button_flow or (top.mod_gui_top_frame and top.mod_gui_top_frame.mod_gui_inner_frame)
            if bar and own(bar[DISPATCH_BUTTON]) then bar[DISPATCH_BUTTON].destroy() end
            for _, root_name in ipairs(GUI_ROOTS) do
                for _, element in pairs(gui[root_name].children) do
                    if own(element) and not SHARED[element.name] then element.destroy() end
                end
            end
        end
        rendering.clear(MOD)
    end,
})
