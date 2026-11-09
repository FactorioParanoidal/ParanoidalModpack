if settings.startup["PlanetsLib-enable-lab-science-pack-preview-size-change"].value == true then
   for _,lab in pairs(data.raw.lab) do
        local max_count = 12
        local pack_count = 0
        for _,pack in pairs(lab.inputs) do
            pack_count = pack_count + 1
        end
        if pack_count > max_count then
            --assert(lab.name ~= "cerys-lab")
            local icon_scaling = math.sqrt(max_count/pack_count)
            local left_top = lab.selection_box.left_top or lab.selection_box[1]
            local right_bottom = lab.selection_box.right_bottom or lab.selection_box[2]
            local left_top_x = left_top.x or left_top[1]
            local right_bottom_x = right_bottom.x or right_bottom[1]
            local x = math.abs(left_top_x - right_bottom_x)
            local size_factor = 1
            if x then
                size_factor = math.sqrt(x / 3)
            end
            
            if not lab.icons_positioning then
            lab.icons_positioning = {
                --{inventory_index = defines.inventory.lab_modules, shift = {0, -0.9 * shift_factor}},
            }
            end
            local lab_input_entry
            for _,entry in pairs(lab.icons_positioning) do
                if entry.inventory_index == defines.inventory.lab_input then
                    lab_input_entry = entry
                    break
                end
            end
            local positioning = {
                shift = {0, 0.75*size_factor*(icon_scaling-1)},
                max_icons_per_row = math.floor(6/icon_scaling),
                separation_multiplier = 1,
                scale = 0.5*size_factor*icon_scaling,
            }
            if lab_input_entry then
                -- Update an existing lab-input entry (for example one inherited
                -- from the vanilla lab) instead of adding a duplicate entry.
                for field,value in pairs(positioning) do
                    lab_input_entry[field] = value
                end
            else
                positioning.inventory_index = defines.inventory.lab_input
                table.insert(lab.icons_positioning,positioning)
            end
            
        end
    end 
end

