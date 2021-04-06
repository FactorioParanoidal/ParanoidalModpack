-- normalize mining productivity
if settings.startup["inf-tech-mining-productivity-log-formula"].value and data.raw.technology["mining-productivity-4"] then
  data.raw.technology["mining-productivity-4"].unit.count_formula = "2^(L-3)*1000"
end

-- normalize follower count
if data.raw.technology["follower-robot-count-7"] then
  data.raw.technology["follower-robot-count-7"].unit.time = settings.startup["inf-tech-follower-count-time"].value
  if settings.startup["inf-tech-follower-count-log-formula"].value then
    data.raw.technology["follower-robot-count-7"].unit.count_formula = "2^(L-6)*1000"
  end
end
