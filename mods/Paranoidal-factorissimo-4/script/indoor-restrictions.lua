-- Buildings that make no sense under a roof cannot be placed inside factory buildings.
-- With Space Age the "ceiling" surface property already blocks some of them through surface_conditions
-- (prototypes/ceiling.lua); without Space Age surface_conditions are unavailable, so it is done here.
-- Buildings that already stand inside factories are left alone.

local BANNED_TYPES = {
    "artillery-turret",
    "artillery-wagon",
    "rocket-silo",
    "cargo-landing-pad",
}

-- Rocket Silo Construction: the construction site turns into a rocket silo by script.
local banned_names = {}
for name in pairs(prototypes.get_entity_filtered {{filter = "type", type = "assembling-machine"}}) do
    if name:find("^rsc%-silo%-stage") then banned_names[#banned_names + 1] = name end
end

local banned_type_set, banned_name_set = {}, {}
for _, t in pairs(BANNED_TYPES) do banned_type_set[t] = true end
for _, name in pairs(banned_names) do banned_name_set[name] = true end

local function is_banned(entity)
    if entity.type == "entity-ghost" then
        return banned_type_set[entity.ghost_type] or banned_name_set[entity.ghost_name]
    end
    return banned_type_set[entity.type] or banned_name_set[entity.name]
end

local function message(entity)
    local name = entity.type == "entity-ghost" and entity.ghost_prototype.localised_name or entity.localised_name
    return {"factory-connection-text.cannot-build-indoors", name}
end

factorissimo.on_event(factorissimo.events.on_built(), function(event)
    local entity = event.entity
    if not entity.valid then return end
    if not storage.surface_factories[entity.surface_index] then return end
    if not is_banned(entity) then return end

    if entity.type == "entity-ghost" then
        local text = message(entity)
        local position = entity.position
        entity.destroy()
        local player = event.player_index and game.get_player(event.player_index)
        if player then
            player.create_local_flying_text {text = text, position = position, create_at_cursor = true}
        end
        return
    end

    factorissimo.cancel_creation(entity, event.player_index, message(entity), nil, event.robot)
end, factorissimo.join_filters(
    factorissimo.entity_filters(BANNED_TYPES, banned_names),
    factorissimo.ghost_filters(BANNED_TYPES, banned_names)
))
