local format = {}
-- local status, serpent = pcall(require, "__debug/serpent")
-- 
-- if status then
--     function format.debug(msg)
--         game.print(serpent.line(msg))
--     end
-- else
--     function format.debug(msg)
--     end
-- end

function format.all(msg)
    game.print("[color=yellow][LTN Cleanup][/color] " .. msg)
end

function format.item(name)
    return "[item=" .. name .. "]"
end

function format.fluid(name)
    return "[fluid=" .. name .. "]"
end

function format.train(train)
    if #train.locomotives.front_movers == 0 and #train.locomotives.back_movers == 0 then
        return "Train " .. train.id
    elseif #train.locomotives.back_movers == 0 then
        return "[train=" .. train.locomotives.front_movers[1].unit_number .. "]"
    else
        return "[train=" .. train.locomotives.back_movers[1].unit_number .. "]"
    end
end

function format.warning(msg)
    format.all("[color=#ffa500]Warning:[/color] " .. msg .. "")
end

function format.alert(msg)
    format.all("[color=#ff2b1f]Alert:[/color] " .. msg .. "")
end

function format.info(msg)
    format.all("[color=#008b8b]Info:[/color] " .. msg .. "")
end

function format.train_depot_alert(train)
    format.alert("Train " .. format.train(train) .. " will arrive at depot with remaining cargo")
end

return format
