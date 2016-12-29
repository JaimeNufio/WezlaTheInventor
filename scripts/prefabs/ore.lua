local assets =
{
	Asset("ANIM", "anim/ore.zip"),	
	Asset("IMAGE", "images/inventoryimages/ore.tex"),	
	Asset("ATLAS", "images/inventoryimages/ore.xml"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("ore")
    inst.AnimState:SetBuild("ore")
    inst.AnimState:PlayAnimation("idle")
	
	local s = 1.5
	inst.Transform:SetScale(s,s,s)
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "ore"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/ore.xml"
	inst.entity:AddMiniMapEntity()	
	inst.MiniMapEntity:SetIcon( "ore.tex" )		    
	
    return inst
end
return Prefab("common/inventory/ore", fn, assets)  
