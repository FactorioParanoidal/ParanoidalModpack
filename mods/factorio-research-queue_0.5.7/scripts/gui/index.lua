local eventlib = require('__flib__.event')

local event_handlers = require('.event_handlers')
local actions = require('.actions')

local function handle_event(player, action, event)
  if type(action) == 'string' then
    event_handlers[action](player, event)
  else
    event_handlers[action.type](player, action, event)
  end
end

return {
  handle_event = handle_event,
  actions = actions,
}
