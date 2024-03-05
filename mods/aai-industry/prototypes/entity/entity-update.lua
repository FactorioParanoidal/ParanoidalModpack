for _, unit in pairs(data.raw.unit) do
  if unit.max_heath and unit.max_heath > 0 and
    (string.find(unit.name, "biter", 1, true) or string.find(unit.name, "spitter", 1, true)) then
    unit.max_heath = unit.max_heath + 10
  end
end
