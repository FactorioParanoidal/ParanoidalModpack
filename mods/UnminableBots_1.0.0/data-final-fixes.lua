-- Code adopted from Choumiko - SmallFixes

local bot_types = {"construction-robot", "logistic-robot"}
local bot_names = {}

-- fill bot_names with all bots
for _, bot in pairs(bot_types) do
  for _, entity in pairs(data.raw[bot]) do
    bot_names[entity.name] = true

    -- while iterating also set minable properties
    if bot == "construction-robot" and settings.startup["Unminable-bots-construction"].value then
      entity.minable = nil
      --log(bot.."."..entity.name.." made unminable")
    end

    if bot == "logistic-robot" and settings.startup["Unminable-bots-logistic"].value then
      entity.minable = nil
      --log(bot.."."..entity.name.." made unminable")
    end

    if settings.startup["Unminable-bots-click-through"].value then
      entity.selection_box = {{ 0, 0}, {0, 0}}
      --log(bot.."."..entity.name.." made click-through")
    end

  end
end

