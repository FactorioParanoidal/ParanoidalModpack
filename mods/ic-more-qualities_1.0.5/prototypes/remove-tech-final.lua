-- odebere nadbytecny vyzkumy, protoze nove kvality upravi cely system kvalit

if data.raw.technology["legendary-quality"] then
  for i = #data.raw.technology["legendary-quality"].effects, 1, -1 do
    effect = data.raw.technology["legendary-quality"].effects[i]
    if effect.type == "unlock-quality" then
      table.remove(data.raw.technology["legendary-quality"].effects, i)
    end
  end

  if next(data.raw.technology["legendary-quality"].effects) == nil then
    data.raw.technology["legendary-quality"] = nil
  end
end

if data.raw.technology["epic-quality"] then
  for i = #data.raw.technology["epic-quality"].effects, 1, -1 do
    effect = data.raw.technology["epic-quality"].effects[i]
    if effect.type == "unlock-quality" and effect.quality == "epic" then
      table.remove(data.raw.technology["epic-quality"].effects, i)
    end
  end

  if next(data.raw.technology["epic-quality"].effects) == nil and not data.raw.technology["legendary"] then
    data.raw.technology["epic-quality"] = nil
  end
end
