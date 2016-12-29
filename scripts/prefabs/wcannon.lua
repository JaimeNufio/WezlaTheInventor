require "prefabutil"
require "brains/eyeturretbrain"
require "stategraphs/SGeyeturret"

local assets=
{
	Asset("ANIM", "anim/wcannon.zip"),
	Asset("ANIM", "anim/eyeball_turret.zip"),
    Asset("ANIM", "anim/eyeball_turret_object.zip"),

}

local prefabs = 
{
    "eye_charge",
   -- "eyeturret_base",
}

local function retargetfn(inst)
    local newtarget = FindEntity(inst, 20, function(guy)
            return  guy.components.combat and 
                    inst.components.combat:CanTarget(guy) and
                    (guy.components.combat.target == GetPlayer() or GetPlayer().components.combat.target == guy)
    end)

    return newtarget
end


local function shouldKeepTarget(inst, target)
    if target and target:IsValid() and
        (target.components.health and not target.components.health:IsDead()) then
        local distsq = target:GetDistanceSqToInst(inst)
        return distsq < 20*20
    else
        return false
    end
end

local function OnAttacked(inst, data)
    local attacker = data and data.attacker
    if attacker == GetPlayer() then
        return
    end
    inst.components.combat:SetTarget(attacker)
    inst.components.combat:ShareTarget(attacker, 15, function(dude) return dude:HasTag("eyeturret") end, 10)
end

local function WeaponDropped(inst)
    inst:Remove()
end

local function EquipWeapon(inst)
    if inst.components.inventory and not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
        local weapon = CreateEntity()
        weapon.entity:AddTransform()
        weapon:AddComponent("weapon")
        weapon.components.weapon:SetDamage(100)--inst.components.combat.defaultdamage)
        weapon.components.weapon:SetRange(inst.components.combat.attackrange, inst.components.combat.attackrange+4)
        weapon.components.weapon:SetProjectile("wcannon_projectile")--("eye_charge")
        weapon:AddComponent("inventoryitem")
        weapon.persists = false
        weapon.components.inventoryitem:SetOnDroppedFn(WeaponDropped)
        weapon:AddComponent("equippable")
        
        inst.components.inventory:Equip(weapon)
    end
end

local function TurnOff(inst, instant)
	inst.on = false
--	inst.components.fueled:StopConsuming()
	if instant then
		--inst.sg:GoToState("idle_off")--
	else
		--inst.sg:GoToState("turn_off")--
	end
end

local function TurnOn(inst, instant)
	inst.on = true
	--inst.components.fueled:StartConsuming()
	if instant then
		--inst.sg:GoToState("idle_on")--
	else
		--inst.sg:GoToState("turn_on")--
	end
end

local function dotweenin(inst, l)
    inst.components.lighttweener:StartTween(nil, 0, .65, .7, nil, 0.15, 
        function(i, light) if light then light:Enable(false) end end)
end

local function syncanim(inst, animname, loop)
    inst.AnimState:PlayAnimation(animname, loop)
  --  inst.base.AnimState:PlayAnimation(animname, loop)
end

local function syncanimpush(inst, animname, loop)
    inst.AnimState:PushAnimation(animname, loop)
   -- inst.base.AnimState:PushAnimation(animname, loop)
end

local function OnFuelEmpty(inst)
	inst.components.machine:TurnOff()
end

local function getstatus(inst, viewer)
	if inst.on then
		if inst.components.fueled and (inst.components.fueled.currentfuel / inst.components.fueled.maxfuel) <= .25 then
			return "LOWFUEL"
		else
			return "ON"--..inst.components.fueled.currentfuel.." SHOTS LEFT"
		end
	else
		return "OFF"--..inst.components.fueled.currentfuel.." SHOTS LEFT"
	end
end

local function CanInteract(inst)
	return not inst.components.fueled:IsEmpty()
end

local function takefuel(inst)
	inst.components.health:DoDelta(TUNING.EYETURRET_HEALTH*25)
	print("healed "..(TUNING.EYETURRET_HEALTH*25))
	inst.components.fueled:MakeEmpty()
end

local function OnGetItemFromPlayer(inst, giver, item)
	print("recognized")
	if item:HasTag("iron") then
	print("accepting")
	inst.components.health:DoDelta(TUNING.EYETURRET_HEALTH*.25)
	print("healed "..(TUNING.EYETURRET_HEALTH*.25))
	--inst.components.fueled:MakeEmpty()
    end
end
	
local function OnRefuseItem()
	print("not accepting")
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
 	inst.entity:AddSoundEmitter()
    inst.Transform:SetFourFaced()

    MakeObstaclePhysics(inst, 1.2)
        
    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("wcannon.tex")

    --inst.base = SpawnPrefab("eyeturret_base")
  --  inst.base.entity:SetParent( inst.entity )

    inst:AddTag("eyeturret")
    inst:AddTag("companion")
	inst.on = true

	inst:AddComponent("inspectable")
	--inst.components.inspectable.getstatus = getstatus
--[[
	inst:AddComponent("machine")
	inst.components.machine.turnonfn = TurnOn
	inst.components.machine.turnofffn = TurnOff
	inst.components.machine.caninteractfn = CanInteract
	inst.components.machine.cooldowntime = 0.5


	inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "IRONREPAIR"
    inst.components.fueled:InitializeFuelLevel(0)
    inst.components.fueled.maxfuel = 100
    inst.components.fueled:SetDepletedFn(OnFuelEmpty)
    inst.components.fueled.ontakefuelfn = takefuel(inst)
    inst.components.fueled.accepting = true
	]]
	
   -- inst.syncanim = function(name, loop) syncanim(inst, name, loop) end
   -- inst.syncanimpush = function(name, loop) syncanimpush(inst, name, loop) end

    inst.AnimState:SetBank("wcannon")
    inst.AnimState:SetBuild("wcannon")
    inst.AnimState:PlayAnimation("idle")
    --inst.syncanim("idle_loop")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.EYETURRET_HEALTH) 
    inst.components.health:StartRegen(TUNING.EYETURRET_REGEN, 5)
    
	inst:AddComponent("combat")
    inst.components.combat:SetRange(TUNING.EYETURRET_RANGE)
    inst.components.combat:SetDefaultDamage(100)--200
    inst.components.combat:SetAttackPeriod(15)--15--TUNING.EYETURRET_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(1, retargetfn)
    inst.components.combat:SetKeepTargetFunction(shouldKeepTarget)

    inst:AddComponent("lighttweener")
    local light = inst.entity:AddLight()
    inst.components.lighttweener:StartTween(light, 0, .65, .7, {251/255, 234/255, 234/255}, 0, 
        function(inst, light) if light then light:Enable(false) end end)

    inst.dotweenin = dotweenin

	inst:AddComponent("trader")	
	
	inst.components.trader:SetAcceptTest(
		function(inst, item)
			return item.components.tradable.goldvalue > 0
		end)
	
    inst.components.trader.onrefuse = OnRefuseItem	
    inst.components.trader.onaccept = OnGetItemFromPlayer

    MakeLargeFreezableCharacter(inst)
    
    inst:AddComponent("inventory")
    inst:DoTaskInTime(1, EquipWeapon)

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_TINY    
    
    inst:AddComponent("lootdropper")
    
    inst:ListenForEvent("attacked", OnAttacked)

    inst:SetStateGraph("SGwcannon")
    local brain = require "brains/wcannonbrain"
    inst:SetBrain(brain)

	local s = -1.2
	inst.Transform:SetScale(s,s,s)
	
    return inst
end


return Prefab( "common/wcannon", fn, assets, prefabs),
--Prefab("common/eyeturret_item", itemfn, assets, prefabs),
MakePlacer("common/wcannon_placer", "wcannon", "wcannon", "idle")--,
--Prefab( "common/wcannon_base", basefn, baseassets)