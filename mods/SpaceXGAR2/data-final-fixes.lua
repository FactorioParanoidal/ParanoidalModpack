-- 2.0: гард на отсутствующие предметы (rocket-control-unit удалён из базы,
-- часть SpaceX-предметов существует только при выключенном classic mode).
local function sub(name, subgroup)
	if data.raw.item[name] then
		data.raw.item[name].subgroup = subgroup
	end
end

sub("rocket-fuel", "space-exploration-a")
sub("low-density-structure", "space-exploration-a")
sub("rocket-control-unit", "space-exploration-a")
sub("satellite", "space-exploration-a")
sub("rocket-silo", "space-exploration-b")
sub("assembly-robot", "space-exploration-x")
sub("drydock-assembly", "space-exploration-x")
sub("drydock-structural", "space-exploration-x")
sub("fusion-reactor", "space-exploration-y")
sub("hull-component", "space-exploration-y")
sub("protection-field", "space-exploration-y")
sub("space-thruster", "space-exploration-y")
sub("fuel-cell", "space-exploration-y")
sub("habitation", "space-exploration-y")
sub("life-support", "space-exploration-y")
sub("command", "space-exploration-y")
sub("astrometrics", "space-exploration-y")
sub("ftl-drive", "space-exploration-y")
sub("spacex-combinator", "space-exploration-x")
