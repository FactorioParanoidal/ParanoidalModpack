local G = require("graph")
local Goal = require("goal")
local M = {}
local ROOT = "ptt_native"
local SIZES = {48, 64, 80, 96}
local QUEUE_SLOTS = 7 -- engine limit measured on 2.0.77: the 8th add_research is rejected
local NAV_WIDTH = 190
local MAX_WAVES = 5
local COLORS = {done={0.55,0.8,0.55}, available={1,0.85,0.35}, locked={0.65,0.65,0.65},
  current={0.3,0.85,1}, queued={0.5,0.7,1}, disabled={0.6,0.6,0.6}, trigger={0.9,0.6,1},
  path={1,0.65,0.35}, goal={1,0.8,0.2}, warn={1,0.45,0.35}, name={0.9,0.9,0.9}, dim={0.6,0.6,0.6}}
local STYLES = {done="slot_sized_button_green", available="yellow_slot_button", locked="slot_sized_button",
  current="slot_sized_button_blue", queued="slot_sized_button_blue", disabled="red_slot_button",
  trigger="slot_sized_button"}

local function state(p)
  storage.native_players = storage.native_players or {}
  local s = storage.native_players[p.index]
  if not s then
    -- chain=false: the full tree is shown until the player picks a technology (then the chain turns on).
    s = { size=2, chain=false, query="", translations={}, pending={}, request_index=1, expanded={} }
    storage.native_players[p.index] = s
  end
  s.expanded = s.expanded or {}
  return s
end
M.state = state
local function graph(p) return Goal.graph(p.force) end
M.graph = graph
local function root(p) return p.gui.screen[ROOT] end
M.root = root
local function tags_of(action, extra)
  local tags = {ptt=true, action=action}
  for k, v in pairs(extra or {}) do tags[k] = v end
  return tags
end
local function button(parent, action, caption, extra)
  return parent.add{type="button", caption=caption, tags=tags_of(action, extra)}
end
local function mini(parent, action, caption, tooltip, extra, sprite)
  local b
  if sprite and helpers.is_valid_sprite_path(sprite) then
    b = parent.add{type="sprite-button", sprite=sprite, tags=tags_of(action, extra), style="mini_button"}
    b.style.size = 20; b.style.padding = 2
  else
    b = button(parent, action, caption, extra)
    b.style = "mini_button"; b.style.size = 20; b.style.font = "default-bold"
  end
  b.tooltip = tooltip
  return b
end
local function text(parent, caption, width)
  local l = parent.add{type="label", caption=caption}
  l.style.single_line=false
  if width then l.style.width=width end
  return l
end
local function title(parent, caption)
  return parent.add{type="label", caption=caption, style="heading_2_label"}
end
local function sorted_keys(t)
  local a={}; for n in pairs(t) do a[#a+1]=n end; table.sort(a); return a
end
local function pack_caption(item)
  if not item then return {"ptt.era-none"} end
  local proto = prototypes.item[item]
  return {"", "[item="..item.."] ", proto and proto.localised_name or item}
end
local TRIGGERS = {["craft-item"]=true, ["mine-entity"]=true, ["craft-fluid"]=true, ["build-entity"]=true,
  ["send-item-to-orbit"]=true, ["capture-spawner"]=true, ["create-space-platform"]=true, ["scripted"]=true}
local function trigger_kind(name)
  local t = prototypes.technology[name]
  local tr = t and t.research_trigger
  if not tr then return nil end
  return TRIGGERS[tr.type] and tr.type or "other", tr
end
local function thing(kind, id)
  if type(id) == "table" then id = id.name end
  if not id then return "" end
  local proto = (kind == "item" and prototypes.item[id]) or (kind == "entity" and prototypes.entity[id])
    or (kind == "fluid" and prototypes.fluid[id])
  if not proto then return id end
  return {"", "["..kind.."="..id.."] ", proto.localised_name}
end
-- Exact unlock condition of a trigger technology, e.g. "Craft 50 × [item] Steel plate".
local function trigger_text(name)
  local kind, tr = trigger_kind(name)
  if not kind then return nil end
  if kind == "craft-item" then return {"ptt.trigger-craft-item", tr.count or 1, thing("item", tr.item)} end
  if kind == "craft-fluid" then return {"ptt.trigger-craft-fluid", tr.amount or 1, thing("fluid", tr.fluid)} end
  if kind == "mine-entity" or kind == "build-entity" then return {"ptt.trigger-"..kind, thing("entity", tr.entity)} end
  if kind == "send-item-to-orbit" then return {"ptt.trigger-send-item-to-orbit", thing("item", tr.item)} end
  if kind == "scripted" and tr.trigger_description then return tr.trigger_description end
  return {"ptt.trigger-"..kind}
end
M.trigger_text = trigger_text
local function techbutton(parent, p, name, size, st)
  local t=p.force.technologies[name]
  if not t then return end
  st = st or G.status(p.force,name)
  local b=parent.add{type="sprite-button", sprite="technology/"..name, style=STYLES[st],
    tooltip={"",t.localised_name,"\n",{"ptt.status-"..st}},
    tags={ptt=true,action="select",tech=name}, toggled=state(p).selected==name}
  b.style.size=size
  return b
end

-- Shared per-refresh context: researched snapshot, queue, goal and plan of the chain target.
local function context(p)
  local s, force = state(p), p.force
  local g = graph(p)
  local done = G.snapshot(force)
  local queue, qi = G.queue(force)
  local target = s.pinned or s.selected
  local ctx = { g=g, done=done, queue=queue, qi=qi, goal=Goal.get(force), mark=G.marker() }
  -- "N left" counters depend only on the researched set; reuse them for queue-only events.
  local sig = 0
  for _ in pairs(done) do sig = sig + 1 end
  if not (s.rcache and s.rcache.sig == sig) then s.rcache = { sig = sig, map = {} } end
  ctx.rcache = s.rcache.map
  ctx.plan = target and G.plan(g, force, target, done) or nil
  return ctx
end

local function marker(p, n, st, ctx)
  if st == "done" then return {"ptt.mark-done"}, COLORS.done end
  if st == "current" then
    return {"ptt.mark-current", math.floor(p.force.research_progress * 100)}, COLORS.current
  end
  if st == "queued" then return {"ptt.mark-queued", ctx.qi[n] or "?"}, COLORS.queued end
  if st == "available" then return {"ptt.mark-ready"}, COLORS.available end
  if st == "trigger" then return {"ptt.mark-trigger-"..(trigger_kind(n) or "other")}, COLORS.trigger end
  if st == "disabled" then return {"ptt.mark-disabled"}, COLORS.disabled end
  local left = ctx.rcache[n]
  if not left then left = G.remaining(ctx.g, ctx.done, n, ctx.mark); ctx.rcache[n] = left end
  -- Single accent: technologies on the path to the selected one.
  local on_path = ctx.plan and ctx.plan.set[n]
  return {"ptt.mark-left", left}, on_path and COLORS.path or COLORS.locked
end

local function update_card(p, n, ctx)
  local s = state(p)
  local ref = s.refs and s.refs[n]
  if not (ref and ref.button.valid) then return end
  local st = G.status(p.force, n, ctx.qi, ctx)
  local size = SIZES[s.size]
  if ref.status ~= st then
    ref.button.style = STYLES[st]; ref.button.style.size = size
    ref.status = st
  end
  local t = p.force.technologies[n]
  local node = ctx.g.nodes[n]
  ref.button.tooltip = {"", t.localised_name, "\n", {"ptt.status-"..st}, "\n", {"ptt.card-stage", node and node.depth or "?"}}
  ref.button.toggled = s.selected == n
  ref.name.style.font_color = st == "done" and COLORS.dim or COLORS.name
  local caption, color = marker(p, n, st, ctx)
  ref.marker.caption = caption; ref.marker.style.font_color = color
  local is_goal = ctx.goal and ctx.goal.tech == n
  ref.goal.caption = is_goal and {"ptt.mark-goal"} or ""
  ref.goal.visible = is_goal and true or false
end

local function card(parent, p, n, ctx, size)
  local s = state(p)
  local t = p.force.technologies[n]
  local c = parent.add{type="frame", direction="vertical", style="inside_shallow_frame"}
  c.style.padding=6; c.style.width=size+112; c.style.height=size+90
  local top = c.add{type="flow", direction="horizontal"}
  local b = top.add{type="sprite-button", sprite="technology/"..n, style="slot_sized_button",
    tags={ptt=true, action="select", tech=n}}
  b.style.size = size
  local info = top.add{type="flow", direction="vertical"}
  info.style.vertical_spacing = 2
  local m = info.add{type="label"}; m.style.font = "default-small-semibold"
  m.style.maximal_width = 96; m.style.single_line = false
  local goal = info.add{type="label"}; goal.style.font = "default-small-semibold"
  goal.style.font_color = COLORS.goal
  local name = text(c, t.localised_name, size+100)
  name.style.maximal_height = 60
  name.tooltip = t.localised_name
  s.cards[n] = c
  s.refs[n] = { button=b, name=name, marker=m, goal=goal }
  s.tech_buttons[n] = b
  update_card(p, n, ctx)
end

local function expanded(s, key, default)
  if s.expanded[key] ~= nil then return s.expanded[key] end
  return default
end
local ACTIONABLE = {available=true, current=true, queued=true, trigger=true}

local function count_done(names, done)
  local k = 0
  for _, n in ipairs(names) do if done[n] then k = k + 1 end end
  return k
end

local function columns(s)
  local cw = SIZES[s.size] + 112
  return math.max(1, math.floor((s.tree_width - 24 + 12) / (cw + 12)))
end

-- Open the era containing `name` (and its researched cards if needed) so its card exists.
local function reveal(p, name)
  local s, g = state(p), graph(p)
  local key = g.era_of[name]
  if not key then return end
  s.expanded[key] = true
  local t = p.force.technologies[name]
  if t and t.researched then s.expanded[key.."/done"] = true end
end

function M.focus(p)
  local s=state(p)
  if s.scroll and s.scroll.valid and s.cards and s.focus_key and s.headers and s.headers[s.focus_key]
    and s.headers[s.focus_key].valid then
    s.scroll.scroll_to_element(s.headers[s.focus_key],"top-third")
  elseif s.scroll and s.scroll.valid and s.cards and s.selected and s.cards[s.selected] then
    s.scroll.scroll_to_element(s.cards[s.selected],"top-third")
  elseif s.scroll and s.scroll.valid then
    s.scroll.scroll_to_top()
  end
end

local function choose(p)
  local s,g=state(p),graph(p)
  if s.user_selected and s.selected and g.nodes[s.selected] then return end
  -- Without the player's own choice: the force goal first, then the current research, then anything available.
  local goal=Goal.get(p.force)
  if goal and g.nodes[goal.tech] then s.selected=goal.tech; return end
  if s.selected and g.nodes[s.selected] then return end
  local q=p.force.research_queue
  if q and q[1] and g.nodes[q[1].name] then s.selected=q[1].name; return end
  for d=1,g.max_depth do
    for _,n in ipairs(g.layers[d] or {}) do
      if G.status(p.force,n)=="available" then s.selected=n; return end
    end
  end
  s.selected=g.names[1]
end

local function nav(p, ctx, shown)
  local s = state(p)
  if not (s.nav and s.nav.valid) then return end
  s.nav.clear(); s.nav_buttons = {}
  for _, era in ipairs(ctx.g.eras) do
    if shown[era.key] then
      local b = button(s.nav, "nav", "", {key=era.key})
      b.style.horizontally_stretchable = true; b.style.width = NAV_WIDTH - 24
      b.style.horizontal_align = "left"
      b.tooltip = pack_caption(era.item)
      s.nav_buttons[era.key] = b
    end
  end
  M.nav_captions(p, ctx, shown)
end

function M.nav_captions(p, ctx, shown, current)
  local s = state(p)
  current = current or (s.selected and ctx.g.era_of[s.selected])
  for key, b in pairs(s.nav_buttons or {}) do
    local info = shown[key]
    if b.valid and info then
      local era
      for _, e in ipairs(ctx.g.eras) do if e.key == key then era = e; break end end
      local icon = era.item and ("[item="..era.item.."] ") or ""
      local name = era.item and "" or {"ptt.era-none-short"}
      local done = count_done(info, ctx.done)
      b.caption = {"", key == current and "→ " or "", icon, name, " ", done, "/", #info}
      b.style.font_color = done == #info and COLORS.done or {1,1,1}
    end
  end
end

-- One continuous grid per era, ordered by dependency stage. Researched cards are hidden
-- behind a per-era "show researched" switch (always shown while searching).
function M.tree(p, focus)
  local s,g=state(p),graph(p)
  if not root(p) then return end
  s.scroll.clear(); s.cards={}; s.refs={}; s.tech_buttons={}; s.headers={}; s.era_labels={}; s.open_now={}
  local ctx = context(p)
  local stack=s.scroll.add{type="flow",direction="vertical"}
  stack.style.vertical_spacing=8
  local subset=s.chain and G.chain(g,s.pinned or s.selected) or nil
  local query=G.lower(s.query)
  local searching = query ~= ""
  local total=0
  local size=SIZES[s.size]
  local cols = columns(s)
  local shown = {}
  local function keep(n)
    if searching then
      return G.lower(n):find(query,1,true) or G.lower(s.translations[n] or ""):find(query,1,true)
    end
    return not subset or subset[n]
  end
  for _, era in ipairs(g.eras) do
    local names = {}
    for _, d in ipairs(era.depths) do
      for _, n in ipairs(era.layers[d]) do if keep(n) then names[#names+1] = n end end
    end
    if #names > 0 then
      shown[era.key] = names
      local done = count_done(names, ctx.done)
      local default = done ~= #names
      if not subset then
        -- Full view: open only eras with something to research now.
        default = false
        for _, n in ipairs(names) do
          if ACTIONABLE[G.status(p.force, n, ctx.qi, ctx)] then default = true; break end
        end
      end
      local open = searching or expanded(s, era.key, default)
      local show_done = searching or expanded(s, era.key.."/done", false)
      s.open_now[era.key] = open; s.open_now[era.key.."/done"] = show_done
      local head = stack.add{type="flow", direction="horizontal"}
      head.style.vertical_align = "center"
      if not searching then
        mini(head, "toggle", open and "−" or "+", {open and "ptt.collapse" or "ptt.expand"}, {key=era.key})
      end
      local label = head.add{type="label", style="heading_2_label",
        caption={"ptt.era", pack_caption(era.item), done, #names}}
      label.style.font = "heading-1"
      if done == #names then label.style.font_color = COLORS.done end
      if open and done > 0 and done < #names and not searching then
        local tb = button(head, "toggle", show_done and {"ptt.hide-done"} or {"ptt.show-done", done}, {key=era.key.."/done"})
        tb.style.font = "default-small"; tb.style.height = 24; tb.style.left_margin = 12
      end
      s.headers[era.key] = head; s.era_labels[era.key] = label
      if open then
        local grid = stack.add{type="table", column_count=cols}
        grid.style.horizontal_spacing = 12; grid.style.vertical_spacing = 12
        grid.style.left_margin = 16
        grid.style.horizontally_stretchable = false
        local all_done = done == #names
        for _, n in ipairs(names) do
          if show_done or all_done or not ctx.done[n] then card(grid, p, n, ctx, size) end
        end
      end
      total = total + #names
    end
  end
  if total==0 then text(stack,{"ptt.no-results"},400) end
  s.shown=total
  s.shown_eras = shown
  nav(p, ctx, shown)
  if focus then
    M.focus(p)
    -- Native scroll bounds settle after layout; repeat once on the next update.
    s.focus_due=game.tick+1
  else
    s.focus_key=nil
  end
end

-- Goal in the title bar: one clickable line, pause/resume and a small clear button.
function M.goal_line(p, ctx)
  local s = state(p)
  if not (s.goal_flow and s.goal_flow.valid) then return end
  s.goal_flow.clear()
  local goal = ctx.goal
  if not goal then return end
  local t = p.force.technologies[goal.tech]
  if not t then return end
  local plan = G.plan(ctx.g, p.force, goal.tech, ctx.done)
  local by = (goal.by and goal.by ~= "") and goal.by or "?"
  local b = button(s.goal_flow, "select", {"ptt.goal-line", t.localised_name, plan and plan.count or 0},
    {tech=goal.tech})
  b.style.font_color = COLORS.goal; b.style.height = 28
  b.tooltip = {"ptt.goal-line-hint", by}
  if goal.paused then
    local pt = p.force.technologies[goal.paused]
    local l = s.goal_flow.add{type="label", caption={"ptt.goal-paused-line", pt and pt.localised_name or goal.paused}}
    l.style.font_color = COLORS.warn
    local r = button(s.goal_flow, "goal_resume", {"ptt.goal-resume"}); r.style.height = 28
  end
  mini(s.goal_flow, "goal_clear", "×", {"ptt.goal-clear"})
end

-- Research queue: icons only. Click selects, Shift+click moves up, right click or × removes.
-- Items placed by the goal use a yellow frame.
function M.queue_bar(p, ctx)
  local s = state(p)
  if not (s.queue_flow and s.queue_flow.valid) then return end
  s.queue_flow.clear(); s.progress = nil
  local ql = s.queue_flow.add{type="label", caption={"ptt.queue"}, style="caption_label"}
  ql.tooltip = {"ptt.queue-hint"}
  local force = p.force
  local goal = ctx.goal
  for i = 1, math.max(QUEUE_SLOTS, #ctx.queue) do
    local n = ctx.queue[i]
    local slot = s.queue_flow.add{type="flow", direction="horizontal"}
    slot.style.horizontal_spacing = 0
    if n then
      local t = force.technologies[n]
      local ours = goal and goal.ours and goal.ours[n]
      local style = i == 1 and "slot_sized_button_blue" or (ours and "yellow_slot_button" or "slot_sized_button")
      local b = slot.add{type="sprite-button", sprite="technology/"..n, style=style,
        tags={ptt=true, action="q_slot", tech=n, index=i},
        tooltip={"", t.localised_name, "\n", {"ptt.status-"..(i==1 and "current" or "queued")},
          ours and {"", "\n", {"ptt.queue-goal"}} or "", "\n", {"ptt.queue-hint"}}}
      b.style.size = 40
      if i == 1 then
        b.number = math.floor(force.research_progress * 100)
        s.progress = b
      end
      local x = mini(slot, "q_remove", "×", {"ptt.queue-remove"}, {index=i})
    else
      local e = slot.add{type="sprite-button", style="slot_sized_button", enabled=false}
      e.style.size = 40
      local pad = slot.add{type="empty-widget"}; pad.style.width = 20
    end
  end
end

-- Does `n` (transitively) require `p`?
function M.depends(g, n, p)
  if not p then return false end
  local seen, stack = {[n]=true}, {n}
  while #stack > 0 do
    local c = table.remove(stack)
    for _, x in ipairs(g.pre[c] or {}) do
      if x == p then return true end
      if not seen[x] then seen[x] = true; stack[#stack+1] = x end
    end
  end
  return false
end

local function tech_table(parent, p, names, ctx, columns_count)
  local tbl = parent.add{type="table", column_count=columns_count or 5}
  for _, n in ipairs(names) do techbutton(tbl, p, n, 48, G.status(p.force, n, ctx.qi, ctx)) end
  return tbl
end

function M.panel(p)
  local s=state(p)
  if not root(p) then return end
  local body=s.panel; body.clear()
  local t=s.selected and p.force.technologies[s.selected]
  if not t then text(body,{"ptt.select-hint"}); return end
  local ctx = context(p)
  M.help(p, ctx)
  local width=s.panel_width-30
  local h=text(body,t.localised_name,width); h.style.font="heading-2"
  techbutton(body,p,t.name,64)
  local st=G.status(p.force,t.name)
  local l=text(body,{"ptt.status-"..st},width); l.style.font_color=COLORS[st]
  if t.prototype.research_trigger then
    local cond = text(body, trigger_text(t.name), width); cond.style.font_color = COLORS.trigger
    text(body,{"ptt.trigger-hint"},width)
  else
    title(body,{"ptt.cost"})
    local ingredients=body.add{type="table",column_count=5}
    for _,i in ipairs(t.research_unit_ingredients or {}) do
      ingredients.add{type="sprite-button",sprite="item/"..i.name,number=i.amount,
        elem_tooltip={type="item",name=i.name},style="slot_button"}
    end
    text(body,{"ptt.units",t.research_unit_count,t.research_unit_energy/60},width)
  end
  local b=button(body,"research",{"ptt.research"})
  b.style.width=width; b.tooltip={"ptt.research-hint"}
  b.enabled=st=="available"
  local goal = ctx.goal
  local gb
  if goal and goal.tech == t.name then
    gb = button(body, "goal_clear", {"ptt.goal-clear"})
  else
    gb = button(body, "goal_set", {"ptt.goal-set-button"}); gb.tooltip = {"ptt.goal-hint"}
    gb.enabled = st ~= "done"
  end
  gb.style.width = width
  if s.notice then text(body,s.notice,width) end
  -- Path to the selected technology.
  local plan = st ~= "done" and G.plan(ctx.g, p.force, t.name, ctx.done) or nil
  if plan then
    title(body, {"ptt.path"})
    text(body, {"ptt.path-count", plan.count}, width)
    if #plan.cost > 0 then
      local costs = body.add{type="table", column_count=5}
      for _, c in ipairs(plan.cost) do
        costs.add{type="sprite-button", sprite="item/"..c.name, number=c.amount,
          elem_tooltip={type="item", name=c.name}, style="slot_button"}
      end
    end
    if #plan.ready > 0 then
      local r = title(body, {"ptt.path-ready", #plan.ready}); r.style.font_color = COLORS.available
      tech_table(body, p, plan.ready, ctx)
    end
    if #plan.triggers > 0 then
      local r = title(body, {"ptt.path-triggers", #plan.triggers}); r.style.font_color = COLORS.trigger
      tech_table(body, p, plan.triggers, ctx)
    end
    if #plan.blocked > 0 then
      local r = title(body, {"ptt.path-blocked", #plan.blocked}); r.style.font_color = COLORS.warn
      tech_table(body, p, plan.blocked, ctx)
    end
    local rest = 0
    for k = 2, #plan.waves do
      if k <= MAX_WAVES then
        title(body, {"ptt.path-wave", k, #plan.waves[k]})
        tech_table(body, p, plan.waves[k], ctx)
      else rest = rest + #plan.waves[k] end
    end
    if rest > 0 then text(body, {"ptt.path-more", rest, #plan.waves - MAX_WAVES}, width) end
  end
  title(body,{"ptt.parents"})
  tech_table(body, p, sorted_keys(t.prerequisites), ctx)
  title(body,{"ptt.children"})
  local node = ctx.g.nodes[t.name]
  tech_table(body, p, node and node.children or {}, ctx)
  title(body,{"ptt.unlocks"})
  local effects=body.add{type="table",column_count=5}
  for _,effect in ipairs(t.prototype.effects or {}) do
    if effect.type=="unlock-recipe" and prototypes.recipe[effect.recipe] then
      effects.add{type="sprite-button",sprite="recipe/"..effect.recipe,
        elem_tooltip={type="recipe",name=effect.recipe},style="slot_button"}
    end
  end
end

-- View switch (full tree / chain), pin and the "View" menu state.
local function update_view(p)
  local s = state(p)
  if s.view_all and s.view_all.valid then
    s.view_all.toggled = not s.chain
    s.view_chain.toggled = s.chain and true or false
    s.pin_button.enabled = s.chain and true or false
    s.pin_button.toggled = s.pinned ~= nil
  end
  if s.menu and s.menu.valid then
    s.menu.visible = s.menu_open and true or false
    if s.size_label and s.size_label.valid then s.size_label.caption = {"ptt.menu-size-value", SIZES[s.size]} end
  end
end

-- Help block: one "what to do now" line plus a collapsible how-to (state remembered per player).
local function next_step(p, ctx)
  local s = state(p)
  local goal = ctx.goal
  if goal and goal.paused then return {"ptt.help-step-paused"}, COLORS.warn end
  if goal then return {"ptt.help-step-goal"}, COLORS.done end
  if not s.user_selected then return {"ptt.help-step-select"}, COLORS.available end
  local t = s.selected and p.force.technologies[s.selected]
  if t and t.researched then return {"ptt.help-step-done"}, COLORS.available end
  return {"ptt.help-step-set-goal"}, COLORS.available
end

function M.help(p, ctx)
  local s = state(p)
  if not (s.help and s.help.valid) then return end
  s.help.clear()
  local width = NAV_WIDTH - 12
  local step, color = next_step(p, ctx)
  local l = text(s.help, step, width); l.style.font = "default-semibold"; l.style.font_color = color
  local head = s.help.add{type="flow", direction="horizontal"}
  head.style.vertical_align = "center"
  mini(head, "help", s.help_hidden and "+" or "−", {s.help_hidden and "ptt.help-show" or "ptt.help-hide"})
  local h = head.add{type="label", caption={"ptt.help-title"}, style="caption_label"}
  h.tooltip = {s.help_hidden and "ptt.help-show" or "ptt.help-hide"}
  if not s.help_hidden then
    for k = 1, 6 do
      local x = text(s.help, {"ptt.help-"..k}, width); x.style.font = "default-small"
    end
  end
end

function M.close(p)
  local s=state(p)
  local r=root(p)
  if r then r.destroy() end
  s.scroll=nil; s.panel=nil; s.cards=nil; s.refs=nil; s.status_labels=nil; s.summary=nil; s.open=false
  s.nav=nil; s.queue_flow=nil; s.goal_flow=nil; s.progress=nil; s.headers=nil
  s.view_all=nil; s.view_chain=nil; s.pin_button=nil; s.menu=nil; s.size_label=nil; s.help=nil
end

function M.open(p)
  if root(p) then return end
  -- Scripts may enable/disable technologies during play; rebuild the cached graph if needed.
  local graphs = storage.native_graphs
  if graphs and graphs[p.force.index] and G.stale(graphs[p.force.index], p.force.technologies) then
    graphs[p.force.index] = nil
  end
  local s=state(p); choose(p)
  local w=math.max(800,math.floor(p.display_resolution.width/p.display_scale)-24)
  local h=math.max(500,math.floor(p.display_resolution.height/p.display_scale)-24)
  local pw=math.min(300,math.floor(w*0.3)); s.panel_width=pw
  local r=p.gui.screen.add{type="frame",name=ROOT,direction="vertical"}
  r.style.width=w; r.style.height=h; r.location={12,12}
  -- Single title row: title, view switch, pin, search, goal, menu, close.
  local header=r.add{type="flow",direction="horizontal"}
  header.style.vertical_align = "center"; header.style.horizontal_spacing = 6
  title(header,{"ptt.title"})
  local sw = header.add{type="flow", direction="horizontal"}
  sw.style.left_margin = 16; sw.style.horizontal_spacing = 0
  s.view_all = button(sw, "view_all", {"ptt.view-all"}); s.view_all.tooltip = {"ptt.view-all-hint"}
  s.view_chain = button(sw, "view_chain", {"ptt.view-chain"}); s.view_chain.tooltip = {"ptt.view-chain-hint"}
  s.pin_button = button(header, "pin", {"ptt.pin"}); s.pin_button.tooltip = {"ptt.pin-hint"}
  for _, x in ipairs({s.view_all, s.view_chain, s.pin_button}) do x.style.height = 28 end
  local icon = header.add{type="sprite", sprite="utility/search", tooltip={"ptt.search-hint"}}
  icon.style.left_margin = 16; icon.style.size = 20; icon.style.stretch_image_to_widget_size = true
  local field=header.add{type="textfield",name="ptt_query",text=s.query,tags={ptt=true,action="search"}}
  field.style.width=200; field.tooltip = {"ptt.search-hint"}
  mini(header, "clear", "×", {"ptt.clear"})
  local gf = header.add{type="flow", direction="horizontal"}
  gf.style.left_margin = 16; gf.style.vertical_align = "center"
  s.goal_flow = gf
  local gap=header.add{type="empty-widget"}; gap.style.horizontally_stretchable=true
  local mb = button(header, "menu", {"ptt.menu"}); mb.style.height = 28; mb.tooltip = {"ptt.menu-hint"}
  local close = header.add{type="sprite-button", sprite="utility/close", style="frame_action_button",
    tags={ptt=true, action="close"}, tooltip={"ptt.close"}}
  -- "View" menu: rarely used settings, hidden by default.
  s.menu = r.add{type="frame", style="inside_shallow_frame", direction="horizontal"}
  s.menu.style.padding = 4
  local menu = s.menu.add{type="flow", direction="horizontal"}
  menu.style.horizontal_spacing = 6; menu.style.vertical_align = "center"
  menu.add{type="label", caption={"ptt.menu-size"}}.style.top_margin = 2
  mini(menu, "smaller", "−", {"ptt.menu-smaller"})
  s.size_label = menu.add{type="label"}
  mini(menu, "larger", "+", {"ptt.menu-larger"})
  local fb = button(menu, "focus", {"ptt.focus"}); fb.style.height = 24; fb.style.left_margin = 16
  local q = r.add{type="flow", direction="horizontal"}
  q.style.vertical_align = "center"; q.style.horizontal_spacing = 6
  s.queue_flow = q
  local body=r.add{type="flow",direction="horizontal"}
  body.style.horizontal_spacing=8
  local bh = h - 96
  -- Left column: era navigator (own scroll) above a fixed help block.
  local left = body.add{type="flow", direction="vertical"}
  left.style.width = NAV_WIDTH; left.style.height = bh; left.style.vertical_spacing = 6
  local navpane = left.add{type="scroll-pane", horizontal_scroll_policy="never", vertical_scroll_policy="auto"}
  navpane.style.width = NAV_WIDTH
  navpane.style.vertically_stretchable = true; navpane.style.vertically_squashable = true
  local help = left.add{type="frame", style="inside_shallow_frame", direction="vertical"}
  help.style.width = NAV_WIDTH; help.style.padding = 6
  help.style.vertically_squashable = false
  s.help = help.add{type="flow", direction="vertical"}
  s.help.style.vertical_spacing = 4
  s.nav = navpane.add{type="flow", direction="vertical"}
  s.nav.style.vertical_spacing = 2
  s.tree_width = w - pw - NAV_WIDTH - 40
  s.scroll=body.add{type="scroll-pane",name="ptt_scroll",horizontal_scroll_policy="never",vertical_scroll_policy="always"}
  s.scroll.style.width=s.tree_width; s.scroll.style.height=bh
  local panel=body.add{type="scroll-pane",horizontal_scroll_policy="never",vertical_scroll_policy="auto"}
  panel.style.width=pw; panel.style.height=bh
  s.panel=panel.add{type="flow",direction="vertical"}; s.panel.style.vertical_spacing=8
  s.open=true -- no world camera or surface exists in this implementation
  p.opened=r
  update_view(p)
  local goal = Goal.get(p.force)
  if s.selected and (s.user_selected or (goal and goal.tech == s.selected)) then reveal(p, s.selected) end
  M.tree(p,true); M.panel(p)
  local ctx = context(p)
  M.goal_line(p, ctx); M.queue_bar(p, ctx); M.help(p, ctx)
end

local function clear_search(p)
  local s = state(p)
  s.query = ""
  local r = root(p)
  if r then
    for _, child in pairs(r.children) do if child.ptt_query then child.ptt_query.text = "" end end
  end
end

function M.select(p,name)
  if not p.force.technologies[name] then return end
  local s=state(p); s.selected=name; s.notice=nil; s.focus_key=nil
  if not s.user_selected then
    -- First own choice: switch from the full overview to the selected chain.
    s.user_selected = true; s.chain = true
    update_view(p)
  end
  if s.pinned then
    -- Keep the existing tree and both scroll positions; only selection/details change.
    s.focus_due=nil
    for n,b in pairs(s.tech_buttons or {}) do if b.valid then b.toggled=n==name end end
    M.panel(p)
    return
  end
  -- A click from search exits search so the chosen chain remains navigable.
  if not root(p) then return end
  clear_search(p)
  reveal(p, name)
  M.tree(p,true); M.panel(p)
end

-- Mark open windows of every player in the force for a deferred refresh.
function M.refresh_force(force)
  for _, q in pairs(force.connected_players) do
    if root(q) then state(q).refresh_due = true end
  end
end

local function rewrite_queue(force, list)
  storage.ptt_filling = true
  force.research_queue = list
  storage.ptt_filling = nil
end

local function queue_remove(p, i)
  local force = p.force
  local list = G.queue(force)
  local n = list[i]
  if not n then return end
  local goal = Goal.get(force)
  if goal and not goal.paused and Goal.needed(force, n) then Goal.pause(force, n) end
  local new = {}
  for k, x in ipairs(list) do if k ~= i then new[#new+1] = x end end
  rewrite_queue(force, new)
  if goal and goal.ours then goal.ours[n] = nil end
  Goal.fill(force)
end

local function queue_up(p, i)
  local force, s = p.force, state(p)
  local list = G.queue(force)
  local n = list[i]
  if not n or i < 2 then return end
  if M.depends(graph(p), n, list[i-1]) then s.notice = {"ptt.queue-move-rejected"}; return end
  local new = {}
  for k, x in ipairs(list) do new[k] = x end
  new[i], new[i-1] = new[i-1], new[i]
  rewrite_queue(force, new)
  local after = G.queue(force)
  if #after ~= #list then rewrite_queue(force, list); s.notice = {"ptt.queue-move-rejected"} end
end
M.queue_up = queue_up

function M.click(e)
  if not (e.element and e.element.valid) then return end
  local tag=e.element.tags
  if not tag.ptt then return end
  local p=game.get_player(e.player_index); if not p then return end
  local s=state(p); local a=tag.action
  local force = p.force
  if a=="close" then M.close(p)
  elseif a=="select" then M.select(p,tag.tech)
  elseif a=="help" then
    s.help_hidden = not s.help_hidden
    M.help(p, context(p))
  elseif a=="menu" then
    s.menu_open = not s.menu_open; update_view(p)
  elseif a=="smaller" or a=="larger" then
    s.size=math.max(1,math.min(#SIZES,s.size+(a=="smaller" and -1 or 1)))
    update_view(p); M.tree(p,true)
  elseif a=="focus" then
    clear_search(p); s.focus_key=nil; choose(p)
    if s.selected then reveal(p, s.selected) end
    M.tree(p,true)
  elseif a=="clear" then
    clear_search(p); M.tree(p,true)
  elseif a=="view_all" or a=="view_chain" then
    s.chain = a=="view_chain"
    if not s.chain then s.pinned=nil end
    update_view(p); M.tree(p,true)
  elseif a=="pin" then
    if s.chain then
      s.pinned = (not s.pinned) and s.selected or nil
      s.focus_due=nil
      update_view(p)
      if not s.pinned then M.tree(p,true) end
    end
  elseif a=="toggle" then
    local key = tag.key
    local era = key:match("^(.-)/done$") or key
    local cur = s.headers and s.headers[era] and s.headers[era].valid
    s.expanded[key] = not (s.open_now and s.open_now[key])
    s.focus_key = cur and era or nil
    M.tree(p, true)
  elseif a=="nav" then
    local h = s.headers and s.headers[tag.key]
    if h and h.valid then s.scroll.scroll_to_element(h, "top-third") end
  elseif a=="research" then
    if s.selected and G.status(force,s.selected)=="available" then
      local ok=force.add_research(s.selected)
      s.notice={ok and "ptt.added" or "ptt.rejected"}
    else s.notice={"ptt.rejected"} end
    M.panel(p); M.refresh(p)
  elseif a=="goal_set" then
    if s.selected and Goal.set(force, s.selected, p) then s.notice = {"ptt.goal-accepted"} end
    M.refresh_force(force); M.panel(p); M.refresh(p)
  elseif a=="goal_clear" then
    local goal = Goal.get(force)
    if goal then
      local t = force.technologies[goal.tech]
      force.print({"ptt.goal-cleared", p.name, t and t.localised_name or goal.tech})
      Goal.clear(force)
    end
    M.refresh_force(force); M.panel(p); M.refresh(p)
  elseif a=="goal_resume" then
    Goal.resume(force)
    M.refresh_force(force); M.panel(p); M.refresh(p)
  elseif a=="q_slot" then
    if e.button == defines.mouse_button_type.right then
      queue_remove(p, tag.index)
    elseif e.shift then
      queue_up(p, tag.index); M.panel(p)
    else
      M.select(p, tag.tech); return
    end
    M.refresh_force(force); M.refresh(p)
  elseif a=="q_remove" then
    queue_remove(p, tag.index)
    M.refresh_force(force); M.refresh(p)
  end
end

function M.changed(e)
  if not (e.element and e.element.valid and e.element.tags.ptt) then return end
  local p=game.get_player(e.player_index); local s=state(p)
  if e.element.tags.action=="search" then s.query=e.element.text; s.search_due=game.tick+15 end
end

-- In-place refresh: statuses, markers, counters, navigator, queue and goal line. No tree rebuild,
-- so the scroll position is preserved.
function M.refresh(p)
  local s=state(p)
  if not s.open or not root(p) then return end
  local ctx = context(p)
  for n in pairs(s.refs or {}) do update_card(p, n, ctx) end
  for key, label in pairs(s.era_labels or {}) do
    local names = s.shown_eras and s.shown_eras[key]
    if label.valid and names then
      local era
      for _, e in ipairs(ctx.g.eras) do if e.key == key then era = e; break end end
      local done = count_done(names, ctx.done)
      label.caption = {"ptt.era", pack_caption(era.item), done, #names}
      if done == #names then label.style.font_color = COLORS.done end
    end
  end
  M.nav_captions(p, ctx, s.shown_eras or {})
  M.goal_line(p, ctx); M.queue_bar(p, ctx); M.help(p, ctx)
end

function M.tick()
  for _,p in pairs(game.connected_players) do
    local s=storage.native_players and storage.native_players[p.index]
    if s and s.open and root(p) then
      if s.search_due and game.tick>=s.search_due then s.search_due=nil; M.tree(p,false) end
      if s.focus_due and game.tick>=s.focus_due then s.focus_due=nil; M.focus(p); s.focus_key=nil end
      if s.progress and s.progress.valid then
        s.progress.number = math.floor(p.force.research_progress * 100)
      end
      local names=graph(p).names
      for _=1,32 do
        local n=names[s.request_index]
        if not n then break end
        s.request_index=s.request_index+1
        local id=p.request_translation(p.force.technologies[n].localised_name)
        if id then s.pending[id]=n end
      end
    end
  end
end
function M.translated(e)
  local s=storage.native_players and storage.native_players[e.player_index]
  if not s then return end
  local name=s.pending[e.id]
  if name then
    s.pending[e.id]=nil
    if e.translated then s.translations[name]=e.result end
    if s.query~="" then s.search_due=game.tick+30 end
  end
end
function M.invalidate()
  for _,p in pairs(game.players) do
    M.close(p)
    -- Close only our old prototype GUI; preserve the old private surface/save data.
    for _,name in ipairs({"ptt_toolbar","ptt_view","ptt_panel"}) do
      if p.gui.screen[name] then p.gui.screen[name].destroy() end
    end
    local old=storage.players and storage.players[p.index]
    if old then
      for _,f in pairs(old.frames or {}) do if f.valid then f.destroy() end end
      if old.select_box and old.select_box.valid then old.select_box.destroy() end
      old.open=false
    end
  end
  storage.native_players={}; storage.native_graphs={}
end
return M
