local Event = require('__stdlib__/stdlib/event/event')
local use_bp_prio = not script.active_mods['BotPrioritizer'] and settings.get_startup('picker-bp-prioritizer')

local sc = {shortcut = defines.events.on_lua_shortcut, proto_name = 'picker-bp-prioritizer-shortcut'}
local entity_names = {
    ['entity-ghost'] = true,
    ['tile-ghost'] = true,
    ['deconstructible-tile-proxy'] = true
}
local function bp_prioritizer(event)
    if event.name == sc.shortcut and event.prototype_name ~= sc.prototype_name then return end
    local player = game.get_player(event.player_index)

    local character = player.character
    if not character then return end

    local cell = character.logistic_cell
    if not (cell and cell.mobile) then return end

    local radius = math.min(cell.construction_radius, 32)
    local force = player.force
    local surface = player.surface

    local entities = surface.find_entities_filtered{position = player.position, radius = radius, force = force}
    for _, entity in ipairs(entities) do
        if entity_names[entity.name] then
            if entity.clone({position = entity.position, force = force}) then
                entity.destroy()
            end
        elseif entity.name == 'item-request-proxy' then
            if surface.create_entity{
                name = entity.name,
                target = entity.proxy_target,
                position = entity.position,
                force = force,
                modules = entity.item_requests
            } then
                entity.destroy()
            end
        elseif entity.to_be_deconstructed() then
            entity.cancel_deconstruction(force, player)
            entity.order_deconstruction(force, player)
        elseif entity.to_be_upgraded() then
            local upgrade_proto = entity.get_upgrade_target()
            if upgrade_proto then
                entity.cancel_upgrade(force, player)
                entity.order_upgrade({force = entity.force, target = upgrade_proto, player = player})
            end
        end
    end
end
local events = {'picker-bp-prioritizer-input', defines.events.on_lua_shortcut}
Event.register_if(use_bp_prio, events, bp_prioritizer)
