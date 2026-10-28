-- Paranoidal: the giant worms placed by the map generator before their autoplace was removed are destroyed in
-- on_configuration_changed (control.lua, once per save). This migration only makes sure that it runs: the change
-- is in control.lua alone, which raises no configuration change by itself. Not destroyed here: the raised
-- destroy reaches RampantFixed, whose state is restored only in its on_load, after the migrations.
log("Big-Monsters: migration of the autoplaced giant worms (removed in on_configuration_changed)")
