
function add_gui_frame_title_and_close_bt(frame,caption,trd_but,search_text)
  local title_table =frame.title_table
  if not title_table then 
    local c=2
    if trd_but then c=c+1 end
    if search_text then c=c+1 end

    title_table = frame.add{type="table", name="title_table", column_count=c, draw_horizontal_lines=false}
    title_table.style.horizontally_stretchable = true
    title_table.style.column_alignments[1] = "left"
    for x=2,c do title_table.style.column_alignments[x] = "right" end
    local title_frame = title_table.add{type="frame", name="title_frame",  caption = caption, style="ic_title_frame"}
    title_frame.ignored_by_interaction = true
    if search_text then 
      local tf = title_table.add(search_text) 
      tf.style.width = 100
      end
    if trd_but then 
      local bt_3 = title_table.add(trd_but) 
      end
    local bt_close = title_table.add{type = "sprite-button", name='bt_destroy_my_2parent', style = "shortcut_bar_button_small", sprite = "utility/close", tooltip={"close"} } 
    if frame.parent==game.players[frame.player_index].gui.screen then
      frame.auto_center = true 
      title_table.drag_target = frame
      title_frame.drag_target = frame
      end
    end
  end



function add_gui(parent,element,destroy,style)
    local E = parent[element.name]
    if destroy and E then E.destroy() E=nil end
    if not E then E=parent.add(element) end
    if style then for s=1,#style do E.style[style[s][1]]=style[s][2] end end
    return E
    end


-- Message Board
function create_message_board_gui_for_player(player,title,sprite,subtitle,message_table,tab_size)
  local gui = player.gui.center
  local frame = add_gui (gui,{type = "frame", name = "tc_frame_message_board", caption =title, direction = "vertical"},true)
  if sprite or subtitle then
    local tab_0 = frame.add{type = "table", column_count = 2} 
    if sprite then tab_0.add{type="sprite", sprite = sprite} end
    if subtitle then add_gui (tab_0, {type = "label", name='subtitle' , caption =subtitle},nil,{{'font',"default-large-bold"},{'font_color', colors.yellow}}) end
    end
    
  local tab_1 = frame.add{type = "table", column_count = tab_size} 	
  for t=1,#message_table do
    tab_1.add{type = "label", caption =message_table[t]}
    end
  local btClose= frame.add{name="bt_destroy_my_parent", type="button", style = "back_button", caption={"close"}}
  end

  function create_message_board_gui_for_force(force,title,sprite,subtitle,message_table,tab_size)
  for _,player in pairs (force.connected_players) do
    create_message_board_gui_for_player(player,title,sprite,subtitle,message_table,tab_size)
    end
  end
