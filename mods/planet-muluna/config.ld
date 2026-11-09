project = 'Muluna'
description = 'Muluna'
full_description = 'Muluna, Moon of Nauvis is a mod that expands Factorio by adding a new planet. This documentation is a work in progress.'
title = 'Muluna documentation'
dir = 'docs'
template = true
use_markdown_titles = true
readme = "README.md" 
style = 'docs_templates'
template = "docs_templates"
format = 'markdown'
sort_modules=true
ignore=true
file = '.'
kind_names={topic='Manual',module='Libraries'}
tparam_alias('array','array')
tparam_alias('array2d','array')
tparam_alias('TechnologyPrototype','[TechnologyPrototype](https://lua-api.factorio.com/latest/prototypes/TechnologyPrototype.html)')
alias("LuaForce",'@{LuaForce}')
alias('ret',{'return',modifiers={type="$1"}})
