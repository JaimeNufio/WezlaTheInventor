local assets =
{
	Asset("ANIM", "anim/iron.zip"),
	Asset("IMAGE", "images/inventoryimages/iron.tex"),	
	Asset("ATLAS", "images/inventoryimages/iron.xml"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("iron")
    inst.AnimState:SetBuild("iron")
    inst.AnimState:PlayAnimation("idle")
	
	local s = 1.5
	inst.Transform:SetScale(s,s,s)
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("tradable")
	inst:AddTag("iron")
    inst.components.tradable.goldvalue = 1
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "iron"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/iron.xml"
	inst.entity:AddMiniMapEntity()	
	inst.MiniMapEntity:SetIcon( "iron.tex" )		    
	
    return inst
end


return Prefab( "common/inventory/iron", fn, assets)
