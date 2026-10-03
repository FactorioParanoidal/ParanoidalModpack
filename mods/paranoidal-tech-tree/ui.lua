local G = require("graph")
local M = {}
local ROOT = "ptt_native"
local SIZES = {48, 64, 80, 96}
local COLORS = {done={0.4,1,0.4}, available={1,0.85,0.35}, locked={0.7,0.7,0.7},
  current={0.3,0.85,1}, queued={0.5,0.7,1}, disabled={0.6,0.6,0.6}, trigger={0.9,0.6,1}}
local function state(p)
  storage.native_players = storage.native_players or {}
  local s = storage.native_players[p.index]
  if not s then
    s = { size=2, chain=true, query="", translations={}, pending={}, request_index=1 }
    storage.native_players[p.index] = s
  end
  return s
end
M.state = state
local function graph(p)
  storage.native_graphs = storage.native_graphs or {}
  local id = p.force.index
  if not storage.native_graphs[id] then storage.native_graphs[id] = G.build(p.force.technologies) end
  return storage.native_graphs[id]
end
M.graph = graph
local function root(p) return p.gui.screen[ROOT] end
M.root = root
local function button(parent, action, caption, tech)
  return parent.add{type="button", caption=caption, tags={ptt=true, action=action, tech=tech}}
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
local function techbutton(parent, p, name, size)
  local t=p.force.technologies[name]
  if not t then return end
  local st=G.status(p.force,name)
  local b=parent.add{type="sprite-button", sprite="technology/"..name,
    tooltip={"",t.localised_name,"\n",{"ptt.status-"..st}},
    tags={ptt=true,action="select",tech=name}, toggled=state(p).selected==name}
  b.style.size=size
  return b
end
function M.focus(p)
  local s=state(p)
  if s.scroll and s.scroll.valid and s.cards and s.selected and s.cards[s.selected] then
    s.scroll.scroll_to_element(s.cards[s.selected],"top-third")
  elseif s.scroll and s.scroll.valid then
    s.scroll.scroll_to_top(); s.scroll.scroll_to_left()
  end
end
local function choose(p)
  local s,g=state(p),graph(p)
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
function M.tree(p, focus)
  local s,g=state(p),graph(p)
  if not root(p) then return end
  s.scroll.clear(); s.cards={}; s.status_labels={}; s.tech_buttons={}
  local stack=s.scroll.add{type="flow",direction="vertical"}
  stack.style.vertical_spacing=12
  local subset=s.chain and G.chain(g,s.pinned or s.selected) or nil
  local query=G.lower(s.query)
  local total=0
  local size=SIZES[s.size]
  for d=1,g.max_depth do
    local names={}
    for _,n in ipairs(g.layers[d] or {}) do
      if (query~="" or not subset or subset[n]) and
        (query=="" or G.lower(n):find(query,1,true) or
          G.lower(s.translations[n] or ""):find(query,1,true)) then names[#names+1]=n end
    end
    if #names>0 then
      local layer=stack.add{type="flow",direction="vertical"}
      title(layer,{"ptt.layer",d,#names})
      local row=layer.add{type="flow",direction="horizontal"}
      row.style.horizontal_spacing=12
      for _,n in ipairs(names) do
        local t=p.force.technologies[n]
        local card=row.add{type="frame", direction="vertical", style="inside_shallow_frame"}
        card.style.padding=6; card.style.width=size+112
        card.style.height=size+94
        local top=card.add{type="flow",direction="horizontal"}
        s.tech_buttons[n]=techbutton(top,p,n,size)
        local name=text(card,t.localised_name,size+100)
        name.style.height=64
        name.tooltip=t.localised_name
        local st=G.status(p.force,n)
        name.style.font_color=COLORS[st]
        s.status_labels[n]=name
        s.cards[n]=card
      end
      total=total+#names
    end
  end
  if total==0 then text(stack,{"ptt.no-results"},400) end
  s.shown=total
  s.summary.caption={"ptt.summary",total,#g.names,SIZES[s.size]}
  if focus then
    M.focus(p)
    -- Native scroll bounds settle after layout; repeat once on the next update.
    s.focus_due=game.tick+1
  end
end
function M.panel(p)
  local s=state(p)
  if not root(p) then return end
  local body=s.panel; body.clear()
  local t=s.selected and p.force.technologies[s.selected]
  if not t then text(body,{"ptt.select-hint"}); return end
  local width=s.panel_width-30
  local h=text(body,t.localised_name,width); h.style.font="heading-2"
  techbutton(body,p,t.name,64)
  local st=G.status(p.force,t.name)
  local l=text(body,{"ptt.status-"..st},width); l.style.font_color=COLORS[st]
  if t.prototype.research_trigger then
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
  b.style.width=width
  b.enabled=st=="available"
  text(body,{"ptt.research-hint"},width)
  if s.notice then text(body,s.notice,width) end
  title(body,{"ptt.parents"})
  local parents=body.add{type="table",column_count=4}
  for _,n in ipairs(sorted_keys(t.prerequisites)) do techbutton(parents,p,n,48) end
  title(body,{"ptt.children"})
  local children=body.add{type="table",column_count=4}
  for _,n in ipairs(graph(p).nodes[t.name] and graph(p).nodes[t.name].children or {}) do techbutton(children,p,n,48) end
  title(body,{"ptt.unlocks"})
  local effects=body.add{type="table",column_count=4}
  for _,effect in ipairs(t.prototype.effects or {}) do
    if effect.type=="unlock-recipe" and prototypes.recipe[effect.recipe] then
      effects.add{type="sprite-button",sprite="recipe/"..effect.recipe,
        elem_tooltip={type="recipe",name=effect.recipe},style="slot_button"}
    end
  end
end
function M.close(p)
  local s=state(p)
  local r=root(p)
  if r then r.destroy() end
  s.scroll=nil; s.panel=nil; s.cards=nil; s.status_labels=nil; s.summary=nil; s.open=false
end
function M.open(p)
  if root(p) then return end
  local s=state(p); choose(p)
  local w=math.max(600,math.floor(p.display_resolution.width/p.display_scale)-24)
  local h=math.max(400,math.floor(p.display_resolution.height/p.display_scale)-24)
  local pw=math.min(300,math.floor(w*0.34)); s.panel_width=pw
  local r=p.gui.screen.add{type="frame",name=ROOT,direction="vertical"}
  r.style.width=w; r.style.height=h; r.location={12,12}
  local header=r.add{type="flow",direction="horizontal"}
  title(header,{"ptt.title"})
  local gap=header.add{type="empty-widget"}; gap.style.horizontally_stretchable=true
  button(header,"close",{"ptt.close"})
  local tools=r.add{type="flow",direction="horizontal"}
  button(tools,"smaller","−").style.width=36
  button(tools,"larger","+").style.width=36
  button(tools,"focus",{"ptt.focus"})
  tools.add{type="checkbox",name="ptt_chain",caption={"ptt.chain"},state=s.chain,tags={ptt=true,action="chain"}}
  tools.add{type="checkbox",name="ptt_pin",caption={"ptt.pin"},
    tooltip={"ptt.pin-hint"},state=s.pinned~=nil,enabled=s.chain,tags={ptt=true,action="pin"}}
  local search=r.add{type="flow",direction="horizontal"}
  search.add{type="label",caption={"ptt.search"}}
  local field=search.add{type="textfield",name="ptt_query",text=s.query,tags={ptt=true,action="search"}}
  field.style.width=220
  button(search,"clear",{"ptt.clear"})
  s.summary=search.add{type="label"}
  text(r,{"ptt.navigation"},w-30)
  local body=r.add{type="flow",direction="horizontal"}
  body.style.horizontal_spacing=8
  s.scroll=body.add{type="scroll-pane",name="ptt_scroll",horizontal_scroll_policy="always",vertical_scroll_policy="always"}
  s.scroll.style.width=w-pw-40; s.scroll.style.height=h-174
  local panel=body.add{type="scroll-pane",horizontal_scroll_policy="never",vertical_scroll_policy="auto"}
  panel.style.width=pw; panel.style.height=h-174
  s.panel=panel.add{type="flow",direction="vertical"}; s.panel.style.vertical_spacing=8
  s.open=true -- no world camera or surface exists in this implementation
  p.opened=r
  M.tree(p,true); M.panel(p)
end
function M.select(p,name)
  if not p.force.technologies[name] then return end
  local s=state(p); s.selected=name; s.notice=nil
  if s.pinned then
    -- Keep the existing tree and both scroll positions; only selection/details change.
    s.focus_due=nil
    for n,b in pairs(s.tech_buttons or {}) do if b.valid then b.toggled=n==name end end
    M.panel(p)
    return
  end
  -- A click from search exits search so the chosen chain remains navigable.
  s.query=""
  local r=root(p)
  if not r then return end
  for _,child in pairs(r.children) do if child.ptt_query then child.ptt_query.text="" end end
  M.tree(p,true); M.panel(p)
end
function M.click(e)
  if not (e.element and e.element.valid) then return end
  local tag=e.element.tags
  if not tag.ptt then return end
  local p=game.get_player(e.player_index); if not p then return end
  local s=state(p); local a=tag.action
  if a=="close" then M.close(p)
  elseif a=="select" then M.select(p,tag.tech)
  elseif a=="smaller" or a=="larger" then
    s.size=math.max(1,math.min(#SIZES,s.size+(a=="smaller" and -1 or 1)))
    M.tree(p,true)
  elseif a=="focus" then
    s.query=""; choose(p)
    for _,child in pairs(root(p).children) do if child.ptt_query then child.ptt_query.text="" end end
    M.tree(p,true)
  elseif a=="clear" then
    s.query=""
    for _,child in pairs(root(p).children) do if child.ptt_query then child.ptt_query.text="" end end
    M.tree(p,true)
  elseif a=="research" then
    if s.selected and G.status(p.force,s.selected)=="available" then
      local ok=p.force.add_research(s.selected)
      s.notice={ok and "ptt.added" or "ptt.rejected"}
    else s.notice={"ptt.rejected"} end
    M.panel(p); M.refresh(p)
  end
end
function M.changed(e)
  if not (e.element and e.element.valid and e.element.tags.ptt) then return end
  local p=game.get_player(e.player_index); local s=state(p)
  if e.element.tags.action=="chain" then
    s.chain=e.element.state
    if not s.chain then s.pinned=nil end
    for _,child in pairs(root(p).children) do
      if child.ptt_pin then child.ptt_pin.enabled=s.chain; child.ptt_pin.state=s.pinned~=nil end
    end
    M.tree(p,true)
  elseif e.element.tags.action=="pin" then
    s.pinned=e.element.state and s.selected or nil
    s.focus_due=nil
    if not s.pinned then M.tree(p,true) end
  elseif e.element.tags.action=="search" then s.query=e.element.text; s.search_due=game.tick+15 end
end
function M.refresh(p)
  local s=state(p)
  if not s.open or not root(p) then return end
  for n,l in pairs(s.status_labels or {}) do if l.valid then l.style.font_color=COLORS[G.status(p.force,n)] end end
end
function M.tick()
  for _,p in pairs(game.connected_players) do
    local s=storage.native_players and storage.native_players[p.index]
    if s and s.open and root(p) then
      if s.search_due and game.tick>=s.search_due then s.search_due=nil; M.tree(p,false) end
      if s.focus_due and game.tick>=s.focus_due then s.focus_due=nil; M.focus(p) end
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
