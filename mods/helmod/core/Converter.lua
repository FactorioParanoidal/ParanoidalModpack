---
---Description of the module.
---@class Converter
local ImportReader = require("core.ImportReader")
local Converter = {
  ---single-line comment
  classname = "HMConverter",
  ---use gzip
  compressed = true,
  ---length of line
  line_length = 120
}

-------------------------------------------------------------------------------
---Trim string
---@param s string
---@return string
function Converter.trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-------------------------------------------------------------------------------
---Write table to string
---@param data_table table
---@return string
function Converter.write(data_table)
  local data_string = serpent.dump(data_table)
  return helpers.encode_string(data_string)
end

-------------------------------------------------------------------------------
---Read string to table
---@param data_string string
---@return table
function Converter.read(data_string)
  if type(data_string) ~= "string" or #data_string > ImportReader.max_bytes then return nil end
  data_string = Converter.trim(data_string)
  if string.sub(data_string, 1, 8) ~= "do local" then
    local ok, decoded = pcall(helpers.decode_string, data_string)
    if not ok or type(decoded) ~= "string" then return nil end
    data_string = decoded
  end
  return ImportReader.read(data_string)
end

-------------------------------------------------------------------------------
---Indent string
---@param json string
---@return string
function Converter.indent(json)
  local table_value = helpers.json_to_table(json)
  local result = Converter.indentTable(table_value, 0)
  return result
end

-------------------------------------------------------------------------------
---Indent table
---@param input any
---@param level number
---@return string
function Converter.indentTable(input, level)
  local indent_char = "    "
  if type(input) == "table" then
    local first = true
    local is_array = true
    local temp = ""
    for key,value in pairs(input) do
      if first == false then
        temp = temp .. ",\n"
      end
      if type(key) == "string" then
        is_array = false
        temp = temp .. string.rep(indent_char, level)
        temp = temp .. "\"" .. key .. "\": "
        temp = temp .. Converter.indentTable(value, level + 1)
      else
        temp = temp .. string.rep(indent_char, level)
        temp = temp .. Converter.indentTable(value, level + 1)
      end
      first = false
    end
    if is_array == true then
      temp = "[\n" .. temp .. "\n"
      temp = temp .. string.rep(indent_char, level-1)
      temp = temp .. "]"
      return temp
    else
      temp = "{\n" .. temp .. "\n"
      temp = temp .. string.rep(indent_char, level-1)
      temp = temp .. "}"
      return temp
    end
  elseif type(input) == "string" then
    return "\"" .. input .. "\""
  elseif type(input) == "boolean" then
    if input == true then
      return "true"
    else
      return "false"
    end
  end
  return input
end

return Converter
