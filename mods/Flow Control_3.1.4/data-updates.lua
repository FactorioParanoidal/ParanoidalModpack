if settings.startup["flow-control-revert-to-normal-pipe"].value == false then
  data.raw["storage-tank"]["pipe-elbow"].minable.result = "pipe-elbow"
  data.raw["storage-tank"]["pipe-junction"].minable.result = "pipe-junction"
  data.raw["storage-tank"]["pipe-straight"].minable.result = "pipe-straight"
end
