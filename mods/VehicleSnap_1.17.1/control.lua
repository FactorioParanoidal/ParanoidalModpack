-- snap amount is the amount of different angles car can drive on,
-- (360 / vehiclesnap_amount) is the difference between 2 axis
-- car will slowly turn towards such angle axis
-- Default 16, recommended other tries 4, 8 or 32.

-- You can change snapping amount and keybinds ingame in menus.

local function OnOffText(value)
  if value then return {"description.VehicleSnap_enable"}
  else return {"description.VehicleSnap_disable"} end
end

script.on_event("VehicleSnap-toggle", function(event)
  local player = game.players[event.player_index]
  global.players[event.player_index].snap = not global.players[event.player_index].snap
  CheckDrivingState(player)
  -- Create floating text at car position (auto-disappears after a couple of seconds)
  player.surface.create_entity{ name = "flying-text", position = player.position,
    text = OnOffText(global.players[event.player_index].snap) }
end)

-- This is ran everytime the game is changed (adding mods upgrading etc) and installed.
local function run_install()
  global.players = global.players or {}
  for i in (pairs(game.players)) do
    --game.players[i].print("VehicleSnap installed") -- Debug
    global.players[i] = global.players[i] or {
      snap = true,
      player_ticks = 0,
      last_orientation = 0,
      -- driving is only true if snapping is true and player is in a valid vehicle
      driving = false,
      moves = 0,
      eff_moves = 0, -- Effective tile moves from last time period
      snap_amount = 16
    }
    local snap = settings.get_player_settings(game.players[i])["VehicleSnap_amount"].value
    if snap ~= nil then
      global.players[i].snap_amount = snap
    end
    CheckDrivingState(game.players[i])
  end
  ToggleEvents(true)
end

-- Any time a new player is created run this.
script.on_event(defines.events.on_player_created, function(event)
  global.players[event.player_index] = {
    snap = true,
    player_ticks = 0,
    last_orientation = 0,
    driving = false,
    moves = 0,
    eff_moves = 0,
    snap_amount = 16
  }
  local snap = settings.get_player_settings(game.players[event.player_index])["VehicleSnap_amount"].value
  if snap ~= nil then
    global.players[event.player_index].snap_amount = snap
  end
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  if event.setting == "VehicleSnap_amount" then
    local snap = settings.get_player_settings(game.players[event.player_index])["VehicleSnap_amount"].value
    if snap ~= nil then
      global.players[event.player_index].snap_amount = snap
    end
  end
end)

function CheckDrivingState(player)
  local pdata = global.players[player.index]
  local driving = false
  if player.vehicle and pdata.snap then -- and player.connected
    driving = (player.vehicle.type == "car")
    pdata.moves = 0
    pdata.eff_moves = 0
    pdata.snap_amount = pdata.snap_amount or 16
  end
  pdata.driving = driving
  ToggleEvents(true)
end

script.on_event(defines.events.on_player_driving_changed_state, function(event)
  CheckDrivingState(game.players[event.player_index])
end)

script.on_event(defines.events.on_player_died, function(event)
  CheckDrivingState(game.players[event.player_index])
end)

local function onPlayerChangedPosition(event)
  local pdata = global.players[event.player_index]
  if pdata and pdata.driving then
    pdata.moves = pdata.moves + 1
    
    -- Debug player speed values
    --local player = game.players[event.player_index]
    --if player.vehicle then
     -- player.surface.create_entity{ name = "flying-text", position = player.position, text = player.vehicle.speed }
    --end
  end
end

local function onTick()
  if game.tick % 2 == 0 then
    local drivers = false 
    moveReset = (game.tick % 40 == 0)
    for _, player in pairs(game.connected_players) do
      local pdata = global.players[player.index]
      if pdata.driving and pdata.snap then
        if not player.vehicle then
          -- Unexpected error happened, CAR NOT FOUND!
          pdata.driving = false
        else
          drivers = true
          if (pdata.eff_moves > 1) and (math.abs(player.vehicle.speed) > 0.03) then
            local o = player.vehicle.orientation -- float value, the direction vehicle is facing
            -- Has player turned vehicle? Don't push against,
            -- so delay snapping a little with player_ticks
            if math.abs(o - pdata.last_orientation) < 0.001 then
              if pdata.player_ticks > 1 then
                local snap_o = math.floor(o * pdata.snap_amount + 0.5) / pdata.snap_amount
                -- Interpolate with 80% current and 20% target orientation
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
          if moveReset then -- Counting tile changes, reset every 40 ticks
            pdata.eff_moves = pdata.moves
            pdata.moves = 0
          end
        end
      end
    end
    if not drivers then
      ToggleEvents(false)
    end
  end
end

function ToggleEvents(enable)
  global.RegisterEvents = enable
  if enable then
    script.on_event(defines.events.on_tick, onTick)
    script.on_event(defines.events.on_player_changed_position, onPlayerChangedPosition)
  else
    script.on_event(defines.events.on_tick, nil)
    script.on_event(defines.events.on_player_changed_position, nil)
  end
end

script.on_init(run_install)
script.on_configuration_changed(run_install)

script.on_load(function()
  if global.RegisterEvents then
    ToggleEvents(true)
  end
end)