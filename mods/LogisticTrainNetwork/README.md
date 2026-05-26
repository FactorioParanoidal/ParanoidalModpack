# Factorio - Logistic Train Network

Factorio mod adding "logistic-train-stops" acting as anchor points for building a train powered logistic network.

It can handle multiple train configurations and will pick the best available train for a delivery.

## FAQs

### I get error messages: "No station supplying ... found in networks 0x0"

LTN uses "Network Id" to allow creating multiple networks that can act separately. A lot of examples assume that there is only one network ("the LTN network"). When using only a single network, all stations have the same network id. The network id is provided either through a signal sent into the Station Lamp *OR* as a default setting in LTN. Many "getting started" examples assume that the stations get their station id from that default setting.

Up until 2.2.0, the default network id was "-1" (which actually translates to "all LTN networks"). This is fine, as long as there is only one network.

For more elaborate setups with multiple networks, this default value caused a problem: Any station that is built and that does not get an explicit network signal (e.g. through a LTN Combinator) will show up in "all LTN networks". This especially happens when the LTN combinator is fully configured but then turned *off*. So trains from all the networks will show up at the station because there was a signal *missing*. This was hard to reason about and hard to debug.

For that reason, the "default network id" was changed in release 2.2.0 from "-1" to "0". This means, that a newly built LTN train stop will not be part of *any* network unless there is an explicit network id signal sent into the station. *OR* the default network id is set by the player.

If you run a relatively simple setup (only a single LTN network) and do not have you stations provide an explicit network id, you will encounter the `No station supplying ... found in networks 0x0` error message. In that case, go to `Settings -> Mod Settings -> Map -> LTN - Logistic Train Network -> "Default network ID"` and change the default value from "0" to e.g. "1". You can also use the old default ("-1").

If all your stations have an explicit network id provided (e.g. through LTN Combinators), the default of "0" is correct and will avoid that new stations mess up your train schedule.

### What is 'Advanced Cross-Surface Delivery'?

If you are not using a mod like [Space Exploration](https://mods.factorio.com/mod/space-exploration) and the [Space Exploration LTN integration](https://mods.factorio.com/mod/se-ltn-glue) mod, this setting is not for you and you should simply leave it off.

This setting is for games where the train network stretches across multiple surfaces *that are connected*. This is not true if you e.g. use the same network id on two planets (e.g. Gleba and Nauvis) that are not connected.

If you have a network across multiple surfaces, then normally a train can be dispatched to a provider on the same surface as the depot, go through the space elevator into orbit and deliver to a requester on a different surface, then return back to the depot on the original surface. LTN will not schedule anything else, the provider *must* be on the same surface as the depot.

With this setting, LTN will schedule trains to go through the space elevator first if necessary to pick up a delivery from a different surface. It may even schedule a delivery where both provider and requester are on a different surface as the depot. The train will still return to its original depot.

Cross-surface delivery is a glorious hack and at least for Space Exploration, the [Space Exploration LTN integration](https://mods.factorio.com/mod/se-ltn-glue) mod needs to support advanced scheduling. Do *NOT* turn this setting on before you verified that it is supported, otherwise your trains will stall with "No path found".


## Factorio 2.0 Updates

LTN has been ported to Factorio 2.0. It will get minimal updates (only really glaring bugs). The current plan is to provide a successor that takes advantage of the improved 2.0 trains while maintaining the ease of scheduling and dispatching with LTN.

### Train Schedule Interrupts (since 2.3.0)

Factorio 2.0 trains support "Train Schedule Interrupts" which trigger under certain conditions. Starting with 2.3.0, LTN will not change any interrupts in the train schedule unless explicitly configured with the `ltn-schedule-reset-interrupts` setting.

### Refueling support (since 2.3.0)

Starting with 2.3.0, LTN supports a new station type: 'Fuel Station'. Fuel station support must be explicitly enabled by setting the `ltn-schedule-fuel-station` setting.

Similar to a depot, there is a virtual signal that declares a stop to be a fuel station. This stop needs to receive additional signals:

- A network id signal that describes for which networks this fuel station is valid. Use `-1` for all networks.
- Fuel signals ('coal', 'wood', 'solid fuel', 'rocket fuel', 'nuclear fuel' in the base game) with a value that is used as the threshold for refueling. A fuel station does not need to send only the signals for fuels that it provides; the signals are used to create the condition for the fuel interrupt.

E.g. a station that receives 'wood' = 250 and 'rocket-fuel' = 200 for network id 1 will create a refuel interrupt for all locomotives in the network 1 that will send any locomotive to this refuel stop if they use either wood or rocket fuel and the count drops under 250 for wood or 200 for rocket fuel.

If a station receives both the depot and the fuel station signal, it is considered a depot and will not be used as a fuel station.

A fuel station has a cyan-colored station lamp to signify that it is a fuel station. Starting with 2.5.0, if a fuel station has no actual fuel signal, it will turn its lamp grey.

Trains arriving at a fuel station will leave if either all locomotives are fully fueled or there are 120 ticks (two seconds) of inactivity. When a train leaves a fuel station, the refuel interrupt is temporarily removed (it gets re-added when the train arrives at a depot that is part of a network that supports refueling).

LTN refueling is very limited and only looks at the fuel count across all locomotives. By disabling the resetting of Train Schedule interrupts and the builtin refueling support, other mods can be used to control refueling without LTN interfering.

### Depot changing (since 2.3.0)

A train that is added to the LTN network will return to a depot when it finishes a delivery. If the 'ltn-schedule-reselect-depot' option is disabled, a train will always return to the depot it was assigned to (the depot that it was sent to when sit registered with the LTN network).

If this setting turned on and also 'ltn-dispatcher-requester-delivery-reset' is enabled, then LTN will, as soon as the train leaves the requester, select one of the depots that accepts trains in the current network at random. Trains may go to a different depot in that case. This is especially important if a depot serves multiple networks. A train that gets sent to a depot that serves multiple networks becomes eligible to requests in those networks (assuming that capacity, length etc. also match).

This setting has the potential to pile up trains in depots that are too small to accommodate all trains that are sent there. Use with caution.

### Controlling LTN Stops with the circuit network (or logistics network)

LTN stops are managed by the central dispatcher and require some settings that will be enforced. Each LTN stop will always have "Read train contents" and "Send to train" activated, even if no circuit network is connected.

The 'Priority' 'Enable/Disable', 'Read stopped train', 'Read train count' and 'Set priority' fields can be manually changed.

#### Depot stop train limits [Since 2.7.0]

LTN manages train limits for all stops automatically. For normal operations, it will remove any train limit (and disable setting through the circuit network) as this interferes with the dispatcher. For most stop types (requester, provider and fuel station), this can not be changed.

The train limit for depot stops can be modified by changing the startup option 'ltn-depot-stop-limit-trains'. There are three possible values:

- Reset Train Limit: This is the default. Depot stops behave like all other station types: Any limit is reset and can not be modified
- Set Train Limit to 1: Sets a limit of one train for each depot stop.
- Do not modify Train limit: LTN stops managing the train limit setting for depot stops and it can now managed like the other fields listed above.


### API

[LTN Settings Documentation](https://github.com/hgschmie/factorio-LogisticTrainNetwork/blob/master/SETTINGS.md)
[LTN API Documentation](https://github.com/hgschmie/factorio-LogisticTrainNetwork/blob/master/API.md)
[LTN additional Documentation](https://github.com/hgschmie/factorio-LogisticTrainNetwork/blob/master/MANUAL.md)

Starting with version 2.1.0, LTN supports quality for requester and provider signals. To support this, there are a few *minimal*, *backwards compatible* API changes. If you maintain a mod that uses the LTN remote API, the changes are documented [LTN API Documentation](https://github.com/hgschmie/factorio-LogisticTrainNetwork/blob/master/API.md#changelog)

### Contact

- [Forum](https://mods.factorio.com/mod/LogisticTrainNetwork/discussion) (changed from pre-2.0!)
- [Bug Reports](https://github.com/hgschmie/factorio-LogisticTrainNetwork/issues)
- [Source Code](https://github.com/hgschmie/factorio-LogisticTrainNetwork)
- [Download](https://mods.factorio.com/mod/LogisticTrainNetwork/downloads)
- [Manual (on the LTN subforum)](https://forums.factorio.com/viewtopic.php?f=214&t=51072)

### How you can help

If you maintain an LTN mod and stopped working on it, consider porting it to 2.0!

----

## Legal

LTN is (C) 2017-2018 by Optera [under a restrictive license](LICENSE.md).

The 2.0 port is maintained with permission by @hgschmie
