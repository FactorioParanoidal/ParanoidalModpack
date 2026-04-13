require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---@class KuxCoreLib.Path
local Path = {
	__class  = "Path",
	__guid   = "{6C02BAA4-AA92-4760-95C9-F62C7EF1E373}",
	__origin = "Kux-CoreLib/lib/Path.lua",
}
if not KuxCoreLib.__classUtils.ctor(Path) then return self end
---------------------------------------------------------------------------------------------------
local String = KuxCoreLib.String
local Table = KuxCoreLib.Table

---Gets the folder name
---@param path string
---@return string
function Path.getFolderName(path)
	-- Remove the separator at the end of the path, if present
	if path:sub(-1) == "/" then
		path = path:sub(1, -2)
	end
	-- Search the last separator in the path
	local lastSeparatorIndex = path:match(".*/()")
	-- Extract the folder path
	local folderName = path:sub(1, lastSeparatorIndex - 1)
	return folderName
end

---Gets the file name fram a path
---@param path string
---@return string
function Path.getFileName(path)
	-- Search the last separator in the path
	local lastSeparatorIndex = path:match(".*/()")
	-- Extract the filename
	local fileName = path:sub(lastSeparatorIndex)
	return fileName
end

function Path.getFileNameWithoutExtension(path)
	local fn = path
	if(string.find(fn,"/")) then fn = Path.getFileName(path) end

	local lastDotIndex = fn:find(".[^%.]*$")
	if lastDotIndex then
		return fn:sub(1, lastDotIndex - 1)
	else
		return fn
	end
end

function Path.getExtension(path)
	local match = string.match(path, "%.(.*)$")
	return match
end

function Path.GetFilesRecursive(currentFolder)
    local fullFilePaths = {}
	---@diagnostic disable-next-line: undefined-field
    for file in io.popen('dir /b /s /a-d "'..currentFolder..'"'):lines() do
        table.insert(fullFilePaths, file)
    end
    return fullFilePaths
end

function Path.getCurrentDirectory()
	return io.popen("cd"):read("*l"):gsub("/", "\\")
end

function Path.guessFullName(path)
	-- "...rio\\Mods\\Kux-CoreLib/tests/storage/GlobalPlayersTests.lua"

	local curFolder = Path.getCurrentDirectory()
	local fragments = String.split(path, nil, { "\\", "/" })
	table.remove(fragments, 1) -- remove the first incomplete fragment ("...rio")
	local partialPath = String.join("\\", fragments)
	local a = String.split(curFolder, nil, { "\\", "/" })

	-- abcd
	--   cdef
	local aStart,aEnd,bStart,bEnd = Table.overlaps(a,fragments)
	if(not aStart) then return nil end
	for i = bEnd+1, #partialPath, 1 do
		table.insert(a,fragments[i])
	end
	local fullPath=String.join("\\", a)
	return fullPath

	-- local files = Path.GetFilesRecursive(curFolder)
	-- for _, file in ipairs(files) do
	-- 	if(String.endsWith(file, partialPath,true)) then return file end
	-- end
end

function Path.exist(path)
    local cmd

    ---@diagnostic disable-next-line: undefined-field
    if package.config:sub(1,1) == "\\" then
        cmd = "dir " .. path
    else
        cmd = "ls " .. path
    end

    local handle = io.popen(cmd)
    local result = handle:read("*a")
    handle:close()

    return result ~= ""
end
function Path.getRelativePath(path, root)
	path = path:gsub("/", "\\")
	root = (root or Path.getCurrentDirectory()):gsub("/", "\\")

	if(not string.match(path, "^%a:.*") and path[1]~="/") then return path end -- path is already relativ

	 -- Überprüfe, ob der angegebene Pfad absolut ist
	 if(String.startsWith(path,root, true))then
        -- Mache den Pfad relativ, indem du den Wurzelpfad vom Pfad entfernst
        local relativePath = string.sub(path, string.len(root) + 1)
		if(relativePath:sub(1,1)=="\\") then relativePath = relativePath:sub(2) end
        return relativePath
    end

	-- TODO: test path="C:\a\b\file", root ="C:\c" => 	"..\a\b\file"
	local rootParts = String.split(root,nil,{"/","\\"})
	local pathParts = String.split(path,nil,{"/","\\"})
    -- Ermitteln der gemeinsamen Verzeichnisse
    local commonCount = 0
    for i = 1, math.min(#pathParts, #rootParts) do
        if pathParts[i] == rootParts[i] then
            commonCount = commonCount + 1
        else
            break
        end
    end

    -- Erstellen des relativen Pfads
    if commonCount == 0 then
        -- Pfade haben keine gemeinsamen Verzeichnisse
        return path
    else
		local separator="\\" --package.config:sub(1,1)
		local relativePath = ""
        -- Number of directories that need to be returned
        local upCount = #rootParts - commonCount + 1

        -- Creating the relative path structure
        for i = 1, upCount do
            relativePath = relativePath .. ".." .. separator
        end

        for i = commonCount + 1, #pathParts do
            relativePath = relativePath .. pathParts[i] .. separator
        end

        -- Removing the terminating delimiter
        relativePath = string.sub(relativePath, 1, -2)
    end

    return path
end

function Path.getFullName(relativPath, root)
	root = root or Path.getCurrentDirectory()
	relativPath = relativPath:gsub("/","\\")
	if(root:sub(-1)~="\\") then root = root .."\\" end
	return root .. relativPath
end

---------------------------------------------------------------------------------------------------

---Provides Path in the global namespace
---@return KuxCoreLib.Path
function Path.asGlobal() return KuxCoreLib.__classUtils.asGlobal(Path) end

return Path