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

_table.insert_all_if_not_exists = function(table1, table2)
	_table.each(table2,
		function(item)
			if not _table.contains_f(table1,
					function(value)
						return _table.deep_compare(item, value)
					end)
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
_table.remove_item = function(__table, item)
	--log(Utils.dump_to_console(__table))
	--log(Utils.dump_to_console(item))
	local item_key = _table.get_item_index(__table, item)
	if not item_key then
		return false
	end
	__table[item_key] = nil
	return true
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
	local result = object
	local temp_result
	if object[mode] then temp_result = object[mode] end
	if not temp_result then return result end
	local keys = _table.keys(temp_result)
	_table.remove_keys(result, keys)
	return _table.merge(result, temp_result)
end
