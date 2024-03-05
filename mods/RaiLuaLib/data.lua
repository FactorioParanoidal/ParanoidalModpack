local tests = require("tests.tests")
for _,test in pairs(tests) do
  require("tests."..test..".data")
end