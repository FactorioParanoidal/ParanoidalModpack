local NO_FLUID_ON_THIS_SURFACE = -1

local BOREHOLE_PUMP_FIXED_RECIPES = {
    ["nauvis"] = "water",
    ["gleba"] = "water",
    ["vulcanus"] = "lava",
    ["fulgora"] = "heavy-oil",
    ["aquilo"] = "ammoniacal-solution",
    ["cerys"] = "water",
    ["maraxsis"] = "maraxsis-saline-water",
    ["maraxsis-trench"] = "lava",
    ["tenebris"] = "sulfuric-acid",
    ["muluna"] = NO_FLUID_ON_THIS_SURFACE,
    ["luna"] = NO_FLUID_ON_THIS_SURFACE,
    ["corrundum"] = "petroleum-gas",
    ["lignumis"] = "water",
    ["moshine"] = "molten-iron",
    ["aiur"] = "water",
    ["tiber"] = "water",
    ["arrakis"] = NO_FLUID_ON_THIS_SURFACE,
    ["char"] = "lava",
    ["terrapalus"] = "water",
    ["castra"] = "light-oil",
    ["janus"] = NO_FLUID_ON_THIS_SURFACE,
    ["nix"] = "dark-matter-fluid",
    ["cubium"] = "ultradense-lava",
    ["planet-dea-dia"] = NO_FLUID_ON_THIS_SURFACE,
    ["prosephina"] = "mineral-water",
    ["lemures"] = "lava",
    ["frozeta"] = NO_FLUID_ON_THIS_SURFACE,
    ["ringworld"] = NO_FLUID_ON_THIS_SURFACE,
    ["shipyard"] = "gray-goo",
    ["neo-nauvis"] = "water",
    ["electria"] = "water"
}
local BOREHOLE_PUMP_SMOKE_OFFSETS = {
    [defines.direction.north] = {-1.2, -2.1},
    [defines.direction.east] = {0.3, -2.2},
    [defines.direction.south] = {0, -2.2},
    [defines.direction.west] = {-2, -2},
}
local function get_borehole_smoke_position(borehole)
    local offset = BOREHOLE_PUMP_SMOKE_OFFSETS[borehole.direction]
    return {borehole.position.x + offset[1], borehole.position.y + offset[2]}
end

local function update_borehole_smokestacks()
    for unit_number, smokestack_data in pairs(storage.borehole_smokestacks or {}) do
        local borehole, smokestack = smokestack_data.borehole, smokestack_data.smokestack
        if not borehole.valid then
            if smokestack.valid then smokestack.destroy() end
            storage.borehole_smokestacks[unit_number] = nil
            update_borehole_smokestacks()
            return
        elseif not smokestack.valid and borehole.energy > 0 and borehole.is_crafting() and borehole.crafting_progress ~= 1 then
            smokestack_data.smokestack = borehole.surface.create_entity {
                name = "borehole-pump-smokestack",
                position = get_borehole_smoke_position(borehole),
                force = borehole.force_index
            }
        end
    end
end

factorissimo.on_nth_tick(33, update_borehole_smokestacks)

factorissimo.on_event(factorissimo.events.on_built(), function(event)
    local borehole = event.entity
    if not borehole.valid or borehole.name ~= "borehole-pump" then return end

    local surface = borehole.surface
    local parent_planet_name = surface.name:gsub("%-factory%-floor$", "")
    local parent_planet = game.planets[parent_planet_name]
    if not parent_planet then return end
    local fixed_recipe = BOREHOLE_PUMP_FIXED_RECIPES[parent_planet_name]
    if not fixed_recipe then return end

    if fixed_recipe == NO_FLUID_ON_THIS_SURFACE then
        factorissimo.cancel_creation(borehole, event.player_index, {"factory-connection-text.borehole-pump-no-fluid"})
        return
    end

    borehole.set_recipe("borehole-pump-" .. fixed_recipe)
    borehole.recipe_locked = true

    local smokestack = surface.create_entity {
        name = "borehole-pump-smokestack",
        position = get_borehole_smoke_position(borehole),
        force = borehole.force_index
    }
    smokestack.destroy() -- Instantly destroy the first smokestack. This handles the case when the borehole is initally unpowered.

    storage.borehole_smokestacks = storage.borehole_smokestacks or {}
    storage.borehole_smokestacks[borehole.unit_number] = {borehole = borehole, smokestack = smokestack}
end)
