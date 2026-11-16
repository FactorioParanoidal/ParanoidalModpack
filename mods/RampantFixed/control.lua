-- RampantFixed save bridge (Paranoidal). Up to 9.02.15 the Rampant fork of the build was the mod RampantFixed;
-- since 9.3.0 it is Paranoidal-Rampant. Factorio keeps a mod's storage under the mod name, so a save made before
-- the rename keeps the Rampant state in the storage of this mod. Paranoidal-Rampant takes it in its on_init
-- ("take") and empties this mod in its on_configuration_changed ("release"). No prototypes, settings or events.

local GUI_ROOTS = {"top", "left", "center", "screen", "goal", "relative"}

remote.add_interface("RampantFixed-save-bridge", {
    -- the kept Rampant state (a copy goes to the caller), nil when there is none
    take = function()
        if storage.universe == nil then
            return nil
        end
        return storage
    end,

    -- forget the state and remove the GUI elements left by RampantFixed (Paranoidal-Rampant builds its own);
    -- render objects are left: they are attached to entities or expire, and Paranoidal-Rampant can reach them
    release = function()
        for key in pairs(storage) do
            storage[key] = nil
        end
        for _, player in pairs(game.players) do
            local gui = player.gui
            for _, rootName in ipairs(GUI_ROOTS) do
                for _, element in pairs(gui[rootName].children) do
                    if element.valid and (element.get_mod() == script.mod_name) then
                        element.destroy()
                    end
                end
            end
        end
    end,
})
