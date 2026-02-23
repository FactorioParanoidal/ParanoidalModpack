require("mod")
local extend = KuxCoreLib.SettingsData.extend


local x = extend{"startup","a",prefix=""}
x:int{"ion-cannon-radius",25,2,50}
x:int{"ion-cannon-heatup-multiplier",2,1,50}
x:int{"ion-cannon-laser-damage",2500,1}
x:int{"ion-cannon-explosion-damage",1000,1}
x:int{"ion-cannon-electric-damage",1000,1}
x:bool{"ion-cannon-flames",true}
x:bool{"ion-cannon-bob-updates",true}
x:bool{"ion-cannon-early-recipe",false}
x:bool{"ion-cannon-1x1-controler",false}

x = extend{"runtime-global","a",prefix=""}
x:bool{"ion-cannon-auto-targeting",true}
x:bool{"ion-cannon-target-worms",true}
x:bool{"ion-cannon-auto-target-visible",true}
x:int{"ion-cannon-cooldown-seconds",300,2}
x:int{"ion-cannon-chart-tag-duration",720,120}
x:int{"ion-cannon-min-cannons-ready",2,0}
x:bool{"ion-cannon-cheat-menu",false}

x = extend{"runtime-per-user","a",prefix=""}
x:bool{"ion-cannon-play-voices",true}
--x:bool{"ion-cannon-play-voices-ion-cannon-ready",true}
x:int{"ion-cannon-voice-volume",70,0,100}
x:string{"ion-cannon-voice-style","CommandAndConquer",{"CommandAndConquer","TiberianSunEVA","TiberianSunCABAL","TiberianSunEVA-FR","TiberianSunCABAL-FR"}}
x:string{"ion-cannon-play-klaxon","local",{"none","local","surface","global"}}
--x:int_const{"ion-cannon-play-klaxon-locaal-distance",32}
x:int{"ion-cannon-klaxon-volume",70,0,100}
x:int{"ion-cannon-ready-ticks",360,1}
x:bool{"ion-cannon-custom-alerts",true}
