local guilib = require('__flib__.gui-beta')
local translationlib = require('__flib__.translation')

local rqtech = require('scripts.rqtech')

local function update_tech_button_tooltip(player, gui_data, tech)
  local player_data = global.players[player.index]
  local translation_data = global.players[player.index].translations

  local has_description = false
  if translation_data ~= nil then
    local tech_translations = translation_data[tech.tech.name]
    if tech_translations ~= nil then
      local description_key = translationlib.serialise_localised_string(
        tech.tech.localised_description)
      has_description = tech_translations[description_key] ~= nil
    end
  end

  local cost = '[[font=count-font]'
  for _, ingredient in ipairs(tech.tech.research_unit_ingredients) do
    cost = cost .. string.format(
      '[img=%s/%s]%d ',
      ingredient.type,
      ingredient.name,
      ingredient.amount)
  end
  cost = cost .. string.format(
    '[img=quantity-time]%d[/font]][font=count-font][img=quantity-multiplier]%d[/font]',
    tech.tech.research_unit_energy / 60,
    tech.research_unit_count)

  local tooltip_lines = {}
  table.insert(tooltip_lines, {'',
    '[font=heading-2]',
    tech.tech.localised_name,
    '[/font]'})
  if has_description then
    table.insert(tooltip_lines, tech.tech.localised_description)
  end
  table.insert(tooltip_lines, cost)
  table.insert(tooltip_lines, {'factorio-research-queue.tech-button-enqueue-last'})
  table.insert(tooltip_lines, {'factorio-research-queue.tech-button-enqueue-second'})
  table.insert(tooltip_lines, {'factorio-research-queue.tech-button-dequeue'})
  table.insert(tooltip_lines, {'factorio-research-queue.tech-button-open'})

  local tooltip = {''}
  do
    local first = true
    for _, line in ipairs(tooltip_lines) do
      if not first then
        table.insert(tooltip, '\n')
      end
      table.insert(tooltip, line)
      first = false
    end
  end

  gui_data.button.tooltip = tooltip
end

local function build(player, parent, tech, list_type)
  local gui_data = guilib.build(parent, {
    {
      type = 'flow',
      style = 'rq_tech_button_container_'..list_type,
      direction = 'vertical',
      children = {
        {
          ref = {'button'},
          type = 'sprite-button',
          actions = {
            on_click = { type = 'on_click_tech_button', tech = tech.id },
          },
          sprite = 'technology/'..tech.tech.name,
          number = tech.level,
          mouse_button_filter = {'left', 'right'},
        },
        {
          ref = {'progressbar'},
          type = 'progressbar',
          style = 'rq_tech_button_progressbar_'..list_type,
        },
      },
    },
  })

  update_tech_button_tooltip(player, gui_data, tech)

  return gui_data
end

return {
  build = build,
  update_tech_button_tooltip = update_tech_button_tooltip,
}
