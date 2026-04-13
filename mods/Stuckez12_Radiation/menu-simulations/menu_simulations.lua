local menu_simulations = {}

local file_location = "__Stuckez12_Radiation__/menu-simulations/"

menu_simulations.train_sim =
{
  checkboard = false,
  save = file_location .. "saves/train.zip",
  length = 60 * 16,
  init_file = file_location .. "train-sim/init.lua",
  update_file = file_location .. "train-sim/update.lua",
}

menu_simulations.edge_patch =
{
  checkboard = false,
  save = file_location .. "saves/edge-patch.zip",
  length = 60 * 16,
  init_file = file_location .. "edge-patch/init.lua",
  update_file = file_location .. "edge-patch/update.lua",
}

menu_simulations.patch_dies =
{
  checkboard = false,
  save = file_location .. "saves/patch-dies.zip",
  length = 60 * 12,
  init_file = file_location .. "patch-dies/init.lua",
}

menu_simulations.mining_patch =
{
  checkboard = false,
  save = file_location .. "saves/mining-patch.zip",
  length = 60 * 16,
  init_file = file_location .. "mining-patch/init.lua",
  update_file = file_location .. "mining-patch/update.lua",
}

menu_simulations.rad_factory =
{
  checkboard = false,
  save = file_location .. "saves/rad-factory.zip",
  length = 60 * 16,
  init_file = file_location .. "rad-factory/init.lua",
}

menu_simulations.biter_breach =
{
  checkboard = false,
  save = file_location .. "saves/biter-breach.zip",
  length = 60 * 16,
  init_file = file_location .. "biter-breach/init.lua",
  update_file = file_location .. "biter-breach/update.lua",
}

menu_simulations.rad_nuke =
{
  checkboard = false,
  save = file_location .. "saves/rad-nuke.zip",
  length = 60 * 16,
  init_file = file_location .. "rad-nuke/init.lua",
  update_file = file_location .. "rad-nuke/update.lua",
}

menu_simulations.rad_corpse =
{
  checkboard = false,
  save = file_location .. "saves/rad-corpse.zip",
  length = 60 * 16,
  init_file = file_location .. "rad-corpse/init.lua",
  update_file = file_location .. "rad-corpse/update.lua",
}

menu_simulations.rad_spider =
{
  checkboard = false,
  save = file_location .. "saves/rad-spider.zip",
  length = 60 * 16,
  init_file = file_location .. "rad-spider/init.lua",
  update_file = file_location .. "rad-spider/update.lua",
}

return menu_simulations
