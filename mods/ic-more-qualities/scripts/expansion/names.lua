-- Prototype and signal names of the quality-control expansion. Shared by data and control stages.
local M = {
    workshop = "ic-refine-workshop",
    post = "ic-control-post",
    workshop_power = "ic-refine-workshop-power",
    drive = "ic-refine-workshop-drive",
    emitter = "ic-signal-emitter",
    mode_power_prefix = "ic-mode-power-",
    refine_recipe_prefix = "ic-refine-item-",
    refine_category = "ic-refine",
    repair_fuel = "ic-repair-resource",
    subgroup = "ic-quality-control",
    signal_subgroup = "ic-quality-signals",
    mod_data = "ic-quality-expansion",
    panel_shortcut = "ic-quality-panel",
    panel_hotkey = "ic-quality-panel",
    rotate = "ic-control-post-rotate",
    reverse_rotate = "ic-control-post-reverse-rotate",
    graphics = "__ic-more-qualities__/graphics/",
}

-- Virtual signals. Status signals are written by the mod, command signals are read.
M.signals = {
    -- Refinement workshop status.
    ws_working = "ic-ws-working",
    ws_progress = "ic-ws-progress",
    ws_grade = "ic-ws-grade",
    ws_resource = "ic-ws-resource",
    ws_need = "ic-ws-need",
    ws_no_resource = "ic-ws-no-resource",
    ws_no_item = "ic-ws-no-item",
    ws_output_full = "ic-ws-output-full",
    -- Control post / production order status.
    order_active = "ic-order-active",
    order_required = "ic-order-required",
    order_accepted = "ic-order-accepted",
    order_remaining = "ic-order-remaining",
    order_to_refine = "ic-order-to-refine",
    order_done = "ic-order-done",
    order_batches = "ic-order-batches",
    -- Commands (read from the circuit network when network control is enabled).
    cmd_start = "ic-cmd-start",
    cmd_pause = "ic-cmd-pause",
    cmd_stop = "ic-cmd-stop",
}

-- Item types that never get a refinement recipe: tools of the player, not products.
M.not_refinable_types = {
    ["repair-tool"] = true, blueprint = true, ["blueprint-book"] = true, ["deconstruction-item"] = true,
    ["upgrade-item"] = true, ["copy-paste-tool"] = true, ["selection-tool"] = true, ["spidertron-remote"] = true,
}

return M
