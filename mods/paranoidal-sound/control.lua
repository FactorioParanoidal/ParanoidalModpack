-- Event-only audio: no tick handler, storage, polling, timers or save migration.
-- Old input IDs are retained; each linked control can fire several IDs, but only
-- the matching entity's handler plays, preserving the original spatial sound.
local inventory = defines.inventory
local bindings = {
    ["switch-gun-key"] = {sound = "select-smg", ammo = inventory.character_ammo},
    ["switch-gun-key-tank"] = {vehicle = "tank", sound = "select-cannon", ammo = inventory.car_ammo},
    ["switch-gun-key-car"] = {vehicle = "car", sound = "select-machine-gun", ammo = inventory.car_ammo},
    ["switch-gun-key-spider"] = {vehicle = "spidertron", sound = "select-machine-gun", ammo = inventory.spider_ammo},
}
for vehicle, sounds in pairs{
    car = {W = "car-engine-loads", S = "car-engine-loads-reverse", A = "car-steering", D = "car-steering"},
    tank = {W = "tank-engine-loads", S = "tank-engine-loads-reverse", A = "tank-engine-loads-rotation", D = "tank-engine-loads-rotation"},
} do
    for key, sound in pairs(sounds) do
        bindings[vehicle .. "-moving-key-" .. key] = {vehicle = vehicle, sound = sound}
    end
end

local function occupied(entity, id)
    local contents = entity.get_inventory(id)
    return contents and not contents.is_empty()
end

local function on_input(event)
    local binding = bindings[event.input_name]
    local player = game.get_player(event.player_index)
    if not binding or not player or not player.valid then return end
    local entity
    if binding.vehicle then
        entity = player.vehicle
        if not entity or not entity.valid or entity.name ~= binding.vehicle then return end
    else
        entity = player.character
        if player.driving or not entity or not entity.valid then return end
        if not occupied(entity, inventory.character_guns) then return end
    end
    if binding.ammo then
        if not occupied(entity, binding.ammo) then return end
    elseif not entity.burner or not entity.burner.currently_burning then
        return
    end
    entity.surface.play_sound{path = binding.sound, position = entity.position}
end

for name in pairs(bindings) do script.on_event(name, on_input) end
