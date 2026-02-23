local Printer = {}

Printer.prefix = "LOG: "

-- print data.raw[tp] section as: prefix: type,name
Printer.TraceDataSectionToLog = function (tp)
	for name, _ in pairs(data.raw[tp]) do
		log(Printer.prefix .. tp .. "," .. name)
	end
end

return Printer
