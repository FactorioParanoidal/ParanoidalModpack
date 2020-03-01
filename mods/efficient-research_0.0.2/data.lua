
data:extend{
  { type = "technology", name = "research-efficiency-1",
    icon_size = 128,
    icon = "__efficient-research__/gfx/research-prod.png",
    effects =
    {
      { type = "laboratory-productivity", modifier = 0.01 },
      { type = "laboratory-speed", modifier = -0.06 }
    },
    prerequisites = {"research-speed-1"},
    unit =
    {
      count_formula = "25*L+75",
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1}
      },
      time = 45
    },
    upgrade = true,
    max_level = "3",
    order = "c-m-a-2"
  },
  { type = "technology", name = "research-efficiency-4",
    icon_size = 128,
    icon = "__efficient-research__/gfx/research-prod.png",
    effects =
    {
      { type = "laboratory-productivity", modifier = 0.01 },
      { type = "laboratory-speed", modifier = -0.08 }
    },
    prerequisites = {"research-speed-2","research-efficiency-1"},
    unit =
    {
      count_formula = "25*L+100",
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1}
      },
      time = 45
    },
    upgrade = true,
    max_level = "6",
    order = "c-m-b-2"
  },
  { type = "technology", name = "research-efficiency-7",
    icon_size = 128,
    icon = "__efficient-research__/gfx/research-prod.png",
    effects =
    {
      { type = "laboratory-productivity", modifier = 0.01 },
      { type = "laboratory-speed", modifier = -0.10 }
    },
    prerequisites = {"research-speed-3","research-efficiency-4"},
    unit =
    {
      count_formula = "100*L-450",
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1}
      },
      time = 45
    },
    upgrade = true,
    max_level = "9",
    order = "c-m-c-2"
  },
  { type = "technology", name = "research-efficiency-10",
    icon_size = 128,
    icon = "__efficient-research__/gfx/research-prod.png",
    effects =
    {
      { type = "laboratory-productivity", modifier = 0.01 },
      { type = "laboratory-speed", modifier = -0.12 }
    },
    prerequisites = {"research-speed-4","research-efficiency-7"},
    unit =
    {
      count_formula = "500",
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1}
      },
      time = 45
    },
    upgrade = true,
    max_level = "12",
    order = "c-m-d-2"
  },
  { type = "technology", name = "research-efficiency-13",
    icon_size = 128,
    icon = "__efficient-research__/gfx/research-prod.png",
    effects =
    {
      { type = "laboratory-productivity", modifier = 0.01 },
      { type = "laboratory-speed", modifier = -0.09 }
    },
    prerequisites = {"research-speed-5","research-efficiency-10"},
    unit =
    {
      count_formula = "500",
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1}
      },
      time = 45
    },
    upgrade = true,
    max_level = "16",
    order = "c-m-e-2"
  },
  { type = "technology", name = "research-efficiency-17",
    icon_size = 128,
    icon = "__efficient-research__/gfx/research-prod.png",
    effects =
    {
      { type = "laboratory-productivity", modifier = 0.01 },
      { type = "laboratory-speed", modifier = -0.09 }
    },
    prerequisites = {"research-speed-6","research-efficiency-13"},
    unit =
    {
      count_formula = "100*L-1200",
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1}
      },
      time = 45
    },
    upgrade = true,
    max_level = "20",
    order = "c-m-f-2"
  },

}
--[[
20 rb		100
30 rb		200
40 rbg		250
50 rbg		500
50 rbgp		500
60 rbgpy	500

--]]


--[[
local find, sub =string.find, string.sub
local pool,chains = {},{}


local n,p

for _,t in pairs(data.raw.technology) do
	for _,e in pairs(t.effects or {}) do
		if e.type=="laboratory-speed" and e.modifier>0 then
			n = 0
			repeat
				p = n
				n = find(name,"-",n+1)
			until n == nil
			
			if p>0 then
				n,p = sub(name,1,p-1),tonumber(sub(name,p+1))
			else
				n,p =name,1
			end
			
			if pool[n]==nil then
				pool[n]={
					
				}
			end
			pool[n] = (pool[n] or 0) + e.modifier
			
		end
	end
end
--]]