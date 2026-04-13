local imageUtils = {}

-- module code

local function foreach(table_, fun_)
    for _, tab in pairs(table_) do fun_(tab) end
    return table_
end

function imageUtils.create_burnt_patch_pictures(attributes)
    local base = {
        filename = "__base__/graphics/entity/fire-flame/burnt-patch.png",
        line_length = 3,
        width = 115,
        height = 56,
        frame_count = 9,
        axially_symmetrical = false,
        tint = attributes.tint2,
        direction_count = 1,
        shift = {-0.09375, 0.125},
    }

    local variations = {}

    for y=1,(base.frame_count / base.line_length) do
        for x=1,base.line_length do
            table.insert(variations,
                         {
                             filename = base.filename,
                             width = base.width,
                             height = base.height,
                             tint = base.tint,
                             shift = base.shift,
                             x = (x-1) * base.width,
                             y = (y-1) * base.height,
            })
        end
    end

    return variations
end


function imageUtils.create_small_tree_flame_animations(opts)
    local fire_blend_mode = opts.blend_mode or "additive"
    local fire_animation_speed1 = opts.animation_speed or 0.5
    local fire_scale1 =  opts.scale or 1
    local fire_tint = opts.tint2
    local fire_flags = { "always-compressed" }
	  local retval =
	  {
		{
		  filename = "__base__/graphics/entity/fire-flame/tree-flame-01.png",
		  line_length = 10,
		  width = 82,
		  height = 110,
		  frame_count = 90,
		  shift = {0, 0},
		  blend_mode = fire_blend_mode,
		  animation_speed = fire_animation_speed1,
		  scale = fire_scale1,
		  tint = fire_tint,
		  flags = fire_flags

		},
		{
		  filename = "__base__/graphics/entity/fire-flame/tree-flame-02.png",
		  line_length = 10,
		  width = 82,
		  height = 114,
		  frame_count = 90,
		  shift = {0, 0},
		  blend_mode = fire_blend_mode,
		  animation_speed = fire_animation_speed1,
		  scale = fire_scale1,
		  tint = fire_tint,
          flags = fire_flags
		  
		}		
      }

    return foreach(retval, function(tab)
                       if tab.shift and tab.scale then tab.shift = { tab.shift[1] * tab.scale, tab.shift[2] * tab.scale } end
    end)
end

function imageUtils.create_fire_pictures(opts)
  local fire_blend_mode = opts.blend_mode or "normal"
  local fire_animation_speed1 = opts.animation_speed1 or 0.5
  local fire_animation_speed2 = opts.animation_speed2 or 0.9
  local fire_scale1 =  opts.scale1 or 0.55
  local fire_scale2 =  opts.scale2 or (fire_scale1 * 0.7)
  local fire_tint = opts.tint2
  local fire_flags = nil
  local retval =
  {
    {
      filename = "__base__/graphics/entity/fire-flame/fire-flame-01.png",
      line_length = 10,
      width = 84,
      height = 130,
      frame_count = 90,
      blend_mode = fire_blend_mode,
      animation_speed = fire_animation_speed1,
      scale = fire_scale1,
      tint = fire_tint,
      flags = fire_flags,
      shift = { 0, -0.7 }
    },
    {
      filename = "__base__/graphics/entity/fire-flame/fire-flame-02.png",
      line_length = 10,
      width = 82,
      height = 106,
      frame_count = 90,
      blend_mode = fire_blend_mode,
      animation_speed = fire_animation_speed1,
      scale = fire_scale1,
      tint = fire_tint,
      flags = fire_flags,
      shift = { 0, -0.7 }
    },
    {
      filename = "__base__/graphics/entity/fire-flame/fire-flame-03.png",
      line_length = 10,
      width = 84,
      height = 124,
      frame_count = 90,
      blend_mode = fire_blend_mode,
      animation_speed = fire_animation_speed1,
      scale = fire_scale1,
      tint = fire_tint,
      flags = fire_flags,
      shift = { 0, -0.7 }
    },
    {
      filename = "__base__/graphics/entity/fire-flame/fire-flame-04.png",
      line_length = 10,
      width = 84,
      height = 94,
      frame_count = 90,
      blend_mode = fire_blend_mode,
      animation_speed = fire_animation_speed1,
      scale = fire_scale1,
      tint = fire_tint,
      flags = fire_flags,
      shift = { 0, -0.25 }
    },
    {
      filename = "__base__/graphics/entity/fire-flame/fire-flame-01.png",
      line_length = 10,
      width = 84,
      height = 130,
      frame_count = 90,
      blend_mode = fire_blend_mode,
      animation_speed = fire_animation_speed2,
      scale = fire_scale2,
      tint = fire_tint,
      flags = fire_flags,
      shift = { 0, -0.7 }
    },
    {
      filename = "__base__/graphics/entity/fire-flame/fire-flame-02.png",
      line_length = 10,
      width = 82,
      height = 106,
      frame_count = 90,
      blend_mode = fire_blend_mode,
      animation_speed = fire_animation_speed2,
      scale = fire_scale2,
      tint = fire_tint,
      flags = fire_flags,
      shift = { 0, -0.7 }
    },
    {
      filename = "__base__/graphics/entity/fire-flame/fire-flame-03.png",
      line_length = 10,
      width = 84,
      height = 124,
      frame_count = 90,
      blend_mode = fire_blend_mode,
      animation_speed = fire_animation_speed2,
      scale = fire_scale2,
      tint = fire_tint,
      flags = fire_flags,
      shift = { 0, -0.7 }
    },
    {
      filename = "__base__/graphics/entity/fire-flame/fire-flame-04.png",
      line_length = 10,
      width = 84,
      height = 94,
      frame_count = 90,
      blend_mode = fire_blend_mode,
      animation_speed = fire_animation_speed2,
      scale = fire_scale2,
      tint = fire_tint,
      flags = fire_flags,
      shift = { 0, -0.25 }
    }
  }
  retval = foreach(retval, function(tab)
    if tab.shift and tab.scale then tab.shift = { tab.shift[1] * tab.scale, tab.shift[2] * tab.scale } end
  end)
  for k, layer in pairs (retval) do
    retval[k] = util.draw_as_glow(layer)
  end
  return retval

    -- local fire_blend_mode = opts.blend_mode or "additive"
    -- local fire_animation_speed = opts.animation_speed or 0.5
    -- local fire_scale =  opts.scale or 1
    -- local fire_tint = opts.tint2
    -- local fire_flags = { "always-compressed" }
    -- local retval = {
        -- {
            -- filename = "__base__/graphics/entity/fire-flame/fire-flame-04.png",
            -- line_length = 8,
            -- width = 67,
            -- height = 130,
            -- frame_count = 32,
            -- axially_symmetrical = false,
            -- direction_count = 1,
            -- blend_mode = fire_blend_mode,
            -- animation_speed = fire_animation_speed,
            -- scale = fire_scale,
            -- tint = fire_tint,
            -- flags = fire_flags,
			-- shift = { 0, -0.25 }
        -- },
        -- {
            -- filename = "__base__/graphics/entity/fire-flame/fire-flame-03.png",
            -- line_length = 8,
            -- width = 74,
            -- height = 117,
            -- frame_count = 32,
            -- axially_symmetrical = false,
            -- direction_count = 1,
            -- blend_mode = fire_blend_mode,
            -- animation_speed = fire_animation_speed,
            -- scale = fire_scale,
            -- tint = fire_tint,
            -- flags = fire_flags,
			-- shift = { 0, -0.7 }
        -- },
        -- {
            -- filename = "__base__/graphics/entity/fire-flame/fire-flame-02.png",
            -- line_length = 8,
            -- width = 74,
            -- height = 114,
            -- frame_count = 32,
            -- axially_symmetrical = false,
            -- direction_count = 1,
            -- blend_mode = fire_blend_mode,
            -- animation_speed = fire_animation_speed,
            -- scale = fire_scale,
            -- tint = fire_tint,
            -- flags = fire_flags,
			-- shift = { 0, -0.7 }
        -- },
        -- {
            -- filename = "__base__/graphics/entity/fire-flame/fire-flame-01.png",
            -- line_length = 8,
            -- width = 66,
            -- height = 119,
            -- frame_count = 32,
            -- axially_symmetrical = false,
            -- direction_count = 1,
            -- blend_mode = fire_blend_mode,
            -- animation_speed = fire_animation_speed,
            -- scale = fire_scale,
            -- tint = fire_tint,
            -- flags = fire_flags,
			-- shift = { 0, -0.7 }
        -- },
    -- }
    -- return foreach(retval, function(tab)
                       -- if tab.shift and tab.scale then tab.shift = { tab.shift[1] * tab.scale, tab.shift[2] * tab.scale } end
    -- end)
end

return imageUtils
