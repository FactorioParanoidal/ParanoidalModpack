require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---flying-text
---@class KuxCoreLib.FlyingText : KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.FlyingText
local FlyingText = {
	__class  ="FlyingText",
	__guid   = "{8BFF3C82-2A4F-41F8-A7B3-C2969A741749}",
	__origin = "Kux-CoreLib/lib/FlyingText.lua",
}
if not KuxCoreLib.__classUtils.ctor(FlyingText) then return self end

local function posOffset( pos, offset )
	return { x=pos.x + offset.x, y=pos.y + offset.y }
end

local function localiseString(text)
	if(type(text)~="table") then return text end
	local flattenedTable = {""}

	local function flatten(tbl)
		for _, value in ipairs(tbl) do
			if type(value) == "table" then
				flatten(value)
			elseif(value=="") then
				--skip empty string
			else
				table.insert(flattenedTable, value)
			end
		end
	end
	flatten(text)
	return flattenedTable
end



---@class KuxCoreLib.FlyingTextOptions
---@field player uint|LuaPlayer
---@field text string|table
---@field color Color|nil
---@field position MapPosition|nil
---@field target LuaEntity|nil
---@field speed float|nil
---@field time_to_live uint|nil

---Creates a flying text entity
function FlyingText.create_V1(player, text, color)
	--trace.append(serpent.block(player))
	local args
	if(type(player)=="table" and not text and not color) then
		args = player ---@cast args LuaSurface.create_entity_param
		player = args.player or args[1]
		args.text = args.text or args[2]
		args.color = args.color or args[3]
		args["__class"] = "LuaSurface.create_entity_param"
		assert(player, "Invalid Argument: 'player' must not be nil.")
		assert(args.text, "Invalid Argument: 'text' must not be nil.")
	else
		args = {
			text = text,
			color = color
		}
		---@cast args LuaSurface.create_entity_param
	end
	args.name = "flying-text"
	args.position = args.position or posOffset(player.position,{x=-0.5, y=0.2})
	args.color = args.color or {0.8,0.8,0.8}
	player.surface.create_entity(args)
end

function FlyingText.create(player, text, color)
	if isV1 then return FlyingText.create_V1(player, text, color) end

	--trace.append(serpent.block(player))
	local args
	if(type(player)=="table" and not text and not color) then
		args = player ---@cast args LuaPlayer.create_local_flying_text_param
		player = args.player or args[1]
		args.text = args.text or args[2]
		args.color = args.color or args[3]
		args["__class"] = "LuaPlayer.create_local_flying_text_param"
		assert(player, "Invalid Argument: 'player' must not be nil.")
		assert(args.text, "Invalid Argument: 'text' must not be nil.")
	else
		args = {
			text = text,
			color = color
		}
		---@cast args LuaPlayer.create_local_flying_text_param
	end
	args.position = args.position or posOffset(player.position,{x=-0.5, y=0.2})
	args.color = args.color or {0.8,0.8,0.8}
	player.create_local_flying_text(args)
end

---------------------------------------------------------------------------------------------------
return FlyingText