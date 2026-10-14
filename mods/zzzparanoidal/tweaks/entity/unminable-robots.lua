-- Летающих строительных и логистических роботов нельзя снять рукой, как в Beta 8 (UnminableBots).
-- В 2.0 сущность с next_upgrade обязана быть добываемой, поэтому цепочка улучшений роботов Bob
-- (у строительных к тому же ошибочная: MK3 -> MK3, MK4 -> MK3) снимается вместе с minable.
for _, robot_type in pairs({"construction-robot", "logistic-robot"}) do
  for _, robot in pairs(data.raw[robot_type] or {}) do
    robot.minable = nil
    robot.next_upgrade = nil
  end
end
