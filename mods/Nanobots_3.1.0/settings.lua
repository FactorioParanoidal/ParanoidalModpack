data:extend{
    {
        type = "bool-setting",
        name = "nanobots-nanobots-auto",
        setting_type = "runtime-global",
        default_value = true,
        order = "nanobots-aa[auto-bots-roll-out]-f"
    },
    {
        type = "bool-setting",
        name = "nanobots-nano-build-tiles",
        setting_type = "runtime-global",
        default_value = true,
        order = "nanobots-aa[build-tiles]-f"
    },
    {
        type = "bool-setting",
        name = "nanobots-network-limits",
        setting_type = "runtime-global",
        default_value = true,
        order = "nanobots-aa[check-networks]-f"
    },
    {
        type = "int-setting",
        name = "nanobots-nano-poll-rate",
        setting_type = "runtime-global",
        default_value = 60,
        maximum_value = 60*60*60,
        minimum_value = 1,
        order = "nanobots-ab[nano-poll-rate]-f"
    },
    {
        type = "int-setting",
        name = "nanobots-nano-queue-rate",
        setting_type = "runtime-global",
        default_value = 12,
        maximum_value = 60*60*60,
        minimum_value = 4,
        order = "nanobots-ac[nano-queue-rate]-f"
    },
    {
        type = "int-setting",
        name = "nanobots-nano-queue-per-cycle",
        setting_type = "runtime-global",
        default_value = 100,
        maximum_value = 800,
        minimum_value = 1,
        order = "nanobots-ad[nano-queue-rate]-f"
    },
    {
        type = "int-setting",
        name = "nanobots-cell-queue-rate",
        setting_type = "runtime-global",
        default_value = 5,
        maximum_value = 60*60*60,
        minimum_value = 1,
        order = "nanobots-ba[cell-queue-rate]-f"
    },
    {
        type = "int-setting",
        name = "nanobots-free-bots-per",
        setting_type = "runtime-global",
        default_value = 50,
        maximum_value = 100,
        minimum_value = 1,
        order = "nanobots-bb[free-bots-per]-f"
    },
    {
        type = "bool-setting",
        name = "nanobots-equipment-auto",
        setting_type = "runtime-global",
        default_value = true,
        order = "nanobots-bc[poll-rate]-f"
    }
}
