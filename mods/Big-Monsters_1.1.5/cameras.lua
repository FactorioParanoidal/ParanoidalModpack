--[[ 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

			C A M E R A S

v 1.06  16/02/2021	 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  
** Usage: 
Add this file to mod root, and this to your control.lua events:

require "cameras"

cam_on_init() ==>  on_init / on_changed
cam_on_tick(event) ==>  on_tick 
cam_on_gui_click(event) ==>  on_gui_click - on the last line of the event


** Create cameras with:
CreateCameraForConnectedPlayers(Object,Surface,Text,size,seconds,Zoom)
CreateCameraForForce(Force,Object,Surface,Text,size,seconds,Zoom)
CreateCameraForPlayer(player,Object,Surface,Text,size,AutoCloseTick,Zoom)


Parameters:
Object = may be an entity or a fixed position. If entity is a unit, camera will follow its position
Surface = optional. If object is entity, gets its surface. If Surface is nil and Object is not entity, gets nauvis
Text = nil or {text='Camera', color={r=1,g=1,b=1}}
size = nil or camera size
AutoCloseTick = nil or number - when it will be closed in game.tick
Zoom = nil or Camera Zoon value 
]]


--default values. May be changed by your mod
Camera_Default_Zoon   = 0.25
Camera_Default_Size   = 230
Camera_Default_Text   = 'Camera'
Camera_Default_Time   = nil           -- Number - how many ticks it stays on screen. nil => undefined, 60 => 1 second
Camera_Count_Limit = 5

--## CAMERAS

-- Object may be an entity or a fixed position, if entity, camera will follow it
function CreateCameraForPlayer(player,Object,Surface,Text,size,AutoCloseTick,Zoom)
local count = global.active_player_cameras[player.name] or 0
if count<Camera_Count_Limit then 
	if Zoom==nil then Zoom=Camera_Default_Zoon end
	if size==nil then size=Camera_Default_Size end
	local tick=game.tick
	local guileft
	if not player.gui.left.mf_flow_cameras then
	   guileft = player.gui.left.add({type="flow", name="mf_flow_cameras", direction="horizontal"})
	   else
	   guileft = player.gui.left.mf_flow_cameras end
	   guileft.style.horizontally_stretchable = false

	while guileft["mf_framecam"..tick] do
		  tick=tick+1
		  end
	local frname="mf_framecam"..tick
	local frame = guileft.add({ type="frame", name=frname, direction="vertical"})   
		frame.style.horizontally_stretchable = false
		--frame.style.minimal_height = size+55
		--frame.style.maximal_height = size+55
		--frame.style.minimal_width = size+10
		--frame.style.maximal_width = size+10

	local position

	if (not AutoCloseTick) and Camera_Default_Time then AutoCloseTick=Camera_Default_Time end

	if Object and Object.valid and Object.position then
		Surface=Object.surface
		position=Object.position 
		local tabdata = {player=player, camframe=frame,tick=tick, entity=Object,autoclosetick=AutoCloseTick}
		table.insert(global.mf_frame_cameras,tabdata)
		else 
		if Surface==nil then Surface=game.surfaces[1] end
		local tabdata = {player=player, camframe=frame,tick=tick, entity=nil,autoclosetick=AutoCloseTick}
		table.insert(global.mf_frame_cameras,tabdata)
		position=Object 
		end 

	local Capt = Camera_Default_Text
	if Text then Capt = Text end

	local tab   = frame.add{type = "table", column_count = 4} 
	local closeb = tab.add{name="mf_bt_cameraclose"..tick,  type="sprite-button", sprite = "utility/close_black", style = "shortcut_bar_button_small"}
	local zoomin = tab.add{name="mf_bt_camerazoomin"..tick, type="sprite-button", sprite = "utility/speed_up", style = "shortcut_bar_button_small"}
	local zoomout= tab.add{name="mf_bt_camerazoomout"..tick,type="sprite-button", sprite = "utility/editor_speed_down", style = "shortcut_bar_button_small"}
	local title = tab.add{type = "label", caption = Capt}

	title.style.font = "default-bold"
	--if Text and Text.color then title.style.font_color = Text.color  end

	local surface_index = Surface.index
		
	local cam = frame.add({ type="camera", name="mf_camera"..tick, position = position, surface_index=surface_index, zoom = Zoom })
		  cam.style.width = size
		  cam.style.height = size


	global.active_player_cameras[player.name] = count +1
end
end


function CreateCameraForConnectedPlayers(Object,Surface,Text,size,seconds,Zoom)
local AutoCloseTick
if seconds then AutoCloseTick = game.tick + seconds*60 end
	for p, pl in pairs(game.connected_players) do
		CreateCameraForPlayer(pl,Object,Surface,Text,size,AutoCloseTick,Zoom) 
		end
end

function CreateCameraForForce(Force,Object,Surface,Text,size,seconds,Zoom)
local AutoCloseTick
if seconds then AutoCloseTick = game.tick + seconds*60 end
	for p, pl in pairs(Force.connected_players) do
		if not global.disabled_player_camera[pl.name] then CreateCameraForPlayer(pl,Object,Surface,Text,size,AutoCloseTick,Zoom) end
		end
end


function CloseAllCameras()
if #global.mf_frame_cameras>0 then
	for K,tabdata in pairs (global.mf_frame_cameras) do
		local frame = tabdata.camframe
		if frame and frame.valid then frame.destroy() end
		end
	global.mf_frame_cameras = {}
	end
	
	
global.active_player_cameras = {}	
end


function CloseAllCamerasForPlayer(player)
if #global.mf_frame_cameras>0 then
	for K,tabdata in pairs (global.mf_frame_cameras) do
		local frame = tabdata.camframe
		if player==frame.gui.player then
			if frame and frame.valid then frame.destroy() end end
		end
	global.mf_frame_cameras = {}
	end
if global.active_player_cameras[player.name] then global.active_player_cameras[player.name] = 0 end
end


local function get_gps_cam_tag(position,surface)
local r = '[gps='..math.floor(position.x)..','..math.floor(position.y)
if surface then r=r..','..surface.name end
r=r..']'
return r
end

-- Gui click
function CameraClose(player,num)
if player.gui.left.mf_flow_cameras then
if player.gui.left.mf_flow_cameras["mf_framecam"..num] then
   player.gui.left.mf_flow_cameras["mf_framecam"..num].destroy() 
   if global.active_player_cameras[player.name] then global.active_player_cameras[player.name] = math.max(global.active_player_cameras[player.name]-1,0) end
   end end
end
function CameraZoomIn(player,num)
if player.gui.left.mf_flow_cameras then
if player.gui.left.mf_flow_cameras["mf_framecam"..num] then
	local z = player.gui.left.mf_flow_cameras["mf_framecam"..num]["mf_camera"..num].zoom
    if z>0.1 then player.gui.left.mf_flow_cameras["mf_framecam"..num]["mf_camera"..num].zoom = z - 0.05 end
    end end
end
function CameraZoomOut(player,num)
if player.gui.left.mf_flow_cameras then
if player.gui.left.mf_flow_cameras["mf_framecam"..num] then
	local z = player.gui.left.mf_flow_cameras["mf_framecam"..num]["mf_camera"..num].zoom
    if z<1 then player.gui.left.mf_flow_cameras["mf_framecam"..num]["mf_camera"..num].zoom = z + 0.1 end
   end end
end




function ClickCamera(player,num)
if player.gui.left.mf_flow_cameras and player.gui.left.mf_flow_cameras["mf_framecam"..num] and
	player.gui.left.mf_flow_cameras["mf_framecam"..num]["mf_camera"..num] then
	local position = player.gui.left.mf_flow_cameras["mf_framecam"..num]["mf_camera"..num].position
	local surface = player.gui.left.mf_flow_cameras["mf_framecam"..num]["mf_camera"..num].surface_index
	surface = game.surfaces[surface]
	player.print(get_gps_cam_tag(position,surface))
	end
end

-- ************  EVENTS ********************************


function cam_on_gui_click(event)
if event and event.element and event.element.valid and event.player_index and game.players[event.player_index] then 
local player = game.players[event.player_index]
local name = event.element.name
	if string.sub(name,1,17)=="mf_bt_cameraclose" then CameraClose(player,string.sub(name,18,string.len(name)))
	elseif string.sub(name,1,18)=="mf_bt_camerazoomin" then CameraZoomIn(player,string.sub(name,19,string.len(name)))
	elseif string.sub(name,1,19)=="mf_bt_camerazoomout" then CameraZoomOut(player,string.sub(name,20,string.len(name)))
	elseif string.sub(name,1,9)=="mf_camera" then ClickCamera(player,string.sub(name,10,string.len(name))) 
	end
	
end
end


--#Camera Updates
function cam_on_tick(event)
if #global.mf_frame_cameras>0 then
local kill=false
	for K=#global.mf_frame_cameras,1,-1 do
	
		local frame = global.mf_frame_cameras[K].camframe
		local tick  = global.mf_frame_cameras[K].tick
		local entity= global.mf_frame_cameras[K].entity
		local player= global.mf_frame_cameras[K].player
		local autoclosetick  = global.mf_frame_cameras[K].autoclosetick
		if frame and frame.valid then 
			if entity and entity.valid then
				frame["mf_camera"..tick].position = entity.position end
			if autoclosetick and autoclosetick<game.tick then kill=true end
			else table.remove(global.mf_frame_cameras,K) end
		if kill then 
			if frame and frame.valid then frame.destroy() end
			if player and player.valid and global.active_player_cameras[player.name] then 
				global.active_player_cameras[player.name] = math.max(global.active_player_cameras[player.name]-1,0) 
				end
			table.remove(global.mf_frame_cameras,K) 
			end
		end
	end
end


function cam_on_init()
global.mf_frame_cameras = global.mf_frame_cameras or {}
global.active_player_cameras = global.active_player_cameras or {}
global.disabled_player_camera = global.disabled_player_camera or {}
end

