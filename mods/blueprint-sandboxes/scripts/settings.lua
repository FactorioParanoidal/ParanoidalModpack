local Settings = {}

Settings.scanSandboxes = BPSB.pfx .. "scan-all-chunks"
Settings.allowAllTech = BPSB.pfx .. "allow-all-technology"
Settings.onlyAdminsForceReset = BPSB.pfx .. "only-admins-force-reset"
Settings.craftToCursor = BPSB.pfx .. "craft-to-cursor"
Settings.bonusInventorySlots = BPSB.pfx .. "bonus-inventory-slots"
Settings.extraMiningSpeed = BPSB.pfx .. "extra-mining-speed"
Settings.extraLabSpeed = BPSB.pfx .. "extra-lab-speed"
Settings.godAsyncTick = BPSB.pfx .. "god-async-tick"
Settings.godAsyncCreateRequestsPerTick = BPSB.pfx .. "god-async-create-per-tick"
Settings.godAsyncUpgradeRequestsPerTick = BPSB.pfx .. "god-async-upgrade-per-tick"
Settings.godAsyncDeleteRequestsPerTick = BPSB.pfx .. "god-async-delete-per-tick"

function Settings.SetupScanSandboxes()
    if settings.global[Settings.scanSandboxes].value then
        script.on_nth_tick(Lab.chartAllLabsTick, God.ChartAllOccupiedSandboxes)
    else
        script.on_nth_tick(Lab.chartAllLabsTick, nil)
    end
end

function Settings.SetupConditionalHandlers()
    Settings.SetupScanSandboxes()
    script.on_nth_tick(settings.global[Settings.godAsyncTick].value, God.HandleAllSandboxRequests)
end

function Settings.OnRuntimeSettingChanged(event)
    if event.setting == Settings.scanSandboxes then
        Settings.SetupScanSandboxes()
    elseif event.setting == Settings.allowAllTech then
        Research.SyncAllForces()
    elseif event.setting == Settings.onlyAdminsForceReset then
        for _, player in pairs(game.players) do
            ToggleGUI.Update(player)
        end
    elseif event.setting == Settings.bonusInventorySlots then
        Force.SyncAllForces()
    elseif event.setting == Settings.extraMiningSpeed then
        Force.SyncAllForces()
    elseif event.setting == Settings.extraLabSpeed then
        Force.SyncAllForces()
    elseif event.setting == Settings.godAsyncTick then
        local newValue = settings.global[Settings.godAsyncTick].value
        script.on_nth_tick(global.lastSettingForAsyncGodTick, nil)
        script.on_nth_tick(newValue, God.HandleAllSandboxRequests)
        global.lastSettingForAsyncGodTick = newValue
    end
end

return Settings
