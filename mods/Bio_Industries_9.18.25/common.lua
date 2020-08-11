return function (mod_name)
    local common = {}

    ------------------------------------------------------------------------------------
    -- Get mod name and path to mod
    common.modName = mod_name
    common.modRoot = "__" .. mod_name .. "__"

    ------------------------------------------------------------------------------------
    -- Sane values for collision masks
    common.RAIL_BRIDGE_MASK = {"floor-layer", "object-layer", "consider-tile-transitions"}
    common.RAIL_MASK = {"item-layer", "floor-layer", "object-layer", "water-tile", "consider-tile-transitions"}


    ------------------------------------------------------------------------------------
    -- Set maximum_wire_distance of Power-to-rail connectors
    common.POWER_TO_RAIL_WIRE_DISTANCE = 4
    ------------------------------------------------------------------------------------
    -- Enable writing to log file until startup options are set, so debugging output
    -- from the start of a game session can be logged. This depends on a locally
    -- installed dummy mod to allow debugging output during development without
    -- spamming real users.
    ------------------------------------------------------------------------------------
    local function is_debug()
        local debugging
        -- If the "_debug" is active, debugging will always be on. If you don't have this
        -- dummy mod but want to turn on logging anyway, set the default value to "true"!
        local default = false

        if game then
            debugging = game.active_mods["_debug"] and true or default
        elseif mods then
            debugging = mods and mods["_debug"] and true or default
        end
        return debugging
    end


    --------------------------------------------------------------------
    --- DeBug Messages
    common.writeDebug = function (message)
      if is_debug() then
        log(tostring(message))
        if game then
          game.print(tostring(message))
        end
      end
    end

    ------------------------------------------------------------------------------------
    -- Are tiles from Alien Biomes available? (Returns true or false)
    common.AB_tiles = function()

      local ret = false

      if game then
        local AB = game.item_prototypes["fertiliser"].place_as_tile_result.result.name
        -- In data stage, place_as_tile is only changed to Alien Biomes tiles if
        -- both "vegetation-green-grass-1" and "vegetation-green-grass-3" exist. Therefore,
        -- we only need to check for one tile in the control stage.
        ret = (AB == "vegetation-green-grass-3") and true or false
      else
        ret = data.raw.tile["vegetation-green-grass-1"] and
              data.raw.tile["vegetation-green-grass-3"] and true or false
      end

      return ret
    end

    ------------------------------------------------------------------------------------
    -- Determine which version of Factorio is running. Based on this result, we can set
    -- icon sizes of vanilla icons correctly, thus making the same code usable for both
    -- Factorio versions using the old 32x32 icons, and for new versions with 64x64 icons.
    common.base_version = function()

        local F_version = util.split(mods["base"], '.')
        local ret = true

        if tonumber(F_version[1]) == 0 then
            if tonumber(F_version[2]) < 18 then
                ret = false
            end
        end
        return ret
    end

------------------------------------------------------------------------------------
--                                    END OF FILE
------------------------------------------------------------------------------------
return common
end
