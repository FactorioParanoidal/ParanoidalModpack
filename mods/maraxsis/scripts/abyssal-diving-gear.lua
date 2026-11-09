--note: much of this code is duplicated from the nightvision script.

local function init()
    storage.external_modifiers = storage.external_modifiers or {light_radius = {}, swim_speed = {}}
    storage.base_character_values = storage.base_character_values or {light_radius = 0, swim_speed = 0}
end

maraxsis.on_event(maraxsis.events.on_init(), init)

local is_abyssal_diving_gear = {
    ["maraxsis-abyssal-diving-gear"] = true,
    ["maraxsis-abyssal-diving-gear-disabled"] = true,
}

-- returns the default buff amount per quality level in vanilla
local function get_quality_buff(quality_level)
    return 1 + quality_level
end

local function get_abyssal_light_size(player)
    init()
    local character = player.character
    local light_size = storage.base_character_values["light_radius"]
    if not character then return light_size end
    local grid = character.grid
    if not grid then return light_size end

    for _, equipment in pairs(grid.get_contents()) do
        if equipment.name == "maraxsis-abyssal-diving-gear" then
            local quality = prototypes.quality[equipment.quality]
            light_size = light_size + (equipment.count * get_quality_buff(quality.level))
        end
    end
    return light_size
end

maraxsis.is_wearing_abyssal_diving_gear = function(player)
    local character = player.character
    if not character then return false end
    local grid = character.grid
    if not grid then return false end

    for _, equipment in pairs(grid.get_contents()) do
        if is_abyssal_diving_gear[equipment.name] then
            return true
        end
    end

    return false
end

local function update_abyssal_light_cone(player)
    init()
    local is_on_maraxsis = not not maraxsis_constants.MARAXSIS_SURFACES[player.physical_surface.name]
    storage.abyssal_light_cones = storage.abyssal_light_cones or {}

    local cone = storage.abyssal_light_cones[player.index]
    if cone then
        cone.destroy()
        storage.abyssal_light_cones[player.index] = nil
        if not is_on_maraxsis then return end
    end

    local light_size = get_abyssal_light_size(player)
    if light_size == 0 then return end

    local character = player.character
    if not character then return end
    storage.abyssal_light_cones[player.index] = rendering.draw_light {
        sprite = "utility/light_medium",
        scale = light_size * 0.6 + 5.5,
        target = character,
        surface = character.surface_index,
        players = {player},
        intensity = 1,
        color = {r = 1, g = 0.8, b = 0.6},
        minimum_darkness = 0.5,
    }
end

---does the same thing as swap_diving_gear_to_correct_prototype, but only for one equipment
local function swap_diving_gear(grid, player, equipment)
    local equipment_name = equipment.name
    local position = equipment.position
    local quality = equipment.quality.name
    local target
    if not maraxsis_constants.MARAXSIS_SURFACES[player.physical_surface.name] then
        if equipment_name:match("%-disabled$") then return end
        target = equipment_name .. "-disabled"
    else
        target = equipment_name:gsub("%-disabled$", "")
        if target == equipment_name then return end
    end

    assert(is_abyssal_diving_gear[target], "invalid target equipment: " .. target)

    local energy = equipment.energy
    grid.take {equipment = equipment}
    local new_equipment = grid.put {name = target, position = position, quality = quality}
    new_equipment.energy = energy
end

local function swap_diving_gear_to_correct_prototype(grid, player)
    for _, equipment in pairs(grid.equipment) do
        if is_abyssal_diving_gear[equipment.name] then
            swap_diving_gear(grid, player, equipment)
        end
    end
end

maraxsis.on_event({
    defines.events.on_player_changed_surface,
    defines.events.on_player_armor_inventory_changed,
    defines.events.on_player_created,
}, function(event)
    local player = game.get_player(event.player_index)
    update_abyssal_light_cone(player)
    local character = player.character
    if not character or not character.grid then return end
    swap_diving_gear_to_correct_prototype(character.grid, player)
end)

maraxsis.on_event(defines.events.on_equipment_inserted, function(event)
    local equipment = event.equipment
    if not equipment.valid or not is_abyssal_diving_gear[equipment.name] then return end
    local grid = event.grid
    if not grid.valid then return end

    for _, player in pairs(game.players) do
        local armor = player.get_inventory(defines.inventory.character_armor)
        if not armor then goto continue end
        for i = 1, #armor do
            local stack = armor[i]
            if stack.valid_for_read and stack.is_armor and stack.grid == grid then
                swap_diving_gear(grid, player, equipment)
            end
        end
        ::continue::
        update_abyssal_light_cone(player)
    end
end)

maraxsis.on_event({defines.events.on_equipment_removed, defines.events.on_player_controller_changed}, function(event)
    for _, player in pairs(game.players) do
        update_abyssal_light_cone(player)
    end
end)



--#region Maraxsis remote interfaces
---The given source will add the given value to light radius or other maraxsis modifiers.
---@param source_key string A unique string to allow overwriting the previous source of a modifier.
---@param modifier_type string string tied to the type of parameter to control. See relevant dic
---@param modifier double The actual bonus value to be added
local function set_modifier(source_key, modifier_type, modifier)
    init()
    local modifier_list = storage.external_modifiers[modifier_type]
    assert(modifier_list, "Invalid modifier type for Maraxsis: " .. modifier_type)

    if modifier and modifier ~= 0 then
        modifier_list[source_key] = modifier --Told to have a modifier
    else
        modifier_list[source_key] = nil --Told to remove modifier
    end

    --Update the base value from scratch
    local base_value = 0
    for _, entry in pairs(modifier_list) do
        base_value = base_value + entry
    end

    --In case anyone gets spicey with negatives. >:(
    if base_value < 0 then base_value = 0 end

    storage.base_character_values[modifier_type] = base_value
    for _, player in pairs(game.players) do
        update_abyssal_light_cone(player)
    end
end

--Define the interface to modify underwater parameters
remote.add_interface("maraxsis-character-modifier",{
    set_light_radius_modifier = function(source_key, modifier) set_modifier(source_key, "light_radius", modifier) end,
    set_swim_speed_modifier =   function(source_key, modifier) set_modifier(source_key, "swim_speed", modifier) end,
})
--#endregion
