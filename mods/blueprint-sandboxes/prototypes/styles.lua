data.raw["gui-style"]["default"][BPSB.pfx .. "toggle-frame"] = {
    type = "frame_style",
    parent = "frame",
    title_style = {
      type = "label_style",
      parent = "frame_title",
      font = "heading-2",
    },
    header_filler_style = {
      type = "empty_widget_style",
      horizontally_stretchable = "on",
      vertically_stretchable = "on",
    },
    horizontally_stretchable = "off",
}

data.raw["gui-style"]["default"][BPSB.pfx .. "shallow-semi-padded-frame"] = {
    type = "frame_style",
    parent = "inside_shallow_frame",
    padding = 8,
    horizontal_flow_style = {
        type = "horizontal_flow_style",
        parent = "horizontal_flow",
        horizontal_spacing = 6,
        vertical_align = "center",
    },
    vertical_flow_style = {
        type = "vertical_flow_style",
        parent = "vertical_flow",
        vertical_spacing = 6,
        horizontal_align = "center",
    },
}

data.raw["gui-style"]["default"][BPSB.pfx .. "tab-scroll-pane"] = {
    type = "scroll_pane_style",
    parent = "tab_scroll_pane",
    left_padding = 18,
    right_padding = 18,
    horizontal_flow_style = {
        type = "horizontal_flow_style",
        parent = "horizontal_flow",
        horizontal_spacing = 6,
    },
    vertical_flow_style = {
        type = "vertical_flow_style",
        parent = "vertical_flow",
        vertical_spacing = 12,
    },
}

data.raw["gui-style"]["default"][BPSB.pfx .. "padded-horizontal-flow"] = {
    type = "horizontal_flow_style",
    parent = "horizontal_flow",
    horizontal_spacing = 6,
}

data.raw["gui-style"]["default"][BPSB.pfx .. "centered-horizontal-flow"] = {
    type = "horizontal_flow_style",
    parent = BPSB.pfx .. "padded-horizontal-flow",
    vertical_align = "center",
}

data.raw["gui-style"]["default"][BPSB.pfx .. "sandbox-dropdown"] = {
    type = "dropdown_style",
    parent = "dropdown",
    minimal_width = 100,
}

data.raw["gui-style"]["default"][BPSB.pfx .. "daylight-slider"] = {
    type = "slider_style",
    parent = "notched_slider",
    minimal_width = 100,
}

data.raw["gui-style"]["default"][BPSB.pfx .. "drag-handle"] = {
    type = "empty_widget_style",
    parent = "draggable_space",
    height = 32,
    horizontally_stretchable = "on",
    right_margin = 4,
}

data.raw["gui-style"]["default"][BPSB.pfx .. "sprite-like-tool-button"] = {
    type = "image_style",
    parent = "image",
    natural_size = 28,
    stretch_image_to_widget_size = true,
}

data.raw["gui-style"]["default"][BPSB.pfx .. "left-padded-checkbox"] = {
    type = "checkbox_style",
    parent = "checkbox",
    left_margin = 8,
}

data.raw["gui-style"]["default"][BPSB.pfx .. "three-column-table"] = {
    type = "table_style",
    wide_as_column_count = true,
    margin = 8,
    column_alignments = {
        { -- property
            column = 1,
            alignment = "right",
        },
        { -- input
            column = 2,
            alignment = "center",
        },
        { -- unit
            column = 3,
            alignment = "left",
        },
    },
}

data.raw["gui-style"]["default"][BPSB.pfx .. "two-column-table"] = {
    type = "table_style",
    wide_as_column_count = true,
    margin = 8,
    column_alignments = {
        { -- property
            column = 1,
            alignment = "right",
        },
        { -- input
            column = 2,
            alignment = "left",
        },
    },
}

data.raw["gui-style"]["default"][BPSB.pfx .. "surface-property-description"] = {
    type = "label_style",
    single_line = false,
    maximal_width = 300,
}