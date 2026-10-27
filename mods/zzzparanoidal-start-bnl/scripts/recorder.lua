-- Flight recorder decoding (research "bnl-flight-recorder-decoding", the recorder is its only
-- ingredient): the flight log of the "Axiom-7" goes to the BnL journal, the beacons of the trail get
-- their names, the previous expedition is charted, the captain's safe code (B and N) is written
-- down, and BnL "retraining materials" arrive as red science packs.
local config = require("bnl-config")
local util = require("scripts.util")
local journal = require("scripts.journal")
local trail = require("scripts.trail")
local events = require("scripts.events")
local tags = require("scripts.tags")
local geology = require("scripts.geology")
local goals = require("scripts.goals")
local safe = require("scripts.safe")
local M = {}

local TECH = "bnl-flight-recorder-decoding"
local PACK = "automation-science-pack"

local function give_packs(force, count)
    local players = force.connected_players
    if not players[1] then players = force.players end
    if not players[1] then return end
    local each = math.floor(count / #players)
    local extra = count - each * #players
    for i, player in ipairs(players) do
        local n = each + (i <= extra and 1 or 0)
        if n > 0 then
            local inserted = player.insert({name = PACK, count = n})
            if inserted < n and player.character then
                player.surface.spill_item_stack({position = player.character.position, stack = {name = PACK, count = n - inserted},
                    enable_looted = true, allow_belts = false})
            end
        end
    end
end

local function on_research_finished(event)
    local research = event.research
    if research.name ~= TECH or not storage.bnl then return end
    local s = storage.bnl
    if s.recorder_done then return end
    s.recorder_done = true
    local force = research.force
    for i = 1, 6 do journal.add("flight-log-" .. i, nil, {silent = i > 1}) end
    local code = s.safe and s.safe.code
    if code then journal.add("flight-log-safe", {code[1], code[2]}, {silent = true}) end
    local packs = util.int(config.recorder.packs)
    if prototypes.item[PACK] then give_packs(force, packs) end
    journal.add("flight-log-reward", {packs}, {open = true})
    tags.remove("recorder")
    trail.reveal()
    geology.reveal()
    goals.refresh()
    goals.wake()
    safe.wake()
end

events.on(defines.events.on_research_finished, on_research_finished)

return M
