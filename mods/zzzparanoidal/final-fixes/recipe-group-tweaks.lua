--переносим рецепты в новые вкладки
--перенос в логику
if not mods["angelsindustries"] then
	data.raw["item-subgroup"]["circuit-network"] =
		{ type = "item-subgroup", name = "circuit-network", group = "circuit", order = "a" }
	data.raw["item-subgroup"]["circuit-network-2"] =
		{ type = "item-subgroup", name = "circuit-network-2", group = "circuit", order = "h2" }

	data.raw["recipe"]["power-switch"].group = "circuit"
	data.raw["recipe"]["power-switch"].subgroup = "circuit-connection"
	data.raw.item["power-switch"].subgroup = "circuit-connection"

	data.raw["recipe"]["arithmetic-combinator"].group = "circuit"
	data.raw["recipe"]["arithmetic-combinator"].subgroup = "circuit-combinator"
	data.raw.item["arithmetic-combinator"].subgroup = "circuit-combinator"

	data.raw["recipe"]["decider-combinator"].group = "circuit"
	data.raw["recipe"]["decider-combinator"].subgroup = "circuit-combinator"
	data.raw.item["decider-combinator"].subgroup = "circuit-combinator"

	data.raw["recipe"]["constant-combinator"].group = "circuit"
	data.raw["recipe"]["constant-combinator"].subgroup = "circuit-combinator"
	data.raw.item["constant-combinator"].subgroup = "circuit-combinator"

	data.raw["recipe"]["small-lamp"].group = "circuit"
	data.raw["recipe"]["small-lamp"].subgroup = "circuit-visual"
	data.raw.item["small-lamp"].subgroup = "circuit-visual"

	data.raw["recipe"]["programmable-speaker"].group = "circuit"
	data.raw["recipe"]["programmable-speaker"].subgroup = "circuit-auditory"
	data.raw.item["programmable-speaker"].subgroup = "circuit-auditory"

	if mods["InlaidLampsExtended"] then
		bobmods.lib.tech.add_prerequisite("flat-lamp-t", "electronics")
		bobmods.lib.tech.add_prerequisite("flat-lamp-t", "logistic-science-pack")
		data.raw["recipe"]["flat-lamp-c"].group = "circuit"
		data.raw["recipe"]["flat-lamp-c"].subgroup = "circuit-visual"
		data.raw.item["flat-lamp"].subgroup = "circuit-visual"

		data.raw["recipe"]["flat-lamp-big"].group = "circuit"
		data.raw["recipe"]["flat-lamp-big"].subgroup = "circuit-visual"
		data.raw.item["flat-lamp-big"].subgroup = "circuit-visual"
	end

	if mods["DeadlockLargerLamp"] then
		data.raw["recipe"]["deadlock-copper-lamp"].group = "circuit"
		data.raw["recipe"]["deadlock-copper-lamp"].subgroup = "circuit-visual"
		data.raw.item["deadlock-copper-lamp"].subgroup = "circuit-visual"

		data.raw["recipe"]["deadlock-large-lamp"].group = "circuit"
		data.raw["recipe"]["deadlock-large-lamp"].subgroup = "circuit-visual"
		data.raw.item["deadlock-large-lamp"].subgroup = "circuit-visual"

		data.raw["recipe"]["deadlock-floor-lamp"].group = "circuit"
		data.raw["recipe"]["deadlock-floor-lamp"].subgroup = "circuit-visual"
		data.raw.item["deadlock-floor-lamp"].subgroup = "circuit-visual"
	end

	if mods["capacity-combinator"] then
		data.raw["recipe"]["capacity-combinator"].group = "circuit"
		data.raw["recipe"]["capacity-combinator"].subgroup = "circuit-combinator"
		data.raw.item["capacity-combinator"].subgroup = "circuit-combinator"

		data.raw["recipe"]["capacity-combinator-MK2"].group = "circuit"
		data.raw["recipe"]["capacity-combinator-MK2"].subgroup = "circuit-combinator"
		data.raw.item["capacity-combinator-MK2"].subgroup = "circuit-combinator"
	end

	if mods["power-combinator"] then
		data.raw["recipe"]["power-combinator"].group = "circuit"
		data.raw["recipe"]["power-combinator"].subgroup = "circuit-combinator"
		data.raw.item["power-combinator"].subgroup = "circuit-combinator"

		data.raw["recipe"]["power-combinator-MK2"].group = "circuit"
		data.raw["recipe"]["power-combinator-MK2"].subgroup = "circuit-combinator"
		data.raw.item["power-combinator-MK2"].subgroup = "circuit-combinator"
	end

	if mods["Biter_Detector_Sentinel_Combinator"] then
		data.raw["recipe"]["sentinel-combinator"].group = "circuit"
		data.raw["recipe"]["sentinel-combinator"].subgroup = "circuit-input"
		data.raw.item["sentinel-combinator"].subgroup = "circuit-input"

		data.raw["recipe"]["sentinel-alarm"].group = "circuit"
		data.raw["recipe"]["sentinel-alarm"].subgroup = "circuit-input"
		data.raw.item["sentinel-alarm"].subgroup = "circuit-input"
	end

	if mods["LTN_Combinator_Fix"] then
		data.raw["recipe"]["ltn-combinator"].subgroup = "circuit-combinator"
		data.raw.item["ltn-combinator"].subgroup = "circuit-combinator"
	end
	if mods["LTN_Content_Reader"] then
		data.raw["recipe"]["ltn-provider-reader"].subgroup = "circuit-combinator"
		data.raw.item["ltn-provider-reader"].subgroup = "circuit-combinator"
		data.raw["recipe"]["ltn-requester-reader"].subgroup = "circuit-combinator"
		data.raw.item["ltn-requester-reader"].subgroup = "circuit-combinator"
		data.raw["recipe"]["ltn-delivery-reader"].subgroup = "circuit-combinator"
		data.raw.item["ltn-delivery-reader"].subgroup = "circuit-combinator"
	end
	-------------------------------------------------------------------------------------------------
	--перенос в транспорт
	data.raw["item-subgroup"]["train-transport"] =
		{ type = "item-subgroup", name = "train-transport", group = "transport", order = "e" }
	data.raw["item-subgroup"].transport =
		{ type = "item-subgroup", name = "transport", group = "transport", order = "f" }
	data.raw["item-subgroup"]["locomotive"] =
		{ type = "item-subgroup", name = "locomotive", group = "transport", order = "e-a1" }
	data.raw["item-subgroup"]["cargo-wagon"] =
		{ type = "item-subgroup", name = "cargo-wagon", group = "transport", order = "e-a2" }
	data.raw["item-subgroup"]["fluid-wagon"] =
		{ type = "item-subgroup", name = "fluid-wagon", group = "transport", order = "e-a3" }
	data.raw["item-subgroup"]["transport-drones"] =
		{ type = "item-subgroup", name = "transport-drones", group = "transport", order = "ez" }
	data.raw["item-subgroup"]["bet-logistics"] =
		{ type = "item-subgroup", name = "bet-logistics", group = "transport", order = "ez" }

	data.raw["recipe"]["rail"].subgroup = "transport-rail"
	data.raw["recipe"]["rail"].order = "b"
	data.raw["rail-planner"].rail.subgroup = "transport-rail"
	data.raw["rail-planner"].rail.order = "b"
	-------------------------------------------------------------------------------------------------
	--жд светофоры, станции и тп

	data.raw["recipe"]["rail-signal"].subgroup = "transport-rail-other"
	data.raw["recipe"]["rail-signal"].order = "d"
	data.raw.item["rail-signal"].subgroup = "transport-rail-other"
	data.raw.item["rail-signal"].order = "d"

	data.raw["recipe"]["rail-chain-signal"].subgroup = "transport-rail-other"
	data.raw["recipe"]["rail-chain-signal"].order = "e"
	data.raw.item["rail-chain-signal"].subgroup = "transport-rail-other"
	data.raw.item["rail-chain-signal"].order = "e"

	data.raw["recipe"]["train-stop"].subgroup = "transport-rail-other"
	data.raw["recipe"]["train-stop"].order = "f"
	data.raw.item["train-stop"].subgroup = "transport-rail-other"
	data.raw.item["train-stop"].order = "f"

	if mods["LogisticTrainNetwork"] then
		data.raw["recipe"]["logistic-train-stop"].subgroup = "transport-rail-other"
		data.raw["recipe"]["logistic-train-stop"].order = "g"
		data.raw.item["logistic-train-stop"].subgroup = "transport-rail-other"
		data.raw.item["logistic-train-stop"].order = "g"
	end

	if mods["railloader"] then
		data.raw["recipe"]["railloader"].subgroup = "transport-rail-other"
		data.raw["recipe"]["railloader"].order = "h"
		data.raw.item["railloader"].subgroup = "transport-rail-other"
		data.raw.item["railloader"].order = "h"

		data.raw["recipe"]["railunloader"].subgroup = "transport-rail-other"
		data.raw["recipe"]["railunloader"].order = "i"
		data.raw.item["railunloader"].subgroup = "transport-rail-other"
		data.raw.item["railunloader"].order = "i"
	end
	-------------------------------------------------------------------------------------------------
	--артиллерийские вагоны
	data.raw["recipe"]["artillery-wagon"].subgroup = "artillery-wagon"
	data.raw["recipe"]["artillery-wagon"].order = "a"
	data.raw["item-with-entity-data"]["artillery-wagon"].subgroup = "artillery-wagon"
	data.raw["item-with-entity-data"]["artillery-wagon"].order = "a"

	data.raw["recipe"]["bob-artillery-wagon-2"].subgroup = "artillery-wagon"
	data.raw["recipe"]["bob-artillery-wagon-2"].order = "b"
	data.raw["item-with-entity-data"]["bob-artillery-wagon-2"].subgroup = "artillery-wagon"
	data.raw["item-with-entity-data"]["bob-artillery-wagon-2"].order = "b"

	data.raw["recipe"]["bob-artillery-wagon-3"].subgroup = "artillery-wagon"
	data.raw["recipe"]["bob-artillery-wagon-3"].order = "c"
	data.raw["item-with-entity-data"]["bob-artillery-wagon-3"].subgroup = "artillery-wagon"
	data.raw["item-with-entity-data"]["bob-artillery-wagon-3"].order = "c"
	-------------------------------------------------------------------------------------------------
	--павуки
	data.raw["recipe"]["bob-antron"].subgroup = "spider"
	data.raw["item-with-entity-data"]["bob-antron"].subgroup = "spider"
	data.raw["recipe"]["spidertron"].subgroup = "spider"
	data.raw["item-with-entity-data"]["spidertron"].subgroup = "spider"
	data.raw["recipe"]["bob-tankotron"].subgroup = "spider"
	data.raw["item-with-entity-data"]["bob-tankotron"].subgroup = "spider"
	data.raw["recipe"]["bob-logistic-spidertron"].subgroup = "spider"
	data.raw["item-with-entity-data"]["bob-logistic-spidertron"].subgroup = "spider"
	data.raw["recipe"]["bob-heavy-spidertron"].subgroup = "spider"
	data.raw["item-with-entity-data"]["bob-heavy-spidertron"].subgroup = "spider"
	-------------------------------------------------------------------------------------------------
	--самолеты
	if mods["Aircraft"] then
		data.raw["recipe"]["gunship"].subgroup = "aircraft"
		data.raw["item-with-entity-data"]["gunship"].subgroup = "aircraft"
		data.raw["recipe"]["cargo-plane"].subgroup = "aircraft"
		data.raw["item-with-entity-data"]["cargo-plane"].subgroup = "aircraft"
		data.raw["recipe"]["jet"].subgroup = "aircraft"
		data.raw["item-with-entity-data"]["jet"].subgroup = "aircraft"
		data.raw["recipe"]["flying-fortress"].subgroup = "aircraft"
		data.raw["item-with-entity-data"]["flying-fortress"].subgroup = "aircraft"
	end

	if mods["betterCargoPlanes"] then
		data.raw["recipe"]["better-cargo-plane"].subgroup = "aircraft"
		data.raw["item-with-entity-data"]["better-cargo-plane"].subgroup = "aircraft"
		data.raw["recipe"]["even-better-cargo-plane"].subgroup = "aircraft"
		data.raw["item-with-entity-data"]["even-better-cargo-plane"].subgroup = "aircraft"
	end
	--###############################################################################################
	--переносим трубы
	if mods["FluidMustFlow"] then
		data.raw["recipe"]["duct-small"].subgroup = "FluidMustFlow"
		data.raw["item"]["duct-small"].subgroup = "FluidMustFlow"
		data.raw["recipe"]["duct-t-junction"].subgroup = "FluidMustFlow"
		data.raw["item"]["duct-t-junction"].subgroup = "FluidMustFlow"
		data.raw["recipe"]["duct-curve"].subgroup = "FluidMustFlow"
		data.raw["item"]["duct-curve"].subgroup = "FluidMustFlow"
		data.raw["recipe"]["duct-cross"].subgroup = "FluidMustFlow"
		data.raw["item"]["duct-cross"].subgroup = "FluidMustFlow"
		data.raw["recipe"]["duct-underground"].subgroup = "FluidMustFlow"
		data.raw["item"]["duct-underground"].subgroup = "FluidMustFlow"
		data.raw["recipe"]["non-return-duct"].subgroup = "FluidMustFlow"
		data.raw["item"]["non-return-duct"].subgroup = "FluidMustFlow"
		data.raw["recipe"]["duct-end-point-intake"].subgroup = "FluidMustFlow"
		data.raw["item"]["duct-end-point-intake"].subgroup = "FluidMustFlow"
		data.raw["recipe"]["duct-end-point-outtake"].subgroup = "FluidMustFlow"
		data.raw["item"]["duct-end-point-outtake"].subgroup = "FluidMustFlow"
		data.raw["item"]["duct"].subgroup = "FluidMustFlow"
		data.raw["item"]["duct-long"].subgroup = "FluidMustFlow"
		data.raw["recipe"]["check-valve"].subgroup = "FluidMustFlow"
		data.raw["item"]["check-valve"].subgroup = "FluidMustFlow"
		data.raw["recipe"]["valves-overflow"].subgroup = "FluidMustFlow"
		data.raw["item"]["valves-overflow"].subgroup = "FluidMustFlow"
		data.raw["recipe"]["underflow-valve"].subgroup = "FluidMustFlow"
		data.raw["item"]["underflow-valve"].subgroup = "FluidMustFlow"
	end
	-------------------------------------------------------------------------------------------------
	if mods["Bio_Industries"] then
		data.raw["recipe"]["bi-wood-pipe"].subgroup = "pipe"
		data.raw["recipe"]["bi-wood-pipe"].order = "a"
		data.raw["item"]["bi-wood-pipe"].subgroup = "pipe"
		data.raw["item"]["bi-wood-pipe"].order = "a"

		data.raw["recipe"]["bi-wood-pipe-to-ground"].subgroup = "pipe-to-ground"
		data.raw["recipe"]["bi-wood-pipe-to-ground"].order = "a"
		data.raw["item"]["bi-wood-pipe-to-ground"].subgroup = "pipe-to-ground"
		data.raw["item"]["bi-wood-pipe-to-ground"].order = "a"
	end
	-------------------------------------------------------------------------------------------------
	if mods["Flow Control"] then
		data.raw["recipe"]["pipe-junction"].group = "logistics"
		data.raw["recipe"]["pipe-junction"].subgroup = "FlowControl"
		data.raw["item"]["pipe-junction"].group = "logistics"
		data.raw["item"]["pipe-junction"].subgroup = "FlowControl"

		data.raw["recipe"]["pipe-straight"].group = "logistics"
		data.raw["recipe"]["pipe-straight"].subgroup = "FlowControl"
		data.raw["item"]["pipe-straight"].group = "logistics"
		data.raw["item"]["pipe-straight"].subgroup = "FlowControl"

		data.raw["recipe"]["pipe-elbow"].group = "logistics"
		data.raw["recipe"]["pipe-elbow"].subgroup = "FlowControl"
		data.raw["item"]["pipe-elbow"].group = "logistics"
		data.raw["item"]["pipe-elbow"].subgroup = "FlowControl"
	end
	--###############################################################################################
	--переносим рецепты и предметы куда следует
	--бронированный манипулятор
	if mods["scattergun_turret"] then
		data.raw["recipe"]["w93-hardened-inserter"].group = "logistics"
		data.raw["recipe"]["w93-hardened-inserter"].subgroup = "bob-logistic-tier-1"
		data.raw["recipe"]["w93-hardened-inserter"].order = "z"
		data.raw["item"]["w93-hardened-inserter"].group = "logistics"
		data.raw["item"]["w93-hardened-inserter"].subgroup = "bob-logistic-tier-1"
		data.raw["item"]["w93-hardened-inserter"].order = "z"
	end
	-------------------------------------------------------------------------------------------------
	--деревянные столбы
	data.raw["recipe"]["small-electric-pole"].subgroup = "wooden-pole"
	data.raw["item"]["small-electric-pole"].subgroup = "wooden-pole"

	if mods["Bio_Industries"] then
		data.raw["recipe"]["bi-wooden-pole-big"].subgroup = "wooden-pole"
		data.raw["item"]["bi-wooden-pole-big"].subgroup = "wooden-pole"
		data.raw["recipe"]["bi-wooden-pole-huge"].subgroup = "wooden-pole"
		data.raw["item"]["bi-wooden-pole-huge"].subgroup = "wooden-pole"
	end

	data.raw["recipe"]["medium-electric-pole"].subgroup = "medium-electric-pole"
	data.raw["item"]["medium-electric-pole"].subgroup = "medium-electric-pole"
	data.raw["recipe"]["bob-medium-electric-pole-2"].subgroup = "medium-electric-pole"
	data.raw["item"]["bob-medium-electric-pole-2"].subgroup = "medium-electric-pole"
	data.raw["recipe"]["bob-medium-electric-pole-3"].subgroup = "medium-electric-pole"
	data.raw["item"]["bob-medium-electric-pole-3"].subgroup = "medium-electric-pole"
	data.raw["recipe"]["bob-medium-electric-pole-4"].subgroup = "medium-electric-pole"
	data.raw["item"]["bob-medium-electric-pole-4"].subgroup = "medium-electric-pole"

	data.raw["recipe"]["big-electric-pole"].subgroup = "big-electric-pole"
	data.raw["item"]["big-electric-pole"].subgroup = "big-electric-pole"
	data.raw["recipe"]["bob-big-electric-pole-2"].subgroup = "big-electric-pole"
	data.raw["item"]["bob-big-electric-pole-2"].subgroup = "big-electric-pole"
	data.raw["recipe"]["bob-big-electric-pole-3"].subgroup = "big-electric-pole"
	data.raw["item"]["bob-big-electric-pole-3"].subgroup = "big-electric-pole"
	data.raw["recipe"]["bob-big-electric-pole-4"].subgroup = "big-electric-pole"
	data.raw["item"]["bob-big-electric-pole-4"].subgroup = "big-electric-pole"

	data.raw["recipe"]["substation"].subgroup = "substation"
	data.raw["item"]["substation"].subgroup = "substation"
	data.raw["recipe"]["bob-substation-2"].subgroup = "substation"
	data.raw["item"]["bob-substation-2"].subgroup = "substation"
	data.raw["recipe"]["bob-substation-3"].subgroup = "substation"
	data.raw["item"]["bob-substation-3"].subgroup = "substation"
	data.raw["recipe"]["bob-substation-4"].subgroup = "substation"
	data.raw["item"]["bob-substation-4"].subgroup = "substation"

	if mods["LightedPolesPlus"] then
		data.raw["recipe"]["lighted-small-electric-pole"].subgroup = "wooden-pole"
		data.raw["item"]["lighted-small-electric-pole"].subgroup = "wooden-pole"
		data.raw["recipe"]["lighted-bi-wooden-pole-big"].subgroup = "wooden-pole"
		data.raw["item"]["lighted-bi-wooden-pole-big"].subgroup = "wooden-pole"
		data.raw["recipe"]["lighted-bi-wooden-pole-huge"].subgroup = "wooden-pole"
		data.raw["item"]["lighted-bi-wooden-pole-huge"].subgroup = "wooden-pole"

		data.raw["recipe"]["lighted-medium-electric-pole"].subgroup = "medium-electric-pole"
		data.raw["item"]["lighted-medium-electric-pole"].subgroup = "medium-electric-pole"
		data.raw["recipe"]["lighted-medium-electric-pole-2"].subgroup = "medium-electric-pole"
		data.raw["item"]["lighted-medium-electric-pole-2"].subgroup = "medium-electric-pole"
		data.raw["recipe"]["lighted-medium-electric-pole-3"].subgroup = "medium-electric-pole"
		data.raw["item"]["lighted-medium-electric-pole-3"].subgroup = "medium-electric-pole"
		data.raw["recipe"]["lighted-medium-electric-pole-4"].subgroup = "medium-electric-pole"
		data.raw["item"]["lighted-medium-electric-pole-4"].subgroup = "medium-electric-pole"

		data.raw["recipe"]["lighted-big-electric-pole"].subgroup = "big-electric-pole"
		data.raw["item"]["lighted-big-electric-pole"].subgroup = "big-electric-pole"
		data.raw["recipe"]["lighted-big-electric-pole-2"].subgroup = "big-electric-pole"
		data.raw["item"]["lighted-big-electric-pole-2"].subgroup = "big-electric-pole"
		data.raw["recipe"]["lighted-big-electric-pole-3"].subgroup = "big-electric-pole"
		data.raw["item"]["lighted-big-electric-pole-3"].subgroup = "big-electric-pole"
		data.raw["recipe"]["lighted-big-electric-pole-4"].subgroup = "big-electric-pole"
		data.raw["item"]["lighted-big-electric-pole-4"].subgroup = "big-electric-pole"

		data.raw["recipe"]["lighted-substation"].subgroup = "substation"
		data.raw["item"]["lighted-substation"].subgroup = "substation"
		data.raw["recipe"]["lighted-substation-2"].subgroup = "substation"
		data.raw["item"]["lighted-substation-2"].subgroup = "substation"
		data.raw["recipe"]["lighted-substation-3"].subgroup = "substation"
		data.raw["item"]["lighted-substation-3"].subgroup = "substation"
		data.raw["recipe"]["lighted-substation-4"].subgroup = "substation"
		data.raw["item"]["lighted-substation-4"].subgroup = "substation"
	end
	-------------------------------------------------------------------------------------------------
	--сундуки и склады
	data.raw["item"]["steel-chest"].subgroup = "logistic-chests-1"
	data.raw["item"]["angels-logistic-chest-passive-provider"].subgroup = "logistic-chests-1"
	data.raw["item"]["angels-logistic-chest-storage"].subgroup = "logistic-chests-1"
	data.raw["item"]["angels-logistic-chest-active-provider"].subgroup = "logistic-chests-1"
	data.raw["item"]["angels-logistic-chest-requester"].subgroup = "logistic-chests-1"
	data.raw["item"]["angels-logistic-chest-buffer"].subgroup = "logistic-chests-1"

	data.raw["item"]["bob-brass-chest"].subgroup = "logistic-chests-2"

	data.raw["item"]["bob-titanium-chest"].subgroup = "logistic-chests-3"

	if mods["Warehousing"] then
		data.raw["item"]["storehouse-basic"].subgroup = "logistic-chests-4"
		data.raw["item"]["storehouse-passive-provider"].subgroup = "logistic-chests-4"
		data.raw["item"]["storehouse-storage"].subgroup = "logistic-chests-4"
		data.raw["item"]["storehouse-active-provider"].subgroup = "logistic-chests-4"
		data.raw["item"]["storehouse-requester"].subgroup = "logistic-chests-4"
		data.raw["item"]["storehouse-buffer"].subgroup = "logistic-chests-4"

		data.raw["item"]["storehouse-basic"].order = "1"
		data.raw["item"]["storehouse-passive-provider"].order = "4"
		data.raw["item"]["storehouse-storage"].order = "6"
		data.raw["item"]["storehouse-active-provider"].order = "2"
		data.raw["item"]["storehouse-requester"].order = "5"
		data.raw["item"]["storehouse-buffer"].order = "3"

		data.raw["item"]["warehouse-basic"].subgroup = "logistic-chests-5"
		data.raw["item"]["warehouse-passive-provider"].subgroup = "logistic-chests-5"
		data.raw["item"]["warehouse-storage"].subgroup = "logistic-chests-5"
		data.raw["item"]["warehouse-active-provider"].subgroup = "logistic-chests-5"
		data.raw["item"]["warehouse-requester"].subgroup = "logistic-chests-5"
		data.raw["item"]["warehouse-buffer"].subgroup = "logistic-chests-5"

		data.raw["item"]["warehouse-basic"].order = "1"
		data.raw["item"]["warehouse-passive-provider"].order = "4"
		data.raw["item"]["warehouse-storage"].order = "6"
		data.raw["item"]["warehouse-active-provider"].order = "2"
		data.raw["item"]["warehouse-requester"].order = "5"
		data.raw["item"]["warehouse-buffer"].order = "3"
	end
	if mods["Nanobots"] then
		data.raw["item"]["roboport-interface"].subgroup = "bob-logistic-roboport"
		data.raw["item"]["roboport-interface-cc"].subgroup = "bob-logistic-roboport"
	end
end --конец mods["angelsindustries"]

