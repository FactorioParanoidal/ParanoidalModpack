local data_util = require("data-util")
local def = data.raw["utility-constants"].default

if settings.startup["night-lut-set"].value == "Dark" or settings.startup["night-lut-set"].value == "Bright" then
  local night_suffix = ""
  if settings.startup["night-lut-set"].value == "Bright" then
    night_suffix = "-bright"
  end
  def.daytime_color_lookup =
  {
    {0.00, "identity"},
    {0.20, "identity"},
    {0.35, data_util.mod_path.."/graphics/color_luts/lut-sunset"..night_suffix..".png"},
    {0.45, data_util.mod_path.."/graphics/color_luts/lut-night"..night_suffix..".png"},
    {0.55, data_util.mod_path.."/graphics/color_luts/lut-night"..night_suffix..".png"},
    {0.80, "identity"},
    {0.85, "identity"}
  }
  def.zoom_to_world_daytime_color_lookup =
  {
    {0.00, "identity"},
    {0.20, "identity"},
    {0.35, data_util.mod_path.."/graphics/color_luts/lut-sunset"..night_suffix..".png"},
    {0.45, data_util.mod_path.."/graphics/color_luts/lut-night"..night_suffix..".png"},
    {0.55, data_util.mod_path.."/graphics/color_luts/lut-night"..night_suffix..".png"},
    {0.75, "identity"},
    {0.85, "identity"}
  }
end

if settings.startup["enhanced-nightvision"].value then
  data.raw["night-vision-equipment"]["night-vision-equipment"].color_lookup = {
    {0.5, data_util.mod_path.."/graphics/color_luts/lut-nightvision.png"}
  }
end

if settings.startup["wide-flashlight"].value then
  for _, character in pairs(data.raw.character) do
    if character.light then
      if character.light.intensity then
        character.light = {character.light}
      end
      for i, light in pairs(character.light) do
        if light.picture and light.picture.filename == "__core__/graphics/light-cone.png" then
          character.light[i] = {
            type = "oriented",
            minimum_darkness = 0.3,
            picture =
            {
              filename = data_util.mod_path.."/graphics/light/light-torch.png",
              priority = "extra-high",
              flags = { "light" },
              scale = 1.5,
              width = 512,
              height = 512
            },
            shift = {0, -24},
            size = 2,
            intensity = 0.6,
          }
        elseif light.type ~= "oriented" then
          character.light[i] = {
            type = "oriented",
            shift = {0, -1},
            minimum_darkness = 0.3,
            intensity = 0.4,
            size = 2,
            color = {r=0.8, g=0.8, b=1.0},
            picture =
            {
              filename = data_util.mod_path.."/graphics/light/light-pin.png",
              priority = "extra-high",
              flags = { "light" },
              scale = 4,
              width = 512,
              height = 512
            },
          }
        end
      end
    end
  end
  for _, car in pairs(data.raw.car) do
    if car.light then
      if car.light.intensity then
        car.light = {car.light}
      end
      local pin_light_i
      for i, light in pairs(car.light) do
        if light.picture and light.picture.filename == "__core__/graphics/light-cone.png" then
          light.picture.filename = data_util.mod_path.."/graphics/light/light-torch.png"
          light.picture.width = 512
          light.picture.height = 512
          light.picture.scale = (light.picture.scale or 1) / 2 * 1.5
          local origin_offset_x = light.shift.x or light.shift[1]
          local origin_offset_y = light.shift.y or light.shift[2] + 13
          light.shift =
          {
            x = origin_offset_x,
            y = origin_offset_y + -16 * light.picture.scale
          }
        end
        if light.type ~= "oriented" then
          pin_light_i = i
        end
      end
      if not pin_light_i then
        pin_light_i = #car.light
      end
      car.light[pin_light_i] = {
        type = "oriented",
        shift = {0, -1},
        minimum_darkness = 0.3,
        intensity = 0.4,
        size = 2,
        color = {r=0.8, g=0.8, b=1.0},
        picture =
        {
          filename = data_util.mod_path.."/graphics/light/light-pin.png",
          priority = "extra-high",
          flags = { "light" },
          scale = 4,
          width = 512,
          height = 512
        },
      }
    end
  end
end
