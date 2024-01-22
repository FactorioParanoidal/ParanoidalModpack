-- Copyright (C) 2022  veden

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.


if guiG then
    return guiG
end

-- imports

local constants = require("Constants")
local processRecord = require("libs/ProcessRecord")

-- constants

local TICKS_PER_FIVE_HOURS = constants.TICKS_PER_FIVE_HOURS
local TICKS_PER_MINUTE = constants.TICKS_PER_MINUTE
local TICKS_PER_HOUR = constants.TICKS_PER_HOUR

local POLLUTION_TO_PERCENTAGE = constants.POLLUTION_TO_PERCENTAGE

-- import functions

local recordSelection = processRecord.recordSelection
local getResearch = constants.getResearch
local roundToNearest = constants.roundToNearest
local mMin = math.min
local calculateLowFailure = constants.calculateLowFailure
local calculateHighFailure = constants.calculateHighFailure
local calculateLowCooldown = constants.calculateLowCooldown
local calculateHighCooldown = constants.calculateHighCooldown
local calculateLowDowntime = constants.calculateLowDowntime
local calculateHighDowntime = constants.calculateHighDowntime
local calculateLowDamage = constants.calculateLowDamage
local calculateHighDamage = constants.calculateHighDamage

-- module code

local gui = {}

local function convertToTimeScale(v)
    local ts
    local suffix
    if v < TICKS_PER_FIVE_HOURS then
        ts = roundToNearest(v / TICKS_PER_MINUTE, 0.01)
        suffix = "(m)"
    else
        ts = roundToNearest(v / TICKS_PER_HOUR, 0.001)
        suffix = "(h)"
    end
    return tostring(ts) .. suffix
end

function gui.create(player, world)
    local guis = player.gui.screen.children
    for i=1,#guis do
        if guis[i].name == "rampant-maintenance--metrics" then
            return guis[i]
        end
    end
    local panel = player.gui.screen.add({
            type="frame",
            name="rampant-maintenance--metrics",
            direction="vertical",
            caption="Maintenance Metrics"
    })
    panel.auto_center = true
    local contentPanel = panel.add({type="frame", name="contentPanel", direction="horizontal"})
    local contents = contentPanel.add({type="table", name="contentTable", column_count=2})
    contents.draw_horizontal_lines = true
    contents.vertical_centering = true
    contents.add({
            type = "label",
            caption = {"description.rampant-maintenance--active-inactive"},
            tooltip = {"tooltip.rampant-maintenance--active-inactive"}
    })
    contents.add({
            type = "label",
            name = "ActiveInactiveValue"
    })

    contents.add({
            type = "label",
            caption = {"description.rampant-maintenance--breakdowns"},
            tooltip = {"tooltip.rampant-maintenance--breakdowns"}
    })
    contents.add({
            type = "label",
            name = "BreakdownValue"
    })

    contents.add({
            type = "label",
            caption = {"description.rampant-maintenance--mtbf-mttr"},
            tooltip = {"tooltip.rampant-maintenance--mtbf-mttr"}
    })
    contents.add({
            type = "label",
            name = "MTBFMTTRValue"
    })

    if world.useTileModifier then
        contents.add({
                type = "label",
                caption = {"description.rampant-maintenance--tile-modifier"},
                tooltip = {"tooltip.rampant-maintenance--tile-modifier"}
        })
        contents.add({
                type = "label",
                name = "TileModifierValue"
        })
    end

    if world.usePollutionModifier then
        contents.add({
                type = "label",
                caption = {"description.rampant-maintenance--pollution-modifier"},
                tooltip = {"tooltip.rampant-maintenance--pollution-modifier"}
        })
        contents.add({
                type = "label",
                name = "PollutionModifierValue"
        })
    end

    contents.add({
            type = "label",
            caption = {"description.rampant-maintenance--cooldown"},
            tooltip = {"tooltip.rampant-maintenance--cooldown"}
    })
    contents.add({
            type = "label",
            name = "CooldownModifierValue"
    })

    contents.add({
            type = "label",
            caption = {"description.rampant-maintenance--downtime"},
            tooltip = {"tooltip.rampant-maintenance--downtime"}
    })
    contents.add({
            type = "label",
            name = "DowntimeModifierValue"
    })

    contents.add({
            type = "label",
            caption = {"description.rampant-maintenance--damage"},
            tooltip = {"tooltip.rampant-maintenance--damage"}
    })
    contents.add({
            type = "label",
            name = "DamageModifierValue"
    })

    contents.add({
            type = "label",
            caption = {"description.rampant-maintenance--uptime"},
            tooltip = {"tooltip.rampant-maintenance--uptime"}
    })
    contents.add({
            type = "label",
            name = "UptimeValue"
    })

    return panel
end

function gui.close(world, playerIndex)
    local guiPanel = world.playerGuiOpen[playerIndex]
    if guiPanel then
        guiPanel.destroy()
        world.playerGuiOpen[playerIndex] = nil
    end
end

local function clearMetrics(guiPanel)
    local contentTable = guiPanel.contentPanel.contentTable
    contentTable.ActiveInactiveValue.caption = ""
    contentTable.BreakdownValue.caption = ""
    contentTable.MTBFMTTRValue.caption = ""
    contentTable.TileModifierValue.caption = ""
    contentTable.PollutionModifierValue.caption = ""
    contentTable.CooldownModifierValue.caption = ""
    contentTable.DowntimeModifierValue.caption = ""
    contentTable.DamageModifierValue.caption = ""
    contentTable.UptimeValue.caption = ""
end

function gui.update(world, playerId, entityRecord, tick)
    local guiPanel = world.playerGuiOpen[playerId]
    if guiPanel then
        if not entityRecord then
            clearMetrics(guiPanel)
            world.playerGuiTick[playerId] = nil
        else
            recordSelection(entityRecord, tick)
            if (world.playerEntity[playerId] ~= entityRecord.eU) then
                clearMetrics(guiPanel)
                world.playerGuiTick[playerId] = nil
            elseif world.playerGuiTick[playerId] and ((tick - world.playerGuiTick[playerId]) < 300) then
                return
            else
                world.playerGuiTick[playerId] = tick
            end
            world.playerEntity[playerId] = entityRecord.eU
            local contentTable = guiPanel.contentPanel.contentTable
            local entity = entityRecord.e
            local mttr = 0
            local mtbf = entityRecord["u"]
            if entityRecord["fC"] ~= 0 then
                mttr = (entityRecord["d"] / entityRecord["fC"])
                mtbf = (mtbf / entityRecord["fC"])
            end
            local uptimeDenominator = (mttr + mtbf)
            local uptime
            if uptimeDenominator ~= 0 then
                uptime = tostring(roundToNearest((mtbf / uptimeDenominator) * 100, 0.1)).."%"
            else
                uptime = tostring(100).."%"
            end
            local uptimeDuration = convertToTimeScale(entityRecord["u"])
            local downtimeDuration = convertToTimeScale(entityRecord["d"])
            local mtbfDuration = convertToTimeScale(mtbf)
            local mttrDuration = convertToTimeScale(mttr)
            local pollutionModifier
            local maxPollutionModifier
            local tileModifier
            local baseTileModifier
            local totalTileModifier
            local entityForceName = entity.force.name
            if world.useTileModifier then
                tileModifier = entityRecord["tM"]
                baseTileModifier = roundToNearest(entityRecord["t"], 0.01)
                totalTileModifier = tostring(
                    roundToNearest(entityRecord["t"] + entityRecord["tM"] + getResearch(entity.force.name, world, "tile"), 0.01) * 100
                ) .. "%"
            end
            if world.usePollutionModifier then
                local maxPollution = roundToNearest(entityRecord.p * getResearch(entityForceName, world, "pollution"), 0.01)
                maxPollutionModifier = tostring(maxPollution*100).."%"
                pollutionModifier = tostring(roundToNearest(mMin(entity.surface.get_pollution(entity.position) * POLLUTION_TO_PERCENTAGE,
                                                                 maxPollution) * 100, 0.01)).."%"
            end
            local healthPercent = entity.get_health_ratio()
            local invertedHealthPercent = 1 - healthPercent

            contentTable.ActiveInactiveValue.caption = {
                "description.rampant-maintenance--metric-popup2",
                uptimeDuration,
                downtimeDuration
            }
            contentTable.BreakdownValue.caption = {
                "description.rampant-maintenance--metric-popup3",
                entityRecord["fC"],
                tostring(
                    roundToNearest(
                        calculateLowFailure(world, entityRecord, invertedHealthPercent) * 100,
                        0.01
                    )
                ).."%",
                tostring(
                    roundToNearest(
                        calculateHighFailure(world, entityRecord, invertedHealthPercent) * 100,
                        0.01
                    )
                ).."%"
            }
            contentTable.MTBFMTTRValue.caption = {
                "description.rampant-maintenance--metric-popup2",
                mtbfDuration,
                mttrDuration
            }
            contentTable.TileModifierValue.caption = {
                "description.rampant-maintenance--metric-popup3",
                tostring(baseTileModifier * 100).."%",
                tostring(tileModifier * 100).."%",
                totalTileModifier
            }
            contentTable.PollutionModifierValue.caption = {
                "description.rampant-maintenance--metric-popup2",
                pollutionModifier,
                maxPollutionModifier
            }
            contentTable.CooldownModifierValue.caption = {
                "description.rampant-maintenance--metric-popup2",
                tostring(
                    roundToNearest(
                        calculateLowCooldown(world, entityRecord, healthPercent) / TICKS_PER_MINUTE,
                        0.01
                    )
                ).."(m)",
                tostring(
                    roundToNearest(
                        calculateHighCooldown(world, entityRecord, healthPercent) / TICKS_PER_MINUTE,
                        0.01
                    )
                ).."(m)"
            }
            contentTable.DowntimeModifierValue.caption = {
                "description.rampant-maintenance--metric-popup2",
                tostring(
                    roundToNearest(
                        calculateLowDowntime(world, entityRecord, invertedHealthPercent) / TICKS_PER_MINUTE,
                        0.01
                    )
                ).."(m)",
                tostring(
                    roundToNearest(
                        calculateHighDowntime(world, entityRecord, invertedHealthPercent) / TICKS_PER_MINUTE,
                        0.01
                    )
                ).."(m)"
            }
            contentTable.DamageModifierValue.caption = {
                "description.rampant-maintenance--metric-popup3",
                tostring(
                    roundToNearest(
                        calculateLowDamage(world, entityRecord, invertedHealthPercent),
                        0.01
                    ) * 100
                ).."%",
                tostring(
                    roundToNearest(
                        calculateHighDamage(world, entityRecord, invertedHealthPercent),
                        0.01
                    ) * 100
                ).."%",
                tostring(
                    getResearch(entityForceName, world, "energy") * 100
                ).."%"
            }
            contentTable.UptimeValue.caption = {
                "description.rampant-maintenance--metric-popup2",
                uptime,
                convertToTimeScale(entityRecord.c - tick)
            }
        end
    end
end

guiG = gui
return gui
