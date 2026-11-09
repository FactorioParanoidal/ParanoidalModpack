local Public = {}

local function generate_void_icons(fluid_icons)
    local icons = fluid_icons
    if not icons then return end

    icons = table.deepcopy(icons)
    table.insert(icons, 1, {
        icon = "__core__/graphics/filter-blacklist.png",
        icon_size = 101,
        scale = 0.35*64/101
    })
    return icons
end



function Public.dual_icon(item_1,item_2,item_3)
    local icon = {}
    local type_1 = "item"
    local type_2 = "item"
    local type_3 = "item"
    if data.raw["planet"][item_1] then type_1 = "planet" end
    if data.raw["planet"][item_2] then type_2 = "planet" end
    if data.raw["planet"][item_3] then type_3 = "planet" end
    if data.raw["fluid"][item_1] then type_1 = "fluid" end
    if data.raw["fluid"][item_2] then type_2 = "fluid" end
    if data.raw["fluid"][item_3] then type_3 = "fluid" end
    if data.raw["capsule"][item_1] then type_1 = "capsule" end
    if data.raw["capsule"][item_2] then type_2 = "capsule" end
    if data.raw["capsule"][item_3] then type_3 = "capsule" end
    if data.raw["tool"] then
        if data.raw["tool"][item_1] then type_1 = "tool" end
        if data.raw["tool"][item_2] then type_2 = "tool" end
        if data.raw["tool"][item_3] then type_3 = "tool" end
    end
    
    if data.raw["surface"][item_1] then type_1 = "surface" end
    if data.raw["surface"][item_2] then type_2 = "surface" end
    if data.raw["surface"][item_3] then type_3 = "surface" end

    if data.raw[type_1][item_1] and data.raw[type_1][item_1].icon then
        icon[1]={
            icon=data.raw[type_1][item_1].icon,
            icon_size=data.raw[type_1][item_1].icon_size,
            scale=0.35,
            draw_background = true,
        }
        if data.raw[type_1][item_1].icon_size then
            icon[1].scale=icon[1].scale * 64 /data.raw[type_1][item_1].icon_size
        end
    elseif data.raw[type_1][item_1] and data.raw[type_1][item_1].icons then
        

        icon[1]={
            icon=data.raw[type_1][item_1].icons[1].icon,
            icon_size=data.raw[type_1][item_1].icons[1].icon_size,
            scale=0.35,
            draw_background = true,
            tint = data.raw[type_1][item_1].icons[1].tint,
        }
    else 
        log(type_1 .. " \"".. item_1 .. "\" icon not found. Using a placeholder in composite icon instead." )
        icon[1]={
            icon = "__core__/graphics/filter-blacklist.png",
            icon_size = 101,
            scale = 0.35,
            draw_background = true,
        }
    end
    if data.raw[type_2][item_2] and data.raw[type_2][item_2].icon then
        icon[2]={
            icon=data.raw[type_2][item_2].icon,
            icon_size=data.raw[type_2][item_2].icon_size,
            scale=0.30,
            shift = {10,-10},
            draw_background = true,
            }
            if data.raw[type_2][item_2].icon_size then
                icon[2].scale=icon[2].scale* 64 /data.raw[type_2][item_2].icon_size
            end
    elseif data.raw[type_2][item_2] and data.raw[type_2][item_2].icons then
        icon[2]={
            icon=data.raw[type_2][item_2].icons[1].icon,
            icon_size=data.raw[type_2][item_2].icons[1].icon_size,
            scale=0.30,
            shift = {10,-10},
            draw_background = true,
            tint = data.raw[type_2][item_2].icons[1].tint,
            }
    else
        icon[2]={
            log(type_2 .. " \"".. item_2 .. "\" icon not found. Using a placeholder in composite icon instead." ),
            icon = "__core__/graphics/filter-blacklist.png",
            icon_size = 101,
            scale = 0.30,
            shift = {10,-10},
            draw_background = true,
        }

    end

    if data.raw[type_3][item_3] then
        icon[3]=table.deepcopy(icon[2]) --Rearrange order.
        icon[2]=table.deepcopy(icon[1]) --Rearrange order.
        if data.raw[type_3][item_3].icon then
            icon[1]={
                icon=data.raw[type_3][item_3].icon,
                icon_size=data.raw[type_3][item_3].icon_size,
                scale=0.30,
                shift = {0,-10},
                draw_background = true,
                }
                if data.raw[type_3][item_3].icon_size then
                    icon[3].scale=icon[3].scale* 64 /data.raw[type_3][item_3].icon_size
                end
                
        elseif data.raw[type_3][item_3].icons then
            icon[1]={
                icon=data.raw[type_3][item_3].icons[1].icon,
                icon_size=data.raw[type_3][item_3].icons[1].icon_size,
                scale=0.30,
                shift = {0,-10},
                draw_background = true,
                tint = data.raw[type_3][item_3].icons[1].tint,
                }
        end
    end
    for _,sub_icon in pairs(icon) do
        sub_icon.scale = sub_icon.scale / 1
        if not sub_icon.shift then sub_icon.shift = {0,0} end
        sub_icon.shift[1] = (sub_icon.shift[1]-5) / 1 
        sub_icon.shift[2] = (sub_icon.shift[2]+5) / 1 
    end
    
    
    
    return icon
end

    function Public.dual_icon_reversed(item_1,item_2)
        local icon = {}
        local type_1 = "item"
        local type_2 = "item"
        if data.raw["fluid"][item_1] then type_1 = "fluid" end
        if data.raw["fluid"][item_2] then type_2 = "fluid" end
        if data.raw[type_1][item_1].icon then
            icon[1]={
                icon=data.raw[type_1][item_1].icon,
                icon_size=data.raw[type_1][item_1].icon_size,
                scale=0.35,
                draw_background = true,
                shift = {10,0},
            }
            if data.raw[type_1][item_1].icon_size then
                icon[1].scale=icon[1].scale * 64 /data.raw[type_1][item_1].icon_size
            end
        else
            icon[1]={
                icon=data.raw[type_1][item_1].icons[1].icon,
                icon_size=data.raw[type_1][item_1].icons[1].icon_size,
                scale=0.35,
                draw_background = true,
            }
        end
        if data.raw[type_2][item_2].icon then
            icon[2]={
                icon=data.raw[type_2][item_2].icon,
                icon_size=data.raw[type_2][item_2].icon_size,
                scale=0.30,
                shift = {0,-10},
                draw_background = true,
                }
                if data.raw[type_2][item_2].icon_size then
                    icon[2].scale=icon[2].scale* 64 /data.raw[type_2][item_2].icon_size
                end
        else
            icon[2]={
                icon=data.raw[type_2][item_2].icons[1].icon,
                icon_size=data.raw[type_2][item_2].icons[1].icon_size,
                scale=0.30,
                shift = {10,-10},
                draw_background = true,
                }
        end
        
        
        return icon
    end





return Public