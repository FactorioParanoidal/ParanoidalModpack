local Public = {}

function Public.blur_technology_icon(icons,blurriness)
        --Apply blur effect to planet by layering many nearly-transparent copies of sprites shifted slightly from primary sprites.
        --TODO: Add settings to modify blur intensity that aren't difficult to understand.
        --if not blurriness then blurriness = 1 end
        local blur_count = 8
        local blur_shift_max = 5 * blurriness
        local blur_shift_start = 1 * blurriness
        local blur_shift_steps= 1 * blurriness
        local brightness_modifier = 1
        local sprites_list = table.deepcopy(icons)
        icons = {}
        --local shift_x = blur_shift -- Initial shift, top left corner.
        --local shift_y = blur_shift
        -- for _,entry in pairs(sprites_list) do
            
        -- end
        local n = blur_count*(1+(blur_shift_max-blur_shift_start)/blur_shift_steps)
        for _,child_original in pairs(sprites_list) do -- Rotate background bodies about main body.
            local copy = table.deepcopy(child_original)
            copy.tint = {1,1,1} --half-black mask to ensure that none of the sprite is transparent where it shouldn't be
            table.insert(icons,copy)
            local child = table.deepcopy(child_original)
            for i = 1,blur_count do
                for blur_shift = blur_shift_start,blur_shift_max,blur_shift_steps do
                    local shift_x = blur_shift * math.cos(i*2*math.pi/blur_count)
                    local shift_y = blur_shift * math.sin(i*2*math.pi/blur_count)
                    
                        if child.shift then
                            if not child.shift[1] then
                                child.shift[1] = shift_x
                            else
                                child.shift[1] = child.shift[1] + shift_x
                            end
                            if not child.shift[2] then
                                child.shift[2] = shift_y
                            else
                                child.shift[2] = child.shift[2] + shift_y
                            end
                        else
                            child.shift = {shift_x, shift_y}
                        end
                            --assert(1/n > 0.01, "".. tostring(1/n))
                            child.tint = {brightness_modifier/n,brightness_modifier/n,brightness_modifier/n,brightness_modifier/n}
                            child.blend_mode = "multiplicative-with-alpha"
                            table.insert(icons,child)
                            
                        
                end
            end
        end
        return icons
    end





return Public