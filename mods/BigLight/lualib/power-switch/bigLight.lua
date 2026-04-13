function power_switch(name)
    local LuaEntityPrototype = data.raw["power-switch"][name]
    local led_blend_mode = nil
    local ledOn = LuaEntityPrototype.led_on
    local ledOff = LuaEntityPrototype.led_off

    local value = settings.startup["ritnmods-bl-04"].value

    LuaEntityPrototype.led_on = {
      layers = {
        ledOn,
        {
          filename = "__BigLight__/graphics/entity/train-stop/hr-N-light.png",
          width = 20,
          height = 20,
          blend_mode = led_blend_mode,
          tint = {0,1,0,0.8},
          shift = util.by_pixel(23, 2),
          scale = value / 4,
          --[[ hr_version =
            {
              filename = "__BigLight__/graphics/entity/train-stop/hr-N-light.png",
              width = 20,
              height = 20,
              blend_mode = led_blend_mode,
              tint = {0,1,0,0.8},
              shift = util.by_pixel(23, 2),
              scale = value / 2,
            } ]]
        }
      }
    }

    -- led_off
    LuaEntityPrototype.led_off = {
      layers = {
        ledOff,
        {
          filename = "__BigLight__/graphics/entity/train-stop/hr-N-light.png",
          width = 20,
          height = 20,
          blend_mode = led_blend_mode,
          tint = {1,0,0,0.8},
          shift = util.by_pixel(23, 6),
          scale = value / 4,
          --[[ hr_version =
            {
              filename = "__BigLight__/graphics/entity/train-stop/hr-N-light.png",
              width = 20,
              height = 20,
              blend_mode = led_blend_mode,
              tint = {1,0,0,0.8},
              shift = util.by_pixel(23, 6),
              scale = value / 2,
            } ]]
        }
      }
    }

    return LuaEntityPrototype
end