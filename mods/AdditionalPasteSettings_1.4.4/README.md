# Equipment Grid Logistic Module

This mod is based on .. https://mods.factorio.com/mod/logiquipment .. by dorfl
Dorfl has moved away from "logiquipment" and combining several other ideas into the mod "Autodrive"
I was finding "Autodrive" a little UPS heavy and only wanted the logistics functionality from the mod.

This mod should work for Cars (Cars / Tanks / Planes) and Cargo Wagons

Needs one of the vehicle grid mods!


How to use
- Research "Equipment Grid Logistic Module", build one and insert into a car/cargo wagon equipment grid.
- Set some trunk filtered slots (see screen shots). These will be treated like logistic request slots.
- Park the car inside a logistics zone with robots -- mod won't activate if a car is moving.
- Robots should arrive...

Note that:
- Mod only ticks every few seconds, so be patient :)
- There must be at least one trunk filter set for the mod to trigger.
- Filtered trunk slots are used to set the request slots of a hidden requester chest.
- Unfiltered trunk slots are considered trash and put into a hidden active provider chest.
- If the current fuel is requested in a slot, fuel tank will be filled up first.
- Entering and starting the car is fine -- items still in hidden chests will be reclaimed.
