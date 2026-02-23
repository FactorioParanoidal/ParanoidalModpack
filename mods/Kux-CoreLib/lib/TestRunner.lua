require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

-- if TestRunner then
--     if TestRunner.__guid == "{68FAAD34-FF3D-40A2-9844-BF1F9400E5A8}" then return TestRunner end
--     error("A global TestRunner class already exist.")
--     --TODO combine
-- end

---@class KuxCoreLib.TestRunner
---Example:
---local tests = {name="Lua"}
---function tests.myTest() ..[your test code].. end
---TestRunner.run(tests)
local TestRunner = {
	__class  = "TestRunner",
	__guid   = "{68FAAD34-FF3D-40A2-9844-BF1F9400E5A8}",
	__origin = "Kux-CoreLib/lib/TestRunner.lua",
}
if not KuxCoreLib.__classUtils.ctor(TestRunner) then return self end
---------------------------------------------------------------------------------------------------
local Debug = KuxCoreLib.Debug
local Path = KuxCoreLib.Path
local String = KuxCoreLib.String

---@class private
local private = {}

---@class settings TestRunner settings
TestRunner.settings = {
	name="TestRunner.settings",
}

---@class settings TestRunner results
TestRunner.results = {
	name="TestRunner.results",
	successedTest=0,
	failedTests=0
}

TestRunner.tests={}

function private.runTestClass(testClass)
	if not testClass.name then testClass.name ="(unnamed)" end

	for name, f in pairs(testClass) do
		if type(f)~="function" then goto next end
		local stacktrace =""
		local innerException
		local tracebackOutput
		-- print(testClass.name .. " "..name)
		local success = xpcall(f, function (ex2)
			stacktrace = debug.traceback(ex2, 2)
			innerException = ex2
		end)
		if success then
			TestRunner.results.successedTest = TestRunner.results.successedTest + 1
			-- print("  Successful")
		else
			TestRunner.results.failedTests=TestRunner.results.failedTests + 1
			-- print("  FAIL: "..ex)
			--local file, line = private.getFunctionLocation(f)
			local caller= Debug.util.extractLineBeforeXpcall(stacktrace)
			local file, line = Debug.util.extractLineInfo(caller)
			if(String.startsWith(innerException,"...")) then innerException = Path.guessFullName(innerException) or innerException end
			innerException = Path.getRelativePath(innerException)
			file = Path.getRelativePath(file)
			print("FAIL: "..testClass.name.." "..name.." > "..innerException.." in test "..tostring(file)..":"..tostring(line))
			--print(traceback)
		end
		-- print("--------------------------------------------------------------------------------")
		::next::
	end
	-- print(testClass.name)
	-- print(failedTests.." tests failed. "..successedTest.." successful.")
	-- print("================================================================================")
end

-- function private.getFunctionLocation(func)
--     local success, info = pcall(debug.getinfo, func, "Sl")
--     if success and info then
--         return info.source, info.currentline
--     end
--     return nil, nil
-- end

function private.getFunctionLocation(func)
    local info = debug.getinfo(func, "Sl")
    if info and info.source and info.currentline then
        return info.source, info.currentline
    end
    return nil, nil
end

---By default run() starts immediately the test, with isCollecting=true you can collect first and then call runCollected()
TestRunner.isCollecting=false

local function printSummary()
	if(TestRunner.results.failedTests>0) then
		io.write("\27[31m") -- Textfarbe auf Rot setzen
	else
		io.write("\27[32m") -- Textfarbe auf Grün setzen
	end
	print("--------------------------------------------------------------------------------")
	print(TestRunner.results.failedTests.." tests failed. "..TestRunner.results.successedTest.." successful.")
	print("================================================================================")
	io.write("\27[0m") -- Zurücksetzen auf Standardfarben
end

---This is called by any test module
---@param testClass table contains the test methods
function TestRunner.run(testClass)
	if TestRunner.isCollecting then
		table.insert(TestRunner.tests,testClass)
	else
		TestRunner.results.successedTest = 0
		TestRunner.results.failedTests = 0
		private.runTestClass(testClass)
		printSummary()
	end
end

function TestRunner.runCollected()
	TestRunner.results.successedTest = 0
	TestRunner.results.failedTests = 0
	for _,testClass in ipairs(TestRunner.tests) do
		private.runTestClass(testClass)
	end
	printSummary()
end

---------------------------------------------------------------------------------------------------

---Provides TestRunner in the global namespace
---@return KuxCoreLib.TestRunner
function TestRunner.asGlobal() return KuxCoreLib.__classUtils.asGlobal(TestRunner) end

return TestRunner