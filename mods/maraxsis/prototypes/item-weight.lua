local function i_want_to_fit_this_many_per_rocket(item, count)
    for item_type in pairs(defines.prototypes.item) do
        local item = (data.raw[item_type] or {})[item]
        if item then
            if count == 0 then
                item.weight = 5000000
            else
                item.weight = 1000000 / count
            end
            return
        end
    end
    error("Could not find item " .. item)
end

i_want_to_fit_this_many_per_rocket("maraxsis-fishing-tower", 20)
i_want_to_fit_this_many_per_rocket("maraxsis-big-cliff-explosives", 10)
i_want_to_fit_this_many_per_rocket("sp-spidertron-dock", 20)
i_want_to_fit_this_many_per_rocket("maraxsis-diesel-submarine", 1)
i_want_to_fit_this_many_per_rocket("maraxsis-nuclear-submarine", 1)
i_want_to_fit_this_many_per_rocket("maraxsis-hydro-plant", 5)
i_want_to_fit_this_many_per_rocket("maraxsis-sonar", 20)
i_want_to_fit_this_many_per_rocket("maraxsis-pressure-dome", 0)
i_want_to_fit_this_many_per_rocket("maraxsis-coral", 500)
i_want_to_fit_this_many_per_rocket("limestone", 200)
i_want_to_fit_this_many_per_rocket(maraxsis_constants.SAND_ITEM_NAME, 500)
i_want_to_fit_this_many_per_rocket("maraxsis-glass-panes", 500)
i_want_to_fit_this_many_per_rocket("maraxsis-fish-food", 100)
i_want_to_fit_this_many_per_rocket("maraxsis-tropical-fish", 100)
i_want_to_fit_this_many_per_rocket("maraxsis-microplastics", 1000)
i_want_to_fit_this_many_per_rocket("maraxsis-wyrm-specimen", 20)
i_want_to_fit_this_many_per_rocket("maraxsis-wyrm-confinement-cell", 20)
i_want_to_fit_this_many_per_rocket("maraxsis-super-sealant-substance", 3)
i_want_to_fit_this_many_per_rocket("salt", 1000)
i_want_to_fit_this_many_per_rocket("maraxsis-salt-filter", 50)
i_want_to_fit_this_many_per_rocket("maraxsis-saturated-salt-filter", 50)
i_want_to_fit_this_many_per_rocket("maraxsis-abyssal-diving-gear", 1)
i_want_to_fit_this_many_per_rocket("maraxsis-trench-duct", 1)
i_want_to_fit_this_many_per_rocket("maraxsis-geothermal-generator", 5)
i_want_to_fit_this_many_per_rocket("maraxsis-oversized-steam-turbine", 1)
i_want_to_fit_this_many_per_rocket("maraxsis-conduit", 20)
i_want_to_fit_this_many_per_rocket("maraxsis-fat-man", 10)
