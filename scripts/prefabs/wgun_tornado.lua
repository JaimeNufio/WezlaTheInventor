local assets=
{
	Asset("ANIM", "anim/bishop_attack.zip"),
	Asset("SOUND", "sound/chess.fsb"),
	Asset("ANIM", "anim/tornado.zip"),
	Asset("ANIM", "anim/tornado_stick.zip"),
	Asset("ANIM", "anim/swap_tornado_stick.zip"),
}

local function OnHit(inst, owner, target)
    inst:Remove()
    inst.SoundEmitter:PlaySound("dontstarve/creatures/bishop/shotexplo")
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	inst.Transform:SetFourFaced()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
    
	anim:SetBank("tornado")
	anim:SetBuild("tornado")
	anim:PlayAnimation("tornado_pre")
	anim:PushAnimation("tornado_loop")
    sound:PlaySound("dontstarve_DLC001/common/tornado", "spinLoop")

    inst:AddTag("projectile")
    inst.persists = false
    
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(30)
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetHitDist(2)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnMissFn(OnHit)
	
	local light = inst.entity:AddLight()
    inst.Light:Enable(false)
    inst.Light:SetRadius(2)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.8)
    inst.Light:SetColour(235/255,121/255,12/255)	
    
	local s = .45
	inst.Transform:SetScale(s,s,s)
		
    return inst
end

return Prefab("wgun_tornado", fn, assets) 