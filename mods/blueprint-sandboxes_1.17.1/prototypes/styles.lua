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

data.raw["gui-style"]["default"][BPSB.pfx .. "sprite-like-tool-button"] = {
    type = "image_style",
    parent = "image",
    natural_size = 28,
    stretch_image_to_widget_size = true,
}
