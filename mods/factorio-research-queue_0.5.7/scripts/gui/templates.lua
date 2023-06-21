local futil = require('__core__.lualib.util')

local templates = {}

function templates.frame_title(title)
  return {
    type = 'label',
    style = 'frame_title',
    caption = title,
    elem_mods = {
      ignored_by_interaction = true,
    },
  }
end

function templates.titlebar_drag_handle()
  return {
    type = 'empty-widget',
    style = 'flib_titlebar_drag_handle',
    elem_mods = {
      ignored_by_interaction = true,
    },
  }
end

function templates.frame_action_button(props)
  return futil.merge{
    {
      type = 'sprite-button',
      style = 'frame_action_button',
      mouse_button_filter = {'left'},
    },
    props,
  }
end

function templates.tool_button(props)
  return futil.merge{
    {
      type = 'sprite-button',
      style = 'tool_button',
      mouse_button_filter = {'left'},
    },
    props,
  }
end

return templates
