if data.raw["inserter"]["green-inserter"] then
purpletier = "express"
greentier = "green"
end
if data.raw["inserter"]["turbo-inserter"] then
purpletier = "turbo"
greentier = "express"
end

if settings.startup["bobmods-logistics-inserteroverhaul"] then
if settings.startup["bobmods-logistics-inserteroverhaul"].value == true then

if settings.startup["fancy-inserters"].value == true then


data.raw["inserter"]["inserter"].hand_base_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/yellow-base-1.png"
data.raw["inserter"]["inserter"].hand_closed_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/yellow-hc-1.png"
data.raw["inserter"]["inserter"].hand_open_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/yellow-ho-1.png"
data.raw["inserter"]["inserter"].platform_picture.sheet.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/yellow-plat-1.png"

data.raw["inserter"]["red-inserter"].hand_base_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/red-base-1.png"
data.raw["inserter"]["red-inserter"].hand_closed_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/red-hc-1.png"
data.raw["inserter"]["red-inserter"].hand_open_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/red-ho-1.png"
data.raw["inserter"]["red-inserter"].platform_picture.sheet.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/red-plat-1.png"

data.raw["inserter"]["fast-inserter"].hand_base_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/blue-base-1.png"
data.raw["inserter"]["fast-inserter"].hand_closed_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/blue-hc-1b.png"
data.raw["inserter"]["fast-inserter"].hand_open_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/blue-ho-1.png"
data.raw["inserter"]["fast-inserter"].platform_picture.sheet.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/blue-plat-1.png"

data.raw["inserter"][greentier.."-inserter"].hand_base_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/green-base-1.png"
data.raw["inserter"][greentier.."-inserter"].hand_closed_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/green-hc-1.png"
data.raw["inserter"][greentier.."-inserter"].hand_open_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/green-ho-1.png"
data.raw["inserter"][greentier.."-inserter"].platform_picture.sheet.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/green-plat-1.png"

data.raw["inserter"][purpletier.."-inserter"].hand_base_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/purple-base-1.png"
data.raw["inserter"][purpletier.."-inserter"].hand_closed_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/purple-hc-1.png"
data.raw["inserter"][purpletier.."-inserter"].hand_open_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/purple-ho-1.png"
data.raw["inserter"][purpletier.."-inserter"].platform_picture.sheet.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/purple-plat-1.png"



data.raw["inserter"]["yellow-filter-inserter"].hand_base_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/yellow-base-2.png"
data.raw["inserter"]["yellow-filter-inserter"].hand_closed_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/yellow-hc-2.png"
data.raw["inserter"]["yellow-filter-inserter"].hand_open_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/yellow-ho-2.png"
data.raw["inserter"]["yellow-filter-inserter"].platform_picture.sheet.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/yellow-plat-2.png"

data.raw["inserter"]["red-filter-inserter"].hand_base_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/red-base-2.png"
data.raw["inserter"]["red-filter-inserter"].hand_closed_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/red-hc-2.png"
data.raw["inserter"]["red-filter-inserter"].hand_open_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/red-ho-2.png"
data.raw["inserter"]["red-filter-inserter"].platform_picture.sheet.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/red-plat-2.png"

data.raw["inserter"]["filter-inserter"].hand_base_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/blue-base-2.png"
data.raw["inserter"]["filter-inserter"].hand_closed_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/blue-hc-2.png"
data.raw["inserter"]["filter-inserter"].hand_open_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/blue-ho-2.png"
data.raw["inserter"]["filter-inserter"].platform_picture.sheet.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/blue-plat-2.png"

data.raw["inserter"][greentier.."-filter-inserter"].hand_base_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/green-base-2.png"
data.raw["inserter"][greentier.."-filter-inserter"].hand_closed_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/green-hc-2.png"
data.raw["inserter"][greentier.."-filter-inserter"].hand_open_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/green-ho-2.png"
data.raw["inserter"][greentier.."-filter-inserter"].platform_picture.sheet.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/green-plat-2.png"

data.raw["inserter"][purpletier.."-filter-inserter"].hand_base_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/purple-base-2.png"
data.raw["inserter"][purpletier.."-filter-inserter"].hand_closed_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/purple-hc-2.png"
data.raw["inserter"][purpletier.."-filter-inserter"].hand_open_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/purple-ho-2.png"
data.raw["inserter"][purpletier.."-filter-inserter"].platform_picture.sheet.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/purple-plat-2.png"




data.raw["inserter"]["red-stack-inserter"].hand_base_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/red-base-1.png"
data.raw["inserter"]["red-stack-inserter"].hand_closed_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/red-hc-3.png"
data.raw["inserter"]["red-stack-inserter"].hand_open_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/red-ho-3.png"
data.raw["inserter"]["red-stack-inserter"].platform_picture.sheet.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/red-plat-3.png"

data.raw["inserter"]["stack-inserter"].hand_base_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/blue-base-1.png"
data.raw["inserter"]["stack-inserter"].hand_closed_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/blue-hc-3.png"
data.raw["inserter"]["stack-inserter"].hand_open_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/blue-ho-3.png"
data.raw["inserter"]["stack-inserter"].platform_picture.sheet.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/blue-plat-3.png"

data.raw["inserter"][greentier.."-stack-inserter"].hand_base_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/green-base-1.png"
data.raw["inserter"][greentier.."-stack-inserter"].hand_closed_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/green-hc-3.png"
data.raw["inserter"][greentier.."-stack-inserter"].hand_open_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/green-ho-3.png"
data.raw["inserter"][greentier.."-stack-inserter"].platform_picture.sheet.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/green-plat-3.png"

data.raw["inserter"][purpletier.."-stack-inserter"].hand_base_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/purple-base-1.png"
data.raw["inserter"][purpletier.."-stack-inserter"].hand_closed_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/purple-hc-3.png"
data.raw["inserter"][purpletier.."-stack-inserter"].hand_open_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/purple-ho-3.png"
data.raw["inserter"][purpletier.."-stack-inserter"].platform_picture.sheet.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/purple-plat-3.png"



data.raw["inserter"]["red-stack-filter-inserter"].hand_base_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/red-base-2.png"
data.raw["inserter"]["red-stack-filter-inserter"].hand_closed_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/red-hc-4.png"
data.raw["inserter"]["red-stack-filter-inserter"].hand_open_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/red-ho-4.png"
data.raw["inserter"]["red-stack-filter-inserter"].platform_picture.sheet.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/red-plat-4.png"

data.raw["inserter"]["stack-filter-inserter"].hand_base_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/blue-base-2.png"
data.raw["inserter"]["stack-filter-inserter"].hand_closed_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/blue-hc-4.png"
data.raw["inserter"]["stack-filter-inserter"].hand_open_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/blue-ho-4.png"
data.raw["inserter"]["stack-filter-inserter"].platform_picture.sheet.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/blue-plat-4.png"

data.raw["inserter"][greentier.."-stack-filter-inserter"].hand_base_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/green-base-2.png"
data.raw["inserter"][greentier.."-stack-filter-inserter"].hand_closed_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/green-hc-4.png"
data.raw["inserter"][greentier.."-stack-filter-inserter"].hand_open_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/green-ho-4.png"
data.raw["inserter"][greentier.."-stack-filter-inserter"].platform_picture.sheet.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/green-plat-4.png"

data.raw["inserter"][purpletier.."-stack-filter-inserter"].hand_base_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/purple-base-2.png"
data.raw["inserter"][purpletier.."-stack-filter-inserter"].hand_closed_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/purple-hc-4.png"
data.raw["inserter"][purpletier.."-stack-filter-inserter"].hand_open_picture.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/purple-ho-4.png"
data.raw["inserter"][purpletier.."-stack-filter-inserter"].platform_picture.sheet.hr_version.filename = "__ShinyBobGFX__/graphics/insert-entity/purple-plat-4.png"



data.raw.item["inserter"].icon = "__ShinyBobGFX__/graphics/insert-icon/yellow-1.png"
data.raw.item["long-handed-inserter"].icon = "__ShinyBobGFX__/graphics/insert-icon/red-1.png"
data.raw.item["long-handed-inserter"].icon = "__ShinyBobGFX__/graphics/insert-icon/red-1.png"
data.raw.item["fast-inserter"].icon = "__ShinyBobGFX__/graphics/insert-icon/blue-1.png"
data.raw.item["fast-inserter"].icon = "__ShinyBobGFX__/graphics/insert-icon/blue-1.png"
data.raw.item[greentier.."-inserter"].icon = "__ShinyBobGFX__/graphics/insert-icon/green-1.png"
data.raw.item[purpletier.."-inserter"].icon = "__ShinyBobGFX__/graphics/insert-icon/purple-1.png"
data.raw.item["yellow-filter-inserter"].icon = "__ShinyBobGFX__/graphics/insert-icon/yellow-2.png"
data.raw.item["red-filter-inserter"].icon = "__ShinyBobGFX__/graphics/insert-icon/red-2.png"
data.raw.item["filter-inserter"].icon = "__ShinyBobGFX__/graphics/insert-icon/blue-2.png"
data.raw.item["filter-inserter"].icon = "__ShinyBobGFX__/graphics/insert-icon/blue-2.png"
data.raw.item[greentier.."-filter-inserter"].icon = "__ShinyBobGFX__/graphics/insert-icon/green-2.png"
data.raw.item[purpletier.."-filter-inserter"].icon = "__ShinyBobGFX__/graphics/insert-icon/purple-2.png"


data.raw.item["red-stack-inserter"].icon = "__ShinyBobGFX__/graphics/insert-icon/red-3.png"
data.raw.item["stack-inserter"].icon = "__ShinyBobGFX__/graphics/insert-icon/blue-3.png"
data.raw.item["stack-inserter"].icon = "__ShinyBobGFX__/graphics/insert-icon/blue-3.png"
data.raw.item[greentier.."-stack-inserter"].icon = "__ShinyBobGFX__/graphics/insert-icon/green-3.png"
data.raw.item[purpletier.."-stack-inserter"].icon = "__ShinyBobGFX__/graphics/insert-icon/purple-3.png"
data.raw.item["red-stack-inserter"].icon_size = 128
data.raw.item["stack-inserter"].icon_size = 128
data.raw.item["stack-inserter"].icon_size = 128
data.raw.item[greentier.."-stack-inserter"].icon_size = 128
data.raw.item[purpletier.."-stack-inserter"].icon_size = 128

data.raw.item["red-stack-filter-inserter"].icon = "__ShinyBobGFX__/graphics/insert-icon/red-4.png"
data.raw.item["stack-filter-inserter"].icon = "__ShinyBobGFX__/graphics/insert-icon/blue-4.png"
data.raw.item["stack-filter-inserter"].icon = "__ShinyBobGFX__/graphics/insert-icon/blue-4.png"
data.raw.item[greentier.."-stack-filter-inserter"].icon = "__ShinyBobGFX__/graphics/insert-icon/green-4.png"
data.raw.item[purpletier.."-stack-filter-inserter"].icon = "__ShinyBobGFX__/graphics/insert-icon/purple-4.png"
data.raw.item["red-stack-filter-inserter"].icon_size = 128
data.raw.item["stack-filter-inserter"].icon_size = 128
data.raw.item["stack-filter-inserter"].icon_size = 128
data.raw.item[greentier.."-stack-filter-inserter"].icon_size = 128
data.raw.item[purpletier.."-stack-filter-inserter"].icon_size = 128

end

else

if data.raw["inserter"]["express-inserter"] then
	-- data.raw["inserter"]["express-inserter"].hand_base_picture.filename =
	-- data.raw["inserter"]["express-inserter"].hand_closed_picture.filename =
	-- data.raw["inserter"]["express-inserter"].hand_open_picture.filename =
	-- data.raw["inserter"]["express-inserter"].platform_picture.sheet.filename =
	-- data.raw["inserter"]["express-filter-inserter"].hand_base_picture.filename =
	-- data.raw["inserter"]["express-filter-inserter"].hand_closed_picture.filename =
	-- data.raw["inserter"]["express-filter-inserter"].hand_open_picture.filename =
	-- data.raw["inserter"]["express-filter-inserter"].platform_picture.sheet.filename =
	data.raw["inserter"]["express-stack-inserter"].hand_base_picture.filename = "__ShinyBobGFX__/graphics/entity/inserter/green-inserter-hand-base.png"
	data.raw["inserter"]["express-stack-inserter"].hand_closed_picture.filename = "__ShinyBobGFX__/graphics/entity/inserter/green-inserter-hand-closed.png"
	data.raw["inserter"]["express-stack-inserter"].hand_open_picture.filename = "__ShinyBobGFX__/graphics/entity/inserter/green-inserter-hand-open.png"
	data.raw["inserter"]["express-stack-inserter"].platform_picture.sheet.filename = "__ShinyBobGFX__/graphics/entity/inserter/green-inserter-platform.png"
	
	data.raw["inserter"]["express-inserter"].hand_base_picture.hr_version.filename = "__ShinyBobGFX__/graphics/entity/inserter/hr-cyan-inserter-hand-base.png"
	data.raw["inserter"]["express-inserter"].hand_closed_picture.hr_version.filename = "__ShinyBobGFX__/graphics/entity/inserter/hr-cyan-inserter-hand-closed.png"
	data.raw["inserter"]["express-inserter"].hand_open_picture.hr_version.filename = "__ShinyBobGFX__/graphics/entity/inserter/hr-cyan-inserter-hand-open.png"
	data.raw["inserter"]["express-inserter"].platform_picture.sheet.hr_version.filename = "__ShinyBobGFX__/graphics/entity/inserter/hr-cyan-inserter-platform.png"
	data.raw["inserter"]["express-filter-inserter"].hand_base_picture.hr_version.filename = "__ShinyBobGFX__/graphics/entity/inserter/hr-magenta-inserter-hand-base.png"
	data.raw["inserter"]["express-filter-inserter"].hand_closed_picture.hr_version.filename = "__ShinyBobGFX__/graphics/entity/inserter/hr-magenta-inserter-hand-closed.png"
	data.raw["inserter"]["express-filter-inserter"].hand_open_picture.hr_version.filename = "__ShinyBobGFX__/graphics/entity/inserter/hr-magenta-inserter-hand-open.png"
	data.raw["inserter"]["express-filter-inserter"].platform_picture.sheet.hr_version.filename = "__ShinyBobGFX__/graphics/entity/inserter/hr-magenta-inserter-platform.png"
	data.raw["inserter"]["express-stack-inserter"].hand_base_picture.hr_version.filename = "__ShinyBobGFX__/graphics/entity/inserter/hr-green-inserter-hand-base.png"
	data.raw["inserter"]["express-stack-inserter"].hand_closed_picture.hr_version.filename = "__ShinyBobGFX__/graphics/entity/inserter/hr-green-inserter-hand-closed.png"
	data.raw["inserter"]["express-stack-inserter"].hand_open_picture.hr_version.filename = "__ShinyBobGFX__/graphics/entity/inserter/hr-green-inserter-hand-open.png"
	data.raw["inserter"]["express-stack-inserter"].platform_picture.sheet.hr_version.filename = "__ShinyBobGFX__/graphics/entity/inserter/hr-green-inserter-platform.png"
	
	data.raw["inserter"]["express-stack-filter-inserter"].icon = "__ShinyBobGFX__/graphics/entity/inserter/icon/tan-inserter.png"
    data.raw["item"]["express-stack-filter-inserter"].icon = "__ShinyBobGFX__/graphics/entity/inserter/icon/tan-inserter.png"
    data.raw["inserter"]["express-stack-filter-inserter"].hand_base_picture.filename = "__ShinyBobGFX__/graphics/entity/inserter/tan-inserter-hand-base.png"
	data.raw["inserter"]["express-stack-filter-inserter"].hand_closed_picture.filename = "__ShinyBobGFX__/graphics/entity/inserter/tan-inserter-hand-closed.png"
	data.raw["inserter"]["express-stack-filter-inserter"].hand_open_picture.filename = "__ShinyBobGFX__/graphics/entity/inserter/tan-inserter-hand-open.png"
	data.raw["inserter"]["express-stack-filter-inserter"].platform_picture.sheet.filename = "__ShinyBobGFX__/graphics/entity/inserter/tan-inserter-platform.png"
	
	data.raw["inserter"]["express-stack-filter-inserter"].hand_base_picture.hr_version.filename = "__ShinyBobGFX__/graphics/entity/inserter/hr-tan-inserter-hand-base.png"
	data.raw["inserter"]["express-stack-filter-inserter"].hand_closed_picture.hr_version.filename = "__ShinyBobGFX__/graphics/entity/inserter/hr-tan-inserter-hand-closed.png"
	data.raw["inserter"]["express-stack-filter-inserter"].hand_open_picture.hr_version.filename = "__ShinyBobGFX__/graphics/entity/inserter/hr-tan-inserter-hand-open.png"
	data.raw["inserter"]["express-stack-filter-inserter"].platform_picture.sheet.hr_version.filename = "__ShinyBobGFX__/graphics/entity/inserter/hr-tan-inserter-platform.png"
end	
	
end
end