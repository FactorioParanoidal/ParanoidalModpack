---@class Argument
---@field name string Name des Arguments
---@field value any Wert des Arguments
---@field result boolean Ergebnis der Prüfung
---@field message string|nil Fehlermeldung
---@field is ArgumentCheck Prüfer für Argumente
local Argument = {}

---@class ArgumentCheck
---@field equal fun(expectedType: string, expectedValue: any): Argument
---@field notEqual fun(expectedType: string, expectedValue: any): Argument
--- --@field andIs ArgumentCheck Verknüpfung weiterer Prüfungen

---@class That
---@overload fun(value:any)
local That = {}

---@param argName string Der Name des Arguments
---@param value any Der Wert des Arguments
---@return Argument
function That.Argument(argName, value)
	local arg = {
		name = argName,
		value = value,
		result = true,
		message = nil,
	}

	-- `is`-Tabelle
	---@type ArgumentCheck
	arg.is = {
		--- Überprüft, ob der Wert den erwarteten Typ hat und gleich einem anderen ist
		---@param expectedType string Erwarteter Typ
		---@param expectedValue any Erwarteter Wert
		---@return Argument
		equal = function(expectedType, expectedValue)
			-- Typprüfung
			arg.result = arg.result and type(arg.value) == expectedType
			if not arg.result then
				arg.message = "Argument '" .. arg.name .. "' is not of type " .. expectedType
				return arg
			end

			-- Wertprüfung
			arg.result = arg.result and arg.value == expectedValue
			if not arg.result then
				arg.message = "Argument '" .. arg.name .. "' does not equal " .. tostring(expectedValue)
			end

			return arg
		end,

		--- Überprüft, ob der Wert nicht den erwarteten Typ hat oder ungleich einem anderen ist
		---@param expectedType string Erwarteter Typ
		---@param expectedValue any Erwarteter Wert
		---@return Argument
		notEqual = function(expectedType, expectedValue)
			-- Typprüfung
			arg.result = arg.result and type(arg.value) ~= expectedType
			if not arg.result then
				arg.message = "Argument '" .. arg.name .. "' should not be of type " .. expectedType
				return arg
			end

			-- Wertprüfung
			arg.result = arg.result and arg.value ~= expectedValue
			if not arg.result then
				arg.message = "Argument '" .. arg.name .. "' should not equal " .. tostring(expectedValue)
			end

			return arg
		end,
	}

	-- `andIs` ist eine Referenz auf `is`, um weitere Prüfungen zu verketten
	arg.is.amdIs = arg.is

	-- Callable Argument für `assert`
	setmetatable(arg, {
		__call = function(self)
			if not self.result then
				error(self.message or "Assertion failed!")
			end
			return true
		end
	})

	return arg
end

-- Optional: Callable That
setmetatable(That, {
	__call = function(_, ...)
		return That.Assert()
	end
})

-- Beispiel-Nutzung:

-- Erfolgreiche Prüfungen:
assert(That.Argument("name", "test").is.equal("string", "test")._or_.notEqual("number", 5))
assert(That.Argument("status", true).is.notEqual("string", "true").andIs.equal("boolean", true))

-- Fehlerhafte Prüfungen:
assert(That.Argument("name", "test").is.equal("string", "foo").andIs.notEqual("string", "test")) -- Fehler: Argument 'name' does not equal foo
