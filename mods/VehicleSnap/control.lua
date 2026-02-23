--[[
Snap amount is the amount of different angles car aims to drive,
(360 / vehiclesnap_amount) is the difference between each direction.
Car will slowly turn towards such angle.
Default amount is 16, recommended to try with other multiples of 4.
You can change snapping amount and keybinds in ingame-menus.

TODO:
 - (Simplify CheckDrivingState to use player index and less local vars)

Note LUA tables indexing starts from 1 not 0!

Vehicle orientation in-game: (Clockwise from up 0 to 1)
Up: 0   Right: 0.25   Down: 0.5   Left: 0.75

]]--
-- Odd angles clockwise from up

-- 0.07386350632 measured from train wagon orientation, still off very tiny bit
local rail_est = 0.07405 -- Best estimate so far 0.07405
local lockAxis = {
  rail_est,     0.25-rail_est, 0.25+rail_est, 0.5-rail_est,
  0.5+rail_est, 0.75-rail_est, 0.75+rail_est, 1.0-rail_est }

local function OnOffText(value)
  if value then return {"description.VehicleSnap_enable"}
  else return {"description.VehicleSnap_disable"} end
end

script.on_event(defines.events.on_lua_shortcut, function(event)
  if event.prototype_name == "VehicleSnap-shortcut" then
		PlayerToggle(event)		
	end
end)

function PlayerToggle(event)
  local player = game.get_player(event.player_index)
  storage.players[event.player_index].snap = not storage.players[event.player_index].snap
  CheckDrivingState(player)
  player.set_shortcut_toggled("VehicleSnap-shortcut", storage.players[event.player_index].snap)
  -- Create floating text at car position (auto-disappears after a couple of seconds)
  player.create_local_flying_text{ text = OnOffText(storage.players[event.player_index].snap),
    position = player.position }
     
  -- DEBUG orientation
  --player.create_local_flying_text{ text = game.connected_players[event.player_index].vehicle.orientation
  --  , position = player.position }
end

script.on_event("VehicleSnap-toggle", PlayerToggle)

-- This is ran everytime the game is changed (adding mods upgrading etc) and installed.
local function run_install()
  storage.players = storage.players or {}
  for i, player in (pairs(game.players)) do
    --game.players[i].print("VehicleSnap installed") -- Debug
    storage.players[i] = storage.players[i] or {
      snap = true,
      player_ticks = 0,
      last_orientation = 0,
      -- driving is only true if snapping is true and player is in a valid vehicle
      driving = false,
      moves = 0,
      eff_moves = 0, -- Effective tile moves from last time period
      snap_amount = 16,
      recheck = true
    }
    local snap = settings.get_player_settings(player)["VehicleSnap_amount"].value
    if snap ~= nil then
      storage.players[i].snap_amount = snap
    end
    
    CheckDrivingState(player)
    player.set_shortcut_toggled("VehicleSnap-shortcut", storage.players[i].snap)
  end
  --ToggleEvents(true)
end

-- Any time a new player is created run this.
script.on_event(defines.events.on_player_created, function(event)
  storage.players[event.player_index] = {
    snap = true,
    player_ticks = 0,
    last_orientation = 0,
    driving = false,
    moves = 0,
    eff_moves = 0,
    snap_amount = 16,
    recheck = true
  }
  local snap = settings.get_player_settings(game.get_player(event.player_index))["VehicleSnap_amount"].value
  if snap ~= nil then
    storage.players[event.player_index].snap_amount = snap
  end
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  if event.setting == "VehicleSnap_amount" then
    local snap = settings.get_player_settings(game.get_player(event.player_index))["VehicleSnap_amount"].value
    if snap ~= nil then
      storage.players[event.player_index].snap_amount = snap
    end
  end
end)

function CheckDrivingState(player)
  --game.print("- - Check driving state on "..tostring(player.index))
  local pdata = storage.players[player.index]
  pdata.recheck = true
  --ToggleEvents(true)
end

script.on_event(defines.events.on_player_driving_changed_state, function(event)
  local player = game.get_player(event.player_index)
  --game.print("- Driving changed state event on "..tostring(player.index))
  CheckDrivingState(player)
end)

script.on_event(defines.events.on_player_changed_surface, function(event)
  local player = game.get_player(event.player_index)
  --game.print("- Player changed surface event on "..tostring(player.index))
  CheckDrivingState(player)
end)

script.on_event(defines.events.on_player_died, function(event)
  local player = game.get_player(event.player_index)
  CheckDrivingState(player)
end)

--function onPlayerJoined(event)
script.on_event(defines.events.on_player_joined_game, function(event)
  local player = game.get_player(event.player_index)
  CheckDrivingState(player)
end)

script.on_event(defines.events.on_player_controller_changed, function(event)
  local player = game.get_player(event.player_index)
  --game.print("- Player controller changed on "..tostring(player.index))
  CheckDrivingState(player)
end)

--[[local function onPlayerChangedPosition(event)
  local pdata = storage.players[event.player_index]
  if pdata and pdata.driving then
    pdata.moves = pdata.moves + 1
    
    -- Debug player speed values
    --local player = game.get_player(event.player_index)
    --if player.vehicle then
     -- player.create_local_flying_text{ text = player.vehicle.speed, position = player.position }
    --end
  end
end]]--

local function AngleDist(a, b)
  local ret = math.abs(a - b)
  if ret >= 1.0 then
    ret = ret - 1.0
  end
  return ret
end

local function onTick()
  --if game.tick % 2 == 0 then
    --local drivers = false 
    --moveReset = (game.tick % 40 == 0)
    for _, player in pairs(game.connected_players) do
      local pdata = storage.players[player.index]
      
      if pdata.recheck then
        pdata.recheck = false
        local driving = false        
        if player.vehicle and pdata.snap then
          driving = (player.vehicle.type == "car")
          --pdata.moves = 0
          --pdata.eff_moves = 0
          pdata.snap_amount = pdata.snap_amount or 16
        end
        pdata.driving = driving
        --game.print("  vehicle: "..tostring(player.vehicle or false))
        --game.print("  driving: "..tostring(driving or false))
      end
      
      if pdata.driving and pdata.snap then
        if not player.vehicle then
          if player.controller_type == defines.controllers.character then
            -- Use of Space Exploration navigation satellite changes controller to godmode,
            -- after which it returns to car.
            pdata.driving = false
          --else
          --  drivers = true
          end
        else
          --drivers = true
          --if (pdata.eff_moves > 1) and (math.abs(player.vehicle.speed) > 0.03) then
          if (math.abs(player.vehicle.speed) > 0.03) then
            -- Float value from 0 to 1, the direction vehicle is facing.
            -- Goes clockwise from up at 0.
            local o = player.vehicle.orientation
            -- Has player turned vehicle? Don't push against,
            -- so delay snapping a little with player_ticks.
            if math.abs(o - pdata.last_orientation) < 0.001 then
              if pdata.player_ticks > 1 then
                local snap_o
                if pdata.snap_amount == 16 then
                  -- Snap with rails table
                  snap_o = math.floor(o * 8.0 + 0.5) / 8.0
                  local nearestI = -1
                  local nearest = AngleDist(o, snap_o)
                  for i = 1, 8 do
                    local d = math.abs(AngleDist(o, lockAxis[i]))
                    if (d < nearest) then
                      nearestI = i
                      nearest = d
                    end
                  end
                  if nearestI >= 0 then
                    snap_o = lockAxis[nearestI]
                  end
                else
                  snap_o = math.floor(o * pdata.snap_amount + 0.5) / pdata.snap_amount
                end
                -- Interpolate (turn towards) with 80% current and 20% target orientation
                o = (o * 4.0 + snap_o) * 0.2
                player.vehicle.orientation = o
              else
                pdata.player_ticks = pdata.player_ticks + 1
              end
            else
              pdata.player_ticks = 0
            end
            pdata.last_orientation = o
          end
          --if moveReset then -- Counting tile changes, reset every 40 ticks
          --  pdata.eff_moves = pdata.moves
          --  pdata.moves = 0
          --end
        end
      end
    end
    --if not drivers then
      --ToggleEvents(false)
      --game.print("No drivers, event goes off.")
    --end
  --end
end

script.on_init(run_install)
script.on_configuration_changed(run_install)
script.on_nth_tick(2, onTick)
--script.on_event(defines.events.on_tick, onTick)
--script.on_event(defines.events.on_player_joined_game, onPlayerJoined)

--script.on_load(function()
--  ToggleEvents(true)
--end)

--[[function ToggleEvents(enable)
  if enable then
    script.on_event(defines.events.on_tick, onTick)
    script.on_event(defines.events.on_player_changed_position, onPlayerChangedPosition)
  else
    script.on_event(defines.events.on_tick, nil)
    script.on_event(defines.events.on_player_changed_position, nil)
  end
end ]]--