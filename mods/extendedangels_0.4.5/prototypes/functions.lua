-- Setup function host
extangels = {}
extangels.triggers = {}

-- Create function to check whether the new number function is live
function extangels.validate_numeral_function()
    return angelsmods.functions.add_number_icon_layer({}, 1, angelsmods["smelting"].number_tint)
end

-- Append angel numerals and return an icons definition
function extangels.numeral_tier(icon_data, tier, tint)
if pcall(extangels.validate_numeral_function) then
        local icons = angelsmods.functions.add_number_icon_layer({icon_data}, tier, tint)
        return icons
    else
        return
        {
            icon_data,
            {
                icon = "__angelsrefining__/graphics/icons/num_"..tier..".png",
                icon_size = 32,
                tint = tint,
                scale = 0.32,
                shift = {-12, -12}
            }
        }
    end
end