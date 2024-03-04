local States = {}

local require = function(string)
  return require("script/character_interface/states/"..string)
end

States.attack = require("attack")
States.combat = require("combat")
States.batch_job = require("batch_job")
States.build_ghost = require("build_ghost")
States.craft_item = require("craft_item")
States.find_and_batch = require("find_and_batch")
States.find_item = require("find_item")
States.follow = require("follow")
States.fuel_entity = require("fuel_entity")
States.idle = require("idle")
States.mining = require("mining")
States.moving = require("moving")
States.moving_spider = require("moving_spider")
States.moving_vehicle = require("moving_vehicle")
States.put_item = require("put_item")
States.repair = require("repair")
States.take_item = require("take_item")
States.take_item_from_belt = require("take_item_from_belt")
States.upgrade = require("upgrade")
States.deferred_job = require("deferred_job")

return States