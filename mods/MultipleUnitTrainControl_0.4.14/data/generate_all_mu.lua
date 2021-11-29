--[[ Copyright (c) 2020 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: generate_all_mu.lua
 * Description: Procedurally generate MU Locomotives for any remaining locos that we have not addressed
--]]



local has_description = {
-- Base
  "locomotive",
-- Batteries Not Included
  "bni_electric-locomotive",
-- YIR American
  "yir_emdf7a_mn",
  "yir_emdf7b_mn",
  "yir_emdf7b_cr",
  "yir_emdf7a_cr",
  "yir_es44cr",
-- YIR Railways Addons
  --"yir_ns2200wr",
  --"yir_ns2200gg",
  "y_loco_diesel_620",
  "yir_usl",
  "yir_lsw_r790orange",
  "yir_lsw_r790red",
  "yir_lsw_840green",
  "y_loco_desw_blue",
-- YIR Uranium Locomotive
  "yir_atom_header",
  "yir_atom_mitte",
-- Yuoki Industries - Railways
  "yir_loco_del_bluegray",
  "y_loco_emd3000_white",
  "yir_loco_del_KR",
  "yir_loco_fut_red",
  "yir_loco_del_mk1400",
  "yir_loco_fesw_op",
  "y_loco_desw",
  "y_loco_desw_orange",
  "y_loco_desw_blue",
  "y_loco_emd1500black",
  "y_loco_emd1500blue",
  "y_loco_emd1500blue_v2",
  "y_loco_emd1500black_v2",
-- FARL
  "farl",
-- Industrial Revolution
  "electric-locomotive",
-- Nuclear Locomotive
  "nuclear-locomotive",
-- Train Overhaul
  "heavy-locomotive",
  "express-locomotive",
  "nuclear-locomotive",
-- X12 Nuclear Locomotive
  "x12-nuclear-locomotive-powered",
-- Schall Armoured Train
  "Schall-nuclear-locomotive",
  "Schall-armoured-locomotive",
-- Steam Locomotive
  "SteamTrains-locomotive",
-- Diesel locomotive
  "Diesel-Locomotive-fluid-locomotive",
-- Neocky's Trains
  "nt-train-electric",
  "nt-train-fusion",
  "nt-train-nuclear",
-- Electric Vehicles Reborn
  "electric-vehicles-electric-locomotive",
-- Space Trains
  "space-trains-locomotive",
  "space-trains-locomotive-solar1",
  "space-trains-locomotive-solar2",
  "space-trains-locomotive-solar3",
  "space-trains-short-locomotive",
  "space-trains-short-locomotive-solar1",
  "space-trains-short-locomotive-solar2",
  "space-trains-short-locomotive-solar3",
}

-- Convert entity-description list to dictionary
local mu_has_description = {}
for _,name in pairs(has_description) do
  mu_has_description[name] = true
end



local blacklist = {
-- Laser Tank (MU is broken when Electric Vehicles Lib: Reborn is *not* installed)
--  "electric-vehicles-electric-locomotive",
-- RailPowerSystem (mod is too broken to test, and mod needs modification to accept MU loco)
  "hybrid-train",
-- Steam Locomotive (this is the old non-working entity that must be mined to be migrated)
  "steam-locomotive",
-- Train Construction Site (this is a dummy entity used when generating trains)
  "trainassembly-placeable",
-- Cargo Ship engines can't couple to each other anyways
  "boat_engine",
  "cargo_ship_engine",
-- Editor Extensions overpowered super loco does not need power doubling at all!
  "ee-super-locomotive",
-- Real Shuttle Trains (no interface to add shuttle locomotives, and the auto-disconnecting logic interferes. also uses Kazuya's nonfunctional electric train interface.)
  "shuttle",
  "electric_shuttle",
-- Space Exploration "special item"
  "se-space-elevator-tug",
-- Railway Motor Cars "personal vehicles"
  "railway-motor-car-train",
  "railway-motor-car-nuclear-train",
}

local yuoki_blacklist = {
-- YIR Industries Railways
  "y_loco_fs_steam_green",
  "yir_loco_sel_blue",
  "y_loco_steam_wt450",
  "y_loco_ses_std",
  "y_loco_ses_red",
-- YIR Railwas Addons
  "yir_mre044",
  "yir_loco_steam_wt580of",
  "yir_kr_green",
}

local kazuya_blacklist = {
-- Battery Locomotive (mod does not have functioning remote interface yet)
  "battery-locomotive",
  "battery-locomotive-mk2",
  "battery-locomotive-mk3"
}

-- Convert blacklist to dictionary
local mu_blacklist = {}
for _,name in pairs(blacklist) do
  mu_blacklist[name] = true
end
-- Add names from blacklist startup setting
local blacklist_setting = settings.startup["multiple-unit-train-control-blacklist"].value
for name in string.gmatch(blacklist_setting, "([^,]+)") do
  mu_blacklist[name] = true
end
-- Add Yuoki Steam Engines if setting is disabled
if settings.startup["multiple-unit-train-control-allow_yuoki_steam"].value == false then
  for _,name in pairs(yuoki_blacklist) do
    mu_blacklist[name] = true
  end
end
-- Add Battery Locomotive to blacklist if it's present (since the names are generic, don't want to exclude others)
if mods["BatteryLocomotive"] then
  for _,name in pairs(kazuya_blacklist) do
    mu_blacklist[name] = true
  end
end

-- Add Degraine's Electric Locomotive to blacklist if present
if mods["ElectricTrains"] then
  mu_blacklist["electric-locomotive"] = true
end


-- Make a list of locomotives to add (can't modify data.raw while iterating over it)
local mu_make_new = {}
for name,loco in pairs(data.raw["locomotive"]) do
  local make_mu = true
  -- Check if this is a MU or if it already has a MU
  if mu_blacklist[name] then
    make_mu = false
    log("Ignoring locomotive \""..name.."\"")
  elseif string.find(name, "%-mu$") ~= nil then
    -- ends in MU, make sure regular loco exists. If not, then the vanilla loco ended with -mu, and the new one will be -mu-mu
    if data.raw["locomotive"][string.sub(name, 1, -4)] then
      -- This MU has a regular loco, do nothing
      make_mu = false
    end
  elseif data.raw["locomotive"][name.."-mu"] then
    -- Already made an MU of this loco
    make_mu = false
  end
  
  if make_mu then
    -- no MU of this loco, make a new one assuming it is basic
    table.insert(mu_make_new, name)
  end
end

-- Create the identified MU locomotives
for _,name in pairs(mu_make_new) do
  createMuLoco{std=name, mu=name.."-mu", hasDescription=mu_has_description[name]}
end
