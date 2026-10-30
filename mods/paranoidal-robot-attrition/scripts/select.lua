-- Default victim choice. A victim comes from the charging queues with the share the queues have in the load
-- of the network (waiting × queue_weight / load): a queue is drawn by its length, then a random logistic robot
-- waiting there. Otherwise, or when that queue holds only construction robots, a random flying logistic robot.
-- The full list of flying robots is fetched only when it is needed.
local shared = require("shared")

local random = math.random
local queue_weight = shared.queue_weight

local M = {}

local function from_queue(ctx, lists)
  local r, counts, index = random(ctx.waiting), ctx.counts, 1
  while index < ctx.queued and r > counts[index] do
    r = r - counts[index]
    index = index + 1
  end
  local list = lists[index]
  if not list then
    list = {}
    local robots = ctx.cells[index].to_charge_robots
    for i = 1, #robots do
      local robot = robots[i]
      if robot.valid and robot.type == "logistic-robot" then list[#list + 1] = robot end
    end
    lists[index] = list
  end
  if #list == 0 then return nil end
  return list[random(#list)]
end

function M.pick(ctx, count)
  local picked, seen, lists, flying = {}, {}, {}, nil
  local queue_share = ctx.load > 0 and ctx.waiting * queue_weight / ctx.load or 0
  for _ = 1, count do
    for _ = 1, 4 do -- a few attempts to find a robot not picked yet
      local robot
      if ctx.waiting > 0 and random() < queue_share then robot = from_queue(ctx, lists) end
      if not robot then
        flying = flying or ctx.network.logistic_robots
        if #flying > 0 then robot = flying[random(#flying)] end
      end
      if robot and robot.valid and not seen[robot.unit_number] then
        seen[robot.unit_number] = true
        picked[#picked + 1] = robot
        break
      end
    end
  end
  return picked
end

return M
