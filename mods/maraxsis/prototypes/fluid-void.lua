data:extend {{
    type = "item-subgroup",
    name = "maraxsis-fluid-void",
    order = "z[maraxsis]-[fluid-void]",
    group = "fluids",
}}

local function generate_void_icons(fluid)
    local icons = fluid.icons or {{icon = fluid.icon, icon_size = fluid.icon_size}}
    if not icons then return end

    icons = table.deepcopy(icons)
    table.insert(icons, 1, {
        icon = "__core__/graphics/filter-blacklist.png",
        icon_size = 101,
    })
    return icons
end

for _, fluid in pairs(data.raw.fluid) do
    if fluid.hidden or fluid.parameter then goto continue end
    data:extend {{
        type = "recipe",
        name = "maraxsis-fluid-void-" .. fluid.name,
        categories = {"maraxsis-hydro-plant"},
        subgroup = "maraxsis-fluid-void",
        order = fluid.order,
        icons = generate_void_icons(fluid),
        enabled = true,
        energy_required = 1,
        ingredients = {
            {type = "fluid", name = fluid.name, amount = 100}
        },
        results = {},
        hidden_in_factoriopedia = true,
        auto_recycle = false,
        hide_from_player_crafting = true,
        allow_decomposition = false,
        allow_as_intermediate = false,
        always_show_made_in = true,
        show_amount_in_title = false,
        hide_from_signal_gui = false,
        localised_name = {"recipe-name.maraxsis-fluid-void", fluid.localised_name or {"fluid-name." .. fluid.name}},
        allowed_module_categories = {"speed", "efficiency"},
    }}
    ::continue::
end
