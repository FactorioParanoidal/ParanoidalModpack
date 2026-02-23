--
-- constants
--

local settings = require('scripts.settings')

---@generic K
---@param t {[uint]: K}
---@return {[K]: true}
local function array_to_dict(t)
    local t2 = {}
    for _, v in pairs(t) do t2[v] = true end
    return t2
end

local const = {
    array_to_dict = array_to_dict,

    api_name = 'PickerDollies',

    -- extension area in which to repair connections for loaders, beacons, cliffs and mining drills.
    grid_size = 32,

    -- Entity types that can not be moved even in cheat_mode.
    blacklist_types = array_to_dict {
        -- rails and train stuff
        'artillery-wagon', 'cargo-wagon', 'curved-rail-a', 'curved-rail-b', 'elevated-curved-rail-a', 'elevated-curved-rail-b', 'elevated-half-diagonal-rail',
        'elevated-straight-rail', 'fluid-wagon', 'half-diagonal-rail', 'legacy-curved-rail', 'legacy-straight-rail', 'locomotive', 'rail-chain-signal',
        'rail-ramp', 'rail-signal', 'rail-support', 'straight-rail', 'train-stop',
        -- robots
        'capture-robot', 'combat-robot', 'construction-robot', 'logistic-robot',
        -- rockets and space stuff
        'asteroid', 'cargo-bay', 'cargo-landing-pad', 'cargo-pod', 'rocket-silo-rocket', 'rocket-silo-rocket-shadow', 'space-platform-hub', 'thruster',
        -- belts and containers
        'linked-belt', 'temporary-container', 'underground-belt',
        -- environment
        'artillery-flare', 'beam', 'cliff', 'explosion', 'fire', 'fish', 'lightning', 'particle-source', 'plant', 'projectile', 'resource', 'sticker', 'stream', 'tree',
        -- internal stuff
        'arrow', 'deconstructible-tile-proxy', 'highlight-box', 'item-entity', 'item-request-proxy', 'smoke-with-trigger', 'speech-bubble', 'sticker', 'tile-ghost',
        -- misc
        'spider-leg',
    },

    -- Entity types that can only be moved in cheat_mode.
    whitelist_cheat_types = array_to_dict {
        'car', 'character', 'character-corpse', 'corpse', 'simple-entity', 'spider-vehicle',
    },

    -- Default entity names to blacklist from moving. Stored in global and can be modified by the user via interface.
    blacklist_names = array_to_dict { 'pumpjack', },

    -- Entities where "transporter mode" is supported.

    --- currently only 1x1 sized types. Underground belt is its own can of worms...
    ---@type table<string, epd.TransporterControl>
    whitelist_transporter_mode_types = {
        ['loader-1x1'] = {
            control_fields = { 'circuit_set_filters', 'circuit_read_transfers', 'circuit_enable_disable', 'connect_to_logistic_network', },
            control_objects = { 'circuit_condition', 'logistic_condition', },
            fields = { 'loader_type', 'loader_filter_mode', },
            filters = true,
        },
        ['transport-belt'] = {
            control_fields = { 'read_contents', 'read_contents_mode', 'circuit_enable_disable', 'connect_to_logistic_network', },
            control_objects = { 'circuit_condition', 'logistic_condition', },
        },
    },

    --- Default entity names with none-square bounding boxes. Stored in global and can be modified by the user via interface.
    oblong_names = {
        ['pump'] = 0.5,
        ['arithmetic-combinator'] = 0.5,
        ['decider-combinator'] = 0.5,
        ['selector-combinator'] = 0.5,
        -- ['recycler'] = 1 -- see https://forums.factorio.com/viewtopic.php?f=7&t=122949
    },

    input_to_direction = {
        ['dolly-move-north'] = defines.direction.north,
        ['dolly-move-east']  = defines.direction.east,
        ['dolly-move-south'] = defines.direction.south,
        ['dolly-move-west']  = defines.direction.west
    },

    oblong_diags = {
        [defines.direction.north] = defines.direction.northeast,
        [defines.direction.south] = defines.direction.northeast,
        [defines.direction.west]  = defines.direction.southwest,
        [defines.direction.east]  = defines.direction.southwest
    },

    belt_types = array_to_dict {
        'lane-splitter', 'linked-belt', 'loader', 'loader-1x1', 'splitter', 'transport-belt', 'underground-belt',
    },
}

if not settings.get_biter_move() then
    const.blacklist_names['captive-biter-spawner'] = true
    for _, type in pairs { 'segment', 'segmented-unit', 'unit', 'unit-spawner', } do
        const.whitelist_cheat_types[type] = true
    end
end

return const
