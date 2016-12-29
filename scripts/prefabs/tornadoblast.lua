local assets = 
{
	Asset("ANIM", "anim/tornado.zip"),
	Asset("ANIM", "anim/tornado_stick.zip"),
	Asset("ANIM", "anim/swap_tornado_stick.zip"),
}


local function tornado_fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()

	anim:SetBank("tornado")
	anim:SetBuild("tornado")
	anim:PlayAnimation("tornado_pre")
	anim:PushAnimation("tornado_loop")

    sound:PlaySound("dontstarve_DLC001/common/tornado", "spinLoop")

	inst:DoTaskInTime(TUNING.TORNADO_LIFETIME, function() inst.sg:GoToState("despawn") end)

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

	inst:AddComponent("knownlocations")

	inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.TORNADO_WALK_SPEED * 0.33
    inst.components.locomotor.runspeed = TUNING.TORNADO_WALK_SPEED

    inst:SetStateGraph("SGtornado")
    inst:SetBrain(require "brains/tornadobrain")

    inst.WINDSTAFF_CASTER = nil

	return inst
end

return Prefab("staff_tornado", staff_fn, assets), 
Prefab("tornado", tornado_fn, assets)