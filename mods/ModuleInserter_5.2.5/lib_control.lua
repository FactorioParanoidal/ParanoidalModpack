local function debugDump(var, force)
    if false or force then
        for _, player in pairs(game.players) do
            local msg
            if type(var) == "string" then
                msg = var
            else
                msg = serpent.dump(var, {name="var", comment=false, sparse=false, sortkeys=true})
            end
            player.print(msg)
        end
    end
end

local function saveVar(var, name)
    var = var or global
    local n = name or ""
    game.write_file("module"..n..".lua", serpent.block(var, {name="global"}))
end

local function config_exists(config, name)
    local configs = {}
    local found = 1
    for i = 1, table_size(config) do
        if config[i].from == name then
            configs[found] = config[i]
            found = found + 1
        end
    end
    return found > 1 and configs or false
end

local M = {}
M.debugDump = debugDump
M.saveVar = saveVar
M.config_exists = config_exists

return M