-- A non-electric presentation/circuit shell owns selection and placement.
-- The native loader keeps its original speed, transport lines and per-item electricity.
local defs = require("loader-definitions")
if not defs.enabled(mods, settings.startup) then return end
local empty = { filename = "__core__/graphics/empty.png", width = 1, height = 1 }
local directions = { "north", "east", "south", "west" }

local function frame(machine, mode, index)
    -- Loader output structures face opposite to belt-flow direction. A combinator
    -- does not perform that loader-specific reversal, so select the opposite frame.
    -- Keep the actual entity direction and moving belt unchanged.
    if mode == "output" then index = (index + 1) % 4 + 1 end
    local layers = {}
    local function add(sheet)
        local s = table.deepcopy(sheet)
        s.x = (index - 1) * s.width
        layers[#layers + 1] = s
    end
    add(machine.structure.back_patch.sheet)
    for _, sheet in ipairs(machine.structure["direction_" .. (mode == "input" and "in" or "out")].sheets) do add(sheet) end
    add(machine.structure.front_patch.sheet)
    return { layers = layers }
end

for i, name in ipairs(defs.names) do
    local machine = assert(data.raw.loader[name], name)
    local item = assert(data.raw.item[name], name)
    local out_name = defs.shell(name, "output")
    for _, mode in ipairs({ "input", "output" }) do
        -- Constant combinators have no energy source, are rotatable, support wires,
        -- blueprint connections and native fast replacement. They emit no signals here.
        local shell = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
        shell.name = defs.shell(name, mode)
        shell.localised_name = table.deepcopy(item.localised_name)
        shell.localised_description = table.deepcopy(item.localised_description)
        shell.custom_tooltip_fields = table.deepcopy(item.custom_tooltip_fields)
        -- Factoriopedia already displays the item's fields; selection tooltips still need them.
        for _, field in ipairs(shell.custom_tooltip_fields or {}) do field.show_in_factoriopedia = false end
        shell.icon = nil
        shell.icons = table.deepcopy(item.icons)
        -- Hidden entities cannot be upgrade-planner sources, including input shells.
        -- Keep both modes upgradeable; hide the presentation entries only in Factoriopedia.
        shell.hidden = false
        -- Factoriopedia merges entries only by identical name: the item is the single entry.
        shell.hidden_in_factoriopedia = true
        shell.flags = { "placeable-neutral", "player-creation" }
        shell.minable = { mining_time = machine.minable.mining_time, result = name }
        shell.placeable_by = { item = name, count = 1 }
        shell.max_health = machine.max_health
        shell.resistances = table.deepcopy(machine.resistances)
        shell.collision_box = table.deepcopy(machine.collision_box)
        shell.selection_box = table.deepcopy(machine.selection_box)
        shell.collision_mask = table.deepcopy(machine.collision_mask
            or data.raw["utility-constants"].default.default_collision_masks.loader)
        -- The worker must collide with belts, but not with its own placement shell.
        -- Other original layers keep the shell's placement/passability restrictions.
        shell.collision_mask.layers.transport_belt = nil
        shell.fast_replaceable_group = "paranoidal-loader-shell"
        shell.next_upgrade = defs.names[i + 1] and defs.shell(defs.names[i + 1], "output") or nil
        shell.corpse = machine.corpse
        shell.dying_explosion = machine.dying_explosion
        shell.open_sound = table.deepcopy(machine.open_sound)
        shell.close_sound = table.deepcopy(machine.close_sound)
        shell.subgroup, shell.order = item.subgroup, item.order
        shell.sprites = {}
        shell.activity_led_sprites = table.deepcopy(empty)
        shell.activity_led_light = { intensity = 0, size = 0 }
        shell.circuit_wire_max_distance = machine.circuit_wire_max_distance
        shell.circuit_wire_connection_points = {}
        for index, direction in ipairs(directions) do
            shell.sprites[direction] = frame(machine, mode, index)
            local connector_index = index + (mode == "input" and 4 or 0)
            shell.circuit_wire_connection_points[index] = table.deepcopy(machine.circuit_connector[connector_index].points)
        end
        data:extend({ shell })
    end
    item.place_result = out_name
    -- Item tooltips include place_result's fields. Keep the item's copy only for
    -- Factoriopedia, after both shells have copied the visible tooltip fields.
    for _, field in ipairs(item.custom_tooltip_fields or {}) do field.show_in_tooltip = false end
    -- Never expose the working energy source through an item or selectable entity.
    machine.hidden = true
    machine.hidden_in_factoriopedia = true
    machine.selectable_in_game = false
    machine.flags = { "placeable-off-grid", "not-on-map", "not-blueprintable", "not-deconstructable", "not-upgradable" }
    machine.minable = nil
    machine.next_upgrade = nil
    machine.fast_replaceable_group = nil
    -- Factorio validates collisions between loaders and other belt-connectable types.
    machine.collision_mask = { layers = { transport_belt = true } }
    machine.structure = { direction_in = table.deepcopy(empty), direction_out = table.deepcopy(empty) }
    machine.draw_circuit_wires = false
    machine.draw_copper_wires = false
    machine.corpse = nil
    machine.dying_explosion = nil
end
