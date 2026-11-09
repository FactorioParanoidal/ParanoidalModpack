--Add custom values to this table when a gui element is by default not wide enough to fit the text of your gui element.
local gui_locales = {
    ["en"] = {
        switch_surface_button_width = 175
    }
}

function maraxsis.get_gui_locale(locale)
    local gui_locale = gui_locales[locale] or gui_locales["en"]
    return gui_locale
end