if data.raw["solar-panel"]["solar-panel-small"] then
    if data.raw["solar-panel"]["solar-panel-small"] then
		bobicon("solar-panel-small","solar-panel",1,3,0)
		bobicon("solar-panel","solar-panel",1,3,0)
		bobicon("solar-panel-large","solar-panel",1,3,0)
			
        -- data.raw["solar-panel"]["solar-panel-small"]["picture"]["filename"] = "__ShinyBobGFX__/graphics/entity/solar-panels/solar-panel-s1.png"
    end

    -- if data.raw["solar-panel"]["solar-panel-small-2"] then
        -- data.raw["solar-panel"]["solar-panel-small-2"]["picture"]["filename"] = "__ShinyBobGFX__/graphics/entity/solar-panels/solar-panel-s2.png"
    -- end

    -- if data.raw["solar-panel"]["solar-panel-small-3"] then
        -- data.raw["solar-panel"]["solar-panel-small-3"]["picture"]["filename"] = "__ShinyBobGFX__/graphics/entity/solar-panels/solar-panel-s3.png"
    -- end
	if data.raw["solar-panel"]["solar-panel-small"] then
		data.raw["solar-panel"]["solar-panel-small"]["picture"]["layers"] = 
			{
        {
          filename = "__ShinyBobGFX__/graphics/entity/solar-panels/solar-panel-1m.png",
          priority = "high",
          width = 116,
          height = 112,
          shift = util.by_pixel(-3, 3),
		  scale = 0.66,
          hr_version = {
            filename = "__ShinyBobGFX__/graphics/entity/solar-panels/hr-solar-panel-1m.png",
            priority = "high",
            width = 230,
            height = 224,
            shift = util.by_pixel(-3, 3.5),
            scale = 0.33
          }
        },
        {
          filename = "__base__/graphics/entity/solar-panel/solar-panel-shadow.png",
          priority = "high",
          width = 112,
          height = 90,
          shift = util.by_pixel(6.5, 4.5),
          draw_as_shadow = true,
		  scale = 0.66,
          hr_version = {
            filename = "__base__/graphics/entity/solar-panel/hr-solar-panel-shadow.png",
            priority = "high",
            width = 220,
            height = 180,
            shift = util.by_pixel(6.5, 5),
            draw_as_shadow = true,
            scale = 0.33
          }
        }
      }
	  data.raw["solar-panel"]["solar-panel-small"]["overlay"] = 
	  {
	  layers =
      {
        {
          filename = "__base__/graphics/entity/solar-panel/solar-panel-shadow-overlay.png",
          priority = "high",
          width = 108,
          height = 90,
          shift = util.by_pixel(7, 5),
		  scale = 0.66,
          hr_version = {
            filename = "__base__/graphics/entity/solar-panel/hr-solar-panel-shadow-overlay.png",
            priority = "high",
            width = 214,
            height = 180,
            shift = util.by_pixel(6.5, 5),
            scale = 0.33
          }
        }
      }
	}
end


if data.raw["solar-panel"]["solar-panel-small-2"] then
		data.raw["solar-panel"]["solar-panel-small-2"]["picture"]["layers"] = 
			{
        {
          filename = "__ShinyBobGFX__/graphics/entity/solar-panels/solar-panel-2m.png",
          priority = "high",
          width = 116,
          height = 112,
          shift = util.by_pixel(-3, 3),
		  scale = 0.66,
          hr_version = {
            filename = "__ShinyBobGFX__/graphics/entity/solar-panels/hr-solar-panel-2m.png",
            priority = "high",
            width = 230,
            height = 224,
            shift = util.by_pixel(-3, 3.5),
            scale = 0.33
          }
        },
        {
          filename = "__base__/graphics/entity/solar-panel/solar-panel-shadow.png",
          priority = "high",
          width = 112,
          height = 90,
          shift = util.by_pixel(6.5, 4.5),
          draw_as_shadow = true,
		  scale = 0.66,
          hr_version = {
            filename = "__base__/graphics/entity/solar-panel/hr-solar-panel-shadow.png",
            priority = "high",
            width = 220,
            height = 180,
            shift = util.by_pixel(6.5, 5),
            draw_as_shadow = true,
            scale = 0.33
          }
        }
      }
	  data.raw["solar-panel"]["solar-panel-small-2"]["overlay"] = 
	  {
	  layers =
      {
        {
          filename = "__base__/graphics/entity/solar-panel/solar-panel-shadow-overlay.png",
          priority = "high",
          width = 108,
          height = 90,
          shift = util.by_pixel(7, 5),
		  scale = 0.66,
          hr_version = {
            filename = "__base__/graphics/entity/solar-panel/hr-solar-panel-shadow-overlay.png",
            priority = "high",
            width = 214,
            height = 180,
            shift = util.by_pixel(6.5, 5),
            scale = 0.33
          }
        }
      }
	}
end


if data.raw["solar-panel"]["solar-panel-small-3"] then
		data.raw["solar-panel"]["solar-panel-small-3"]["picture"]["layers"] = 
			{
        {
          filename = "__ShinyBobGFX__/graphics/entity/solar-panels/solar-panel-3m.png",
          priority = "high",
          width = 116,
          height = 112,
          shift = util.by_pixel(-3, 3),
		  scale = 0.66,
          hr_version = {
            filename = "__ShinyBobGFX__/graphics/entity/solar-panels/hr-solar-panel-3m.png",
            priority = "high",
            width = 230,
            height = 224,
            shift = util.by_pixel(-3, 3.5),
            scale = 0.33
          }
        },
        {
          filename = "__base__/graphics/entity/solar-panel/solar-panel-shadow.png",
          priority = "high",
          width = 112,
          height = 90,
          shift = util.by_pixel(6.5, 4.5),
          draw_as_shadow = true,
		  scale = 0.66,
          hr_version = {
            filename = "__base__/graphics/entity/solar-panel/hr-solar-panel-shadow.png",
            priority = "high",
            width = 220,
            height = 180,
            shift = util.by_pixel(6.5, 5),
            draw_as_shadow = true,
            scale = 0.33
          }
        }
      }
	  data.raw["solar-panel"]["solar-panel-small-3"]["overlay"] = 
	  {
	  layers =
      {
        {
          filename = "__base__/graphics/entity/solar-panel/solar-panel-shadow-overlay.png",
          priority = "high",
          width = 108,
          height = 90,
          shift = util.by_pixel(7, 5),
		  scale = 0.66,
          hr_version = {
            filename = "__base__/graphics/entity/solar-panel/hr-solar-panel-shadow-overlay.png",
            priority = "high",
            width = 214,
            height = 180,
            shift = util.by_pixel(6.5, 5),
            scale = 0.33
          }
        }
      }
	}
end
	  

	
    -- Medium
	
    if data.raw["solar-panel"]["solar-panel"] then
		data.raw["solar-panel"]["solar-panel"]["picture"]["layers"][1] = 
		{
          filename = "__ShinyBobGFX__/graphics/entity/solar-panels/solar-panel-1m.png",
          priority = "high",
          width = 116,
          height = 112,
          shift = util.by_pixel(-3, 3),
          hr_version = {
            filename = "__ShinyBobGFX__/graphics/entity/solar-panels/hr-solar-panel-1m.png",
            priority = "high",
            width = 230,
            height = 224,
            shift = util.by_pixel(-3, 3.5),
            scale = 0.5
          }
        }
	end

	if data.raw["solar-panel"]["solar-panel-2"] then
		data.raw["solar-panel"]["solar-panel-2"]["picture"]["layers"] = 
			{
        {
          filename = "__ShinyBobGFX__/graphics/entity/solar-panels/solar-panel-2m.png",
          priority = "high",
          width = 116,
          height = 112,
          shift = util.by_pixel(-3, 3),
          hr_version = {
            filename = "__ShinyBobGFX__/graphics/entity/solar-panels/hr-solar-panel-2m.png",
            priority = "high",
            width = 230,
            height = 224,
            shift = util.by_pixel(-3, 3.5),
            scale = 0.5
          }
        },
        {
          filename = "__base__/graphics/entity/solar-panel/solar-panel-shadow.png",
          priority = "high",
          width = 112,
          height = 90,
          shift = util.by_pixel(10, 6),
          draw_as_shadow = true,
          hr_version = {
            filename = "__base__/graphics/entity/solar-panel/hr-solar-panel-shadow.png",
            priority = "high",
            width = 220,
            height = 180,
            shift = util.by_pixel(10.5, 6),
            draw_as_shadow = true,
            scale = 0.5
          }
        }
      }
	  data.raw["solar-panel"]["solar-panel-2"]["overlay"] = 
	  {
	  layers =
      {
        {
          filename = "__base__/graphics/entity/solar-panel/solar-panel-shadow-overlay.png",
          priority = "high",
          width = 108,
          height = 90,
          shift = util.by_pixel(11, 6),
          hr_version = {
            filename = "__base__/graphics/entity/solar-panel/hr-solar-panel-shadow-overlay.png",
            priority = "high",
            width = 214,
            height = 180,
            shift = util.by_pixel(10.5, 6),
            scale = 0.5
          }
        }
      }
	}
end
	

if data.raw["solar-panel"]["solar-panel-3"] then
		data.raw["solar-panel"]["solar-panel-3"]["picture"]["layers"] = 
			{
        {
          filename = "__ShinyBobGFX__/graphics/entity/solar-panels/solar-panel-3m.png",
          priority = "high",
          width = 116,
          height = 112,
          shift = util.by_pixel(-3, 3),
          hr_version = {
            filename = "__ShinyBobGFX__/graphics/entity/solar-panels/hr-solar-panel-3m.png",
            priority = "high",
            width = 230,
            height = 224,
            shift = util.by_pixel(-3, 3.5),
            scale = 0.5
          }
        },
        {
          filename = "__base__/graphics/entity/solar-panel/solar-panel-shadow.png",
          priority = "high",
          width = 112,
          height = 90,
          shift = util.by_pixel(10, 6),
          draw_as_shadow = true,
          hr_version = {
            filename = "__base__/graphics/entity/solar-panel/hr-solar-panel-shadow.png",
            priority = "high",
            width = 220,
            height = 180,
            shift = util.by_pixel(10.5, 6),
            draw_as_shadow = true,
            scale = 0.5
          }
        }
      }
	  data.raw["solar-panel"]["solar-panel-3"]["overlay"] = 
	  {
	  layers =
      {
        {
          filename = "__base__/graphics/entity/solar-panel/solar-panel-shadow-overlay.png",
          priority = "high",
          width = 108,
          height = 90,
          shift = util.by_pixel(11, 6),
          hr_version = {
            filename = "__base__/graphics/entity/solar-panel/hr-solar-panel-shadow-overlay.png",
            priority = "high",
            width = 214,
            height = 180,
            shift = util.by_pixel(10.5, 6),
            scale = 0.5
          }
        }
      }
	}
end	

	
--[[
    if data.raw["solar-panel"]["solar-panel"] then
        data.raw["solar-panel"]["solar-panel"]["picture"]["filename"] = "__ShinyBobGFX__/graphics/entity/solar-panels/hr-solar-panel-1.png"
    end

    if data.raw["solar-panel"]["solar-panel-2"] then
        data.raw["solar-panel"]["solar-panel-2"]["picture"]["filename"] = "__ShinyBobGFX__/graphics/entity/solar-panels/hr-solar-panel-2.png"
    end

    if data.raw["solar-panel"]["solar-panel-3"] then
        data.raw["solar-panel"]["solar-panel-3"]["picture"]["filename"] = "__ShinyBobGFX__/graphics/entity/solar-panels/hr-solar-panel-3.png"
    end
--]]
    -- Large
	
	
if data.raw["solar-panel"]["solar-panel-large"] then
		data.raw["solar-panel"]["solar-panel-large"]["picture"]["layers"] = 
			{
        {
          filename = "__ShinyBobGFX__/graphics/entity/solar-panels/solar-panel-1m.png",
          priority = "high",
          width = 116,
          height = 112,
          shift = util.by_pixel(-3, 3),
		  scale = 1.33,
          hr_version = {
            filename = "__ShinyBobGFX__/graphics/entity/solar-panels/hr-solar-panel-1m.png",
            priority = "high",
            width = 230,
            height = 224,
            shift = util.by_pixel(-3, 3.5),
            scale = 0.66
          }
        },
        {
          filename = "__base__/graphics/entity/solar-panel/solar-panel-shadow.png",
          priority = "high",
          width = 112,
          height = 90,
          shift = util.by_pixel(14, 6),
          draw_as_shadow = true,
		  scale = 1.33,
          hr_version = {
            filename = "__base__/graphics/entity/solar-panel/hr-solar-panel-shadow.png",
            priority = "high",
            width = 220,
            height = 180,
            shift = util.by_pixel(14, 6),
            draw_as_shadow = true,
            scale = 0.66
          }
        }
      }
	  data.raw["solar-panel"]["solar-panel-large"]["overlay"] = 
	  {
	  layers =
      {
        {
          filename = "__base__/graphics/entity/solar-panel/solar-panel-shadow-overlay.png",
          priority = "high",
          width = 108,
          height = 90,
          shift = util.by_pixel(14, 6),
		  scale = 1.33,
          hr_version = {
            filename = "__base__/graphics/entity/solar-panel/hr-solar-panel-shadow-overlay.png",
            priority = "high",
            width = 214,
            height = 180,
            shift = util.by_pixel(14, 6),
            scale = 0.66
          }
        }
      }
	}
end	


if data.raw["solar-panel"]["solar-panel-large-2"] then
		data.raw["solar-panel"]["solar-panel-large-2"]["picture"]["layers"] = 
			{
        {
          filename = "__ShinyBobGFX__/graphics/entity/solar-panels/solar-panel-2m.png",
          priority = "high",
          width = 116,
          height = 112,
          shift = util.by_pixel(-3, 3),
		  scale = 1.33,
          hr_version = {
            filename = "__ShinyBobGFX__/graphics/entity/solar-panels/hr-solar-panel-2m.png",
            priority = "high",
            width = 230,
            height = 224,
            shift = util.by_pixel(-3, 3.5),
            scale = 0.66
          }
        },
        {
          filename = "__base__/graphics/entity/solar-panel/solar-panel-shadow.png",
          priority = "high",
          width = 112,
          height = 90,
          shift = util.by_pixel(14, 6),
          draw_as_shadow = true,
		  scale = 1.33,
          hr_version = {
            filename = "__base__/graphics/entity/solar-panel/hr-solar-panel-shadow.png",
            priority = "high",
            width = 220,
            height = 180,
            shift = util.by_pixel(14, 6),
            draw_as_shadow = true,
            scale = 0.66
          }
        }
      }
	  data.raw["solar-panel"]["solar-panel-large-2"]["overlay"] = 
	  {
	  layers =
      {
        {
          filename = "__base__/graphics/entity/solar-panel/solar-panel-shadow-overlay.png",
          priority = "high",
          width = 108,
          height = 90,
          shift = util.by_pixel(14, 6),
		  scale = 1.33,
          hr_version = {
            filename = "__base__/graphics/entity/solar-panel/hr-solar-panel-shadow-overlay.png",
            priority = "high",
            width = 214,
            height = 180,
            shift = util.by_pixel(14, 6),
            scale = 0.66
          }
        }
      }
	}
end	
	
	

if data.raw["solar-panel"]["solar-panel-large-3"] then
		data.raw["solar-panel"]["solar-panel-large-3"]["picture"]["layers"] = 
			{
        {
          filename = "__ShinyBobGFX__/graphics/entity/solar-panels/solar-panel-3m.png",
          priority = "high",
          width = 116,
          height = 112,
          shift = util.by_pixel(-3, 3),
		  scale = 1.33,
          hr_version = {
            filename = "__ShinyBobGFX__/graphics/entity/solar-panels/hr-solar-panel-3m.png",
            priority = "high",
            width = 230,
            height = 224,
            shift = util.by_pixel(-3, 3.5),
            scale = 0.66
          }
        },
        {
          filename = "__base__/graphics/entity/solar-panel/solar-panel-shadow.png",
          priority = "high",
          width = 112,
          height = 90,
          shift = util.by_pixel(14, 6),
          draw_as_shadow = true,
		  scale = 1.33,
          hr_version = {
            filename = "__base__/graphics/entity/solar-panel/hr-solar-panel-shadow.png",
            priority = "high",
            width = 220,
            height = 180,
            shift = util.by_pixel(14, 6),
            draw_as_shadow = true,
            scale = 0.66
          }
        }
      }
	  data.raw["solar-panel"]["solar-panel-large-3"]["overlay"] = 
	  {
	  layers =
      {
        {
          filename = "__base__/graphics/entity/solar-panel/solar-panel-shadow-overlay.png",
          priority = "high",
          width = 108,
          height = 90,
          shift = util.by_pixel(14, 6),
		  scale = 1.33,
          hr_version = {
            filename = "__base__/graphics/entity/solar-panel/hr-solar-panel-shadow-overlay.png",
            priority = "high",
            width = 214,
            height = 180,
            shift = util.by_pixel(14, 6),
            scale = 0.66
          }
        }
      }
	}
end		
		
	

    -- if data.raw["solar-panel"]["solar-panel-large"] then
        -- data.raw["solar-panel"]["solar-panel-large"]["picture"]["filename"] = "__ShinyBobGFX__/graphics/entity/solar-panels/solar-panel-l1.png"
    -- end

    -- if data.raw["solar-panel"]["solar-panel-large-2"] then
        -- data.raw["solar-panel"]["solar-panel-large-2"]["picture"]["filename"] = "__ShinyBobGFX__/graphics/entity/solar-panels/solar-panel-l2.png"
    -- end

    -- if data.raw["solar-panel"]["solar-panel-large-3"] then
        -- data.raw["solar-panel"]["solar-panel-large-3"]["picture"]["filename"] = "__ShinyBobGFX__/graphics/entity/solar-panels/solar-panel-l3.png"
    -- end
end
