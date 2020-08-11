--Sourced from:
--https://sciencenotes.org/molecule-atom-colors-cpk-colors/
local element_colours={
H={r=255,g=255,b=255},
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
Mt={r=235,g=0,b=38}}

function formula_extraction_1(chemical_formula)
local rgb={}
	for n,form in pairs(chemical_formula) do
		local _,_,elem=string.find(form,"(%a+)%d+")
		if not elem then
			elem=form
		end
		table.insert(rgb,element_colours[elem])
		end
	return rgb
end
function formula_extraction_2(chemical_formula)
	local multi={}
	for n,form in pairs(chemical_formula) do
		local _,_,elem=string.find(form,"%a+(%d+)")
		table.insert(multi,elem or 1)
	end
	return multi
end
function fluid_flow_colour(chemical_formula)--parse as label number, label number (example H2,O3,C5, not C5O3H2)
	local rgb=formula_extraction_1(chemical_formula)
	local multi=formula_extraction_2(chemical_formula)
	--should only consist of the first 3 items, with an optional 4th
	local colour_1=rgb[1]
	local ct_1=tonumber(multi[1])
	local colour_2=rgb[2]
	local ct_2=tonumber(multi[2])
	local colour_3=rgb[3]
	local ct_3=tonumber(multi[3])
	local colour_4=rgb[4]
	local ct_4=tonumber(multi[4])
	local colour_5=rgb[5]
	local ct_5=tonumber(multi[5])
	local red=0
	local green=0
	local blue=0
	local alpha=0
	local ave_denom=(ct_1+(ct_2 or 0)+(ct_3 or 0)+(ct_4 or 0)+(ct_5 or 0))
	if colour_1 then
		red=(colour_1.r/255*ct_1/ave_denom)*ct_1
		green=(colour_1.g/255*ct_1/ave_denom)*ct_1
		blue=(colour_1.b/255*ct_1/ave_denom)*ct_1
		alpha=(colour_1.a or 1)*ct_1/ave_denom
		if colour_2 then
			red=red+(colour_2.r/255*ct_2/ave_denom)
			green=green+(colour_2.g/255*ct_2/ave_denom)
			blue=blue+(colour_2.b/255*ct_2/ave_denom)
			alpha=alpha+(colour_2.a or 1)*ct_2/ave_denom
			if colour_3 then
				red=red+(colour_3.r/255*ct_3/ave_denom)
				green=green+(colour_3.g/255*ct_3/ave_denom)
				blue=blue+(colour_3.b/255*ct_3/ave_denom)
				alpha=alpha+(colour_3.a or 1)*ct_3/ave_denom
				if colour_4 then
					red=red+(colour_4.r/255*ct_4/ave_denom)
					green=green+(colour_4.g/255*ct_4/ave_denom)
					blue=blue+(colour_4.b/255*ct_4/ave_denom)
					alpha=alpha+(colour_4.a or 1)*ct_4/ave_denom
					if colour_5 then
						red=red+(colour_5.r/255*ct_5/ave_denom)
						green=green+(colour_5.g/255*ct_5/ave_denom)
						blue=blue+(colour_5.b/255*ct_5/ave_denom)
						alpha=alpha+(colour_5.a or 1)*ct_5/ave_denom
					end
				end
			end
		end
	else
		--some kind of error, throw default
		log("fail")
		log(serpent.block(chemical_formula))
		red=1
		green=1
		blue=1
		alpha=1
	end
	red=math.sqrt(red)
	green=math.sqrt(green)
	blue=math.sqrt(blue)
	--using averaging
	Blends={r=red/ave_denom,g=green/ave_denom,b=blue/ave_denom}--,a=alpha/(ave_denom/1.5)}
	return Blends
end
