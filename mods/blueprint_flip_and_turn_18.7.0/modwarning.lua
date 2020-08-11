--[[if print then
        print("print exists")
        print("game.player", game and game.print)
elseif io.stderr then
        print = function(x) io.stderr:write(tostring(x).."\n") end
end
]]--
if log then
        log("COOL log exists !")
end
local function modwarning(msg)
        --local warning = warning or (game or {}).print or (player or {}).print or print or log
        local warning = log
        if warning then
                warning("[Blueprint Flip and Turn]WARNING: "..tostring(msg))
        end
end
return modwarning
