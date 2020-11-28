
-- data.raw["gui-style"].default["SpaceMod_thin_flow"] =
    -- {
      -- type = "flow_style",
	  -- parent = "flow_style",
      -- horizontal_spacing = 0,
      -- vertical_spacing = 0,
      -- max_on_row = 0,
      -- resize_row_to_width = true,
	  
    -- }
	
	
-- data.raw["gui-style"].default["SpaceMod_thin_frame"] =
    -- {
      -- type = "frame_style",
	  -- parent = "frame_style",
      -- top_padding  = 4,
	  -- bottom_padding = 2,
    -- }

-- data.raw["gui-style"].default["SpaceMod_main_frame"] =
    -- {
      -- type = "frame_style",
	  -- parent = "frame_style",
      -- top_padding  = 0,
	  -- bottom_padding = 0,
    -- }
	
	-- data.raw["gui-style"].default["SpaceMod_button_flow"] =
    -- {
      -- type = "flow_style",
	  -- parent = "flow_style",
	  -- horizontal_spacing=1,
    -- }
	
-- data.raw["gui-style"].default["SpaceMod_button_style"] =
    -- {
      -- type = "button_style",
      -- parent = "button_style",
	  -- top_padding = 1,
      -- right_padding = 5,
      -- bottom_padding = 1,
      -- left_padding = 5,
      -- left_click_sound =
      -- {
        -- {
          -- filename = "__core__/sound/gui-click.ogg",
          -- volume = 1
        -- }
      -- }
    -- }
	
-- data.raw["gui-style"].default["SpaceMod_disabled_button"] =
    -- {
      -- type = "button_style",
	  -- parent = "SpaceMod_button_style",

      -- default_font_color={r=0.34, g=0.34, b=0.34},
	  
	  -- hovered_font_color={r=0.34, g=0.34, b=0.38},
      -- hovered_graphical_set =
      -- {
        -- type = "composition",
        -- filename = "__core__/graphics/gui.png",
        -- corner_size = {3, 3},
        -- position = {0, 0}
      -- },

      -- clicked_font_color={r=0.34, g=0.34, b=0.38},
	  -- clicked_graphical_set =
      -- {
        -- type = "composition",
        -- filename = "__core__/graphics/gui.png",
        -- corner_size = {3, 3},
        -- position = {0, 0}
      -- },
    -- }	
	
	
-- data.raw["gui-style"].default["SpaceMod_selected_button"] =
    -- {
      -- type = "button_style",
	  -- parent = "SpaceMod_button_style",

      -- default_font_color={r=0, g=0, b=0},
	  -- default_graphical_set =
      -- {
        -- type = "composition",
        -- filename = "__core__/graphics/gui.png",
        -- corner_size = {3, 3},
        -- position = {0, 8}
      -- },
	  
	  
      
      -- hovered_font_color={r=1, g=1, b=1},
      -- hovered_graphical_set =
      -- {
        -- type = "composition",
        -- filename = "__core__/graphics/gui.png",
        -- corner_size = {3, 3},
        -- position = {0, 16}
      -- },

      -- clicked_font_color={r=0, g=0, b=0},
	  -- clicked_graphical_set =
      -- {
        -- type = "composition",
        -- filename = "__core__/graphics/gui.png",
        -- corner_size = {3, 3},
        -- position = {0, 0}
      -- },
    -- }
	
-- data.raw["gui-style"].default["SpaceMod_label_style"] =
    -- {
      -- type = "label_style",
	  -- parent = "label_style",
      -- font = "default",
      -- font_color = {r=1, g=1, b=1},
	  -- top_padding = 0,
      -- bottom_padding = 0,
    -- }
	
	data.raw["gui-style"].default["SpaceMod_table_style"] =
		{
		type = "table_style",
		horizontal_spacing = 5,
		vertical_spacing = 5,
		horizontally_stretchable = "on"
		}	
		
	data.raw["gui-style"].default["Launch_label_style"] =
		{
		type = "label_style",
		maximal_width = 400,
		single_line = false,
		vertically_strechable = "on"
		}
		
	data.raw["gui-style"].default["Launch_text_box_style"] =
		{
		type = "textbox_style",
		maximal_width = 400,
		read_only = true
		}