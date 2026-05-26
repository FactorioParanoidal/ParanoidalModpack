# LTN Settings

Most LTN settings are per-map and can be changed while the game is running. Exceptions are marked below.

## Dispatcher Enabled (ltn-dispatcher-enabled) - boolean, default is true

If `true`, the dispatcher will create new deliveries. Set to `false` if you want LTN to pause scheduling new deliveries.

## Update Frequency (in ticks) (ltn-dispatcher-nth_tick) - integer, 1-60, default is 2

Number of ticks between running the dispatcher. Higher numbers spread the load more but stations and requests are not updated as often. Default is `2` (every other tick).

If set to a value > `1`, the Updates per tick for stops and requests updated is forced to `1`.

## Updates per tick (ltn-dispatcher-updates-per-tick) - integer, 1-100, default is 1

Number of stops and requests that is updated at each update cycle. Higher numbers can lead to load spikes which in turn lag the game. Default value is `1` (see above).

If the Update frequency is set to a value > `1`, this value is forced to be `1`.

## Message Level (ltn-interface-console-level) - select, 1-4, default is 2

Selects the level of messages sent to the game console:

- `0` - no messages
- `1` - Errors and Warnings
- `2` - Notifications for deliveries
- `3` - Detailed messages

## GPS Tags (ltn-interface-message-gps) - boolean, default is false

Console messages contain [Factorio rich text](https://wiki.factorio.com/rich_text) GPS tags which can be clicked.

## Send Factorio Alerts (ltn-interface-factorio-alerts) - boolean, default is true

If `true`, any alert message will be registered as a [Factorio Alert](https://wiki.factorio.com/Alerts) with the game.

This setting is per-player, so each player can choose whether to receive alerts or not.

## Enable debug log file (ltn-interface-debug-logfile) - number 0 - 10, default is 0

If larger than zero, write detailed information into the factorio log file. This should only be turned on for debugging purposes. The higher the number, the more log information is written. The majority of the existing log statements uses '5' as the priority.

## Default Request Threshold (ltn-dispatcher-requester-threshold) - integer 1 - max, default is 1000

The minimum number of items to request before LTN creates a delivery.

This value can be overridden by sending virtual signals into a Station input.

## Default Provider Threshold (ltn-dispatcher-provider-threshold) - integer 1 - max, default is 1000

The minimum number of items to provide before LTN creates a delivery. Stations that have fewer items than this setting will not be considered for deliveries.

This value can be overridden by sending virtual signals into a Station input.

## Schedule circuit conditions (ltn-dispatcher-schedule-circuit-control) - boolean, default is false

Adds circuit conditions to wait for `red = 0 OR green ≥ 1` to all stops.

*Warning!* All LTN stops require having "send to train" enabled and a circuit connection. Otherwise trains will be stuck waiting forever a stops that do not have this enabled.

## Depot inactivity in seconds (ltn-dispatcher-depot-inactivity) - integer 1 - 36000, default is 5

Required period of inactivity before a train can leave a depot.

## Stop timeout in seconds (ltn-dispatcher-stop-timeout) - integer 0 - 36000, default is 120

Maximum amount of time that a stop (provider or requester) can take. Once this amount of time has elapsed, a train is forced out of the station. This creates an alert (*"train left with missing cargo"* for a provider or *"train left with left over cargo"* for a requester).

## Delivery timeout in seconds (ltn-dispatcher-delivery-timeout) - integer 60 - 36000, default is 600

Maximum amount of time that a train can take to reach the next stop in its schedule. If the train has not arrived at the next stop when this time elapses, the delivery is considered "lost" (e.g. the train was destroyed or ran out of fuel).

## Delivery completes at requester (ltn-dispatcher-requester-delivery-reset) - boolean, default is false

Whether a delivery is considered complete when the train arrives at the requester of when it arrives at the depot.

If `true`, a delivery is considered "complete" when the train leaves the requester. It will immediately delete its schedule and return to a depot.

If `false`, the train schedule will not be changed until the train arrives at the depot.

When adding additional stops at the end of a delivery (e.g. manually or with another mod), this value must be set to `false`, otherwise these schedule changes will be deleted immediately when the train leaves the requester station.

## Finish loading (ltn-dispatcher-finish-loading) - boolean, default is true

If `true`, an additional delay (2 seconds) is added after loading at a provider or requester has finished and before leaving the station. This allows inserters or pumps to finish loading. If this value is `false`, a train leaves immediately when the loading is complete (enough items or fluid has been loaded). Depending on how stations are set up, immediate departure can lead to inserters holding additional items or fluid remaining in a pump.

## Depot arrival reset filters (ltn-depot-reset-filters) - boolean, default is true

If cargo wagons have filters or stack limitations set, reset those when a train enters a depot.

## Depot arrival removes leftover fluid (ltn-depot-fluid-cleaning) - integer, default is 0

When entering a depot, remove leftover fluid from a train. The fluid is discarded.

Using `0` disables cleaning the fluid.
Using `-1` removed all fluid from the train.

## [CHANGED in 2.2.0] Default network ID (ltn-stop-default-network) - integer, default is 0

LTN use a bit mask to define what network a station belongs to. There can be up to 32 networks and each station can belong to one or more networks if the corresponding bit is set.

The default value is `0`, so any station that has no network set explicitly does *not* belong to any network.

This is a change from pre-2.2.0 releases where the default was `-1` which makes such stations belong to *all* networks.

## Provider stop signals contain existing cargo (ltn-provider-show-existing-cargo) - boolean, default is true

When a train arrives at the provider station, it is possible to "pick up" additional cargo which is still held by inserters and is "left over" from a previous delivery. By default, LTN reports such leftover items as signals.

Setting this signal to `false` makes LTN to report only the requested cargo on its output signals.

## [NEW in 2.2.0, default changed in 2.4.0] Requesters ignore stopped trains (ltn-provider-ignore-stopped-train) - boolean, default is false

Pre-2.2.0 release, when requesting multiple deliveries to the same station of the same item or fluid, LTN would consider a parked train that is currently unloading and subtract that cargo from the next delivery. This can lead to a delivery not using a full train but just a fraction.

If this setting is `true`, LTN will ignore any currently unloading train and request the full amount for a delivery. This makes bulk deliveries (e.g. fluids or plates) more efficient as there will always be the configured requester size be delivered. For expensive items, this may lead to "over delivery".

The pre-2.2.0 default behavior has been restored with 2.4.0 (see https://github.com/hgschmie/factorio-LogisticTrainNetwork/issues/26)

## [NEW in 2.3.0] Enable fuel station (ltn-schedule-fuel-station) - boolean, default is false

Setting this value to `true` will enable refueling support using a new "fuel station" signal. In addition to this signal, a stop must receive additional signals to serve as a fuel station:

- A network id signal that describes for which networks this fuel station is valid. Use `-1` for all networks.
- Fuel signals ('coal', 'wood', 'solid fuel', 'rocket fuel', 'nuclear fuel' in the base game) with a value that is used as the threshold for refueling. A fuel station does not need to send only the signals for fuels that it provides; the signals are used to create the condition for the fuel interrupt.

## [NEW in 2.3.0] Reset Train schedule interrupts (ltn-schedule-reset-interrupts) - boolean, default is false

Setting this value to `true` will restore the pre-2.3.0 behavior of clearing all Train schedule interrupts when a train receives a new schedule. Leaving it at `false` allows other mods to add interrupts to a train schedule and LTN ignore them.

LTN will still manage its own "LTN Fuel" interrupt when enabling fuel stations (see above).

## [NEW in 2.3.0] Reselect Depot when delivery is complete (ltn-schedule-reselect-depot) - boolean, default is false

In normal operations, any LTN controlled train always returns to the depot it was assigned to (the depot that the train was sent to to be registered with LTN).

When this setting is enabled *and* Delivery completes at the requester (ltn-dispatcher-requester-delivery-reset is true), then LTN will choose a new depot at random from the current train network.

This setting has the potential to "pile up" trains in a depot that has not enough available stops. It should only be used if you know what you are doing (and most likely any depot can accommodate all trains in a  network). Normally, this should be kept off.

## [NEW in 2.4.0] Choose whether to use a train interrupt or dynamic scheduling for refueling (ltn-fuel-station-interrupt) - boolean, default is true (use an interrupt)

In normal operation, refueling is controlled by an interrupt (LTN Fuel). There are rare situations where that interrupt triggers in inconvenient moments (e.g. between the arrival of the train at the temporary "pre-stop" and the actual provider or requester). If this causes problems, this setting can be turned off. LTN will now dynamically add temporary refuel stops when arriving at a station or depot with insufficient fuel. Note that this requires a bit more CPU and might have an affect on FPS/UPS. Using an interrupt is preferred and dynamic refueling is considered experimental for now.

## [NEW in 2.5.0] Advanced Cross-Surface Delivery (ltn-advanced-cross-surface-delivery) - boolean, default is false

*This setting is only relevant if you build a cross-surface train network (e.g. using the Space Exploration Space Elevator). It requires additional support from the mods that make LTN compatible with cross-surface train networks. Do not turn on unless you have verified that these mods are compatible, otherwise your trains WILL stall with "can not find a path" errors.*

Normally, LTN will only schedule cross-surface deliveries between provider and requester. The train picking up from the provider is selected from a depot on the same surface and will return to that surface. For any provider, there must be at least one train in a depot to pick up the delivery.

When turning this setting on, LTN will also consider trains to go to another surface first to bring a delivery to a requester on the same surface as the depot and might even schedule a delivery where both provider and requester are on a different surface before the train returns to its depot.

## [NEW in 2.6.0] Depot fudge factor (ltn-depot-fudge-factor) - integer, default is 0

[This setting solely exists to scratch an itch where LTN seems to select specific trains over and over again because they keep ending up at the same depot stops. If you are fine with the current behavior, leave this setting at 0.]

Have you ever had the suspicion that LTN seems to prefer some trains from the depot? You are correct. LTN selects trains based on the distance from the depot stop to the provider. So any train that is closer to the depot exit will be selected over any other train in the depot. The further away a train is from the exit, the less likely is it to be chosen.

As this is unfair to the trains (and they also wear out at a different rate), it is possible to enter a "fudge factor" here, which is the amount by which the path from the depot to the provider can differ while still considered "equal". LTN tracks for each train the number of times it was selected and in case that two stops are considered equal, it will then choose the train that was selected fewer times.

## [NEW in 2.7.0] Depot Train Limit setting (ltn-depot-stop-limit-trains) - select, 0-2, default is 0 [EXPERIMENTAL] - (Startup setting!)

Select behavior of the 'Enable Train Limit' setting for Depot stops.

0: (default) Same behavior as all other stop types: No train limit can be set and any manual override is reset.
1: Set Train Limit to 1. Each depot can only accommodate a single train; the routing mechanism in the game will send only one train at a time to the stop. This requires enough depot stops for all trains associated with it. If a train can not find an available depot stop, it will be stuck at the requester until a stop frees up.
2: Do not modify the Train Limit settings. Train Limit can be set manually or through the circuit network. LTN does not change or reset the value here. Chances are that this might deadlock or interfere with the normal LTN operations. Only select if you know what you are doing.
