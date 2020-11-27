
if circuit_connector_definitions and (not circuit_connector_definitions.create_scaled) then

  circuit_connector_definitions.create_scaled = function(template, definitions, scale)
    -- create unscaled version
    local created_definition = circuit_connector_definitions.create(template, definitions)

    if scale and scale > 0 and scale ~= 1 then -- have to scale it now

      -- sprites
      for _, spriteName in pairs{
        "connector_main",
        "connector_shadow",

        "led_blue",
        "led_blue_off",
        "led_green",
        "led_red",

        "wire_pins",
        "wire_pins_shadow",
      } do
        if created_definition.sprites[spriteName] then
          created_definition.sprites[spriteName].scale = (created_definition.sprites[spriteName].scale or 1) * scale
          for axis, value in pairs(created_definition.sprites[spriteName].shift) do
            created_definition.sprites[spriteName].shift[axis] = value * scale
          end
        end
      end

      -- sprites offset
      for _, spriteName in pairs{
        "blue_led_light_offset",
        "red_green_led_light_offset",
      } do
        if created_definition.sprites[spriteName] then
          for axis, value in pairs(created_definition.sprites[spriteName]) do
            created_definition.sprites.blue_led_light_offset[axis] = value * scale
          end
        end
      end

      -- points
      for layerIndex, layer in pairs(created_definition.points) do
        for colorName, colorConnection in pairs(layer) do
          for axis, value in pairs(colorConnection) do
            created_definition.points[layerIndex][colorName][axis] = value * scale
          end
        end
      end

    elseif scale and scale < 0 then
      error("Error \'circuit_connector_definitions.create_scaled\': Scale argument can't be negative.")
    end

    return created_definition
  end
  
--else
  --log("function \'circuit_connector_definitions.create_scaled\' was already in use")
end
