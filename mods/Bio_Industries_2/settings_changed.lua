--------------------------------------------------------------------
-- If startup settings have been changed, we need to check some stuff.
-- Keep that in a separate file so the main control.lua is easier to
-- read!
--------------------------------------------------------------------


local settings_changed = {}

-- Adjust the force of hidden poles on Musk floor!
-- Runs only when the setting "BI_Show_musk_floor_in_mapview" differs from the state
-- the poles were last set for (any startup setting change of any mod calls this).
settings_changed.musk_floor = function()
    local musk = storage.bi_musk_floor_table
    if not musk or musk.use_musk_force == BioInd.UseMuskForce then
        return
    end
    log("Entered function settings_changed.musk_floor!")
    -- Look for solar panels on every surface. They determine the force poles will use
    -- if the electric grid overlay will be shown in mapview.
    local sm_panel_name = "bi-musk-mat-hidden-panel"
    local sm_pole_name = "bi-musk-mat-hidden-pole"

    -- If dummy force is not used, force of a hidden pole should be that of the hidden solar panel.
    -- That force will be "enemy" for poles/solar panels created with versions of Bio Industries
    -- prior to 0.17.45/0.18.13 because of the bug. We can fix that for singleplayer games by setting
    -- the force to player force. In multiplayer games, we can do this as well if all players are
    -- on the same force. If there are several forces that have players, it's impossible to find out
    -- which force built a certain musk floor tile, so "enemy" will still be used.
    -- (Only fix in this case: Players must remove and rebuild all existing musk floor tiles!)

    local force = nil

    -- Always use dummy force if option is set
    if BioInd.UseMuskForce then
        force = BioInd.MuskForceName
        -- Singleplayer mode: use force of first player
    elseif not game.is_multiplayer() then
        -- Apparently, this crashed for someone (https://mods.factorio.com/mod/Bio_Industries_2/discussion/649d41b778d997d29385b8cf).
        -- Could it be that a game that was originally a multiplayer game has been saved and reused
        -- as singleplayer game, but there was no player 1? Let's go over all players and break after
        -- the first hit, so we make sure we'll get the single player whatever its index!
        for p, player in pairs(game.players) do
            force = player.force.name
            break
        end
        -- Still got no force? Fall back to "player" -- as one of the 3 default forces,
        -- it can't be removed, so we can use it!
        force = force or "player"

        -- Multiplayer game
    else
        local count = 0
        -- Count forces with players
        for _, check_force in pairs(game.forces) do
            if next(check_force.players) then
                force = check_force.name
                count = count + 1
            end
        end
        -- Several forces with players: reset force to nil now and use force of panel later
        -- (If this happens in a game were musk floor was created the buggy way with "force == nil",
        --  it will be impossible to determine which force built it, so the force will still be
        --  the default, i.e. "enemy".)
        if count > 1 then
            force = nil
        end
    end

    if prototypes.entity[sm_panel_name] and prototypes.entity[sm_pole_name] then
        for name, surface in pairs(game.surfaces) do
            local sm_panel = surface.find_entities_filtered { name = sm_panel_name }

            -- Look for hidden poles on position of hidden panels
            for p, panel in ipairs(sm_panel) do
                local sm_pole = surface.find_entities_filtered {
                    name = sm_pole_name,
                    position = panel.position,
                    radius = 0.01, -- by centre: hidden entities have an empty collision box
                }

                -- If more than one hidden pole exists at that position for some reason, remove all but the first!
                for i = 2, #sm_pole do
                    sm_pole[i].destroy()
                end

                -- Set force of the pole
                if sm_pole[1] then
                    sm_pole[1].force = force or panel.force
                end
            end
        end
    end
    musk.use_musk_force = BioInd.UseMuskForce
    log(string.format("Electric grid overlay of musk floor will be %s in map view.",
        BioInd.UseMuskForce and "hidden" or "displayed"))
end

return settings_changed
