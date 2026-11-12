-- Small GUI builder: G.add(parent, spec, refs) where spec has the LuaGuiElement add() fields plus
-- `style_mods` (table applied to element.style), `ref` (name in refs), `children` (list of specs),
-- `elem_mods` (fields set after creation).
local G = {}

function G.add(parent, spec, refs)
  local children, style_mods, ref, elem_mods = spec.children, spec.style_mods, spec.ref, spec.elem_mods
  spec.children, spec.style_mods, spec.ref, spec.elem_mods = nil, nil, nil, nil
  local e = parent.add(spec)
  spec.children, spec.style_mods, spec.ref, spec.elem_mods = children, style_mods, ref, elem_mods
  if style_mods then
    for k, v in pairs(style_mods) do e.style[k] = v end
  end
  if elem_mods then
    for k, v in pairs(elem_mods) do e[k] = v end
  end
  if ref and refs then refs[ref] = e end
  if children then
    for _, c in ipairs(children) do G.add(e, c, refs) end
  end
  return e
end

function G.titlebar(frame, caption, action, extra)
  local bar = frame.add({ type = "flow", direction = "horizontal" })
  bar.style.horizontal_spacing = 8
  bar.drag_target = frame
  bar.add({ type = "label", caption = caption, style = "frame_title", ignored_by_interaction = true })
  local drag = bar.add({ type = "empty-widget", style = "draggable_space_header", ignored_by_interaction = true })
  drag.style.height = 24
  drag.style.horizontally_stretchable = true
  drag.style.right_margin = 4
  if extra then
    for _, spec in ipairs(extra) do G.add(bar, spec) end
  end
  bar.add({ type = "sprite-button", style = "frame_action_button", sprite = "utility/close",
    tooltip = { "gui.close-instruction" }, tags = { ppd = action } })
  return bar
end

function G.spacer(parent)
  local w = parent.add({ type = "empty-widget" })
  w.style.horizontally_stretchable = true
  return w
end

-- set a progressbar colour from a status colour table {r,g,b}
function G.bar_color(bar, c)
  bar.style.color = { r = c[1], g = c[2], b = c[3] }
end

-- replace all children of a flow with label lines; each item { msg, level }
local LEVEL_SPRITE = { ok = "utility/status_working", warn = "utility/status_yellow", bad = "utility/status_not_working" }
function G.lines(parent, items, width)
  parent.clear()
  for _, it in ipairs(items) do
    local row = parent.add({ type = "flow", direction = "horizontal" })
    row.style.vertical_align = "top"
    row.style.horizontal_spacing = 6
    if it.level then
      local s = row.add({ type = "sprite", sprite = LEVEL_SPRITE[it.level] or LEVEL_SPRITE.warn })
      s.style.top_margin = 3
    end
    local l = row.add({ type = "label", caption = it.msg })
    l.style.single_line = false
    if width then l.style.maximal_width = width end
  end
end

return G
