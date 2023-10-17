# Info
This is a 1.1 version of the [Shortcuts](https://mods.factorio.com/mod/Shortcuts) mod by [morley376](https://mods.factorio.com/user/morley376). This will be maintained as long as the original mod isn't updated. Please report any bugs and send in ideas. Some of the things in the mod go beyond my skill (yet), but I like figuring out new things.

You can download the mod on the [mod portal](https://mods.factorio.com/mod/Shortcuts-ick). There is also a [forum post](https://forums.factorio.com/viewtopic.php?f=190&t=88439) about this mod.

You can help translate this mod on [Crowdin](https://crowdin.com/project/factorio-mods-localization).


# General
* A keyboard input can be assigned to every shortcut.
* Most items given to the player by a shortcut can not be placed inside any inventory.
* Most shortcuts are only available if a specific technology has been researched.
* There are startup settings to disable individual shortcuts.
* There is a setting to automatically generate shortcuts for selection tools from other mods.
* There is a setting to disable all changes done to technology requirements for shortcuts in case there is a conflict with an overhaul mod.
* There is a map setting that can be used to prepare certain startup setting changes or uninstallation.


# Shortcuts
**Basic**

* Character lamp
* Emergency locator beacon
* Grid
* Show rail block visualization
* Toggle personal logistic requests
* Zoom out of world
* Show minimap
* MOD: Max rate calculator


**Blueprint**

* Environment Deconstruction planner
* MOD: Well Planner


**Equipment**

* Belt immunity equipment
* Discharge defense remote
* Nightvision
* Personal laser defense


**Artillery**

* Artillery targeting remote
* MOD: Advanced Artillery Remotes Continued
* MOD: Artillery Bombardment Remote
* MOD: Artillery Bombardment Remote (Reloaded)
* MOD: Artillery Bombardment Remote (DBot's fork)
* Artillery cannon toggle
* MOD: M.I.R.V. targeting remote
* MOD: Atomic Artillery Remote
* MOD: Landmine thrower


**Vehicle**

* Driver is gunner
* Spidertron remote
* Spidertron Enable/disable logistics while moving
* Spidertron Logistic request
* Spidertron Auto targeting with gunner
* Spidertron Auto targeting without gunner
* Train Manual mode
* MOD: AAI programmable vehicles remote controls
* MOD: Vehicle waggon 2 winch


# Compatible mods
**Duplicate selection tools from these mods are removed from the inventory:**

* Rail Signal Planner
* Well Planner


**Selection tools from these mods are hidden from the inventory:**

* Circuit Checker
* Orbital Ion Cannon (SE Edition)
* Ore Eraser (continued)
* Module Inserter
* Module Inserter (Non-conflict version)


**Shortcuts from these mods are only available if a specific technology has been researched:**

* Car/Tank/Spidertron Locator Button
* Circuit Checker
* Orbital Ion Cannon (SE Edition)
* Module Inserter
* Module Inserter (Non-conflict version)
* P.U.M.P
* Rail Signal Planner
* Rail Signal Planner (Fixed sliders)
* Spidertron squad control
* Spidertron Waypoints
* VehicleSnap


# KNOWN ISSUES
* Use the map setting **Prepare a startup setting change or uninstallation** in order to prevent the following issues:
	* Disabled artillery and equipment is lost when settings change or the mod is removed. Make sure to enable all artillery and equipment before you uninstall this mod or change related settings.
	* When the mod is disabled items that were previously available via a shortcut might be unavailable. To fix it you can also run this command: <code>/c game.player.force.reset_technology_effects()</code>
* Custom input references in shortcut names only update when a map is loaded.
* The spidertron and train setting shortcuts don't update immediately if you tick the checkboxes in the GUIs. Close the GUI and the shortcut will be in the correct state.
* The order of shortcuts will change if the mod was temporarily disabled.
