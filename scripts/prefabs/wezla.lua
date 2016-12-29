
local MakePlayerCharacter = require "prefabs/player_common"

local assets = {

        Asset( "ANIM", "anim/player_basic.zip" ),
        Asset( "ANIM", "anim/player_idles_shiver.zip" ),
        Asset( "ANIM", "anim/player_actions.zip" ),
        Asset( "ANIM", "anim/player_actions_axe.zip" ),
        Asset( "ANIM", "anim/player_actions_pickaxe.zip" ),
        Asset( "ANIM", "anim/player_actions_shovel.zip" ),
        Asset( "ANIM", "anim/player_actions_blowdart.zip" ),
        Asset( "ANIM", "anim/player_actions_eat.zip" ),
        Asset( "ANIM", "anim/player_actions_item.zip" ),
        Asset( "ANIM", "anim/player_actions_uniqueitem.zip" ),
        Asset( "ANIM", "anim/player_actions_bugnet.zip" ),
        Asset( "ANIM", "anim/player_actions_fishing.zip" ),
        Asset( "ANIM", "anim/player_actions_boomerang.zip" ),
        Asset( "ANIM", "anim/player_bush_hat.zip" ),
        Asset( "ANIM", "anim/player_attacks.zip" ),
        Asset( "ANIM", "anim/player_idles.zip" ),
        Asset( "ANIM", "anim/player_rebirth.zip" ),
        Asset( "ANIM", "anim/player_jump.zip" ),
        Asset( "ANIM", "anim/player_amulet_resurrect.zip" ),
        Asset( "ANIM", "anim/player_teleport.zip" ),
        Asset( "ANIM", "anim/wilson_fx.zip" ),
        Asset( "ANIM", "anim/player_one_man_band.zip" ),
        Asset( "ANIM", "anim/shadow_hands.zip" ),
        Asset( "SOUND", "sound/sfx.fsb" ),
        Asset( "SOUND", "sound/wilson.fsb" ),
        Asset( "ANIM", "anim/beard.zip" ),
		Asset("ANIM", "anim/player_wolfgang.zip"),
        Asset( "ANIM", "anim/wezla.zip" ),
}
local prefabs = {}
local start_inv = {"steamgoggles",--[["bibbitdoll",]]"goatmilk","goatmilk",
"goatmilk","bibbitremote"
--,"gears","gears"
}
local trinkets = {"trinket_9","trinket_14","transistor","gears"}

local stage = false
local song = "jocelismusic/music/music_hoedown"

local function healowner(inst)
	inst.charge_time = inst.charge_time - 1
	local rad = 3
    rad = ((1/5) * math.sin(inst.charge_time)+2)/2 --math.max(.1, rad * (inst.charge_time / 60))
    inst.Light:Enable(true)
    inst.Light:SetRadius(rad)
	if (inst.components.health and inst.components.health:IsHurt())
    and (inst.components.hunger and inst.components.hunger.current > 5 )then
        inst.components.health:DoDelta(40/60,false,"redamulet")
    end
end

local function flashlight(inst)
	local estado = inst.state
	stage = true
	inst:DoPeriodicTask(2, function() 
	if stage then
	
		--inst.Light:Enable(true) 
	
		local pos = Vector3(inst.Transform:GetWorldPosition())
		pos.y = pos.y + 1 + math.random()*1.5
		local spark = SpawnPrefab("sparks")
		spark.Transform:SetPosition(pos:Get())
		
		
		if estado then
			--inst.Light:Enable(false) 	
		end
			stage = false		
	end
	end)	
end


local function OnAttacked(inst, data)
    --inst.components.combat:SetTarget(data.attacker)
	if inst.state then
        if data.attacker.components.health then
            if (data.weapon == nil or (not data.weapon:HasTag("projectile") and data.weapon.projectile == nil)) 
            and (data.attacker ~= GetPlayer() or (data.attacker == GetPlayer() and not GetPlayer().components.inventory:IsInsulated())) then
				
				local impactfx = SpawnPrefab("impact")
				impactfx.Transform:SetScale(3,3,3)
				local spark = SpawnPrefab("sparks")
				spark.Transform:SetScale(3,3,3)
				local pos = Vector3(inst.Transform:GetWorldPosition())

				if impactfx then
					local follower = impactfx.entity:AddFollower()
					follower:FollowSymbol(data.attacker.GUID, data.attacker.components.combat.hiteffectsymbol, 0, 0, 0 )
					impactfx:FacePoint(data.attacker.Transform:GetWorldPosition())
					spark.Transform:SetPosition(pos:Get())
				end
				
				data.attacker.components.health:DoDelta(-TUNING.LIGHTNING_GOAT_DAMAGE*1.5)

				if data.attacker == GetPlayer() then
                    data.attacker.sg:GoToState("electrocute")
					local pos = Vector3(data.attacker.Transform:GetWorldPosition())
                end
            end
        end
    end
end

local function boost(super,inst)

	print("food boost on")
	inst.Light:Enable(true)	
	if  super then
		print("VoltShake")
		inst.sg:GoToState("electrocute")
		inst.components.dynamicmusic:Disable()
		inst.SoundEmitter:PlaySound(song, "jocelismusic")	
	
		inst.components.locomotor.walkspeed = (TUNING.WILSON_WALK_SPEED * 1.85)
		inst.components.locomotor.runspeed = (TUNING.WILSON_RUN_SPEED * 1.85)
		inst.components.combat.damagemultiplier = 1.75
		inst.components.combat.min_attack_period = .35/1.75
		inst.components.talker:Say("THE ENERGY IS COURSING TRHOUGH ME!")
		
		inst.Light:SetRadius(2)
		inst.Light:SetFalloff(0.70)
		inst.Light:SetIntensity(.9)
		inst.Light:SetColour(235/255,121/255,12/255)
	    inst.task = inst:DoPeriodicTask(1.5, function() healowner(inst) end)
		
	else
		print("GoatMilk")
		inst.sg:GoToState("powerup")
		inst.components.dynamicmusic:Disable()
		inst.SoundEmitter:PlaySound(song, "jocelismusic")	
		
		inst.components.locomotor.walkspeed = (TUNING.WILSON_WALK_SPEED * 1.5)
		inst.components.locomotor.runspeed = (TUNING.WILSON_RUN_SPEED * 1.5)
		inst.components.combat.damagemultiplier = 1.75
		inst.components.combat.min_attack_period = .075
		
		inst.components.talker:Say("I CAN TAKE ON THE WORLD!")
		inst.charge_time = 0
	end
	
	
	
	inst:DoPeriodicTask(60, function()
	
		if inst.state then
			print("food boost off")
		
			inst.sg:GoToState("powerdown")
			inst.components.talker:Say("All good things must end, I suppose.")
		
			inst.components.locomotor.walkspeed = (TUNING.WILSON_WALK_SPEED * 1.25)
			inst.components.locomotor.runspeed = (TUNING.WILSON_RUN_SPEED * 1.25)
			inst.components.combat.damagemultiplier = .80
			inst.components.combat.min_attack_period = .35
		
			inst.Light:Enable(false)	
			inst.components.dynamicmusic:Enable()
			inst.SoundEmitter:KillSound("jocelismusic")
			
			local light = inst.Light
			
			light:SetRadius(1)
			inst.Light:SetFalloff(0.75)
			inst.Light:SetIntensity(.9)
			light:SetColour(0/255, 38/255, 255/255)			

			inst.state = false
		
			if inst.task then inst.task:Cancel() inst.task = nil end
			
		end
	end)

end
	
local function oneat(inst, food)
	print("Eating")
	if not inst.state then
		--inst.Light:Enable(true)
		if food.prefab == "goatmilk" then
			boost(false,inst)
			inst.state = true
			inst.Light:SetColour(255/255, 190/255, 0/255)--Yellow
		elseif food.prefab == "vshake" then 
			boost(true,inst)
			inst.state = true
			inst.charge_time = 60--inst.charge_time + TUNING.TOTAL_DAY_TIME*(.5 + .5*math.random())
			inst.Light:SetColour(5/255, 100/255, 240/255)--Blue	
			--test
			--local s = 3
			--inst.Transform:SetScale(s,s,s)
		end
			
	elseif inst.state then
		if food.prefab == "goatmilk" or food.prefab == "vshake" then
			inst.components.health:DoDelta(25)
			inst.components.talker:Say("I was already full of energy.")
		end
	end
end


local magic = {
    "bell","gemsocket","telestaff","icestaff","firestaff","purpleamulet","blueamulet",
	"amulet","armorslurper","batbelt","armor_sanity","nightsword","nightlight","onemanband",
	"panflute","researchlab3_placer","researchlab4_placer","resurrectionstatue", --Magic 
}
	
local ancient = {
	"thulecite","wall_ruins_item","nightmare_timepiece","orangeamulet","yellowamulet","greenamulet",
	"orangestaff","yellowstaff","greenstaff","multitool_axe_pickaxe","ruinshat","ruins_bat","armorruins",
	"eyeturret_placer","eyeturret_item",--Anciet
}
	
local etc = {
	"nightmarefuel","diviningrod", --Etc
}
	
local plus_science = {
	"gunpowder","lightning_rod_placer","wboom","steamgoggles","wteddy","wezlamachine","wezlamachine_place",
	"vshake","wcannon","wcannon_placer","wgun","patches"
	}
	
local super_science = {
	"rainometer_placer","researchlab_placer","firesuppressor_placer","researchlab2_placer","iron","bibbitdoll"
}
	
local function crafted(inst, data)
	local y = 2.25
    local item = data.item
    if table.contains( magic, item.prefab ) then --Magic was crafted
		local x = -15*y
		inst.components.sanity.current = inst.components.sanity.current+x
		--inst.sg:PushEvent("hit")
		inst.components.talker:Say("This isn't science at all!")
	elseif table.contains( etc, item.prefab ) then --etc
		local x = -20*y
		--inst.sg:PushEvent("damaged")
		inst.components.sanity.current = inst.components.sanity.current+x
		inst.components.talker:Say("This... this is bizare.")
	elseif table.contains( ancient, item.prefab ) then --anciet
		local x = -35*y
		--inst.sg:PushEvent("damaged")
		inst.components.sanity.current = inst.components.sanity.current+x
		inst.components.talker:Say("THIS SHOULDN'T MAKE SENSE!")
	elseif table.contains( plus_science, item.prefab ) then --plus science
		flashlight(inst)
		local x = 25
		if inst.components.sanity.current + x <= 300 then
		inst.components.sanity.current = inst.components.sanity.current+x
			else
			inst.components.sanity.current = 300
		end
		inst.components.talker:Say("NOW THIS IS SCIENCE!")
	elseif table.contains( super_science, item.prefab ) then --super science
		flashlight(inst)
		local x = 75
		if inst.components.sanity.current + x <= 300 then
			inst.components.sanity.current = inst.components.sanity.current+x
			else
			inst.components.sanity.current = 300
		end
		--inst.components.talker:Say("Look at all the new possibilites!")
	else
		flashlight(inst)
		local x = 5
		if inst.components.sanity.current + x <= 300 then
			inst.components.sanity.current = inst.components.sanity.current+x
			else
			inst.components.sanity.current = 300
		end
	--inst.components.inventory:DropItem(item)--Wezla will drop the item
end
end
	
	
local fn = function(inst)

	inst.state = false
	inst.charge_time = 0
	-- choose which sounds this character will play
	inst.soundsname = "wezla"

	-- Minimap icon
	inst.MiniMapEntity:SetIcon( "wezla.tex" )
	
	-- Stats	
	inst.components.health:SetMaxHealth(150)
	inst.components.hunger:SetMax(150)
	inst.components.sanity:SetMax(300)
	inst.components.locomotor.walkspeed = (TUNING.WILSON_WALK_SPEED*1.25)
	inst.components.locomotor.runspeed = (TUNING.WILSON_RUN_SPEED*1.25)
	inst.components.combat.damagemultiplier = .80
	inst.components.combat.min_attack_period = .35
	
	inst.components.eater:SetOnEatFn(oneat)
	
	inst:AddComponent("dapperness")
	inst.components.sanity.dapperness = (-TUNING.DAPPERNESS_MED*2)
	 
	inst:AddComponent("insulator")
    inst.components.insulator.insulation = TUNING.INSULATION_MED

	local light = inst.entity:AddLight()
	
	light:SetRadius(1)
    inst.Light:SetFalloff(0.75)
    inst.Light:SetIntensity(.9)
	light:SetColour(0/255, 38/255, 255/255)
	light:Enable(false)
	
	inst:ListenForEvent("builditem",crafted)
	inst:ListenForEvent("buildstructure",crafted)
    inst:ListenForEvent("attacked", OnAttacked)
	
end

return MakePlayerCharacter("wezla", prefabs, assets, fn, start_inv)
