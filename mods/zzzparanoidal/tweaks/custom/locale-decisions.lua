-- Выбранные описания составных достижений: отдельная фраза для каждого порога.
-- В языках без этих ключей сохраняется исходный шаблон more-achievements.
local function localise_description(prototype_type, name)
  local achievement = data.raw[prototype_type] and data.raw[prototype_type][name]
  if achievement and achievement.localised_description then
    achievement.localised_description = {
      "?",
      {"paranoidal-achievement-description." .. name},
      achievement.localised_description,
    }
  end
end

for _, prefix in ipairs({"circuit-veteran-", "computer-age-"}) do
  for tier = 3, 9 do
    localise_description("produce-per-hour-achievement", prefix .. tier)
  end
end
localise_description("produce-achievement", "mass-production-4")
