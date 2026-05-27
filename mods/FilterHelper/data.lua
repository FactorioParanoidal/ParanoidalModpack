local styles = data.raw["gui-style"].default

--TODO use styling mod
styles["fh_content_frame"] = {
    type = "frame_style",
    parent = "frame",
}

styles["fh_deep_frame"] = {
    type = "frame_style",
    parent = "slot_button_deep_frame",
    vertically_stretchable = "on",
    horizontally_stretchable = "on"
    -- top_margin = 16,
    -- left_margin = 8,
    -- right_margin = 8,
    -- bottom_margin = 4
}

-- In order to override the logic for an entity just add their name pointing to a remote interface in your own mod:
-- data.raw["mod-data"]["fh_add_items_hooks"].data.drop_target["assembling-machine-3"] = {"my_mod", "my_function"}
data:extend {
    {
        type = "mod-data",
        name = "fh_add_items_hooks",
        data = { drop_target = {}, pickup_target = {} },
    },
}
-- In your remote interface you will receive the entity. An array of items should be returned.
-- Items are allowed to be in several formats. See fh_util for details. Some examples are:
-- * Item name
-- * Item runtime prototype
-- * { name = <item name> }
-- * { name = <item name>, quality = <quality or quality name> }
-- Note: your mod becomes responsible for ALL suggestions for that entity, like burn results and spoilage.
