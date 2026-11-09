local function set_default_import_location(item, planet)
    for item_prototype in pairs(defines.prototypes.item) do
        local item = (data.raw[item_prototype] or {})[item]
        if item then
            item.default_import_location = planet
            return
        end
    end
end

set_default_import_location("maraxsis-big-cliff-explosives", "nauvis")
set_default_import_location("sp-spidertron-dock", "vulcanus")
set_default_import_location("maraxsis-diesel-submarine", "maraxsis")
set_default_import_location("maraxsis-nuclear-submarine", "maraxsis")
set_default_import_location("maraxsis-hydro-plant", "maraxsis")
set_default_import_location("maraxsis-fishing-tower", "maraxsis")
set_default_import_location("maraxsis-sonar", "maraxsis")
set_default_import_location("maraxsis-pressure-dome", "maraxsis")
set_default_import_location("maraxsis-coral", "maraxsis")
set_default_import_location("limestone", "maraxsis")
set_default_import_location(maraxsis_constants.SAND_ITEM_NAME, "maraxsis")
set_default_import_location("maraxsis-glass-panes", "maraxsis")
set_default_import_location("maraxsis-fish-food", "maraxsis")
set_default_import_location("maraxsis-tropical-fish", "maraxsis")
set_default_import_location("maraxsis-microplastics", "maraxsis")
set_default_import_location("maraxsis-wyrm-specimen", "maraxsis")
set_default_import_location("maraxsis-wyrm-confinement-cell", "maraxsis")
set_default_import_location("maraxsis-super-sealant-substance", "maraxsis")
set_default_import_location("salt", "maraxsis")
set_default_import_location("maraxsis-salt-filter", "maraxsis")
set_default_import_location("maraxsis-saturated-salt-filter", "maraxsis")
set_default_import_location("hydraulic-science-pack", "maraxsis")
set_default_import_location("maraxsis-atmosphere-barrel", "nauvis")
set_default_import_location("maraxsis-liquid-atmosphere-barrel", "aquilo")
set_default_import_location("maraxsis-brackish-water-barrel", "maraxsis")
set_default_import_location("maraxsis-saline-water-barrel", "maraxsis")
set_default_import_location("oxygen-barrel", "maraxsis")
set_default_import_location("hydrogen-barrel", "maraxsis")
set_default_import_location("maraxsis-fat-man", "nauvis")
set_default_import_location("maraxsis-abyssal-diving-gear", "maraxsis")
set_default_import_location("maraxsis-geothermal-generator", "maraxsis")
set_default_import_location("maraxsis-conduit", "maraxsis")
