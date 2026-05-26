for index, force in pairs(game.forces) do
  if force.technologies["logistic-train-network"] ~= nil and force.technologies["logistic-train-network"].researched then
    force.recipes["ltn-combinator"].enabled = true
  end
end
