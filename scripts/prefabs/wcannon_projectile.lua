local assets = 
{
	Asset("ANIM", "anim/wcannon.zip"),
	Asset("ANIM", "anim/wcannon_projectile.zip"),
}

local projectile_assets = 
{
	Asset("ANIM", "anim/wcannon_projectile.zip"),
	Asset("SOUND", "sound/chess.fsb"),
}

local prefabs = 
{
	"collapse_small",
}

local function OnHit(inst, owner, target)
    inst:Remove()
    inst.SoundEmitter:PlaySound("dontstarve/creatures/bishop/shotexplo")
end

local function projectile_fn()


	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	inst.Transform:SetFourFaced()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
    
    anim:SetBank("wcannon_projectile")
    anim:SetBuild("wcannon_projectile")
    anim:PlayAnimation("idle")
    
    inst:AddTag("projectile")
    inst.persists = false

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(10)
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetHitDist(2)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnMissFn(OnHit)
	
	local s = 3
	inst.Transform:SetScale(s,s,s)
    
	return inst
end

return Prefab("wcannon_projectile", projectile_fn, projectile_assets)
