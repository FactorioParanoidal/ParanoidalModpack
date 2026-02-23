require "util"

local is_wire = {
  ["red-wire"] = true,
  ["green-wire"] = true,
  ["copper-wire"] = true,
}
local next_wire = {
  ["red-wire"] = "green-wire",
  ["green-wire"] = "red-wire",
}
if settings.startup["wsx-number-of-shortcuts"].value == "one" then
  next_wire = {
    ["red-wire"] = "green-wire",
    ["green-wire"] = "copper-wire",
    ["copper-wire"] = "red-wire",
  }
end

local function switch_to_wire(wire_name, player)
  -- cursor_stack must be empty before calling this function
  local cursor_stack = player.cursor_stack

  local stack_count = 1
  if remote.interfaces["space-exploration"] and remote.interfaces["space-exploration"]["remote_view_is_unlocked"] and
    remote.call("space-exploration", "remote_view_is_active", { player = player }) then
    -- SE sets the stack count to 2 anyway when in remote view, so pre-empting that here prevents it from
    -- raising on_player_cursor_stack_changed again which will reset storage.holding_temporary_wire
    stack_count = 2
  end
  cursor_stack.set_stack({name = wire_name, count = stack_count})
  player.create_local_flying_text{
    text = {"item-name." .. wire_name},
    create_at_cursor = true,
  }
  if next_wire[wire_name] then
    storage.players_last_wire[player.index] = wire_name
  end
end

local function on_give_combined_wire(event)
  local player = game.get_player(event.player_index)

  -- Try to cycle wire
  local cursor_stack = player.cursor_stack
  if cursor_stack and cursor_stack.valid_for_read then
    local wire_name = cursor_stack.name
    local next_wire_name = next_wire[wire_name]
    if next_wire_name then
      local cleared = player.clear_cursor()
      if not cleared then return end
      switch_to_wire(next_wire_name, player)
      return
    end
  end

  -- Couldn't cycle wire, create wire instead
  local cleared = player.clear_cursor()
  if cleared then
    local wire_name = storage.players_last_wire[event.player_index]
    if not wire_name then
      wire_name = "red-wire"
    end
    switch_to_wire(wire_name, player)
  end
end
script.on_event("wsx-give-wire", on_give_combined_wire)

script.on_event(defines.events.on_lua_shortcut,
  function(event)
    if event.prototype_name == "wsx-give-wire" then
      on_give_combined_wire(event)
    end
  end
)

script.on_event(defines.events.on_player_cursor_stack_changed,
  function(event)
    local player = game.get_player(event.player_index)
    local cursor_stack = player.cursor_stack
    if cursor_stack and cursor_stack.valid_for_read then
      local wire_name = cursor_stack.name
      if next_wire[wire_name] then
        -- Don't wont to store copper-wire if it isn't part of the cycle
        storage.players_last_wire[player.index] = wire_name
      end
      if is_wire[wire_name] then
        player.create_local_flying_text{
          text = {"item-name." .. wire_name},
          create_at_cursor = true,
        }
      end
    end
  end
)

local function setup_global()
  storage.players_last_wire = storage.players_last_wire or {}
end

script.on_init(setup_global)
script.on_configuration_changed(setup_global)