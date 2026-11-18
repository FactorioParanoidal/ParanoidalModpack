--[[
  Business logic for the import task feature.
]]--

function todo.on_import_tasks_click(player)
    local dialog = todo.get_import_dialog(player)
    if (dialog == nil) then
        return
    end

    local buttons = dialog.todo_import_dialog_button_flow
    if buttons and buttons.todo_import_cancel_button then
        buttons.todo_import_cancel_button.caption = {"gui.close"}
    end
    local encoded = dialog.todo_import_string_textbox.text
    if encoded:match("^%s*$") then
        todo.set_transfer_status(dialog, {"todo-action.import-empty"})
        return
    end

    local count = todo.import_tasks(encoded, player)
    if count == nil then
        todo.set_transfer_status(dialog, {"todo-action.import-unreadable"})
    elseif count == 0 then
        todo.set_transfer_status(dialog, {"todo-action.import-no-tasks"})
    else
        dialog.todo_import_string_textbox.text = ""
        todo.set_transfer_status(dialog, {"todo-action.imported", count})
        todo.update_main_task_list_for_everyone()
    end
end

-- Validate only the fields consumed by the existing importer and task UI.
-- Check the whole list before assigning IDs or adding any tasks.
local function readable_task(task)
    if type(task) ~= "table" then return false end
    for _, field in ipairs({"title", "task", "created_by", "assignee"}) do
        if task[field] ~= nil and type(task[field]) ~= "string" then return false end
    end
    if task.subtasks ~= nil then
        local subtasks = task.subtasks
        if type(subtasks) ~= "table" or type(subtasks.open) ~= "table"
            or type(subtasks.done) ~= "table" or type(subtasks.next_id) ~= "number"
            or subtasks.next_id < 1 or subtasks.next_id % 1 ~= 0 then return false end
        local seen = {}
        for _, list in ipairs({subtasks.open, subtasks.done}) do
            local count = 0
            for index, subtask in pairs(list) do
                if type(index) ~= "number" or index < 1 or index % 1 ~= 0
                    or type(subtask) ~= "table" or type(subtask.id) ~= "number"
                    or subtask.id < 1 or subtask.id % 1 ~= 0 or subtask.id >= subtasks.next_id
                    or seen[subtask.id] or type(subtask.task) ~= "string" then return false end
                seen[subtask.id] = true
                count = count + 1
            end
            for index = 1, count do
                if list[index] == nil then return false end
            end
        end
    end
    return true
end

local function import_error(encoded, result)
    local message = string.format("Не удалось прочитать задачи из строки %s. Результат: %s.", encoded, tostring(result))
    log(message)
    todo.log(message)
end

function todo.import_tasks(encoded, player)
    local status, result = pcall(helpers.decode_string, encoded)
    if not status or type(result) ~= "string" then
        import_error(encoded, result)
        return
    end

    local parsed, tasks = pcall(helpers.json_to_table, result)
    if not parsed then
        import_error(encoded, tasks)
        return
    end

    todo.log("Импорт задач:")
    todo.log(serpent.block(tasks))

    if (type(tasks) ~= "table") then
        import_error(encoded, "Ожидалась таблица, получено: " .. tostring(tasks))
        return
    end

    for _, task_to_import in pairs(tasks) do
        if not readable_task(task_to_import) then
            import_error(encoded, "Некорректная структура задачи или подзадачи.")
            return
        end
    end

    local count = 0
    for _, task_to_import in pairs(tasks) do
        local task = todo.assemble_task(task_to_import, player)
        task.created_by = task_to_import.created_by

        if (task_to_import.subtasks) then
            task.subtasks = task_to_import.subtasks

            for _, subtask in pairs(task.subtasks.done) do
                todo.mark_subtask_open(task, subtask.id)
            end
        end

        todo.log(serpent.block(task))
        todo.save_task_to_open_list(task)
        count = count + 1
    end

    todo.log("Imported " .. count .. " tasks.")
    return count
end

function todo.on_import_cancel_click(player)
    local dialog = todo.get_import_dialog(player)
    if (dialog) then
        dialog.destroy()
    end
end