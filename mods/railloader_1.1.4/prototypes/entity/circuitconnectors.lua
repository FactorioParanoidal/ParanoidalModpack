local pictures = require "prototypes.entity.pictures"

local M = {}

local empty_connector_template = {
  connector_main = pictures.empty_animation,
  connector_shadow = pictures.empty_animation,
  wire_pins = pictures.empty_animation,
  wire_pins_shadow = pictures.empty_animation,
  led_blue = pictures.empty_animation,
  led_blue_off = pictures.empty_animation,
  led_green = pictures.empty_animation,
  led_red = pictures.empty_animation,
  wire_offsets = universal_connector_template.wire_offsets,
  wire_shadow_offsets = universal_connector_template.wire_shadow_offsets,
  light_offsets = universal_connector_template.light_offsets,
}

local chest_definition = { variation = 26, main_offset = {0,-1}, shadow_offset = util.by_pixel(7.5, 2), show_shadow = true }

M["railloader-placement-proxy"] = circuit_connector_definitions.create(
  universal_connector_template,
  {
    chest_definition,
    chest_definition,
    chest_definition,
    chest_definition,
  }
)

M["railloader-inserter"] = circuit_connector_definitions.create(
  empty_connector_template,
  {
    chest_definition,
    chest_definition,
    chest_definition,
    chest_definition,
  }
)

return M