Muluna:extend{
    {type = "item-subgroup",
    name = "muluna-products",
    group = "intermediate-products",
    order="gdz[muluna-products]",
    hide_from_signal_gui = false,
    },
    {type = "item-subgroup",
    name = "muluna-forestry",
    group = "intermediate-products",
    order="gdz[muluna-forestry]",
    hidden = true,
    hide_from_signal_gui = false,
    },
    {type = "item-subgroup",
    name = "advanced-boiling",
    group = "intermediate-products",
    order="gdz[muluna-products]",
    hidden = true,
    hide_from_signal_gui = false,
    }
}

if mods["bioprocessing-tab"] then
    data.raw["item-subgroup"]["muluna-forestry"].group = "bioprocessing"
end