-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

if not (reskins.bobs and reskins.bobs.triggers.modules.items) then return end

-- Intermediates, courtesy of Maxi (mxcop).
-- https://github.com/mxcop/maxi-reskins/tree/main

local intermediate_inputs = {
    directory = reskins.bobs.directory,
    mod = "bobs",
    group = "modules",
    make_icon_pictures = false,
    flat_icon = true,
}

-- Setup input defaults
reskins.lib.parse_inputs(intermediate_inputs)

-- Host for item icon instructions.
local items = {
    ["module-contact"] = { subgroup = "intermediates" },
    ["module-processor-board"] = { subgroup = "intermediates" },
    ["module-processor-board-2"] = { subgroup = "intermediates" },
    ["module-processor-board-3"] = { subgroup = "intermediates" },
}

local tools = {
    ["module-case"] = { subgroup = "intermediates" },
    ["module-circuit-board"] = { subgroup = "intermediates" },
}

local intermediates_map = {
    ["speed"] = { color = "blue" },
    ["effectivity"] = { color = "yellow" },
    ["productivity"] = { color = "red" },
    ["pollution-create"] = { color = "brown" },
    ["pollution-clean"] = { color = "green" },
}

for name, map in pairs(intermediates_map) do
    tools[name .. "-processor"] = { subgroup = "intermediates/" .. map.color, image = map.color .. "-processor" }
    items[name .. "-processor-2"] = { subgroup = "intermediates/" .. map.color, image = map.color .. "-processor-2" }
    items[name .. "-processor-3"] = { subgroup = "intermediates/" .. map.color, image = map.color .. "-processor-3" }
end

reskins.lib.create_icons_from_list(items, intermediate_inputs)
reskins.lib.create_icons_from_list(tools, intermediate_inputs)

-- When Bob's module research is a thing, the type changes.
local tool_inputs = util.copy(intermediate_inputs)
tool_inputs.type = "tool"
reskins.lib.create_icons_from_list(tools, tool_inputs)