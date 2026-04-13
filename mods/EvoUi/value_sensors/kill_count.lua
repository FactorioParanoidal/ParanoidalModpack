require "template"

-- Preload known vanilla types
local entity_types = {
    ["unit"] = {
        ["small-biter"] = true,
        ["medium-biter"] = true,
        ["big-biter"] = true,
        ["behemoth-biter"] = true,
        ["small-spitter"] = true,
        ["medium-spitter"] = true,
        ["big-spitter"] = true,
        ["behemoth-spitter"] = true,

    --ArmouredBiters
        ["small-armoured-biter"] = true,
        ["medium-armoured-biter"] = true,
        ["big-armoured-biter"] = true,
        ["behemoth-armoured-biter"] = true,
        ["leviathan-armoured-biter"] = true,
    },
    ["unit-spawner"] = {
        ["biter-spawner"] = true,
        ["spitter-spawner"] = true,
        ["armoured-biter-spawner"] = true, --ArmouredBiters spawner
    },
}



local function is_entity_type(what_type, entity_name)
    if not entity_types[what_type] then entity_types[what_type] = {} end
    local type_cache = entity_types[what_type]

    if type_cache[entity_name] ~= nil then
        return type_cache[entity_name]
    end

    local prototype = game.entity_prototypes[entity_name]
    if prototype and prototype.type == what_type then
        type_cache[entity_name] = true
    else
        type_cache[entity_name] = false
    end

    return type_cache[entity_name]
end


local function is_biter(entity_name)
    return is_entity_type("unit", entity_name)
end


local function is_spawner(entity_name)
    return is_entity_type("unit-spawner", entity_name)
end


local sensor = ValueSensor.new("kill_count")

function sensor:update_ui(owner)
    local player = game.players[owner.player_index]

    local biter_count = 0
    local spawner_count = 0
    local other_count = 0
    for entity_name, kill_count in pairs(player.force.get_kill_count_statistics(player.surface).input_counts) do
        if is_biter(entity_name) then
            biter_count = biter_count + kill_count
        elseif is_spawner(entity_name) then
            spawner_count = spawner_count + kill_count
        else
            other_count = other_count + kill_count
        end
    end

    local biter_kills = {"sensor.kill_count.biter_fragment_single"}
    if biter_count ~= 1 then
        biter_kills = {"sensor.kill_count.biter_fragment_multiple", EvoUi.format_number(biter_count)}
    end

    local spawner_kills = {"sensor.kill_count.spawner_fragment_single"}
    if spawner_count ~= 1 then
        spawner_kills = {"sensor.kill_count.spawner_fragment_multiple", EvoUi.format_number(spawner_count)}
    end

    local other_kills = {"sensor.kill_count.other_fragment_single"}
    if other_count ~= 1 then
        other_kills = {"sensor.kill_count.other_fragment_multiple", EvoUi.format_number(other_count)}
    end

    owner[self.name].caption = {self.format_key, biter_kills, spawner_kills, other_kills}
end

ValueSensor.register(sensor)

