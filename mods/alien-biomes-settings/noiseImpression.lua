local noise = require("noise")

local pne;
local indentInc = "  "

local function escape(str)
  str=string.gsub(str,"\t","\\t")
  str=string.gsub(str,"\n","\\n")
  str=string.gsub(str,"\r","\\r")
  str=string.gsub(str,"\\","\\\\")
  return string.gsub(str,"\"","\\\"")
end

local function impressLiteral(v,stringBuilder)
  stringBuilder.string=stringBuilder.string .. tostring(v.literal_value)
  return v
end

local function impressVariable(v,stringBuilder)
  stringBuilder.string=stringBuilder.string .."noise.var[\"".. escape(v.variable_name) .. "\"]"
  return v
end

local function impressString(v,stringBuilder)
  stringBuilder.string=stringBuilder.string .. "\"".. escape(v.literal_value) .."\""
  return v
end

local function impressArguments(v,stringBuilder,separator,indent)
  local len = #v
  for index, argument in ipairs(v) do
    pne(argument,stringBuilder,indent)
    if len ~= index then
      stringBuilder.string=stringBuilder.string .. separator
    end
  end
  return v
end

local function impressFunction(v,stringBuilder,indent)
  local indentNew = indent..indentInc..indentInc
  local name = "noise[\""..escape(v.function_name).."\"]"
  log(v.source_location.filename..":"..v.source_location.line_number .."  @ ".. v.function_name.." -> "..name)
  if(v.arguments==nil or #v.arguments==0)then
    stringBuilder.string=stringBuilder.string .. name .."()"
  else
    local argumentsBuilder = {string=""}
    impressArguments(v.arguments,argumentsBuilder,",\n"..indentNew,indentNew)
    stringBuilder.string=stringBuilder.string .. name .."(\n" ..  indentNew .. argumentsBuilder.string .. "\n" ..indent.. ")"
  end
  return v
end

local function impressIfElseChain(v,stringBuilder,indent)
  local indentQ = indent..indentInc..indentInc
  local indentNew = indent..indentInc
  local len = #v.arguments

  stringBuilder.string = stringBuilder.string .. " if " 
  pne(v.arguments[1],stringBuilder,indentQ)
  stringBuilder.string = stringBuilder.string .. " then\n"..indentNew.."return "
  pne(v.arguments[2],stringBuilder,indentNew)
  stringBuilder.string = stringBuilder.string .. "\n"..indent

  for index = 4, len, 2 do
    stringBuilder.string = stringBuilder.string .. "elseif " 
    pne(v.arguments[index-1],stringBuilder,indentQ)
    stringBuilder.string = stringBuilder.string .. " then\n"..indentNew.."return "
    pne(v.arguments[index],stringBuilder,indentNew)
    stringBuilder.string = stringBuilder.string .. "\n"..indent
  end
  
  stringBuilder.string = stringBuilder.string .. " else\n"..indentNew.."return "
  pne(v.arguments[len],stringBuilder,indentNew)
  stringBuilder.string = stringBuilder.string .. "\n"..indent .. "end"
end

local function impressOperator(v,stringBuilder,op,indent)
  if(#v.arguments==1) then
    stringBuilder.string = stringBuilder.string .. op
    impressArguments(v.arguments,stringBuilder,op,indent)
  else
    impressArguments(v.arguments,stringBuilder,op,indent)
  end
  return v
end

local ops={
  ["add"]=function (expression,stringBuilder,indent) return impressOperator(expression,stringBuilder,"+",indent) end,
  ["subtract"]=function (expression,stringBuilder,indent) return impressOperator(expression,stringBuilder,"-",indent) end,
  ["multiply"]=function (expression,stringBuilder,indent) return impressOperator(expression,stringBuilder,"*",indent) end,
  ["divide"]=function (expression,stringBuilder,indent) return impressOperator(expression,stringBuilder,"/",indent) end,
  ["exponentiate"]=function (expression,stringBuilder,indent) return impressOperator(expression,stringBuilder,"^",indent) end,
}

function pne(expression,stringBuilder,indent)
  local v = expression.type
  if v == "literal-number" or v == "literal-boolean" or v=="literal-object" then
    return impressLiteral(expression,stringBuilder)
  elseif v == "literal-string" then
    return impressString(expression,stringBuilder)
  elseif v == "variable" then
    return impressVariable(expression,stringBuilder)
  elseif v == "function-application" then
    if ops[expression.function_name] then
      ops[expression.function_name](expression,stringBuilder,indent)
    else
      return impressFunction(expression,stringBuilder,indent)
    end
  elseif v == "if-else-chain" then
    return impressIfElseChain(expression,stringBuilder,indent)
  else
    error("Can't turn " .. v .. " into noise impression")
  end
end

return function (noiseExpr)
  if __DebugAdapter then
    local stringBuilder = {string=""}
    pne(noiseExpr,stringBuilder,"")
    log(stringBuilder.string)
    return noiseExpr
  end
end