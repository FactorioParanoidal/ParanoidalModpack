local M = {}

function M.enabled()
  local option = settings.global["paranoidal-debug-chat"]
  return option ~= nil and option.value
end

function M.print(message, recipient)
  log(message)
  if M.enabled() then
    (recipient or game).print(message)
  end
end

return M
