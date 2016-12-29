local assets =
{
	Asset("ANIM", "anim/patches.zip"),
}

local function onsewn(inst, target, doer)
	if doer.SoundEmitter then
		doer.SoundEmitter:PlaySound("dontstarve/HUD/repair_clothing")
	end
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("patches")
    inst.AnimState:SetBuild("patches")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("tradable")
	inst:AddTag("patch")
    inst.components.tradable.goldvalue = 1
	
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "patches"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/patches.xml"
    
	inst:AddComponent("sewing")
    inst.components.sewing.repair_value = TUNING.SEWINGKIT_REPAIR_VALUE
    inst.components.sewing.onsewn = onsewn
    
    return inst
end

return Prefab( "common/inventory/patches", fn, assets) 