local SurfacePropsGUI = {}

SurfacePropsGUI.name = BPSB.pfx .. "surface-props-gui"
SurfacePropsGUI.pfx = SurfacePropsGUI.name .. "-"

SurfacePropsGUI.dayNightTab = SurfacePropsGUI.pfx .. "day-night-tab"
SurfacePropsGUI.forcedDaytimeCheckbox = SurfacePropsGUI.pfx .. "forced-daytime"
SurfacePropsGUI.daytimeSlider = SurfacePropsGUI.pfx .. "daytime-slider"

SurfacePropsGUI.propertyTab = SurfacePropsGUI.pfx .. "property-tab"
SurfacePropsGUI.propertyIgnored = SurfacePropsGUI.pfx .. "property-ignore-conditions"
SurfacePropsGUI.propertyPresets = {}
SurfacePropsGUI.propertyPresetDefault = SurfacePropsGUI.pfx .. "property-preset-default"
SurfacePropsGUI.propertyPresetDropDown = SurfacePropsGUI.pfx .. "property-preset-drop-down"
SurfacePropsGUI.propertyPresetReset = SurfacePropsGUI.pfx .. "property-preset-reset"
SurfacePropsGUI.propertyTable = SurfacePropsGUI.pfx .. "property-table"
SurfacePropsGUI.propertyTag = SurfacePropsGUI.pfx .. "property"
SurfacePropsGUI.propertiesWithNoRuntimeEffect = {
    ["solar-power"] = true,
    ["day-night-cycle"] = true,
}

SurfacePropsGUI.miscTab = SurfacePropsGUI.pfx .. "miscellaneous-tab"
SurfacePropsGUI.globalElectricNetworkCheckbox = SurfacePropsGUI.pfx .. "global-eletric-network-checkbox"
SurfacePropsGUI.equipmentBlueprintInput = SurfacePropsGUI.pfx .. "equipment-blueprint-input"
SurfacePropsGUI.equipmentBlueprintTag = SurfacePropsGUI.pfx .. "equipment-blueprint"

SurfacePropsGUI.cancel = SurfacePropsGUI.pfx .. "cancel"
SurfacePropsGUI.confirm = SurfacePropsGUI.pfx .. "confirm"

function SurfacePropsGUI.InitPresets()
    local function addPropertyValues(preset, source)
        for propId, prop in pairs(prototypes.surface_property) do
            if not SurfacePropsGUI.propertiesWithNoRuntimeEffect[propId] then
                preset.propValues[propId] = source[propId] or prop.default_value
            end
        end
    end

    local defaults = {
        name = { "gui." .. SurfacePropsGUI.propertyPresetDefault },
        propValues = {},
    }
    addPropertyValues(defaults, {})
    table.insert(SurfacePropsGUI.propertyPresets, defaults)

    for _, location in pairs(prototypes.space_location) do
        if not location.hidden and location.surface_properties then
            local preset = {
                name = {
                    "",
                    "[img=space-location/" .. location.name .. "]",
                    " ",
                    location.localised_name,
                },
                propValues = {},
            }
            addPropertyValues(preset, location.surface_properties)
            table.insert(SurfacePropsGUI.propertyPresets, preset)
        end
    end

    for _, surface in pairs(prototypes.surface) do
        if not surface.hidden and surface.surface_properties then
            local preset = {
                name = {
                    "",
                    "[img=surface/" .. surface.name .. "]",
                    " ",
                    surface.localised_name,
                },
                propValues = {},
            }
            addPropertyValues(preset, surface.surface_properties)
            table.insert(SurfacePropsGUI.propertyPresets, preset)
        end
    end
end

---@param player LuaPlayer
function SurfacePropsGUI.IsOpen(player)
    if player.gui.screen[SurfacePropsGUI.name] then
        return true
    end
    return false
end

---@param pane LuaGuiElement
---@param surface LuaSurface
local function AddDayNightTab(pane, surface)
    local tab = pane.add {
        type = "tab",
        caption = { "gui." .. SurfacePropsGUI.dayNightTab }
    }

    local innerFrame = pane.add {
        type = "scroll-pane",
        direction = "vertical",
        style = BPSB.pfx .. "tab-scroll-pane",
    }

    local daylightFlow = innerFrame.add {
        type = "flow",
        direction = "horizontal",
        style = BPSB.pfx .. "centered-horizontal-flow",
    }

    daylightFlow.add {
        type = "checkbox",
        name = SurfacePropsGUI.forcedDaytimeCheckbox,
        caption = { "gui." .. SurfacePropsGUI.daytimeSlider },
        tooltip = { "gui." .. SurfacePropsGUI.forcedDaytimeCheckbox },
        state = surface.freeze_daytime,
    }

    daylightFlow.add {
        type = "slider",
        name = SurfacePropsGUI.daytimeSlider,
        value = surface.daytime,
        minimum_value = 0.5,
        maximum_value = 0.975,
        value_step = 0.025,
        style = "notched_slider",
    }.style.horizontally_stretchable = true

    pane.add_tab(tab, innerFrame)
end

---@param pane LuaGuiElement
---@param surface LuaSurface
local function AddSurfacePropertiesTab(pane, surface)
    local tab = pane.add {
        type = "tab",
        caption = { "gui." .. SurfacePropsGUI.propertyTab }
    }

    local paneFlow = pane.add {
        type = "flow",
        direction = "vertical",
    }

    local planetPresetFlow = paneFlow.add {
        type = "frame",
        direction = "horizontal",
        style = "subheader_frame",
    }
    planetPresetFlow.style.horizontally_stretchable = true
    planetPresetFlow.add { type = "empty-widget" }.style.horizontally_stretchable = true

    planetPresetFlow.add {
        type = "label",
        caption = { "gui." .. SurfacePropsGUI.propertyPresetDropDown },
        style = "caption_label",
    }

    local planetPresetItems = {}
    for _, preset in pairs(SurfacePropsGUI.propertyPresets) do
        table.insert(planetPresetItems, preset.name)
    end
    planetPresetFlow.add {
        type = "drop-down",
        name = SurfacePropsGUI.propertyPresetDropDown,
        items = planetPresetItems,
        tooltip = { "gui-description." .. SurfacePropsGUI.propertyPresetDropDown },
    }

    planetPresetFlow.add {
        type = "sprite-button",
        name = SurfacePropsGUI.propertyPresetReset,
        tooltip = { "gui-description." .. SurfacePropsGUI.propertyPresetReset },
        style = "tool_button_red",
        sprite = "utility/reset",
    }

    local innerFrame = paneFlow.add {
        type = "scroll-pane",
        direction = "vertical",
        style = BPSB.pfx .. "tab-scroll-pane",
    }

    innerFrame.add {
        type = "checkbox",
        name = SurfacePropsGUI.propertyIgnored,
        caption = { "gui." .. SurfacePropsGUI.propertyIgnored },
        tooltip = { "gui-description." .. SurfacePropsGUI.propertyIgnored },
        state = surface.ignore_surface_conditions,
    }

    innerFrame.add {
        type = "label",
        caption = { "gui-description." .. SurfacePropsGUI.name },
        style = BPSB.pfx .. "surface-property-description",
    }

    local propertiesTable = innerFrame.add {
        type = "table",
        name = SurfacePropsGUI.propertyTable,
        column_count = 3,
        style = BPSB.pfx .. "three-column-table",
    }

    for propId, prop in pairs(prototypes.surface_property) do
        if not prop.hidden and not SurfacePropsGUI.propertiesWithNoRuntimeEffect[propId] then
            propertiesTable.add {
                type = "label",
                caption = { "", prop.localised_name, ":" },
                style = "semibold_caption_label"
            }

            propertiesTable.add {
                type = "textfield",
                text = tostring(surface.get_property(propId)),
                numeric = true,
                allow_decimal = true,
                style = "short_number_textfield",
                tags = { [SurfacePropsGUI.propertyTag] = propId }
            }

            propertiesTable.add {
                type = "label",
                caption = { "surface-property-unit." .. propId, "" },
            }
        end
    end

    pane.add_tab(tab, paneFlow)
end

---@param pane LuaGuiElement
---@param surface LuaSurface
local function AddMiscTab(pane, surface)
    local tab = pane.add {
        type = "tab",
        caption = { "gui." .. SurfacePropsGUI.miscTab }
    }

    local innerFrame = pane.add {
        type = "scroll-pane",
        direction = "vertical",
        style = BPSB.pfx .. "tab-scroll-pane",
    }

    local globalElectricNetworkFlow = innerFrame.add {
        type = "flow",
        direction = "horizontal",
        style = BPSB.pfx .. "centered-horizontal-flow",
    }

    globalElectricNetworkFlow.add {
        type = "checkbox",
        name = SurfacePropsGUI.globalElectricNetworkCheckbox,
        caption = { "gui." .. SurfacePropsGUI.globalElectricNetworkCheckbox },
        tooltip = { "gui-description." .. SurfacePropsGUI.globalElectricNetworkCheckbox },
        state = surface.has_global_electric_network,
    }

    innerFrame.add {
        type = "line",
    }

    local equipmentBlueprintFlow = innerFrame.add {
        type = "flow",
        direction = "horizontal",
        style = BPSB.pfx .. "centered-horizontal-flow",
    }

    equipmentBlueprintFlow.add {
        type = "label",
        caption = { "gui." .. SurfacePropsGUI.equipmentBlueprintInput },
        tooltip = { "gui-description." .. SurfacePropsGUI.equipmentBlueprintInput },
    }

    local currentBlueprintString = Lab.GetEquipmentBlueprint(surface)
    equipmentBlueprintFlow.add {
        type = "sprite-button",
        name = SurfacePropsGUI.equipmentBlueprintInput,
        sprite = "item/blueprint",
        tooltip = { "gui-description." .. SurfacePropsGUI.equipmentBlueprintInput },
        toggled = currentBlueprintString ~= Lab.equipmentString,
        tags = { [SurfacePropsGUI.equipmentBlueprintTag] = currentBlueprintString },
    }

    pane.add_tab(tab, innerFrame)
end

---@param player LuaPlayer
function SurfacePropsGUI.Init(player)
    if SurfacePropsGUI.IsOpen(player) then
        return
    end

    local surface = player.surface

    local frame = player.gui.screen.add {
        type = "frame",
        name = SurfacePropsGUI.name,
        caption = { "gui." .. SurfacePropsGUI.name },
        visible = true,
        direction = "vertical",
    }

    local innerFrame = frame.add {
        type = "frame",
        direction = "vertical",
        style = "inside_deep_frame",
    }

    local tabs = innerFrame.add {
        type = "tabbed-pane",
        style = "tabbed_pane_with_no_side_padding",
    }
    AddDayNightTab(tabs, surface)
    AddSurfacePropertiesTab(tabs, surface)
    AddMiscTab(tabs, surface)

    local actionsFlow = frame.add {
        type = "flow",
        style = "dialog_buttons_horizontal_flow",
    }

    actionsFlow.add {
        type = "button",
        name = SurfacePropsGUI.cancel,
        style = "back_button",
        caption = { "gui.cancel" },
        tags = { action = SurfacePropsGUI.cancel },
    }

    actionsFlow.add {
        type = "empty-widget",
        style = BPSB.pfx .. "drag-handle",
    }.drag_target = frame

    actionsFlow.add {
        type = "button",
        name = SurfacePropsGUI.confirm,
        style = "confirm_button",
        caption = { "gui.confirm" },
        tags = { action = SurfacePropsGUI.confirm },
    }

    player.opened = frame
end

---@param player LuaPlayer
function SurfacePropsGUI.Destroy(player)
    if not SurfacePropsGUI.IsOpen(player) then
        return
    end
    player.gui.screen[SurfacePropsGUI.name].destroy()
end

function SurfacePropsGUI.FindDescendantByName(instance, name)
    for _, child in pairs(instance.children) do
        if child.name == name then
            return child
        end
        local found = SurfacePropsGUI.FindDescendantByName(child, name)
        if found then return found end
    end
end

---@param player LuaPlayer
---@return LuaGuiElement | nil
function SurfacePropsGUI.FindByName(player, name)
    if not SurfacePropsGUI.IsOpen(player) then
        return
    end
    return SurfacePropsGUI.FindDescendantByName(player.gui.screen[SurfacePropsGUI.name], name)
end

---@param player LuaPlayer
function SurfacePropsGUI.LoadPreset(player)
    if not SurfacePropsGUI.IsOpen(player) then
        log("Cannot import Surface Properties without an open GUI")
        return
    end

    local propertiesTable = SurfacePropsGUI.FindByName(player, SurfacePropsGUI.propertyTable)
    if not propertiesTable then
        log("Cannot import Surface Properties without an open GUI")
        return
    end

    local planetIndex = SurfacePropsGUI.FindByName(player, SurfacePropsGUI.propertyPresetDropDown).selected_index
    if not planetIndex then
        log("Cannot import Surface Properties without a selected preset")
        return
    end

    local preset = SurfacePropsGUI.propertyPresets[planetIndex]
    if not preset then
        log("Cannot import Surface Properties without a matching preset")
        return
    end

    for _, child in pairs(propertiesTable.children) do
        local propId = child.tags[SurfacePropsGUI.propertyTag] --[[@as string]]
        if propId then
            local presetPropValue = preset.propValues[propId]
            child.text = tostring(presetPropValue)
        end
    end
end

---@param player LuaPlayer
function SurfacePropsGUI.Apply(player)
    if not SurfacePropsGUI.IsOpen(player) then
        log("Cannot apply Surface Properties without an open GUI")
        return
    end

    local sandboxSurface = player.surface
    if not Lab.IsLab(sandboxSurface) then
        log("Cannot apply Surface Properties outside of a Sandbox")
        return
    end

    local forcedDaytime = SurfacePropsGUI.FindByName(player, SurfacePropsGUI.forcedDaytimeCheckbox).state
    sandboxSurface.freeze_daytime = forcedDaytime

    local daytime = SurfacePropsGUI.FindByName(player, SurfacePropsGUI.daytimeSlider).slider_value
    sandboxSurface.daytime = daytime

    local ignoreSurfaceConditions = SurfacePropsGUI.FindByName(player, SurfacePropsGUI.propertyIgnored).state
    sandboxSurface.ignore_surface_conditions = ignoreSurfaceConditions

    local propertiesTable = SurfacePropsGUI.FindByName(player, SurfacePropsGUI.propertyTable)
    if not propertiesTable then
        log("Cannot apply Surface Properties without an open GUI")
        return
    end
    for _, child in pairs(propertiesTable.children) do
        local propId = child.tags[SurfacePropsGUI.propertyTag] --[[@as string]]
        if propId then
            local propValue = tonumber(child.text)
            if propValue ~= nil then
                sandboxSurface.set_property(propId, propValue)
            end
        end
    end

    local globalElectricNetwork = SurfacePropsGUI.FindByName(player, SurfacePropsGUI.globalElectricNetworkCheckbox).state
    if globalElectricNetwork then
        sandboxSurface.create_global_electric_network()
    else
        sandboxSurface.destroy_global_electric_network()
    end

    local equipmentBlueprintString = SurfacePropsGUI.FindByName(player, SurfacePropsGUI.equipmentBlueprintInput).tags[SurfacePropsGUI.equipmentBlueprintTag]
    Lab.SetEquipmentBlueprint(sandboxSurface, equipmentBlueprintString)
end

---@param event EventData.on_gui_selection_state_changed
function SurfacePropsGUI.OnGuiDropdown(event)
    local player = game.players[event.player_index]
    if event.element.name == SurfacePropsGUI.propertyPresetDropDown then
        SurfacePropsGUI.LoadPreset(player)
        local reset = SurfacePropsGUI.FindByName(player, SurfacePropsGUI.propertyPresetReset)
        if reset and reset.enabled == false then
            reset.enabled = true
        end
    end
end

---@param event EventData.on_gui_click
function SurfacePropsGUI.OnGuiClick(event)
    local player = game.players[event.player_index]
    if event.element.name == SurfacePropsGUI.cancel then
        SurfacePropsGUI.Destroy(player)
    elseif event.element.name == SurfacePropsGUI.confirm then
        SurfacePropsGUI.Apply(player)
        SurfacePropsGUI.Destroy(player)
    elseif event.element.name == SurfacePropsGUI.propertyPresetReset then
        SurfacePropsGUI.LoadPreset(player)
    elseif event.element.name == SurfacePropsGUI.equipmentBlueprintInput then
        if event.button == defines.mouse_button_type.right then
            event.element.tags = { [SurfacePropsGUI.equipmentBlueprintTag] = Lab.equipmentString }
            event.element.toggled = false
        else
            local blueprintString = Inventory.GetCursorBlueprintString(player)
            if blueprintString then
                event.element.tags = { [SurfacePropsGUI.equipmentBlueprintTag] = blueprintString }
                event.element.toggled = blueprintString ~= Lab.equipmentString
            else
                local equipmentString = event.element.tags[SurfacePropsGUI.equipmentBlueprintTag]
                player.cursor_stack.import_stack(equipmentString)
                player.cursor_stack_temporary = true
            end
        end
        return true
    end
end

return SurfacePropsGUI
