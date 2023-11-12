_table = require('__stdlib__/stdlib/utils/table')
_string = require('__stdlib__/stdlib/utils/string')

Utils = {}

_table.contains = function(__table, value)
	return _table.find(__table,
		function(__table_item)
			return __table_item == value
		end) ~= nil
end

_table.contains_f = function(__table, value_function)
	return _table.find(__table,
		function(__table_item)
			return value_function(__table_item)
		end) ~= nil
end

_table.contains_f_deep = function(__table, item)
	return _table.contains_f(__table, function(item1)
		return _table.deep_compare(item, item1)
	end)
end
_table.insert_all_if_not_exists = function(table1, table2)
	_table.each(table2,
		function(item)
			if not _table.contains_f_deep(table1, item)
			then
				table.insert(table1, #table1 + 1, item)
			end
		end)
end
_table.get_item_index = function(__table, item)
	for k, v in pairs(__table) do
		if type(item) == 'table' and _table.deep_compare(v, item) then return k end
		if type(item) ~= 'table' and v == item then return k end
	end
	return nil
end
_table.remove_item = function(__table, item_for_remove, key_evaluate_function)
	local target_item = item_for_remove

	if key_evaluate_function then
		target_item = _table.first(_table.filter(__table, function(table_item)
			return key_evaluate_function(table_item, item_for_remove)
		end))
	end
	local item_key = _table.get_item_index(__table, target_item)

	if not item_key then
		error("Can't delete item " ..
			Utils.dump_to_console(item_for_remove) .. ' with key ' .. Utils.dump_to_console(item_key) ..
			' from given table!')
	end
	__table[item_key] = nil
end
Utils.dump_to_console = function(o)
	if type(o) == 'table' then
		local s = '{ '
		for k, v in pairs(o) do
			if type(k) ~= 'number' then k = '"' .. k .. '"' end
			s = s .. '[' .. k .. '] = ' .. Utils.dump_to_console(v) .. ','
		end
		return s .. '} '
	else
		return tostring(o)
	end
end

Utils.getModedObject = function(object, mode)
	if not object[mode] then
		error('mode ' .. mode .. ' for object ' ..
			Utils.dump_to_console(object) .. ' is not available!')
	end
	return object[mode]
end
