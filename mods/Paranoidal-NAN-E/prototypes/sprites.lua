local shared = require("shared")

local look = settings.startup[shared.settings.look].value
local L = shared.looks[look] or shared.looks.own
local gui = shared.mod .. "/graphics/gui/"
local entity = shared.mod .. "/graphics/entity/nan-e/"

local list = {}
-- Her portrait in the window, a face per emotion (both looks).
for _, emotion in pairs(shared.emotions) do
  list[#list + 1] =
  {
    type = "sprite",
    name = shared.sprite.portrait .. emotion,
    filename = gui .. "portrait-" .. look .. "-" .. emotion .. ".png",
    size = 256,
    scale = 0.5,
    flags = {"gui-icon"},
    priority = "medium"
  }
end

-- The own look's screen faces, drawn by the script over her head while she talks: the same frame as her body, so the
-- face lands on her screen in every direction (her head always turns to the viewer).
if look == "own" then
  for _, emotion in pairs(shared.emotions) do
    list[#list + 1] =
    {
      type = "sprite",
      name = shared.sprite.face .. emotion,
      filename = entity .. "own/face-" .. emotion .. ".png",
      width = L.frame[1],
      height = L.frame[2],
      scale = 0.5,
      shift = {0, -L.frame_z * 0.7071},
      flags = {"no-crop"}
    }
  end
end

-- The umbrella she holds over herself in the rain (paranoidal-rain).
list[#list + 1] =
{
  type = "sprite",
  name = shared.sprite.umbrella,
  filename = entity .. "umbrella.png",
  size = 64,
  scale = 0.5
}

data:extend(list)
