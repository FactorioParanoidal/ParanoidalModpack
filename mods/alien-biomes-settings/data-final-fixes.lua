local doingAnalysis = __DebugAdapter and false

if doingAnalysis then
  require("noiseAnalysis")()
else
  require("noiseSettings")()
end