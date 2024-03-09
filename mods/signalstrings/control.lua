-- Mappings for vanilla signals. Mods may extend this list by calling register_signal in on_load|init
local charmap={
  c2s={
    ["0"]='signal-0',["1"]='signal-1',["2"]='signal-2',["3"]='signal-3',["4"]='signal-4',
    ["5"]='signal-5',["6"]='signal-6',["7"]='signal-7',["8"]='signal-8',["9"]='signal-9',
    ["A"]='signal-A',["B"]='signal-B',["C"]='signal-C',["D"]='signal-D',["E"]='signal-E',
    ["F"]='signal-F',["G"]='signal-G',["H"]='signal-H',["I"]='signal-I',["J"]='signal-J',
    ["K"]='signal-K',["L"]='signal-L',["M"]='signal-M',["N"]='signal-N',["O"]='signal-O',
    ["P"]='signal-P',["Q"]='signal-Q',["R"]='signal-R',["S"]='signal-S',["T"]='signal-T',
    ["U"]='signal-U',["V"]='signal-V',["W"]='signal-W',["X"]='signal-X',["Y"]='signal-Y',
    ["Z"]='signal-Z'
  },
  s2c={
    ['signal-0']='0',['signal-1']='1',['signal-2']='2',['signal-3']='3',['signal-4']='4',
    ['signal-5']='5',['signal-6']='6',['signal-7']='7',['signal-8']='8',['signal-9']='9',
    ['signal-A']='A',['signal-B']='B',['signal-C']='C',['signal-D']='D',
    ['signal-E']='E',['signal-F']='F',['signal-G']='G',['signal-H']='H',
    ['signal-I']='I',['signal-J']='J',['signal-K']='K',['signal-L']='L',
    ['signal-M']='M',['signal-N']='N',['signal-O']='O',['signal-P']='P',
    ['signal-Q']='Q',['signal-R']='R',['signal-S']='S',['signal-T']='T',
    ['signal-U']='U',['signal-V']='V',['signal-W']='W',['signal-X']='X',
    ['signal-Y']='Y',['signal-Z']='Z',
	}
}

local function charsig(c)
	return charmap.c2s[c]
end

local function sigrichtag(signal)
  if signal.type == "item" then
    return "[item=" .. signal.name .. "]"
  elseif signal.type == "fluid" then
    return "[fluid=" .. signal.name .. "]"
  end

end

local function sigchar(signal,userichtags)
  return charmap.s2c[signal.name] or ( userichtags and sigrichtag(signal) or '')
end

local function signals_to_string(set,userichtags)
  local sigbits = {}
  local bitsleft = -1
  local lastbit = 0
  for _,sig in ipairs(set) do
    local newbits = bit32.band(sig.count,bitsleft)
    if newbits ~= 0 then
      for i=0,30 do
        local sigbit = bit32.extract(newbits,i)
        if sigbit==1 then
          local ch = sigchar(sig.signal, userichtags)
          if ch ~= '' then
            sigbits[i+1] = ch
            bitsleft = bit32.replace(bitsleft,0,i)
            if lastbit < i then
              lastbit = i 
            end
            if bitsleft == 0 then
              return table.concat(sigbits)
            end
          end
        end
      end
    end
  end

  for i=1,lastbit do 
    if sigbits[i] == nil then 
      sigbits[i]  = " " 
    end
  end

  return table.concat(sigbits)
end

remote.add_interface('signalstrings',
{
signals_to_string = signals_to_string,
string_to_signals = function(str,extrasignals)
  local letters = {}
  local tags = {}
  local i=1

  while str and i < 0x100000000 do
    local c
    local signal
    if #str > 1 then
      local _,taken,tag,item = str:find("^%[([%a-]+)=([^%[%]=]+)%]")
      
      if tag == "item" and game.item_prototypes[item] then
        signal = {type="item",name = item}
      elseif  tag == "fluid" and game.fluid_prototypes[item] then
        signal = {type="fluid",name = item}
      else
        signal = nil
        taken = 1
      end
      c,str=str:sub(1,taken):upper(),str:sub(taken+1)
      
    else
      c,str=str:upper(),nil
    end
    letters[c]=(letters[c] or 0)+i
    tags[c] = signal
    i=i*2
  end

  local signals = extrasignals or {}
  for c,i in pairs(letters) do
    if i >= 0x80000000 then i =  i - 0x100000000 end
    signals[#signals+1]={index=#signals+1,count=i,signal=tags[c] or {name=charsig(c),type="virtual"}}
  end
  return signals
end,
register_signal = function(signame,sigchar)
  -- map this signal to a character for signals_to_string conversions
  charmap.s2c[signame]=sigchar

  -- if this character was not previously mapped, map it to this signal. Only the first registered signal for a character will ever be used for string_to_signals conversions
  if not charmap.c2s[sigchar] then charmap.c2s[sigchar]=signame end


end,
get_map = function()
  return charmap
end,
})
