-- luacheck: no max line length


return {

  ------------------------------------------------------------------------------------
  -- Key:     property name
  -- Value:   Table with these keys:
  --            default (Used if the player is not connected to a character on init)
  --            init_from_player (If we can get this value directly from the player)
  --            need_techs (List of names of techs that must be researched before the
  --                        property can be accessed)
  ------------------------------------------------------------------------------------
  -- These only work for characters or players with a character
  active                                        = {default = true}, -- Only character!
  allow_dispatching_robots                      = {default = true}, -- Only character!
  character_additional_mining_categories        = {default = {}}, -- Must be a table! Player must have character!
  character_build_distance_bonus                = {default = 0}, -- Must be a number! Player must have character!
  character_crafting_speed_modifier             = {default = 0}, -- Must be a number! Player must have character!
  character_health_bonus                        = {default = 0}, -- Must be a number! Player must have character!
  character_inventory_slots_bonus               = {default = 0}, -- Must be a number! Player must have character!
  character_item_drop_distance_bonus            = {default = 0}, -- Must be a number! Player must have character!
  character_item_pickup_distance_bonus          = {default = 0}, -- Must be a number! Player must have character!
  character_loot_pickup_distance_bonus          = {default = 0}, -- Must be a number! Player must have character!
  character_maximum_following_robot_count_bonus = {default = 0}, -- Must be a number! Player must have character!
  character_mining_speed_modifier               = {default = 0}, -- Must be a number! Player must have character!
  --~ character_personal_logistic_requests_enabled  = {default = true}, -- Player must have character!
  character_reach_distance_bonus                = {default = 0}, -- Must be a number! Player must have character!
  character_resource_reach_distance_bonus       = {default = 0}, -- Must be a number! Player must have character!
  character_running_speed_modifier              = {default = 0}, -- Must be a number! Player must have character!
  character_trash_slot_count_bonus              = {default = 0}, -- Must be a number! Player must have character!
  destructible                                  = {default = true}, -- Player must have character!
  direction                                     = {default = 0}, -- Must be a number! Only character!
  health                                        = {default = 0}, -- Must be a number! Only character!
  last_user                                     = {default = 0}, -- Only character! (This value will be overwritten with player.name when player_data.char_properties is initialized.)
  operable                                      = {default = true}, -- Only character!
  orientation                                   = {default = 0}, -- Must be a number! Only character!
  selected                                      = {default = nil},
  selected_gun_index                            = {default = 1}, -- Must be a number! Only character!
  tick_of_last_attack                           = {default = 0}, -- Must be a number! Only character!
  tick_of_last_damage                           = {default = 0}, -- Must be a number! Only character!

  -- Can be initialized with player data
  color                                         = {init_from_player = true},
  driving                                       = {init_from_player = true}, --  true if the player is in a vehicle. Writing to this attribute puts the player in or out of a vehicle. (Is that a character property?)
  force                                         = {init_from_player = true}, -- Must be a string or a LuaForce!
  mining_state                                  = {init_from_player = true}, -- Must be a table!
  opened                                        = {init_from_player = true}, -- doesn't work? (Seems to be related to player, not character!)
  picking_state                                 = {init_from_player = true},
  repair_state                                  = {init_from_player = true}, -- Must be a table!
  request_from_buffers                          = {init_from_player = true, need_techs = {"logistic-robotics"}}, -- ONLY WITH PERSONAL LOGISTICS RESEARCH! Only character!
  shooting_state                                = {init_from_player = true}, -- Must be a table!
  walking_state                                 = {init_from_player = true}, -- Must be a table!
}
