--[[---------------------------------------------------------------------------
	Defines all global variables (used in Kux-CoreLib)
	REQIRE THIS file ONLY ONE TIME in lib/init.lua
--]]---------------------------------------------------------------------------

--NOTE: KuxCoreLib.require.Xxy does not work here!

---@type "factorio"|"local" Gets the current environment
_G.evironment = "factorio"

---@type boolean Gets if the the current environment is factorio
_G.isFactorio = true

---@type boolean Gets if the the current environment is local
_G.isLocal = false

---@type string The path to the local factorio installation
_G.localFactorioPath = _G.localFactorioPath or nil

---@type string The path to the lualib folder
_G.lualibPath = "__core__/lualib/"

---@type boolean Gets if the current factorio version is 1.x
_G.isV1 = false

---@type boolean Gets if the current factorio version is 2.x
_G.isV2 = true

---@type table<string,string> The active mods
_G.mods = _G.mods or {}

if not KuxCoreLibPath or KuxCoreLibPath:match("^__") then
	require(lualibPath.."util") --require("__core__/lualib/")

	if(script) then -- control-stage
		mods = script.active_mods
	end
	isV1 = string.sub(mods["base"], 1, 2) == "1."
	isV2 = string.sub(mods["base"], 1, 2) == "2."
	isV10 = string.sub(mods["base"], 1, 4) == "1.0."
	isV11 = string.sub(mods["base"], 1, 4) == "1.1."
	isV20 = string.sub(mods["base"], 1, 4) == "2.0."
else
	evironment = "local"
	isFactorio = false
	isLocal = true

	--fallback if localFactorioPath is not set
	if not localFactorioPath then
		--_G.localFactorioPath = "E:/Program Files/Factorio/1.1/"
		localFactorioPath = "E:/Program Files/Factorio/2.0/2.0/"
	end
	lualibPath = localFactorioPath.."data/core/lualib/"

	dofile(lualibPath.."util.lua")

	isV1 = false
	isV10 = false
	isV10 = false
	isV2 = true
	isV20 = true

	_G.mods = { --local mock
		["base"] = "2.0.0",
		["Kux-CoreLib"] = "3.0.0"
	}
end

if(script)then

	local RecipeWithQuality = require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/RecipeWithQuality")

	---@param entity LuaEntity
	---@return KuxCoreLib.RecipeWithQuality?
	function __getRecipe(entity)
		-- 'get_recipe' can only be used if this is crafting-machine
		-- 'previous_recipe' can only be used if this is Furnace

		-- try get_recipe for (crafting-machine->) assembling-machine|furnace|rocket-silo
		if entity.type == "assembling-machine" or entity.type == "furnace"  or entity.type == "rocket-silo" then
			local r,qp = entity.get_recipe();
			if r then return RecipeWithQuality.new(r,qp) end
		end

		--fallback: try previous_recipe for furnace
		if entity.type == "furnace" then
			local pri = entity.previous_recipe --> RecipeIDAndQualityIDPair?
			if not pri then return nil end
			local force = getForce(entity.force)
			local r = entity.previous_recipe.name -- RecipeIDAndQualityIDPair.name ->  RecipeID:LuaRecipePrototype|LuaRecipe|string
			if type(r) == "string" then r = force.recipes[r]
			elseif type(r) ~= "userdata" then r = force.recipes[r.name]
			end
			local q = pri.quality
			if type(q) == "string" then q = prototypes.quality[q] end

			return RecipeWithQuality.new(r,q)
		end
		return nil
	end

	---Gets a value indicating wether `value` is a table or userdata
	---@param value any
	---@param object_name string? The object_name to check for
	---@return boolean
	---@overload fun(value:any):boolean
	---@overload fun(value:any, object_name:string):boolean
	function _G.is_obj(value, object_name)
		local t = type(value)
		local isO = t == "table" or t == "userdata"
		if object_name then return isO and value.object_name == object_name
		else return isO end
	end

	---@param var any
	---@param object_name "LuaPlayer"|"LuaSurface"|"LuaForce"|"LuaRecipe"
	---@param prop string?
	---@param returnNilOnError boolean?
	---@return any
	local function getLuaObject(var, object_name, prop, returnNilOnError)
		if var == nil then
			return nil
		elseif is_obj(var, "LuaEntity") then ---@cast var LuaEntity
			if     object_name == "LuaEntity"  then var = var
			elseif object_name == "LuaSurface" then var = var.surface
			elseif object_name == "LuaForce"   then var = var.force
			elseif object_name == "LuaPlayer"  then var = var.last_user
			elseif object_name == "LuaRecipe"  then var = __getRecipe(var)
			else error("Invalid parameter") end
		elseif is_obj(var, "LuaPlayer") then ---@cast var LuaPlayer
			var =  object_name == "LuaPlayer"  and var
				or object_name == "LuaSurface" and var.surface
				or object_name == "LuaForce"   and var.force
				or var
		elseif is_obj(var, "LuaPlanet") then ---@cast var LuaPlanet
			var =  object_name == "LuaPlanet"  and var
				or object_name == "LuaSurface" and var.surface
				or error("Invalid parameter")
		elseif is_obj(var, "LuaRecipe") then ---@cast var LuaRecipe
			var =  object_name == "LuaRecipe"  and var
				or error("Invalid parameter")
		end

		local list = object_name == "LuaPlayer" and game.players
			or object_name == "LuaSurface" and game.surfaces
			or object_name == "LuaForce" and game.forces
			or object_name == "LuaRecipe" and prototypes.recipe
			or error("Invalid object_name: "..object_name)
		local type = type(var)

		local obj = type=="string" and list[var]
			     or type=="number" and list[var]
			     or type=="userdata" and var["object_name"]==object_name and var
			     or nil
		if not obj and type=="table" and object_name =="LuaPlayer" then
			local field_var = var.player_index or var.player
			if field_var then return getLuaObject(field_var, object_name, prop, returnNilOnError) end
		end
		if obj == nil then
			if returnNilOnError then return nil end
			error("Invalid input: "..serpent.block(var))
		end
		if not obj.valid then
			if returnNilOnError then return nil end
			error("Invalid "..object_name)
		end
		if prop == nil then return obj end
		return obj[prop]
	end

	---@alias LuaPlayerId integer|string|LuaPlayer
	---@alias LuaSurfaceId integer|string|LuaSurface
	---@alias LuaForceId integer|string|LuaForce

	---@param var LuaPlayerId --{player_index:number}|{player:LuaPlayer}
	---@return string
	function _G.getPlayerName(var) return getLuaObject(var, "LuaPlayer", "name")--[[@as string]] end

	---@param var LuaPlayerId
	---@return LuaPlayer
	---@overload fun(var:{player_index:number}):LuaPlayer
	---@overload fun(var:{player:LuaPlayer}):LuaPlayer
	function _G.getPlayer(var) return getLuaObject(var, "LuaPlayer", nil)--[[@as LuaPlayer]] end

	---@param var LuaPlayerId --{player_index:number}|{player:LuaPlayer}
	---@return LuaPlayer?
	function _G.getPlayerOrNil(var) return getLuaObject(var, "LuaPlayer", nil, true)--[[@as LuaPlayer?]] end

	---@param var LuaSurfaceId|LuaEntity|LuaPlayer|LuaPlanet
	---@return string
	function _G.getSurfaceName(var) return getLuaObject(var, "LuaSurface", "name")--[[@as string]] end

	---@param var LuaSurfaceId|LuaEntity|LuaPlayer|LuaPlanet
	---@return LuaSurface
	function _G.getSurface(var) return getLuaObject(var, "LuaSurface", nil)--[[@as LuaSurface]] end

	---@param var LuaSurfaceId|LuaEntity|LuaPlayer|LuaPlanet
	---@return LuaSurface?
	function _G.getSurfaceOrNil(var) return getLuaObject(var, "LuaSurface", nil, true)--[[@as LuaSurface?]] end

	---@param var LuaForceId|LuaEntity|LuaPlayer
	---@return string
	function _G.getForceName(var) return getLuaObject(var, "LuaForce", "name")--[[@as string]] end

	---@param var LuaForceId|LuaEntity|LuaPlayer
	---@return LuaForce
	function _G.getForce(var) return getLuaObject(var, "LuaForce", nil)--[[@as LuaForce]] end

	---@param var LuaForceId|LuaEntity|LuaPlayer
	---@return LuaForce?
	function _G.getForceOrNil(var) return getLuaObject(var, "LuaForce", nil, true)--[[@as LuaForce?]] end


	---@param var LuaRecipe|string|LuaEntity
	---@return string
	function _G.getRecipeName(var) return getLuaObject(var, "LuaRecipe", "name")--[[@as string]] end

	---@param var LuaRecipe|string|LuaEntity
	---@return LuaRecipe
	function _G.getRecipe(var) return getLuaObject(var, "LuaRecipe", nil)--[[@as LuaRecipe]] end

	---@param var LuaRecipe|string|nil|LuaEntity
	---@return LuaRecipe?
	function _G.getRecipeOrNil(var) return getLuaObject(var, "LuaRecipe", nil, true)--[[@as LuaRecipe?]] end

	-- getRecipe can not work in all case (string -> LuaRecipe) Which force is used?


	---
	---@param arg ElemID|Ingredient|Product|string|LuaEntity|LuaItem|LuaRecipe|LuaTechnology|LuaObject|RecipeInfo|SelectedPrototypeData
	---@param expected_type string? -- Can also contain multiple types separated by "|"
	---@return any
	---@return string?
	function getPrototypeAndCategory(arg, expected_type)
		if not arg then return nil, nil end
		local name, types

		if _G.type(arg) == "userdata" then --[[@cast arg LuaObject]]
			if arg.object_name =="LuaEntity" then --[[@cast arg LuaEntity]]
				return arg.prototype, "entity"
			elseif arg.object_name =="LuaEntityPrototype" then --[[@cast arg LuaEntityPrototype]]
				return arg, "entity"
			elseif arg.object_name =="LuaItem" then --[[@cast arg LuaItem]]
				return arg.prototype, "item"
			elseif arg.object_name =="LuaItemPrototype" then --[[@cast arg LuaItemPrototype]]
				return arg, "item"
			elseif arg.object_name =="LuaRecipe" then --[[@cast arg LuaRecipe]]
				return arg.prototype, "recipe"
			elseif arg.object_name =="LuaRecipePrototype" then --[[@cast arg LuaRecipePrototype]]
				return arg, "recipe"
			elseif arg.object_name =="LuaTechnology" then --[[@cast arg LuaTechnology]]
				return arg.prototype, "technology"
			elseif arg.object_name =="LuaTechnologyPrototype" then --[[@cast arg LuaTechnologyPrototype]]
				return arg, "technology"
			else
				error("Invalid argument. object_name="..arg.object_name)
			end
		elseif _G.type(arg) == "table" then
			if arg["__class"] == "RecipeInfo" then --[[@cast arg RecipeInfo]]
				return arg.prototype, "recipe"
			else
				name = arg.name or arg["value"] or error("Invalid argument: missing name")
				types = { arg.type or arg.base_type or error("Invalid argument: missing type") }
			end

		elseif _G.type(arg) == "string" then
			name = arg
			if not expected_type then error("Missing expected_type for string argument") end
			-- Zerlege den expected_type-String in eine Liste von Typen
			types = {}
			for t in expected_type:gmatch("[^|,%s/]+") do table.insert(types, t) end
		else
			error("Invalid argument type")
		end

		-- Check all specified types in the given order
		for _, type in ipairs(types) do
			local t = prototypes[type]
			if t then
				local prototype = t[name]
				if prototype then
					return prototype, type
				end
			end
		end

		error("Invalid name or type not found")
	end


	---
	---@param obj string|number|LuaPlayer|LuaGui|LuaGuiElement|table|any
	---@return integer?
	_G.getPlayerIndex = function(obj)
		local t = type(obj)
		if t == "number" then return obj end
		if t == "string" then return game.players[obj].index end
		if t == "userdata" then
			if obj.object_name=="LuaPlayer" then return obj.index end
			if obj.object_name=="LuaGui" then return obj.player.index end
			if obj.object_name=="LuaGuiElement" then return obj.player_index end
		end
		if t == "table" then
			if obj.player_index then return obj.player_index end
			if obj.player then return obj.player.index end
		end
		return getPlayer(obj).index
		--error("Invalid player argument: "..serpent.block(player))
	end


	rawset(_G, "toElemID", function(arg)
		error("ElementUtils must be required before use toElemID")
	end)

	---Returns the type of the argument, coded as a string. The possible results of this function are "nil" (a string, not the value nil), "number", "string", "boolean", "table", "function", "thread", and "userdata".
	---@param v any
	---@return "boolean"|"function"|"nil"|"number"|"string"|"table"|"thread"|"userdata"
	function typeof(v) return type(v) end

	---Return the name of the argument
	---@param v any
	---@return string
	---<p>The name depends on type: <br>
	---for userdata from <code>__object_name</code>, <br>
	---for tables from <code>__class</code>, <code>__class_name</code> or <code>__object_name</code> (in this order, first non nil), <br>
	---for functions via <code>fname()</code>(require FunctionUtils). <br>
	---or <code>nil</code> if no name is found.</p>
	function nameof(v)
		local t = type(v)
		if t=="userdata" then return v.object_name end
		if t=="table" then return v.__class or v.__class_name or v.object_name or error("no name object") end
		if t=="function" and KuxCoreLib.__modules.FunctionUtils then return KuxCoreLib.__modules.FunctionUtils.nameof(v) or error("no name function") end
		error("invalid argument")
	end

	---@param value any
	---@param enum table
	---@return string|nil
	function _G.getEnumName(value, enum)
		for name, val in pairs(enum) do
			if val == value then return name end
		end
		return nil
	end

end -- runtime

