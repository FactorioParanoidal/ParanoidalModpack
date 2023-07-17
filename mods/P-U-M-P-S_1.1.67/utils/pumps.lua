---------------------
---- control.lua ----
---------------------

local PUMPS = {}

PUMPS.powered_pumps =
{
	["offshore-pump-0-placeholder"] =	{name="offshore-pump-0",	is_offshore=true},
	["offshore-pump-1-placeholder"] =	{name="offshore-pump-1",	is_offshore=true},
	["offshore-pump-2-placeholder"] =	{name="offshore-pump-2",	is_offshore=true},
	["offshore-pump-3-placeholder"] =	{name="offshore-pump-3",	is_offshore=true},
	["offshore-pump-4-placeholder"] =	{name="offshore-pump-4",	is_offshore=true},
	["seafloor-pump-placeholder"] =		{name="seafloor-pump",		is_offshore=true},	-- Angels Refining
	["seafloor-pump-2-placeholder"] =		{name="seafloor-pump-2",		is_offshore=true},	-- Angels Refining
	["seafloor-pump-3-placeholder"] =		{name="seafloor-pump-3",		is_offshore=true},	-- Angels Refining
	["ground-water-pump-placeholder"] =	{name="ground-water-pump",	is_offshore=false},	-- Angels Refining
}
PUMPS.bugged_pumps =
{
	"offshore-pump-output", -- AAI Industries
}

return PUMPS