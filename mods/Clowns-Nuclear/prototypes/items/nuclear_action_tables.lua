--------------------------------------------------------------------------------------------------
-- START WITH THE "SEGMENTED" EXPLOSION PARTS
--------------------------------------------------------------------------------------------------
local explosion_animations = require("__base__.prototypes.entity.explosion-animations")
local smoke_animations = require("__base__.prototypes.entity.smoke-animations")
local smoke_animations = require("__base__.prototypes.entity.smoke-animations")
local sounds = require("__base__.prototypes.entity.sounds")
-- regular nuke setting
local max_nuke_shockwave_movement_distance_deviation = 2
local max_nuke_shockwave_movement_distance = 19 + max_nuke_shockwave_movement_distance_deviation / 6
local nuke_shockwave_starting_speed_deviation = 0.075
-- thermonuke setting
local max_thermonuke_shockwave_movement_distance_deviation = 10
local max_thermonuke_shockwave_movement_distance = 25 + max_thermonuke_shockwave_movement_distance_deviation / 6
local thermonuke_shockwave_starting_speed_deviation = 0.075

local size_up=1.4 --1.6 was a tad big :D

local nuke_action = data.raw.projectile["atomic-rocket"].action
local thermonuke_action = table.deepcopy(data.raw.projectile["atomic-rocket"].action)

prop = {"radius","duration","full_strength_max_distance","max_distance","ease_out_duration","damage","amount"--[[damage.amount]],"action"--[[iterate through radius, repeat count etc]],"repeat_count"}

for i,j in pairs(thermonuke_action.action_delivery.target_effects) do
  if j then
    for k, l in pairs(prop) do
      if j[l] and type(j[l]) ~= "table" then --contains a value?
        if j.type == "destroy-cliffs" then --really boost this one
          j[l] = j[l] * size_up * size_up
        else
          j[l] = j[l] * size_up
        end
      elseif j[l] and type(j[l]) == "table" then
        for m,sub in pairs(prop) do
          if j[l][sub] and type(j[l][sub]) ~= "table" then
            j[l][sub] = j[l][sub]*size_up
          end
        end
      end
    end
    if j.action and j.action.action_delivery and j.action.action_delivery.starting_speed_deviation then
      j.action.action_delivery.starting_speed_deviation = thermonuke_shockwave_starting_speed_deviation
    end
  end
end
--custom increases
--add in the 2 "extra waves"
--starting with the "regular wave"
table.insert(thermonuke_action.action_delivery.target_effects,
{ --wave 1
  type = "nested-result",
  action =
  {
    type = "area",
    target_entities = false,
    trigger_from_target = true,
    repeat_count = 1000*size_up,
    radius = 35,
    action_delivery =
    {
      type = "projectile",
      projectile = "atomic-bomb-wave",
      starting_speed = 0.5 * 0.7,
      starting_speed_deviation = nuke_shockwave_starting_speed_deviation
    }
  }
})
table.insert(thermonuke_action.action_delivery.target_effects,
{
  type = "destroy-cliffs",
  radius = 18,
  explosion_at_trigger = "explosion"
})
table.insert(thermonuke_action.action_delivery.target_effects,
{
  type = "nested-result",
  action =
  {
    type = "area",
    show_in_tooltip = false,
    target_entities = false,
    trigger_from_target = true,
    repeat_count = 1000*size_up,
    radius = 26,
    action_delivery =
    {
      type = "projectile",
      projectile = "atomic-bomb-wave-spawns-cluster-nuke-explosion",
      starting_speed = 0.5 * 0.7,
      starting_speed_deviation = nuke_shockwave_starting_speed_deviation
    }
  }
})
table.insert(thermonuke_action.action_delivery.target_effects,
{
  type = "nested-result",
  action =
  {
    type = "area",
    show_in_tooltip = false,
    target_entities = false,
    trigger_from_target = true,
    repeat_count = 1000*size_up,
    radius = 8,
    action_delivery =
    {
      type = "projectile",
      projectile = "atomic-bomb-wave-spawns-nuke-shockwave-explosion",
      starting_speed = 0.5 * 0.65,
      starting_speed_deviation = nuke_shockwave_starting_speed_deviation
    }
  }
})
table.insert(thermonuke_action.action_delivery.target_effects,
{--wave 3
  type = "nested-result",
  action =
  {
    type = "area",
    target_entities = false,
    trigger_from_target = true,
    repeat_count = 1000*size_up*size_up,
    radius = 35*size_up*size_up,
    action_delivery =
    {
      type = "projectile",
      projectile = "atomic-bomb-wave",
      starting_speed = 0.5 * 0.7*size_up*size_up,
      starting_speed_deviation = thermonuke_shockwave_starting_speed_deviation*0.5
    }
  }
})
table.insert(thermonuke_action.action_delivery.target_effects,
{
  type = "nested-result",
  action =
  {
    type = "area",
    show_in_tooltip = false,
    target_entities = false,
    trigger_from_target = true,
    repeat_count = 1000*size_up*size_up,
    radius = 26*size_up*size_up,
    action_delivery =
    {
      type = "projectile",
      projectile = "atomic-bomb-wave-spawns-cluster-nuke-explosion",
      starting_speed = 0.5 * 0.7*size_up*size_up,
      starting_speed_deviation = thermonuke_shockwave_starting_speed_deviation*0.5
    }
  }
})
table.insert(thermonuke_action.action_delivery.target_effects,
{
  type = "nested-result",
  action =
  {
    type = "area",
    show_in_tooltip = false,
    target_entities = false,
    trigger_from_target = true,
    repeat_count = 1000*size_up*size_up,
    radius = 8*size_up*size_up,
    action_delivery =
    {
      type = "projectile",
      projectile = "atomic-bomb-wave-spawns-nuke-shockwave-explosion",
      starting_speed = 0.5 * 0.65*size_up*size_up,
      starting_speed_deviation = thermonuke_shockwave_starting_speed_deviation*0.5
    }
  }
})
clowns_actions_nuke=nuke_action
clowns_actions_thermonuke=thermonuke_action