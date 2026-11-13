---
-- Description of the module.
-- @class Command
--
local Command = {
    -- single-line comment
    classname = "HMCommand"
}

-------------------------------------------------------------------------------
-- Start
--
function Command.start()
    commands.add_command("helmod", "команды helmod", Command.run)
end

-------------------------------------------------------------------------------
-- Run
--
function Command.run(event)
    -- do nothing
end

-------------------------------------------------------------------------------
-- Parse
--
-- @param event table
--
function Command.parse(event)
    if event.command == "helmod" then
        if event.parameters == "" then
            Command.help()
        else
            Command.execute(event.parameters)
        end
    end
end

function Command.help()
    local commands = Command.initialize()
    local names = {}
    for _, cmd in pairs(commands) do
        table.insert(names, cmd.name)
    end
    Player.print(string.format("Допустимые аргументы: %s", table.concat(names, " | ")))
end

function Command.execute(parameters)
    local commands = Command.initialize()
    local cmd = commands[string.lower(parameters)]
    if cmd ~= nil then
        cmd.action();
    else
        Command.help()
    end
end

function Command.initialize()
    local commands = {}
    commands["close"] = {
        name = "CloseUI",
        description = "Закрыть все панели",
        action = function()
            for _, location in pairs({ "top", "left", "center", "screen", "goal" }) do
                for _, element in pairs(Player.getGui(location).children) do
                    if element.get_mod() == "helmod" and element.name ~= "mod_gui_top_frame" then
                        element.destroy()
                    end
                end
            end
            Player.print("Команда закрытия всех панелей выполнена!")
        end
    }
    commands["resetuserall"] = {
        name = "ResetUserAll",
        description = "Сбросить все параметры для всех пользователей",
        action = function()
            User.resetAll()
            Player.print("Параметры всех пользователей сброшены!")
        end
    }
    commands["resetuser"] = {
        name = "ResetUser",
        description = "Сбросить все параметры пользователя",
        action = function()
            User.reset()
            Player.print("Параметры пользователя сброшены!")
        end
    }
    commands["resetuserexplorer"] = {
        name = "ResetUserExplorer",
        description = "Сбросить параметры обозревателя рецептов пользователя",
        action = function()
            User.setParameter("explore_recipe", nil)
            User.setParameter("explore_recipe_id", nil)
            Player.print("Параметры обозревателя рецептов пользователя сброшены!")
        end
    }
    return commands
end

return Command
