local assets=
{ 
    Asset("ANIM", "anim/wgun.zip"),
    Asset("ANIM", "anim/swap_wgun.zip"), 

    Asset("ATLAS", "images/inventoryimages/wgun.xml"),
    Asset("IMAGE", "images/inventoryimages/wgun.tex"),
}

local prefabs =
{
    "fire_projectile",
	"ice_projectile",
	"stafflight",
	"wgun_charge",
	"bishop_charge",
	"explode_small",}

local function FindAllMobsInRange(center, target)
	local radius = 5
    local grass_insts = {}
    for _, inst in ipairs( TheSim:FindEntities(center.x, center.y, center.z, radius) ) do
        if target:HasTag("burnable") then

        end
    end

end


local function weatherstate(inst,attacker, target)

	local function getspawnlocation(inst, target)
	local tarPos = target:GetPosition()
	local pos = inst:GetPosition()
	local vec = tarPos - pos
	vec = vec:Normalize()
	local dist = pos:Dist(tarPos)
	return pos + (vec * (dist * .15))
	end

	local function cantornado(staff, caster, target, pos)
    return target and (
        (target.components.health and target.components.combat and caster.components.combat:CanTarget(target)) 
        or target.components.workable
        )
	end

	local timeofday = GetClock():GetPhase() 
	--day, dusk, night
	local moonphase = GetClock():GetMoonPhase() 
	-- "new","quarter","half","threequarter","full"
	local isRain = GetSeasonManager():IsRaining()
	-- true false
	--GetSeasonManager().preciptype == "rain"
	local season = GetSeasonManager():GetSeasonString()
	--winter,summer,fall,spring
	--GetSeasonManager().preciptype == "snow"
	
	local temp = GetSeasonManager() and GetSeasonManager():GetCurrentTemperature() or 30
	local high_temp = 35
	local low_temp = 0
	
	local temp = math.min( math.max(low_temp, temp), high_temp)
	local percent = (temp + low_temp) / (high_temp - low_temp)
	-- 1 is maximum, summer
	--inst.components.weapon:SetProjectile("wgun_charge")
	local modifier = 1
	if target and not inst.fuck then
		local pt = Vector3(target.Transform:GetWorldPosition())
	
	if not inst.components.fueled:IsEmpty() then
		if isRain then
			modifier = modifier*1.75
			inst.components.weapon:SetProjectile("bishop_charge")
				target.components.health:DoDelta(-modifier*60)
				local explode = SpawnPrefab("explode_small")
				explode.Transform:SetPosition(pt.x, pt.y, pt.z)
				local sparks = SpawnPrefab("sparks")
				sparks.Transform:SetPosition(pt.x, pt.y, pt.z)
			if not target:HasTag("epic") and not target:HasTag("Player") then
			if isRain and target.components.health:GetPercent() <= 20 and target then
				if math.random(0,100) <= 90 then
					GetSeasonManager():DoLightningStrike(pt)
					local fx = SpawnPrefab("ash")
					fx.Transform:SetPosition(pt.x, pt.y, pt.z)
					target:Remove()
				end
			end
		end
	elseif (timeofday == "night") and (moonphase == "full" or moonphase == "new") then
		inst.components.weapon:SetProjectile("eye_charge")
		target.components.health:DoDelta(-modifier*60)
		if not target:HasTag("Player") and not target:HasTag("epic") then
			attacker.components.sanity:DoDelta(-20)
			SpawnPrefab("statue_transition").Transform:SetPosition(pt:Get())
			SpawnPrefab("statue_transition_2").Transform:SetPosition(pt:Get())
			target:Remove()
		end
	elseif season == "winter" then
	--Winter
		modifier = (1.25-percent)*2
		target.components.health:DoDelta(-modifier*60)
		inst.components.weapon:SetProjectile("ice_projectile")

		if target.components.freezable then
			target.components.freezable:AddColdness(25)
			target.components.freezable:SpawnShatterFX()
		end
		if target.components.sleeper and target.components.sleeper:IsAsleep() then
			target.components.sleeper:WakeUp()
		end
		if target.components.burnable and target.components.burnable:IsBurning() then
			target.components.burnable:Extinguish()
		end
		if target.components.combat then
			target.components.combat:SuggestTarget(attacker)
			if target.sg and not target.sg:HasStateTag("frozen") and target.sg.sg.states.hit then
				target.sg:GoToState("hit")
			end
		end
	elseif season == "summer" then
	--Summer
		modifier = percent*2

		local function OnIgniteFn(inst)
			inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_fuse_LP", "hiss")
		end
		if target.components.burnable and not target.components.burnable:IsBurning() then
			if target.components.freezable and target.components.freezable:IsFrozen() then           
				target.components.freezable:Unfreeze()            
			else            
				target.components.burnable:Ignite(true)
			end   
		end
		if target.components.freezable then
			target.components.freezable:AddColdness(-1) --Does this break ice staff?
			if target.components.freezable:IsFrozen() then
				target.components.freezable:Unfreeze()            
			end
		end
		if target.components.sleeper and target.components.sleeper:IsAsleep() then
			target.components.sleeper:WakeUp()
		end
		if target.components.combat then
			target.components.combat:SuggestTarget(attacker)
			if target.sg and target.sg.sg.states.hit then
				target.sg:GoToState("hit")
			end
		end
		attacker.SoundEmitter:PlaySound("dontstarve/wilson/fireball_explo")
	elseif season == "spring" then
	--Spring
	
		local function getrandomposition(inst)
			local ground = GetWorld()
			local centers = {}
			for i,node in ipairs(ground.topology.nodes) do
				local tile = GetWorld().Map:GetTileAtPoint(node.x, 0, node.y)
				if tile and tile ~= GROUND.IMPASSABLE then
					table.insert(centers, {x = node.x, z = node.y})
				end
			end
			if #centers > 0 then
				local pos = centers[math.random(#centers)]
				return Point(pos.x, 0, pos.z)
			else
				return GetPlayer():GetPosition()
			end
		end
		local t_loc = getrandomposition(inst)
	
		inst.components.weapon:SetProjectile("wgun_charge")
		modifier = 1.25+math.abs(.5-percent)
		SpawnPrefab("collapse_small").Transform:SetPosition(pt:Get())
	
		local blerp = target
        blerp.Transform:SetPosition(t_loc.x, 0, t_loc.z)--(pt + result_offset):Get())

	elseif season == "autumn" then
		--Falll
		print("its fall")
		inst.components.weapon:SetProjectile("wgun_tornado")
		modifier = 1.25+math.abs(.5-percent)
		target.components.health:DoDelta(-modifier*40)
		
		local staff = inst
		local pos = pt:Get()
		
		local tornado = SpawnPrefab("tornado")
		tornado.WINDSTAFF_CASTER = staff.components.inventoryitem.owner
		local spawnPos = staff:GetPosition() + TheCamera:GetDownVec()
		local totalRadius = target.Physics and target.Physics:GetRadius() or 0.5 + tornado.Physics:GetRadius() + 0.5
		local targetPos = target:GetPosition() + (TheCamera:GetDownVec() * totalRadius)
		tornado.Transform:SetPosition(getspawnlocation(staff, target):Get())
		tornado.components.knownlocations:RememberLocation("target", targetPos)

	end
	if not season == "autumn" then
		inst.components.fueled:DoDelta(-1) --use a "bullet"
	else
		inst.components.fueled:DoDelta(-3)
	end
	else
		if inst.components.weapon then
			inst.components.weapon:SetProjectile("")
			target.components.health:DoDelta(0)
			attacker.components.talker:Say("I'm out of ammo!")
		end
	end
end
end


local function onfinished(inst)
	inst.SoundEmitter:PlaySound("dontstarve/common/gem_shatter")
	 if inst.components.weapon then
       -- inst:RemoveComponent("weapon")
		inst.components.fueled.accepting = true
		inst.fuck = true
	end
    --inst:Remove()
end

local function takefuel(inst)
	inst.fuck = false
	if not inst.components.weapon then
	print("addweapon")
    inst:AddComponent("weapon")
	end
    inst.components.weapon:SetDamage(inst.damagecurrent)
    inst.components.weapon:SetRange(10, 20)
    inst.components.weapon:SetOnAttack(weatherstate)
	inst.components.weapon:SetProjectile("wgun_tornado")
	inst.components.fueled:DoDelta(15)

end

local function updateshit(inst)
		local timeofday = GetClock():GetPhase() 
		local moonphase = GetClock():GetMoonPhase() 
		local isRain = GetSeasonManager():IsRaining()
		local season = GetSeasonManager():GetSeasonString()
		
		if isRain then
			inst.components.weapon:SetProjectile("bishop_charge")
		elseif (timeofday == "night") and (moonphase == "full" or moonphase == "new") then
			inst.components.weapon:SetProjectile("eye_charge")
		elseif season == "winter" then
			inst.components.weapon:SetProjectile("ice_projectile")
		elseif season == "summer" then
			inst.components.weapon:SetProjectile("fire_projectile")
		elseif season == "spring" then
			inst.components.weapon:SetProjectile("wgun_charge")
		elseif season == "autumn" then
			inst.components.weapon:SetProjectile("wgun_tornado")
	end
end


local function fn()

	local function OnEquip(inst, owner)
		owner.AnimState:OverrideSymbol("swap_object", "swap_wgun", "swap_wgun")
		owner.AnimState:Show("ARM_carry") 
		owner.AnimState:Hide("ARM_normal") 		
    end

    local function OnUnequip(inst, owner) 
        owner.AnimState:Hide("ARM_carry") 
        owner.AnimState:Show("ARM_normal") 
    end

	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
	
	inst.fuck = false
	inst:AddTag("nopunch")
	
    anim:SetBank("wgun")
    anim:SetBuild("wgun")
	
    anim:PlayAnimation("idle")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "wgun"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/wgun.xml"
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( OnEquip )
    inst.components.equippable:SetOnUnequip( OnUnequip )
	
	--[[
	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetOnFinished(onfinished)
	inst.components.finiteuses:SetMaxUses(50)
    inst.components.finiteuses:SetUses(50)
	]]
	
	
	inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "WEZLA"
    inst.components.fueled:InitializeFuelLevel(100)
    inst.components.fueled.maxfuel = 100
    inst.components.fueled:SetDepletedFn(onfinished(inst))
    inst.components.fueled.ontakefuelfn = takefuel(inst)
    inst.components.fueled.accepting = true
	
	inst.damagecurrent = 30
	
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(inst.damagecurrent)
    inst.components.weapon:SetRange(10, 20)
    inst.components.weapon:SetOnAttack(weatherstate)
	inst.components.weapon:SetProjectile("")
	
	updateshit(inst)
	
	inst:AddComponent("inspectable")
    inst:AddComponent("tradable")

	inst:ListenForEvent("clocktick",updateshit(inst))
	
    return inst
end

return  Prefab("common/inventory/wgun", fn, assets, prefabs)