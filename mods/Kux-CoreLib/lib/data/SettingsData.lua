require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---@class KuxCoreLib.SettingsData: KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.SettingsData
local SettingsData = {
	__class  = "KuxCoreLib.SettingsData",
	__guid   = "{6B1DC373-2A83-4C81-94BD-92E772340FDE}",
	__origin = "Kux-CoreLib/lib/data/SettingsData.lua",
}
if not KuxCoreLib.__classUtils.ctor(SettingsData) then return self end
---------------------------------------------------------------------------------------------------

SettingsData.startup = {}
SettingsData.runtime = {}
SettingsData.runtime.global = {}
SettingsData.runtime.user = {}

local function merge(order_index, common, data, final_fixes)
	--print("merge", order_index, common, data, final_fixes)
	local merged = {}
	--merge common-- << extend(common)
	for k,v in pairs(common) do merged[k] = v end
	merged.setting_type = merged.setting_type or common[1] or error("Missing value 'setting_type'")
	merged.order = (merged.order or common[2])
	if(merged.order) then merged.order = string.format("%s%02d", merged.order, order_index or 0) end
	--print("  order", merged.order)
	--correct missspelled names
	if(merged.setting_type:match("user")) then merged.setting_type = "runtime-per-user"
	elseif(merged.setting_type:match("global")) then merged.setting_type = "runtime-global"
	elseif(merged.setting_type:match("runtime")) then merged.setting_type = "runtime-global"
	end

	--merge data-- << x:int(data)
	for k,v in pairs(data) do merged[k] = type(k)~="number" and v or nil end

	--merge final_fixes--
	for k,v in pairs(final_fixes) do merged[k] = v; end
	merged.allowed_values = final_fixes.allowed_values --WORKOROUND, I dont know why allowed_values is set to 0

	--clean up--
	merged.prefix = nil

	return merged
end

---
---@class KuxCorelib.ExtendArguments
---@field [1] "startup"|"runtime-global"|"runtime-per-user" setting_type
---@field [2] string? order
---@field prefix string? The name prefix for all settings
---

---
---@class KuxCorelib.ExtendArguments.Common
---@field setting_type "startup"|"runtime-global"|"runtime-per-user" setting_type
---@field order string? order
---@field prefix string? The name prefix for all settings
---

local function common_from_args(t)
	local common = {}
	for k,v in pairs(t) do common[k] = v end
	if t[1] then common.setting_type = t[1] end
	if t[2] then common.order = t[2] end
	return common
end

 ---@class KuxCoreLib.SettingsData.ExtendInstance
 ---@field common table
 local x = {}

---Creates a new Extend object
---@param t KuxCorelib.ExtendArguments
---@return KuxCoreLib.SettingsData.Extend
local function call_extend(self, t)
	local new = {common = common_from_args(t), count = 0}
	setmetatable(new, {
		__index = x
	})
	return new
end

---@class KuxCoreLib.SettingsData.Extend
---@field prefix string The name prefix for all settings
---@overload fun(args:KuxCorelib.ExtendArguments|table):KuxCoreLib.SettingsData.ExtendInstance
---<p>Usage: <br>
---<code> local extend = KuxCoreLib.require.SettingsData.extend  </code><br>
---<code> local x = extend { "startup|global|user", order?, prefix?= } </code>
SettingsData.extend = {
	---@type string
	prefix = nil,
	---@type KuxCorelib.ExtendArguments.Common
	common = nil
}
setmetatable(SettingsData.extend --[[@as table]],{
	__call = call_extend
})

---@param args KuxCorelib.ExtendArguments|table
---@return KuxCoreLib.SettingsData.ExtendInstance
---<p>Usage: <br>
---<code> local x = extend.new { "startup|global|user", order?, prefix?= } </code>
function SettingsData.extend.new(args) return call_extend(nil, args) end

---@param self KuxCoreLib.SettingsData.ExtendInstance
---@return string
local function getPrefix(self)
	return (self.common.prefix or SettingsData.extend.prefix or mod and mod["prefix"] or "")
end

---@param self KuxCoreLib.SettingsData.ExtendInstance
---@param name string
---@return string
local function getName(self, name)
	return getPrefix(self)..name
end


---
---@class KuxCorelib.BaseSetting
---@field hidden boolean?
---@field localised_name LocalisedString?
---@field localised_description LocalisedString?
---

---
---@class KuxCorelib.BoolSetting : KuxCorelib.BaseSetting
---
---@field [1] string 'name'
---@field [2] boolean 'default_value' Defines the default value of the setting.
---

---
---@class KuxCorelib.BoolSetting.compatibility : KuxCorelib.BaseSetting
---
---@field name string?
---@field default_value boolean?  Defines the default value of the setting.
---@field forced_value boolean?
---

---
---@class KuxCorelib.BoolSetting.const : KuxCorelib.BaseSetting
---
---@field [1] string 'name'
---@field [2] boolean 'forced_value' Defines the const value of the setting.
---

---Adds bool-setting
---@param t KuxCorelib.BoolSetting|KuxCorelib.BoolSetting.compatibility
function x:bool(t)
	self.count = self.count + 1
	local d = merge(self.count, self.common, t, {
		type          = "bool-setting",
		name          =  getName(self, t.name or t[1]),
		default_value = tostring(t.default_value or t[2] or false) == "true",
		-- forced_value -- Only loaded if hidden = true
	})
	data:extend{d}
end

---Adds bool-setting (hidden constant)
---@param t KuxCorelib.BoolSetting.const
---<p>Usage:<br>
---1. <code>x:bool_const{name, const_value }</code>
function x:bool_const(t)
	self.count = self.count + 1
	local value = tostring(t["default_value"] or t[2] or false)  == "true"
	local d = merge(self.count, self.common, t, {
		type          = "bool-setting",
		name          =  getName(self, t["name"] or t[1]),
		default_value = value,
		forced_value = value,
		hidden = true
	})
	data:extend{d}
end

---@class KuxCorelib.IntSettingArguments
---@field [1] string 'name' Defines the name of the setting.
---@field [2] int64 'default_value' Defines the default value of the setting.
---@field [3] int? Defines the lowest possible number.
---@field [4] int? Defines the lowest possible number.
---@field min int64? Defines the lowest possible number.
---@field max int64? Defines the highest possible number.
---@field allowed int64[]? Makes it possible to force the player to choose between the defined numbers, creates a dropdown instead of a texfield. If only one allowed value is given, the settings is forced to be of that value.

---@class KuxCorelib.IntSettingArguments.const
---@field [1] string 'name' Defines the name of the setting.
---@field [2] int64 'default_value' Defines the const value of the setting.

---@class KuxCorelib.IntSettingArguments.compatibility
---@field name string Defines the name of the setting.  [only for compatibility, use '[1]' instead]
---@field default_value int64 Defines the default value of the setting. [only for compatibility, use '[2]' instead]
---@field minimum_value int64? Defines the lowest possible number. [only for compatibility, use 'min' instead]
---@field maximum_value int64? Defines the highest possible number. [only for compatibility, use 'max' instead]
---@field allowed_values int64[]? Makes it possible to force the player to choose between the defined numbers, creates a dropdown instead of a texfield. If only one allowed value is given, the settings is forced to be of that value.

---Adds int-setting
---@param t KuxCorelib.IntSettingArguments|KuxCorelib.IntSettingArguments.compatibility
---<p>Usage:<br>
---1. <code>x:int{name, default, min?, max?, allowwed?=[] }</code><br>
---2. <code>x:int{name, default, allowed[] }</code><br>
---3. <code>x:int{name=, default_value=, minimum_value?=, maximum_value?=, allowed_values?= }</code> for comatibility
function x:int(t)
	self.count = self.count + 1
	local ff =
	{
		type           = "int-setting",
		name           = getName(self, t.name or t[1]),
		default_value  = t.default_value or t[2] or error("Missing value 'default_value|default|[2]'"),
		minimum_value  = t.minimum_value or t.min or (type(t[3]) == "number" and t[3] or nil),
		maximum_value  = t.maximum_value or t.max or t[4],
		allowed_values = t.allowed_values or t.allowed or (type(t[3]) == "table" and t[3] or nil),
	}
	if type(t[3]) == "number" then
		minimum_value  = t[3]
		maximum_value  = t[4]
	end

	local d = merge(self.count, self.common, t, ff)
	data:extend{d}
end

---Adds int-setting (hidden constant)
---@param t KuxCorelib.IntSettingArguments.const
---<p>Usage:<br>
---1. <code>x:int_const{name, const_value }</code>
function x:int_const(t)
	self.count = self.count + 1
	local value = t["default_value"] or t[2] or error("Missing value 'default_value'|[2]")
	local d = merge(self.count, self.common, t, {
		type           = "int-setting",
		name           = getName(self, t["name"] or t[1]),
		default_value  = value,
		allowed_values = {value},
		hidden = true
	})
	data:extend{d}
end

---@class KuxCorelib.DoubleSettingArguments
---@field [1] string 'name' Defines the name of the setting.
---@field [2] double 'default_value' Defines the default value of the setting.
---@field [3] double? minimum_value double Defines the lowest possible number.
---@field [4] double? Defines the highest possible number.
---@field min double? Defines the lowest possible number.
---@field max double? Defines the highest possible number.
---@field allowed double[]? Makes it possible to force the player to choose between the defined numbers, creates a dropdown instead of a texfield. If only one allowed value is given, the settings is forced to be of that value.  [only for compatibility, use 'allowed' instead]

---@class KuxCorelib.DoubleSettingArguments.compatibility
---@field name string
---@field default_value double Defines the default value of the setting.
---@field minimum_value double? Defines the lowest possible number. [only for compatibility, use 'min' instead]
---@field maximum_value double? Defines the highest possible number. [only for compatibility, use 'max' instead]
---@field allowed_values double[]? Makes it possible to force the player to choose between the defined numbers, creates a dropdown instead of a texfield. If only one allowed value is given, the settings is forced to be of that value.

---@class KuxCorelib.DoubleSettingArguments.const
---@field [1] string 'name' Defines the name of the setting.
---@field [2] double 'default_value' Defines the const value of the setting.

---Adds double-setting
---@param t KuxCorelib.DoubleSettingArguments|KuxCorelib.DoubleSettingArguments.compatibility
---<p>Usage:<br>
---1. <code>x:int{name, default, min?, max?, allowwed?=[] }</code><br>
---2. <code>x:int{name, default, allowed[] }</code><br>
---3. <code>x:int{name=, default_value=, minimum_value?=, maximum_value?=, allowed_values?= }</code> for comatibility
function x:double(t)
	self.count = self.count + 1
	local d = merge(self.count, self.common, t, {
		type           = "double-setting",
		name           = getName(self, t.name or t[1]),
		default_value  = t.default_value or t[2] or error("Missing value 'default_value'"),
		minimum_value  = t.minimum_value or t.min or (type(t[3]) == "number" and t[3] or nil),
		maximum_value  = t.maximum_value or t.max or t[4],
		allowed_values = t.allowed_values or t.allowed or (type(t[3]) == "table" and t[3] or nil),
	})
	data:extend{d}
end

---Adds double-setting (hidden constant)
---@param t KuxCorelib.DoubleSettingArguments.const
---<p>Usage:<br>
---1. <code>x:double_const{name, const_value }</code><
function x:double_const(t)
	self.count = self.count + 1
	local value  = t["default_value"] or t[2] or error("Missing value 'default_value'|[2]")
	local d = merge(self.count, self.common, t, {
		type           = "double-setting",
		name           = getName(self, t["name"] or t[1]),
		default_value  = value,
		allowed_values = {value},
		hidden = true
	})
	data:extend{d}
end

---@class KuxCorelib.StringSettingArguments
---@field [1] string 'name'
---@field [2] string 'default_value' Defines the default value of the setting.
---@field [3] string[] 'allowed_values' Makes it possible to force the player to choose between the defined values, creates a dropdown instead of a texfield. If only one allowed value is given, the settings is forced to be of that value.
---@field allow_blank boolean? Defines whether it's possible for the user to set the textfield to empty and apply the setting.
---@field auto_trim boolean? Whether values that are input by the user should have whitespace removed from both ends of the string.
---@field allowed string[]? Makes it possible to force the player to choose between the defined values, creates a dropdown instead of a texfield. If only one allowed value is given, the settings is forced to be of that value.

---@class KuxCorelib.StringSettingArguments.const
---@field [1] string 'name'
---@field [2] string 'default_value' Defines the const value of the setting.

---@class KuxCorelib.StringSettingArguments.comatibility
---@field name string?
---@field default_value string? Defines the default value of the setting.
---@field allow_blank boolean? Defines whether it's possible for the user to set the textfield to empty and apply the setting.
---@field auto_trim boolean? Whether values that are input by the user should have whitespace removed from both ends of the string.
---@field allowed_values string[]? Makes it possible to force the player to choose between the defined values, creates a dropdown instead of a texfield. If only one allowed value is given, the settings is forced to be of that value.


---Adds string-setting
---@param t KuxCorelib.StringSettingArguments|KuxCorelib.StringSettingArguments.comatibility
---<p>Usage: <br>
---1: <code>x:string { name, default, allowed?, allow_blank?=, auto_trim?= }</code> <br>
---2: <code>x:string { name=, default_value=, allowed_values=, allow_blank?=, auto_trim?= }</code> used for compatibility
---</p>
function x:string(t)
	self.count = self.count + 1
	local d = merge(self.count, self.common, t, {
		type           = "string-setting",
		name           = getName(self, t.name or t[1]),
		default_value  = t.default_value or t[2] or error("Missing value 'default_value'|[2]"),
		allowed_values = t.allowed_values or t.allowed or t[3],
		--allow_blank
		--auto_trim
	})
	data:extend{d}
end

---Adds string-setting (hidden constant)
---@param t KuxCorelib.StringSettingArguments.const
---<p>Usage:<br>
---1. <code>x:string_const{name, const_value }</code>
function x:string_const(t)
	self.count = self.count + 1
	local value  = t["default_value"] or t[2] or error("Missing value 'default_value'")
	local d = merge(self.count, self.common, t, {
		type           = "string-setting",
		name           = getName(self, t["name"] or t[1]),
		default_value  = value,
		allowed_values = {value},
		hidden = true
		--allow_blank
		--auto_trim
	})
	data:extend{d}
end


---@class KuxCorelib.ColorSettingArguments
---@field [1] string 'name'
---@field [2] Color 'default_value' Defines the default value of the setting.
---@field name string?
---@field default_value Color? Defines the default value of the setting.


---Adds color-setting
---@param t KuxCorelib.ColorSettingArguments
function x:color(t)
	self.count = self.count + 1
	local d = merge(self.count, self.common, t, {
		type          = "color-setting",
		name          = getName(self, t.name or t[1]),
		default_value = t.default_value or t[2] or error("default_value is mandatory"),
	})
	data:extent{d}
end

---Adds color-setting (hidden constant)
---<br>NOTE: can not overide already set colors!
---@param t KuxCorelib.ColorSettingArguments
function x:color_const(t)
	self.count = self.count + 1
	local value = t.default_value or t[2] or error("default_value is mandatory")
	local d = merge(self.count, self.common, t, {
		type          = "color-setting",
		name          = getName(self, t.name or t[1]),
		default_value = value,
		hidden = true
	})
	data:extent{d}
end

---------------------------------------------------------------------------------------------------
return SettingsData