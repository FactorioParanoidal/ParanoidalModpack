---@meta

-- -@class LuaObject: userdata

---@class object : LuaObject, {[string]:any}

---@alias KuxCoreLib.BasicTable table<string|number|boolean|KuxCoreLib.BasicTable>

---@alias KuxCoreLib.Tags table<string, string|number|boolean|KuxCoreLib.BasicTable>

-- -@alias LocalisedString string | table<string, (boolean | number | string | LocalisedString)?>
-- -@diagnostic disable-next-line: duplicate-doc-alias
-- -@alias LocalisedString string | table<string, (boolean | number | string)?>


-- -@alias LocalizableString string | table<string | boolean | number | LuaObject | LocalizableString>

-- -@alias LocalizableString (string)|(number)|(boolean)|(LuaObject)|(nil)|((LocalizableString)[])
---@alias LocalizableString (string)|(number)|(boolean)|(userdata)|(nil)|((LocalizableString)[])

--WORKAROUND
---@diagnostic disable-next-line: duplicate-doc-alias
---@alias LocalisedString any