require "prototypes.factory"
require "prototypes.component"
require "prototypes.utility"
require "prototypes.recipe"
require "prototypes.technology"
require "prototypes.tile"
require "prototypes.borehole-pump"
require "prototypes.roboport"
require "prototypes.greenhouse"
require "prototypes.space-age-rebalance"
require "graphics.space-platform-build-anim.entity-build-animations"
require "compat.power-grid-comb"

data:extend {
    {
        type = "item-subgroup",
        name = "factorissimo2",
        group = "logistics",
        order = "e-e"
    },
    {
        type = "custom-input",
        name = "factory-rotate",
        key_sequence = "R",
        controller_key_sequence = "controller-rightstick"
    },
    {
        type = "custom-input",
        name = "factory-increase",
        key_sequence = "SHIFT + R",
        controller_key_sequence = "controller-dpright"
    },
    {
        type = "custom-input",
        name = "factory-decrease",
        key_sequence = "CONTROL + R",
        controller_key_sequence = "controller-dpleft"
    },
    {
        type = "custom-input",
        name = "factory-open-outside-surface-to-remote-view",
        key_sequence = "SHIFT + mouse-button-2",
        controller_key_sequence = "controller-leftstick"
    },
    {
        type = "custom-event",
        name = "on_script_setup_blueprint"
    },
}
