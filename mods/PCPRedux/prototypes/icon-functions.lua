CL = --[[colorLib--]]require("prototypes.colorLib")

local element_colours= {
  c = {{044, 044, 044}, {140, 000, 000}, {140, 000, 000}}, -- Carbon
  k = {{069, 069, 069}, {054, 054, 054}, {036, 036, 036}}, -- Coal/Oil
  h = {{255, 255, 255}, {243, 243, 243}, {242, 242, 242}}, -- Hydrogen
  o = {{249, 013, 013}, {214, 012, 012}, {198, 011, 011}}, -- Oxygen
  d = {{224, 244, 202}, {206, 206, 173}, {196, 196, 156}}, -- Deuterium
  n = {{045, 075, 180}, {045, 076, 175}, {038, 063, 150}}, -- Nitrogen
  l = {{031, 229, 031}, {057, 211, 040}, {075, 195, 045}}, -- Chlorine
  s = {{225, 210, 000}, {216, 196, 017}, {210, 187, 030}}, -- Sulfur
  g = {{105, 135, 090}, {096, 122, 082}, {088, 113, 075}}, -- Natural Gas
  f = {{181, 208, 000}, {181, 208, 000}, {181, 208, 000}}, -- Fluoride
  i = {{142, 148, 148}, {142, 148, 148}, {142, 148, 148}}, -- Silicon
  t = {{135, 090, 023}, {nil, nil, nil}, {nil, nil, nil}}, -- Tungsten
  w = {{094, 114, 174}, {088, 104, 163}, {088, 101, 155}}, -- Water/Steam
  m = {{041, 041, 180}}, -- Complex
  a = {{115, 063, 163}}, -- Sodium
  p = {{244, 125, 001}}, -- Phosphorus
  y = {{255, 105, 180}}, -- Syngas
}
	--Sourced from:
--https://sciencenotes.org/molecule-atom-colors-cpk-colors/
--[[H={r=255,g=255,b=255,a=1},
Hd={r=255,g=255,b=192},--Deuterium
--Ht={r=255,g=255,b=160},--Tritium
He={r=217,g=255,b=255},
Li={r=204,g=128,b=255},
Be={r=194,g=255,b=0},
B={r=255,g=181,b=181},
C={r=144,g=144,b=144},
--C-13={r=80,g=80,b=80},
--C-14={r=64,g=64,b=64},
N={r=48,g=80,b=248},
--N-15={r=16,g=80,b=80},
O={r=255,g=13,b=13},
F={r=144,g=224,b=80},
Ne={r=179,g=227,b=245},
Na={r=171,g=92,b=242},
Mg={r=138,g=255,b=0},
Al={r=191,g=166,b=166},
Si={r=240,g=200,b=160},
P={r=255,g=128,b=0},
S={r=255,g=255,b=48},
Cl={r=31,g=240,b=31},
Ar={r=128,g=209,b=227},
K={r=143,g=64,b=212},
Ca={r=61,g=255,b=0},
Sc={r=230,g=230,b=230},
Ti={r=191,g=194,b=199},
V={r=166,g=166,b=171},
Cr={r=138,g=153,b=199},
Mn={r=156,g=122,b=199},
Fe={r=224,g=102,b=51},
Co={r=240,g=144,b=160},
Ni={r=80,g=208,b=80},
Cu={r=200,g=128,b=51},
Zn={r=125,g=128,b=176},
Ga={r=194,g=143,b=143},
Ge={r=102,g=143,b=143},
As={r=189,g=128,b=227},
Se={r=255,g=161,b=0},
Br={r=166,g=41,b=41},
Kr={r=92,g=184,b=209},
Rb={r=112,g=46,b=176},
Sr={r=0,g=255,b=0},
Y={r=148,g=255,b=255},
Zr={r=148,g=224,b=224},
Nb={r=115,g=194,b=201},
Mo={r=84,g=181,b=181},
Tc={r=59,g=158,b=158},
Ru={r=36,g=143,b=143},
Rh={r=10,g=125,b=140},
Pd={r=0,g=105,b=133},
Ag={r=192,g=192,b=192},
Cd={r=255,g=217,b=143},
In={r=166,g=117,b=115},
Sn={r=102,g=128,b=128},
Sb={r=158,g=99,b=181},
Te={r=212,g=122,b=0},
I={r=148,g=0,b=148},
Xe={r=66,g=158,b=176},
Cs={r=87,g=23,b=143},
Ba={r=0,g=201,b=0},
La={r=112,g=212,b=255},
Ce={r=255,g=255,b=199},
Pr={r=217,g=255,b=199},
Nd={r=199,g=255,b=199},
Pm={r=163,g=255,b=199},
Sm={r=143,g=255,b=199},
Eu={r=97,g=255,b=199},
Gd={r=69,g=255,b=199},
Tb={r=48,g=255,b=199},
Dy={r=31,g=255,b=199},
Ho={r=0,g=255,b=156},
Er={r=0,g=230,b=117},
Tm={r=0,g=212,b=82},
Yb={r=0,g=191,b=56},
Lu={r=0,g=171,b=36},
Hf={r=77,g=194,b=255},
Ta={r=77,g=166,b=255},
W={r=33,g=148,b=214},
Re={r=38,g=125,b=171},
Os={r=38,g=102,b=150},
Ir={r=23,g=84,b=135},
Pt={r=208,g=208,b=224},
Au={r=255,g=209,b=35},
Hg={r=184,g=184,b=208},
Tl={r=166,g=84,b=77},
Pb={r=87,g=89,b=97},
Bi={r=158,g=79,b=181},
Po={r=171,g=92,b=0},
At={r=117,g=79,b=69},
Rn={r=66,g=130,b=150},
Fr={r=66,g=0,b=102},
Ra={r=0,g=125,b=0},
Ac={r=112,g=171,b=250},
Th={r=0,g=186,b=255},
Pa={r=0,g=161,b=255},
U={r=0,g=143,b=255},
Np={r=0,g=128,b=255},
Pu={r=0,g=107,b=255},
Am={r=84,g=92,b=242},
Cm={r=120,g=92,b=227},
Bk={r=138,g=79,b=227},
Cf={r=161,g=54,b=212},
Es={r=179,g=31,b=212},
Fm={r=179,g=31,b=186},
Md={r=179,g=13,b=166},
No={r=189,g=13,b=135},
Lr={r=199,g=0,b=102},
Rf={r=204,g=0,b=89},
Db={r=209,g=0,b=79},
Sg={r=217,g=0,b=69},
Bh={r=224,g=0,b=56},
Hs={r=230,g=0,b=46},
Mt={r=235,g=0,b=38}}]]

local function formula_extraction_1(chemical_formula)
local rgb={}
	for n,form in pairs(chemical_formula) do
		local _,_,elem=string.find(form,"(%a+)%d+")
		if not elem then
			elem=form
		end
		table.insert(rgb,element_colours[elem][1])
		end
	return rgb
end
local function formula_extraction_2(chemical_formula)
	local multi={}
	for n,form in pairs(chemical_formula) do
		local _,_,elem=string.find(form,"%a+(%d+)")
		table.insert(multi,elem or 1)
	end
	return multi
end
if not mods["angelsrefining"] then --use angels if avail

  function angelsmods.functions.fluid_color(chemical_formula)--parse as label number, label number (example H2,O3,C5, not C5O3H2)
    local color = {}
    local rgb = formula_extraction_1(chemical_formula)
    local multi = formula_extraction_2(chemical_formula)
    --should only consist of the first 3 items, with an optional 4th
    local red, green, blue, alpha, comb = 0,0,0,0,0
    local ave_denom = #rgb
    if ave_denom == 2 and rgb[1]==element_colours["c"][1] and rgb[2]==element_colours["h"][1] then
      --Hydrocarbon only
      m_c = tonumber(multi[1])
      m_h = tonumber(multi[2])
      m_t = m_c+m_h
      for i,j in pairs({"r", "g", "b"}) do
        --if multi[1]>=8 then multi[1] = 8 end
        color[j] = ((m_h-m_c)*0.899+m_c*0.01)/(m_h)--maxreader proposed:(6-multi[1])/6*255+10*(multi[2]/multi[1])
      end 
    else --everything else
      for i,colour in pairs(rgb) do
        alpha = colour[4] or 1
        red = red + ((colour[1]/255)^2 * tonumber(multi[i])*alpha)
        green = green + ((colour[2]/255)^2 * tonumber(multi[i])*alpha)
        blue = blue + ((colour[3]/255)^2 * tonumber(multi[i])*alpha)
        comb = comb + tonumber(multi[i]*alpha)
      end
      color = {r = math.sqrt(red/comb), g = math.sqrt(green/comb), b = math.sqrt(blue/comb), a = 1}
        --normalise
      HSV = CL.RGBtoHSV(color)
      HSV.v = 0.8*HSV.v
      HSV.s = 1-0.60*(1-HSV.s)
      color = CL.HSVtoRGB(HSV)
    end
    return color
  end
end