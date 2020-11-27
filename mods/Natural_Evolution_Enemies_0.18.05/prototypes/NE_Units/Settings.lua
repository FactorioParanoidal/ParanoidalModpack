

if not NE_Enemies then NE_Enemies = {} end
if not NE_Enemies.Settings then NE_Enemies.Settings = {} end

NE_Enemies.Settings.NE_Difficulty = settings.startup["NE_Difficulty"].value

---- Biter Attack Function - Normal Biter
function Biter_Melee_Attack_Healthy(damagevalue)
  return
  {
    category = "melee",
    target_type = "entity",
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          type = "damage",
          damage = { amount = damagevalue , type = "physical"}
        },
      }
    }
  }
end



	
Damage = {
	Small_Biter = Biter_Melee_Attack_Healthy(10*NE_Enemies.Settings.NE_Difficulty),
	Medium_Biter = Biter_Melee_Attack_Healthy(35*NE_Enemies.Settings.NE_Difficulty),
	Big_Biter = Biter_Melee_Attack_Healthy(80*NE_Enemies.Settings.NE_Difficulty),
	Behemoth_Biter = Biter_Melee_Attack_Healthy(175*NE_Enemies.Settings.NE_Difficulty)
	}
	
	
Health = {
	Small_Biter = 15,
	Medium_Biter = 75*NE_Enemies.Settings.NE_Difficulty,
	Big_Biter = 450*NE_Enemies.Settings.NE_Difficulty,
	Behemoth_Biter = 5000*NE_Enemies.Settings.NE_Difficulty,
	Small_Spitter = 10,
	Medium_Spitter = 50*NE_Enemies.Settings.NE_Difficulty,
	Big_Spitter = 200*NE_Enemies.Settings.NE_Difficulty,
	Behemoth_Spitter = 2000*NE_Enemies.Settings.NE_Difficulty,
	Small_Worm = 200 + 100 * NE_Enemies.Settings.NE_Difficulty,
	Medium_Worm = 200 + 200 * NE_Enemies.Settings.NE_Difficulty,
	Big_Worm = 400 + 200 * NE_Enemies.Settings.NE_Difficulty,	
	}



Resistances = {
	-- Healthy (Physical)
	Small_Biter = {
	  {type = "fire", decrease = 0, percent = -80},
      {type = "physical", decrease = 1, percent = 5*NE_Enemies.Settings.NE_Difficulty},
      {type = "impact", decrease = 0, percent = 0},
      {type = "explosion", decrease = 0, percent = 0},
      {type = "acid", decrease = 0, percent = 0},
      {type = "poison", decrease = 0, percent = 0},
      {type = "laser", decrease = 0, percent = 0}},
	
	-- Healthy (Physical)
	Medium_Biter = {
	  {type = "fire", decrease = 0, percent = -70},
      {type = "physical", decrease = 6, percent = 10*NE_Enemies.Settings.NE_Difficulty},
      {type = "impact", decrease = 4, percent = 0},
      {type = "explosion", decrease = 4, percent = 0},
      {type = "acid", decrease = 4, percent = 0},
      {type = "poison", decrease = 4, percent = 0},
      {type = "laser", decrease = 4, percent = 0}},
	
	-- Healthy (Physical)
	Big_Biter = {
	  {type = "fire", decrease = 0, percent = -60},
      {type = "physical", decrease = 14, percent = 15*NE_Enemies.Settings.NE_Difficulty},
      {type = "impact", decrease = 10, percent = 0},
      {type = "explosion", decrease = 10, percent = 0},
      {type = "acid", decrease = 10, percent = 0},
      {type = "poison", decrease = 10, percent = 0},
      {type = "laser", decrease = 10, percent = 0}},
	
	-- Healthy (Physical)	
	Behemoth_Biter = {
	  {type = "fire", decrease = 0, percent = -40},
      {type = "physical", decrease = 20, percent = 18*NE_Enemies.Settings.NE_Difficulty},
      {type = "impact", decrease = 16, percent = 0},
      {type = "explosion", decrease = 16, percent = 0},
      {type = "acid", decrease = 16, percent = 0},
      {type = "poison", decrease = 16, percent = 0},
      {type = "laser", decrease = 16, percent = 0}},
	
	-- Healthy (Physical)
	Small_Spitter = {
	  {type = "fire", decrease = 0, percent = -85},
      {type = "physical", decrease = 1, percent = 5*NE_Enemies.Settings.NE_Difficulty},
      {type = "impact", decrease = 0, percent = 0},
      {type = "explosion", decrease = 0, percent = 0},
      {type = "acid", decrease = 0, percent = 0},
      {type = "poison", decrease = 0, percent = 0},
      {type = "laser", decrease = 0, percent = 0}},
	
	-- Healthy (Physical)
	Medium_Spitter = {
	  {type = "fire", decrease = 0, percent = -75},
      {type = "physical", decrease = 4, percent = 10*NE_Enemies.Settings.NE_Difficulty},
      {type = "impact", decrease = 3, percent = 0},
      {type = "explosion", decrease = 3, percent = 0},
      {type = "acid", decrease = 3, percent = 0},
      {type = "poison", decrease = 3, percent = 0},
      {type = "laser", decrease = 3, percent = 0}},

	-- Healthy (Physical)
	Big_Spitter = {
	  {type = "fire", decrease = 0, percent = -60},
      {type = "physical", decrease = 8, percent = 15*NE_Enemies.Settings.NE_Difficulty},
      {type = "impact", decrease = 6, percent = 0},
      {type = "explosion", decrease = 6, percent = 0},
      {type = "acid", decrease = 6, percent = 0},
      {type = "poison", decrease = 6, percent = 0},
      {type = "laser", decrease = 6, percent = 0}},
	
	-- Healthy (Physical)
	Behemoth_Spitter = {
	  {type = "fire", decrease = 0, percent = -40},
      {type = "physical", decrease = 14, percent = 18*NE_Enemies.Settings.NE_Difficulty},
      {type = "impact", decrease = 10, percent = 0},
      {type = "explosion", decrease = 10, percent = 0},
      {type = "acid", decrease = 10, percent = 0},
      {type = "poison", decrease = 10, percent = 0},
      {type = "laser", decrease = 10, percent = 0}},
	
	---- Worms
	Small_Worm = {
	  {type = "fire", decrease = 0, percent = -90},
	  {type = "ne_fire", decrease = 0, percent = 100},
      {type = "physical", decrease = 0, percent = 5},
      {type = "impact", decrease = 0, percent = 0},
      {type = "explosion", decrease = 5, percent = 0},
      {type = "acid", decrease = 1, percent = 0},
      {type = "poison", decrease = 0, percent = 0},
      {type = "laser", decrease = 5, percent = 5}},
	
	Medium_Worm = {
	  {type = "fire", decrease = 0, percent = -80},
	  {type = "ne_fire", decrease = 0, percent = 100},
      {type = "physical", decrease = 10, percent = 10},
      {type = "impact", decrease = 0, percent = 0},
      {type = "explosion", decrease = 10, percent = 10},
      {type = "acid", decrease = 5, percent = 0},
      {type = "poison", decrease = 0, percent = 0},
      {type = "laser", decrease = 10, percent = 10}},

	
	Big_Worm = {
	  {type = "fire", decrease = 0, percent = -70},
	  {type = "ne_fire", decrease = 0, percent = 100},
      {type = "physical", decrease = 15, percent = 15},
      {type = "impact", decrease = 0, percent = 0},
      {type = "explosion", decrease = 15, percent = 15},
      {type = "acid", decrease = 10, percent = 0},
      {type = "poison", decrease = 0, percent = 0},
      {type = "laser", decrease = 15, percent = 15}},

	Behemoth_Worm = {
	  {type = "fire", decrease = 0, percent = -60},
	  {type = "ne_fire", decrease = 0, percent = 100},
      {type = "physical", decrease = 15, percent = 30},
      {type = "impact", decrease = 0, percent = 0},
      {type = "explosion", decrease = 15, percent = 30},
      {type = "acid", decrease = 0, percent = 100},
      {type = "poison", decrease = 5, percent = 25},
      {type = "laser", decrease = 15, percent = 15}},	  
	  
	  
	  --- Spawner
	
	Spawner = {
	  {type = "fire", decrease = 0, percent = -75},
      {type = "physical", decrease = 5, percent = 10*NE_Enemies.Settings.NE_Difficulty},
      {type = "impact", decrease = 15, percent = 15*NE_Enemies.Settings.NE_Difficulty},
      {type = "explosion", decrease = 15, percent = 15*NE_Enemies.Settings.NE_Difficulty},
      {type = "acid", decrease = 15, percent = 12*NE_Enemies.Settings.NE_Difficulty},
      {type = "poison", decrease = 0, percent = 12*NE_Enemies.Settings.NE_Difficulty},
      {type = "laser", decrease = 10, percent = 12*NE_Enemies.Settings.NE_Difficulty}},
	Fire = {
      {type = "fire", decrease = 0, percent = 75}},
}