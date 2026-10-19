-- Permissions-related methods
local Permissions = {}

Permissions.pfx = BPSB.pfx .. "perms-"
local pfxLength = string.len(Permissions.pfx)

-- Whether the Thing is a Permissions Group for Sandboxes
function Permissions.IsSandboxPermissions(name)
    return string.sub(name, 1, pfxLength) == Permissions.pfx
end

-- These actions are not allowed by Players currently in Sandboxes
Permissions.disallowedActions = {
    -- Nothing Space Platform related; prevent cheating
    defines.input_action.cancel_delete_space_platform,
    defines.input_action.create_space_platform,
    defines.input_action.delete_space_platform,
    defines.input_action.instantly_create_space_platform,
    defines.input_action.rename_space_platform,
    defines.input_action.open_new_platform_button_from_rocket_silo,
    defines.input_action.request_missing_construction_materials,
    -- Nothing Rocket or Planet related; prevent cheating
    defines.input_action.land_at_planet,
    defines.input_action.launch_rocket,
    -- Nothing Pin related; prevent unnecessary views of other surfaces
    defines.input_action.add_pin,
    defines.input_action.edit_pin,
    defines.input_action.remove_pin,
    defines.input_action.pin_alert_group,
    defines.input_action.pin_custom_alert,
    defines.input_action.pin_search_result,
    -- Nothing Research related; prevent unnecessary de-synchronization
    defines.input_action.cancel_research,
    defines.input_action.move_research,
    defines.input_action.start_research,
}

-- Create a new Permissions Group based on the Player's existing one
---@param player LuaPlayer
function Permissions.GetOrCreate(player)
    local sandboxPermissionsName = Permissions.pfx .. player.name
    local permissions = game.permissions.get_group(sandboxPermissionsName)
    if not permissions then
        permissions = game.permissions.create_group(sandboxPermissionsName)
    end

    if not permissions then
        log("Failed to get or create permissions group for player " .. player.name)
        return
    end

    local playerPermissions = player.permission_group
    if playerPermissions
            and not Permissions.IsSandboxPermissions(playerPermissions.name)
    then
        log("Synchronizing permissions groups " .. playerPermissions.name .. " -> " .. permissions.name)
        for _, action in pairs(defines.input_action) do
            local allowsAction = playerPermissions.allows_action(action)
            if permissions.allows_action(action) ~= allowsAction then
                permissions.set_allows_action(action, allowsAction)
            end
        end
    end

    for _, action in pairs(Permissions.disallowedActions) do
        if permissions.allows_action(action) then
            permissions.set_allows_action(action, false)
        end
    end

    return permissions
end

return Permissions
