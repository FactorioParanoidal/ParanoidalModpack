-- Optional (startup setting "robotarmy-loot-chest"): squads collect alien artifacts lying around
-- them and teleport them into the force's loot chest.
local config = require("script.config")

local loot = {}

local FULL_MESSAGE_COOLDOWN = 3600

function loot.collect(squad, fd)
  local chest = fd.loot_chest
  if not (chest and chest.valid) or squad.size <= 0 then return end
  local p = squad.pos
  local r = config.ARTIFACT_GRAB_RADIUS
  local items = squad.surface.find_entities_filtered({
    area = {{p.x - r, p.y - r}, {p.x + r, p.y + r}},
    type = "item-entity",
  })
  local full = false
  for _, item in pairs(items) do
    local stack = item.valid and item.stack
    if stack and stack.valid_for_read and stack.name:find("artifact", 1, true) then
      local count = stack.count
      local inserted = chest.insert(stack)
      if inserted >= count then
        item.destroy()
      else
        if inserted > 0 then stack.count = count - inserted end
        full = true
      end
    end
  end
  if full then
    local now = game.tick
    if not fd.loot_full_tick or now >= fd.loot_full_tick + FULL_MESSAGE_COOLDOWN then
      fd.loot_full_tick = now
      fd.force.print({"robotarmy-message.loot-full"})
    end
  end
end

return loot
