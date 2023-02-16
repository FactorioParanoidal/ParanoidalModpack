-- Taken from flib
local fab = "__FactorySearch__/graphics/frame-action-icons.png"

data:extend{
  { type = "sprite", name = "fs_flib_pin_black", filename = fab, position = { 0, 0 }, size = 32, flags = { "icon" } },
  { type = "sprite", name = "fs_flib_pin_white", filename = fab, position = { 32, 0 }, size = 32, flags = { "icon" } }
}

-- Taken from BetterAlertArrows
data:extend{
  {
    type = "sprite",
    name = "fs_arrow",
    filename = "__FactorySearch__/graphics/location-arrow.png",
    size = 96,
    scale = 1.2,
    flags = {"gui-icon"},
    tint = { r = 0, g = 1, b = 0 }
  }
}