local data_util = {}
data_util.str_gsub = string.gsub

function data_util.replace(str, what, with)
    what = data_util.str_gsub(what, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1") -- escape pattern
    with = data_util.str_gsub(with, "[%%]", "%%%%") -- escape replacement
    return data_util.str_gsub(str, what, with)
end

function data_util.replace_filenames_recursive(subject, what, with)
  for _, sub in pairs(subject) do
    if (type(sub) == "table") then
      data_util.replace_filenames_recursive(sub, what, with)
    elseif _ == "filename" then
      subject.filename = data_util.replace(subject.filename, what, with)
    end
  end
end

function data_util.remove_from_table(list, item)
    local index = 0
    for _,_item in ipairs(list) do
        if item == _item then
            index = _
            break
        end
    end
    if index > 0 then
        table.remove(list, index)
    end
end

function data_util.concatenate_lists(a, b)
  for _, item in pairs(b) do
    table.insert(a, item)
  end
end

function data_util.list_to_set(list)
  local set = {}
  for _, item in pairs(list) do
    set[item] = true
  end
  return set
end

return data_util
