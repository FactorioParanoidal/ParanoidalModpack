--Quick fix for One More Tier, before submitting the proper change to original mod.
--EDIT: commented as change has been implemented in OMT

--[[if mods["one-more-tier"] then
  if data.raw["storage-tank"]["omt-pipe-elbow"] then data.raw["storage-tank"]["omt-pipe-elbow"].icon_size = 32 end
  if data.raw["storage-tank"]["omt-pipe-junction"] then data.raw["storage-tank"]["omt-pipe-junction"].icon_size = 32 end
  if data.raw["storage-tank"]["omt-pipe-straight"] then data.raw["storage-tank"]["omt-pipe-straight"].icon_size = 32 end
  if data.raw["item"]["omt-pipe-elbow"] then data.raw["item"]["omt-pipe-elbow"].icon_size = 32 end
  if data.raw["item"]["omt-pipe-junction"] then data.raw["item"]["omt-pipe-junction"].icon_size = 32 end
  if data.raw["item"]["omt-pipe-straight"] then data.raw["item"]["omt-pipe-straight"].icon_size = 32 end
end]]
