local assets=
{
	Asset("ANIM", "anim/bishop_attack.zip"),
	Asset("SOUND", "sound/chess.fsb"),
}

local function OnHit(inst, owner, target)
    inst:Remove()
    inst.SoundEmitter:PlaySound("dontstarve/creatures/bishop/shotexplo")
end

local names = {"f1","f2","f3","f4","f5","f6","f7","f8","f9","f10"}

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	inst.Transform:SetFourFaced()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
	
	anim:SetBank("star")
    anim:SetBuild("star")
    anim:PlayAnimation("idle_loop")--appear
    --anim:PushAnimation("idle_loop", true)
	
	--[[
	anim:SetBank("flowers")
    inst.animname = names[math.random(#names)]
    anim:SetBuild("flowers")
    anim:PlayAnimation(inst.animname)
	]]--
    --[[
    anim:SetBank("bishop_attack")
    anim:SetBuild("bishop_attack")
    anim:PlayAnimation("idle")
    ]]
	
    inst:AddTag("projectile")
    inst.persists = false
	
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(20)
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetHitDist(2)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnMissFn(OnHit)
	
	local light = inst.entity:AddLight()
    inst.Light:Enable(false)
    inst.Light:SetRadius(4)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.8)
    inst.Light:SetColour(235/255,121/255,12/255)	
    
	local s = 1
	inst.Transform:SetScale(s,s,s)
		
    return inst
end

return Prefab( "common/inventory/wgun_charge", fn, assets) 
