local flib = {}

local function get_signal_position_from(selection_box)
    local left_top = {
        x = selection_box[1][1],
        y = selection_box[1][2],
    }
    local right_bottom = {
        x = selection_box[2][1],
        y = selection_box[2][2],
    }
    local center = (left_top.x + right_bottom.x) / 2        -- 0
    local width = math.abs(left_top.x) + right_bottom.x     -- 1.8
    local x = (width > 1.25 and center - 0.5) or center     -- (1.8 and -0.5) or 0
    local y = right_bottom.y                                -- 0.5
    --Calculating bottom center of the selection box
    return {x, y - 0.23}                                    
end

local function status_leds_working_visualisation(selection_box)
    local led_blend_mode = nil -- "additive"
    local led_tint = {1,1,1,1}
    return
    {
      apply_tint = "status",
      always_draw = true,
      --draw_as_sprite = true,
      draw_as_light = true,
      north_animation =
      {
        filename = "__BigLight__/graphics/Light_On.png",
        width = 32,
        height = 32,
        blend_mode = led_blend_mode,
        tint = led_tint,
        --shift = get_signal_position_from(selection_box),
      },
      east_animation =
      {
        filename = "__BigLight__/graphics/Light_On.png",
        width = 32,
        height = 32,
        blend_mode = led_blend_mode,
        tint = led_tint,
        --shift = get_signal_position_from(selection_box),
      },
      south_animation =
      {
        filename = "__BigLight__/graphics/Light_On.png",
        width = 32,
        height = 32,
        blend_mode = led_blend_mode,
        tint = led_tint,
        --shift = get_signal_position_from(selection_box),
      },
      west_animation =
      {
        filename = "__BigLight__/graphics/Light_On.png",
        width = 32,
        height = 32,
        blend_mode = led_blend_mode,
        tint = led_tint,
        --shift = get_signal_position_from(selection_box),
      }
    }
end

local function status_colors()
    return
    {
      -- If no_power, idle, no_minable_resources, disabled, insufficient_input or full_output is used, always_draw of corresponding layer must be set to true to draw it in those states.
  
      no_power = { 0, 0, 0, 0 },                  -- If no_power is not specified or is nil, it defaults to clear color {0,0,0,0}
  
      idle = { 1, 0, 0, 1 },                      -- If idle is not specified or is nil, it defaults to white.
      no_minable_resources = { 1, 0, 0, 1 },      -- If no_minable_resources, disabled, insufficient_input or full_output are not specified or are nil, they default to idle color.
      insufficient_input = { 1, 1, 0, 1 },
      full_output = { 1, 1, 0, 1 },
      disabled = { 1, 1, 0, 1 },
  
      working = { 0, 1, 0, 1 },                   -- If working is not specified or is nil, it defaults to white.
      low_power = { 1, 1, 0, 1 },                 -- If low_power is not specified or is nil, it defaults to working color.
    }
end



local function addBigLight(type, name)
    local entity = data.raw[type][name]
    local working_visu = entity.working_visualisations

    if not working_visu then 
        working_visu = {}
    end
    local status_leds = status_leds_working_visualisation(entity.selection_box)
  
    working_visu.status_colors = status_colors()
    table.insert(working_visu, status_leds)
end

 

local function add_light_offsets(t)
    t.north_position = { 0.8, -1.5}
    t.east_position =  { 1.2, -1}
    t.south_position = { 0.8,  0.8}
    t.west_position =  {-1.2, -1}
    return t
end


----------------------------------
flib.addBigLight = addBigLight
return flib

