require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---
---usage: require "__Kux-CoreLib__/lib/data/@"
---

require(KuxCoreLibPath.."lib/@")

KuxCoreLib.Data.DataRaw        .asGlobal()

if(KuxCoreLib.ModInfo.current_stage:match("^data")) then
	KuxCoreLib.Data.EntityData     .asGlobal()
	KuxCoreLib.Data.ItemData       .asGlobal()
	KuxCoreLib.Data.PrototypeData  .asGlobal()
	KuxCoreLib.Data.RecipeData     .asGlobal()
	KuxCoreLib.Data.TechnologyData .asGlobal()
	KuxCoreLib.Data.TechnologyIndex.asGlobal()
	KuxCoreLib.Data.AnimationData  .asGlobal()
end

return KuxCoreLib