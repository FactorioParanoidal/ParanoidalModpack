require("util")
local compound_entities = require("prototypes.compound_entities.main_list")

-- Helpers shared by the data and the control stage. The runtime handling of compound
-- entities, trees, musk floor and the terraformer lives in the control_*.lua modules.
return function(mod_name)
    local common = {}

    ------------------------------------------------------------------------------------
    -- Get mod name and path to mod
    common.modName = script and script.mod_name or mod_name
    common.modRoot = "__" .. common.modName .. "__"


    ------------------------------------------------------------------------------------
    -- Greatly improved version check for mods (thanks to eradicator!)
    common.Version = {}
    do
        local V = common.Version

        local function parse_version(vstr) -- string "Major.Minor.Patch"
            local err = function()
                error('Invalid Version String: <' .. tostring(vstr) .. '>')
            end
            local r = { vstr:match('^(%d+)%.(%d+)%.(%d+)$') }

            if #r ~= 3 then
                err()
            end

            for i = 1, 3 do
                r[i] = tonumber(r[i])
            end

            return r
        end

        V.gtr = function(verA, verB)
            local a, b, c = unpack(parse_version(verA))
            local x, y, z = unpack(parse_version(verB))
            return (a > x) or (a == x and b > y) or (a == x and b == y and c > z)
        end
        local map = {
            ['='] = function(A, B) return not (V.gtr(A, B) or V.gtr(B, A)) end,
            ['>'] = V.gtr,
            ['!='] = function(A, B) return (V.gtr(A, B) or V.gtr(B, A)) end,
            ['<='] = function(A, B) return V.gtr(B, A) or (not V.gtr(A, B)) end,
            ['>='] = function(A, B) return V.gtr(A, B) or (not V.gtr(B, A)) end,
            ['~='] = function(A, B) return (V.gtr(A, B) or V.gtr(B, A)) end,
            ['<'] = function(A, B) return V.gtr(B, A) end,
        }

        common.check_version = function(mod_name, operator, need_version)
            local mod_version = (mods and mods[mod_name]) or (script and script.active_mods[mod_name])
            return map[operator](mod_version, need_version)
        end
    end

    ------------------------------------------------------------------------------------
    -- List of compound entities
    -- Key:       name of the base entity
    -- tab:       name of the global table where data of these entity are stored
    -- hidden:    table containing the hidden entities needed by this entity
    --            (Key:   name under which the hidden entity will be stored in the table;
    --             Value: name of the entity that should be placed)
    common.compound_entities = compound_entities.get_HE_list()

    -- Map the short handles of hidden entities (e.g. "pole") to real prototype types
    -- (e.g. "electric-pole")
    common.HE_map = compound_entities.HE_map
    -- Reverse lookup
    common.HE_map_reverse = compound_entities.HE_map_reverse

    ------------------------------------------------------------------------------------
    -- There may be trees for which we don't want to create variations. These patterns
    -- are used to build a list of trees we want to ignore.
    common.ignore_name_patterns = {
        -- Ignore our own trees
        "bio%-tree%-.+%-%d",
        -- Tree prototypes created by "Robot Tree Farm" or "Tral's Robot Tree Farm"
        "rtf%-.+%-%d+",
        -- Tree prototypes created by "Industrial Revolution 2"
        ".*%-*ir2%-.+",
    }


    -- Get list of tree prototypes that we want to ignore
    common.get_tree_ignore_list = function()
        local ignore = {}
        local trees = script and
            prototypes.get_entity_filtered({ { filter = "type", type = "tree" } }) or
            data.raw.tree
        for tree_name, tree in pairs(trees) do
            for p, pattern in ipairs(common.ignore_name_patterns) do
                if tree_name:match(pattern) then
                    ignore[tree_name] = true
                    break
                end
            end
        end
        return ignore
    end


    -- 0.17.42/0.18.09 fixed a bug where musk floor was created for the force "enemy".
    -- Because it didn't belong to any player, in map view the electric grid overlay wasn't
    -- shown for musk floor. Somebody complained about seeing it now, so starting with version
    -- 0.17.45/0.18.13, there is a setting to hide the overlay again. If it is set to "true",
    -- a new force will be created that the hidden electric poles of musk floor belong to.
    -- (UPDATE: 0.18.29 reversed the setting -- if active, tiles will now be visible in map
    -- view, not hidden. The definition of UseMuskForce has been changed accordingly.)
    common.MuskForceName = "BI-Musk_floor_general_owner"
    common.UseMuskForce = not settings.startup["BI_Show_musk_floor_in_mapview"].value


    ------------------------------------------------------------------------------------
    -- Enable writing to log file until startup options are set, so debugging output
    -- from the start of a game session can be logged. This depends on a locally
    -- installed dummy mod to allow debugging output during development without
    -- spamming real users.
    -- If the "_debug" dummy mod is active, debugging will always be on. If you don't
    -- have this dummy mod but want to turn on logging anyway, set the default value
    -- to "true"!
    local default = false

    common.is_debug = ((mods and mods["_debug"]) or
            (script and script.active_mods["_debug"])) and
        true or default


    ------------------------------------------------------------------------------------
    --                               DEBUGGING FUNCTIONS                              --
    ------------------------------------------------------------------------------------
    -- Outside debug mode both functions are empty: a call costs nothing but the
    -- evaluation of its arguments, so hot paths must not build expensive arguments.

    ------------------------------------------------------------------------------------
    -- Output debugging text
    common.writeDebug = function(msg, tab, print_line)
        local args = {}
        -- Use serpent.line instead of serpent.block if this is true!
        local line = print_line and
            (string.lower(print_line) == "line" or string.lower(print_line) == "l") and
            true or false

        if type(tab) ~= "table" then
            tab = { tab }
        end
        local v
        for k = 1, #tab do
            v = tab[k]
            -- NIL
            if v == nil then
                args[#args + 1] = "NIL"
                -- TABLE
            elseif type(v) == "table" then
                args[#args + 1] = line and serpent.line(table.deepcopy(v)) or
                    serpent.block(table.deepcopy(v))
                -- OTHER VALUE
            else
                args[#args + 1] = v
            end
        end
        if #args == 0 then
            args[1] = "nil"
        end
        args.n = #args

        -- Print the message text to log and game
        log(string.format(tostring(msg), table.unpack(args)))

        if game then
            game.print(string.format(tostring(msg), table.unpack(args)))
        end
    end

    ------------------------------------------------------------------------------------
    -- Simple helper to show a single value with descriptive text
    common.show = function(desc, term)
        common.writeDebug(tostring(desc) .. ": %s", type(term) == "table" and { term } or term)
    end

    if not common.is_debug then
        common.writeDebug = function() end
        common.show = function() end
    end

    ------------------------------------------------------------------------------------
    -- Print "entityname (id)"
    common.print_name_id = function(entity)
        local id
        local name = "unknown entity"

        if entity and entity.valid then
            -- Stickers don't have an index or unit_number!
            id = (entity.type == "sticker" and entity.type) or
                entity.unit_number or entity.type

            name = entity.name
        end

        return string.format("%s (%s)", name, id or "nil")
    end


    ------------------------------------------------------------------------------------
    -- Throw an error if a wrong argument has been passed to a function
    common.arg_err = function(arg, arg_type)
        error(string.format(
            "Wrong argument! %s is not %s!",
            tostring(arg or "nil"), (arg_type and "a valid " .. arg_type or "valid")
        )
        )
    end

    ------------------------------------------------------------------------------------
    -- Rudimentary check of the arguments passed to a function
    common.check_args = function(arg, arg_type, desc)
        if not (arg and type(arg) == arg_type) then
            common.arg_err(arg or "nil", desc or arg_type or "nil")
        end
    end



    ------------------------------------------------------------------------------------
    --                                  MOD SPECIFIC                                  --
    ------------------------------------------------------------------------------------

    ------------------------------------------------------------------------------------
    -- Are tiles from Alien Biomes available? (Returns true or false)
    common.AB_tiles = function()
        if script then
            -- In data stage, place_as_tile is only changed to Alien Biomes tiles if
            -- both "vegetation-green-grass-1" and "vegetation-green-grass-3" exist. Therefore,
            -- we only need to check for one tile in the control stage.
            local fertilizer = prototypes.item["fertilizer"]
            local tile = fertilizer and fertilizer.place_as_tile_result
            return (tile and tile.result.name == "vegetation-green-grass-3") and true or false
        end
        return data.raw.tile["vegetation-green-grass-1"] and
            data.raw.tile["vegetation-green-grass-3"] and true or false
    end

    ------------------------------------------------------------------------------------
    -- Function to normalize positions
    common.normalize_position = function(pos)
        if pos and type(pos) == "table" then
            local x = pos.x or pos[1]
            local y = pos.y or pos[2]
            if type(x) == "number" and type(y) == "number" then
                return { x = x, y = y }
            end
        end
    end

    ------------------------------------------------------------------------------------
    -- Get the value of a startup setting
    common.get_startup_setting = function(setting_name)
        return settings.startup[setting_name] and settings.startup[setting_name].value
    end


    ------------------------------------------------------------------------------------
    -- Add the "icons" property based on the value of "icon"
    ------------------------------------------------------------------------------------
    common.BI_add_icons = function()
        for tab_name, tab in pairs(data.raw) do
            for proto_type_name, proto_type in pairs(data.raw[tab_name] or {}) do
                if proto_type.BI_add_icon then
                    proto_type.icons = {
                        {
                            icon = proto_type.icon,
                            icon_size = proto_type.icon_size,
                            icon_mipmaps = proto_type.icon_mipmaps
                        }
                    }
                    proto_type.BI_add_icon = nil
                    common.writeDebug("Added \"icons\" property to data.raw[\"%s\"][\"%s\"]: %s",
                        { tab_name, proto_type_name, proto_type.icons }, "line")
                end
            end
        end
    end

    ------------------------------------------------------------------------------------
    --                                    END OF FILE
    ------------------------------------------------------------------------------------
    return common
end
