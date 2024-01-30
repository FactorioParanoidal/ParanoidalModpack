local upgrade_planner_utility = {}

upgrade_planner_utility.get_type = function(entity)
  if game.item_prototypes[entity] then return game.item_prototypes[entity].type end
  return ""
end

upgrade_planner_utility.is_exception = function(from, to)
  local exceptions = {
    {from = "container", to = "logistic-container"},
    {from = "logistic-container", to = "container"},
  }
  for k, exception in pairs(exceptions) do
    if from == exception.from and to == exception.to then return true end
  end
  return false
end

upgrade_planner_utility.get_config_item =
    function(player, index, type)
      if not global["config-tmp"][player.name] or index >
          #global["config-tmp"][player.name] or
          global["config-tmp"][player.name][index][type] == "" then
        return nil
      end
      if not game.item_prototypes[global["config-tmp"][player.name][index][type]] then
        return nil
      end
      if not game.item_prototypes[global["config-tmp"][player.name][index][type]]
          .valid then return nil end

      return
          game.item_prototypes[global["config-tmp"][player.name][index][type]]
              .name
    end

return upgrade_planner_utility
