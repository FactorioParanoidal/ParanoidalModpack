--------------------------------------
--скорость анимации для насосов
local pumps = {
  ["offshore-pump"] = 0.5,
  ["offshore-mk2-pump"] = 0.75,
  ["offshore-mk3-pump"] = 1,
  ["offshore-mk4-pump"] = 1.25
}

for pump, speed in pairs(pumps) do
  for _, direction in pairs({"north", "east", "south", "west"}) do
    data.raw["offshore-pump"][pump].graphics_set.animation[direction].layers[1].hr_version.animation_speed = speed
    data.raw["offshore-pump"][pump].graphics_set.animation[direction].layers[1].animation_speed = speed
  end
end

--фикс бага со сьемом seafloor-pump-3
data.raw["offshore-pump"]["seafloor-pump-3"].minable = { mining_time = 1, result = "seafloor-pump-3" }
data.raw["pump"]["seafloor-pump-3-output"].minable = { mining_time = 1, result = "seafloor-pump-3" }

--------------------------------------
--клонируем анимацию
data.raw["pump"]["offshore-mk0-pump-output"].animations = data.raw["offshore-pump"]["offshore-mk0-pump"].graphics_set.animation
data.raw["pump"]["offshore-pump-output"].animations = data.raw["offshore-pump"]["offshore-pump"].graphics_set.animation
data.raw["pump"]["offshore-mk2-pump-output"].animations = data.raw["offshore-pump"]["offshore-mk2-pump"].graphics_set.animation
data.raw["pump"]["offshore-mk3-pump-output"].animations = data.raw["offshore-pump"]["offshore-mk3-pump"].graphics_set.animation
data.raw["pump"]["offshore-mk4-pump-output"].animations = data.raw["offshore-pump"]["offshore-mk4-pump"].graphics_set.animation






