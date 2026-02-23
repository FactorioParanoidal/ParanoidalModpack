require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

--from Kux-ModExport
--usage:
--[[
    local w = FileWriter.create("active_mods.txt", 1)
	for name, version in pairs(game.active_mods) do
		if excludeModeExport and name == script.mod_name then goto continue end
		w.writeString(name.."\r\n")
		::continue::
	end
]]
---@class KuxCoreLib.FileWriter
local FileWriter = {
	__class  = "FileWriter",
	__guid   = "{D54DB186-3D06-47CC-ABF7-8C25BCAE1B44}",
	__origin = "Kux-CoreLib/lib/FileWriter.lua",
}
if not KuxCoreLib.__classUtils.ctor(FileWriter) then return self end

---------------------------------------------------------------------------------------------------

local That = KuxCoreLib.That

FileWriter.flagAppend = false
FileWriter.file = nil
FileWriter.playerId = nil

---Creates a new FileWriter instance
FileWriter.create = function(file, playerId)
	assert(That.Argument.IsNotNil(file, "file"))
	assert(That.Argument.IsNotNil(file, "playerId"))

	local instance = {}
	instance.this = instance

	instance.writeField = function (obj, fieldName)
		helpers.write_file(FileWriter.file, "\""..fieldName.."\": "..toJsonValue(obj[fieldName]), FileWriter.flagAppend, FileWriter.playerId)
		FileWriter.flagAppend = true
	end
	instance.writeFieldLocalized = function (obj, fieldName)
		helpers.write_file(FileWriter.file, {"", "\""..fieldName.."\": \"", obj[fieldName], "\""}, FileWriter.flagAppend, FileWriter.playerId)
		FileWriter.flagAppend = true
	end
	instance.writeString = function (s)
		helpers.write_file(FileWriter.file, s, FileWriter.flagAppend, FileWriter.playerId)
		FileWriter.flagAppend = true
	end
	instance.writeLocalizedString = function (s)
		helpers.write_file(FileWriter.file, {"", s}, FileWriter.flagAppend, FileWriter.playerId)
		FileWriter.flagAppend = true
	end

	-- TODO create instance
	FileWriter.flagAppend = false
	FileWriter.file = file
	FileWriter.playerId = playerId
	return FileWriter
end

FileWriter.writeField = function (obj, fieldName)
	helpers.write_file(FileWriter.file, "\""..fieldName.."\": "..toJsonValue(obj[fieldName]) , FileWriter.flagAppend, FileWriter.playerId)
	FileWriter.flagAppend = true
end
FileWriter.writeFieldLocalized = function (obj, fieldName)
	helpers.write_file(FileWriter.file, {"", "\""..fieldName.."\": \"", obj[fieldName], "\""} , FileWriter.flagAppend, FileWriter.playerId)
	FileWriter.flagAppend = true
end
FileWriter.writeString = function (s)
	helpers.write_file(FileWriter.file, s, FileWriter.flagAppend, FileWriter.playerId)
	FileWriter.flagAppend = true
end
FileWriter.writeLocalizedString = function (s)
	helpers.write_file(FileWriter.file, {"", s}, FileWriter.flagAppend, FileWriter.playerId)
	FileWriter.flagAppend = true
end

---------------------------------------------------------------------------------------------------

---Provides FileWriter in the global namespace
---@return KuxCoreLib.FileWriter
function FileWriter.asGlobal() return KuxCoreLib.__classUtils.asGlobal(FileWriter) end

return FileWriter