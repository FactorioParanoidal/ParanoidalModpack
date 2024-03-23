-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

-- Setup the function host for applying reskins
if not reskins.lib.apply_skin then reskins.lib.apply_skin = {} end

-- Vanilla prototypes
require('entities.base.chemical-plant')
require('entities.base.oil-refinery')
require('entities.base.transport-belt')
require('entities.base.underground-belt')
require('entities.base.splitter')